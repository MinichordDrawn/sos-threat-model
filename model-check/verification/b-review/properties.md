# The eight properties

Each is a property of a system of processes in which some processes ("monitors") watch
others. `model-spec.md` defines the model they are stated over.

- **P1 Liveness signal.** Each monitor emits a periodic signal, and the absence of the signal
  is an input that makes another monitor raise a flag.
- **P2 Shared substrate.** A monitor and the process it watches share a failure substrate:
  an environment step that takes the substrate away from the watched process also stops the
  monitor, so the monitor's silence is observable through P1.
- **P3 State check.** A monitor compares current state with a known-good reference, so it
  can flag a bad state that no observed event announced.
- **P4 Propagation.** A flag raised by one monitor reaches every other monitor. The path may
  be direct or a chain of reports through other monitors, including up and down through the
  coordinators that join one ring of monitors to another.
- **P5 No single-step removal.** No single environment step removes the monitoring of a
  process without that step being observed. In particular no monitor has a sanctioned off
  switch.
- **P6 Out-of-boundary signal.** When a monitor stops, a process in a separate trust
  boundary that is still live observes its absence and raises a flag.
- **P7 Automatic enrolment.** When a process joins at runtime, the step that adds it also
  puts it under monitoring. There is no interval in which it exists and is unmonitored.
- **P8 Immediate response.** When a monitor raises a flag, the halt takes effect with no
  intermediate evaluating state in which the environment can take further steps.
- **P8b Halt fan-out.** Any process can trigger the halt, and every halt is passed to at
  least two other processes, each of which passes it to at least two more, and so on. In the
  model's terms, every work process takes its halt from at least two monitors.

The function `reference(without=(...))` in `check_model.py` builds a reference system R
with all nine in place, or with the named ones removed.
