---------------------------- MODULE Heartbeat ----------------------------
(* Property P1, the liveness signal, on its own.                           *)
(* Monitors state-check one work process. With HB = TRUE each monitor also *)
(* flags when another monitor's signal is absent. The environment takes at *)
(* most one step per round; then every live monitor takes its step.        *)
EXTENDS Naturals

CONSTANTS Mon,     \* the set of monitors, for example {m1, m2}
          HB       \* TRUE: P1 holds. FALSE: nobody reads a missing signal.

VARIABLES alive,   \* monitors that have not been stopped
          bad,     \* TRUE once the work process's state differs from known-good
          out,     \* out[m] is "nominal" or "flagged"
          turn,    \* "env" or "mon"
          halted   \* TRUE once a monitor has flagged: the response has fired

vars == <<alive, bad, out, turn, halted>>

Init == /\ alive = Mon
        /\ bad = FALSE
        /\ out = [m \in Mon |-> "nominal"]
        /\ turn = "env"
        /\ halted = FALSE

(* Environment steps. *)
Stop(m) == /\ m \in alive
           /\ alive' = alive \ {m}
           /\ UNCHANGED bad

Corrupt == /\ ~bad
           /\ bad' = TRUE
           /\ UNCHANGED alive

Skip == UNCHANGED <<alive, bad>>

Env == /\ turn = "env"
       /\ ~halted
       /\ \/ \E m \in Mon : Stop(m)
          \/ Corrupt
          \/ Skip
       /\ turn' = "mon"
       /\ UNCHANGED <<out, halted>>

(* What a live monitor m sees in its round. *)
SeesBad(m)     == bad
SeesSilence(m) == HB /\ \E p \in Mon \ {m} : p \notin alive
Detects(m)     == SeesBad(m) \/ SeesSilence(m)

MonRound == /\ turn = "mon"
            /\ out' = [m \in Mon |->
                         IF m \in alive /\ Detects(m) THEN "flagged" ELSE out[m]]
            /\ halted' = (\E m \in alive : Detects(m))
            /\ turn' = "env"
            /\ UNCHANGED <<alive, bad>>

(* The model ends at the first response; this step only lets TLC idle there. *)
Done == halted /\ UNCHANGED vars

Next == Env \/ MonRound \/ Done

Spec == Init /\ [][Next]_vars

TypeOK == /\ alive \subseteq Mon
          /\ bad \in BOOLEAN
          /\ out \in [Mon -> {"nominal", "flagged"}]
          /\ turn \in {"env", "mon"}
          /\ halted \in BOOLEAN

(* Judged between rounds: once a monitor round has run on a bad state, *)
(* some live monitor is flagged.                                        *)
NoUndetectedBad == (turn = "env" /\ bad) => (\E m \in alive : out[m] = "flagged")
=============================================================================
