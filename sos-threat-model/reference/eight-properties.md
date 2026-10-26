# The eight properties, and the attack each one closes

The model claims the eight properties are necessary consequences of the four constraints,
not optional features. The practical test of that claim: remove any one property and a
specific, exploitable gap opens where silent compromise becomes possible. Run a system
against this list; each missing property is an open attack.

## 1. Heartbeat

**Gap.** With no liveness signal, nobody knows whether the observer is alive. An attacker
kills it silently; there is no signal whose absence triggers a response. The system keeps
running without protection until a human happens to notice.

**Attack.** Kill the observer. Wait. Operate freely.

## 2. Substrate dependency

**Gap.** A security camera on a separate power grid from the building it watches. A
burglar cuts the building's power: the locks go dead, the alarm goes offline, the vault
opens. The camera keeps recording a dark building and reports nothing wrong, because it
cannot feel the outage that enabled the breach.

**Attack.** Attack the infrastructure the observer does not share. The observer stays
healthy and reports all clear, because the problem is where it cannot feel it.

Substrate dependency means the camera is on the same grid. When the power goes out, the
camera goes dark too, and "camera offline" is the signal. Shared failure is detection.

## 3. Continuous state verification

**Gap.** Without continuous verification against a known-good state, the system has no
definition of normal. It detects events (things that happen) but not states (things that
exist and should not). A persistent backdoor that just sits there is never found.

**Attack.** Make one change. Wait. The observer sees activity, never presence.

## 4. System-wide response

**Gap.** Detection by one agent does not reach the others. Each agent sees its own
compromise and cannot warn the rest.

**Attack.** Compromise the agents one at a time. By the time a human correlates the
failures, all of them are gone.

## 5. Self-defense

**Gap.** One action removes the observer. The attacker's first move is to remove it, then
operate freely; the observer is a single point of failure for the whole security model.

**Attack.** Delete the observer (one API call, one permission). Then do anything.

## 6. Death signaling

**Gap.** When the observer dies, the signal dies with it. Nothing crosses into an
independent trust boundary, so killing the observer removes the detection and the alert
together.

**Attack.** Kill the observer inside its boundary. Nothing outside learns it happened.

## 7. Automatic integration

**Gap.** A new component is unwatched until someone configures the observer for it. The
window between deploying a component and observing it can last days, or forever.

**Attack.** Deploy during the window, or add a component the observer never learns about.

## 8. Reflexive response

**Gap.** The observer detects a violation, then evaluates before responding: is this real,
should it escalate, should it wait for more data. During the evaluation window an
exponential threat doubles.

**Attack.** Trigger detection, then act inside the evaluation window.

## The audit table

| Property | If missing, an attacker can |
|---|---|
| Heartbeat | Kill the observer silently and operate indefinitely |
| Substrate dependency | Attack through infrastructure the observer does not share |
| Continuous state verification | Plant a persistent change that is never detected |
| System-wide response | Compromise agents serially, with no propagation between them |
| Self-defense | Remove the observer in one action, then do anything |
| Death signaling | Kill the observer inside its boundary; no signal escapes |
| Automatic integration | Deploy in the window before the observer is updated |
| Reflexive response | Act during the window while the observer decides |
