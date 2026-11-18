"""Run check_model.py in full, unchanged, as a child process. Output goes to this folder.
Reports wall time and the child's peak working set (Windows)."""
import ctypes
import ctypes.wintypes as wt
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
import os as _os
SCRIPT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", "..", "check_model.py"))


class PMC(ctypes.Structure):
    _fields_ = [("cb", wt.DWORD), ("PageFaultCount", wt.DWORD),
                ("PeakWorkingSetSize", ctypes.c_size_t), ("WorkingSetSize", ctypes.c_size_t),
                ("QuotaPeakPagedPoolUsage", ctypes.c_size_t), ("QuotaPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t), ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
                ("PagefileUsage", ctypes.c_size_t), ("PeakPagefileUsage", ctypes.c_size_t)]


def main():
    extra = sys.argv[1:]
    tag = "traces" if "--traces" in extra else "plain"
    out = os.path.join(HERE, f"full-run-output-{tag}.txt")
    cmd = [sys.executable, "-I", "-B", SCRIPT,
           "--json", os.path.join(HERE, f"full-results-{tag}.json"),
           "--systems", os.path.join(HERE, f"full-systems-{tag}.json")] + extra
    t0 = time.time()
    with open(out, "w", encoding="utf-8") as fh:
        p = subprocess.Popen(cmd, stdout=fh, stderr=subprocess.PIPE, cwd=HERE)
        _, err = p.communicate()
    dt = time.time() - t0
    pmc = PMC()
    pmc.cb = ctypes.sizeof(PMC)
    k32 = ctypes.WinDLL("kernel32", use_last_error=True)
    psapi = ctypes.WinDLL("psapi", use_last_error=True)
    psapi.GetProcessMemoryInfo.argtypes = [wt.HANDLE, ctypes.POINTER(PMC), wt.DWORD]
    ok = psapi.GetProcessMemoryInfo(int(p._handle), ctypes.byref(pmc), pmc.cb)
    with open(os.path.join(HERE, f"full-run-stats-{tag}.txt"), "w") as fh:
        fh.write(f"exit {p.returncode}\nseconds {dt:.1f}\n")
        fh.write(f"peak working set MB {pmc.PeakWorkingSetSize / 2**20:.0f} (ok={ok})\n")
        fh.write(f"peak pagefile MB {pmc.PeakPagefileUsage / 2**20:.0f}\n")
        fh.write("stderr:\n" + err.decode("utf-8", "replace"))
    print(open(os.path.join(HERE, f"full-run-stats-{tag}.txt")).read())


if __name__ == "__main__":
    main()
