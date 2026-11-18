"""Run check_model.py end to end, capture its output, elapsed time and peak memory.
Writes only into this folder."""
import contextlib
import ctypes
import ctypes.wintypes as wt
import os
import runpy
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
sys.argv = ["check_model.py", "--json", os.path.join(HERE, "full-results.json"),
            "--systems", os.path.join(HERE, "full-systems.json")]
t = time.time()
with open(os.path.join(HERE, "full-run-output.txt"), "w", encoding="utf-8") as fh, \
        contextlib.redirect_stdout(fh):
    runpy.run_path(os.path.join(FM, "check_model.py"), run_name="__main__")
elapsed = time.time() - t


class PMC(ctypes.Structure):
    _fields_ = [("cb", wt.DWORD), ("PageFaultCount", wt.DWORD),
                ("PeakWorkingSetSize", ctypes.c_size_t), ("WorkingSetSize", ctypes.c_size_t),
                ("QuotaPeakPagedPoolUsage", ctypes.c_size_t), ("QuotaPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t), ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
                ("PagefileUsage", ctypes.c_size_t), ("PeakPagefileUsage", ctypes.c_size_t)]


pmc = PMC()
pmc.cb = ctypes.sizeof(PMC)
k32 = ctypes.WinDLL("kernel32", use_last_error=True)
psapi = ctypes.WinDLL("psapi", use_last_error=True)
k32.GetCurrentProcess.restype = wt.HANDLE
psapi.GetProcessMemoryInfo.argtypes = [wt.HANDLE, ctypes.POINTER(PMC), wt.DWORD]
ok = psapi.GetProcessMemoryInfo(k32.GetCurrentProcess(), ctypes.byref(pmc), pmc.cb)
with open(os.path.join(HERE, "full-run-stats.txt"), "w", encoding="utf-8") as fh:
    fh.write(f"elapsed_seconds {elapsed:.1f}\n")
    fh.write(f"peak_working_set_bytes {pmc.PeakWorkingSetSize if ok else 'n/a'}\n")
    fh.write(f"peak_pagefile_bytes {pmc.PeakPagefileUsage if ok else 'n/a'}\n")
    fh.write(f"python {sys.version}\n")
