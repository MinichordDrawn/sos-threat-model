# The fault model and the theorems asked for

This is the part of the brief that says what a fault is and what is to be proved, word for word.

## The fault model

One fault per halt. A fault is one stored value changing to any other value by something other than the program's own work: one field of one part of the state, of one observer's copy, of the gate's record (its texts or its copy), of one of the three places of anything kept in three, one entry of one list of what was asked; or one observer's answer in one round being absent or being any other answer. It may land at any instant: between any two steps of a round, or between two rounds. The next fault lands only after the first has been found, its halt has ended, and a round has been worked and recorded since.

Outside the claim, by the author's decision: two faults before that; a list or text made larger than a game can have (the program cuts such things down, and that cutting is not part of this proof: assume sizes a game can have); a fault in the program's code, in the threads' scheduling, or in the machine.

3. **The theorems**, in this order of importance. For each, the statement must be readable beside the specification.
   - **T1. Nothing wrong is recorded.** For every state the program can reach with no fault, every single fault and every instant: the round is either not recorded, or what is recorded is what the same round with no fault records.
   - **T2. Put right.** After the halt that follows, when it has ended, everything stored (the state, the record, every observer's copy, every place of three) is what it is in the run with no fault at the same round, or at the round the faulted run has reached if a round was not worked. Say exactly which.
   - **T3. Never stuck.** No single fault leads to a halt that cannot be put right.
   - **T4. Found, or gone.** A single fault is found in the round it lands in or the next, or it is written over by the program's own work with nothing wrong recorded.
   - **T5. One after another.** Any sequence of faults that meets the model's spacing leaves, after each halt, what T2 says; by induction from T1 to T4.
   - **T6. The edge is where it is said to be.** Two faults in one round that the protocol does not survive: a concrete pair, as a proved counterexample, so that the scope is shown to be tight and not merely convenient. Lowest priority.
