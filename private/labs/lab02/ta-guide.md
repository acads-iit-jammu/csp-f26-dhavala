# Lab 02 — TA / Instructor Guide

First graded lab (each lab from now: equal share of the 20%).
Sessions: EE Tue Aug 18 (4022) · ME Wed Aug 19 (4022) · MT Wed Aug 19 (4021), 2:00–4:00 pm.

## Timing plan (120 min)

| Clock | Segment | Watch for |
|---|---|---|
| 0:00–0:08 | Warm-up circuit (compass + ps + pipe) on the board | everyone in a terminal, nobody installing yet |
| 0:08–0:18 | Install + **the litter speech** (below) + `script session.txt` | `pwd` spot-checks start NOW |
| 0:18–0:45 | Playground p1–p3, TA-driven tinker tables | students PREDICT before each tinker |
| 0:45–0:50 | half-time whistle — pairs swap | |
| 0:50–1:40 | Graded e1–e5, solo; TA helps with *clarifications only* | answer with the spec: "what does the ENSURES line say?" |
| 1:40–1:55 | check.sh, fix, bundle, carry out | bundles leave the room |
| 1:55–2:00 | Wrap: viva sampling if time | |

## The litter speech (say it verbatim, early)

"Everything happens inside the workspace the installer printed. `pwd` before you edit.
Files created anywhere else are invisible to the checker, will not be bundled,
and will be deleted by next week's cleanup. If check.sh says 'not your workspace' — that's
the machine telling you you're lost. Run the compass."

Spot-check ritual: while circulating, ask any student to run `pwd` aloud. Twice per session minimum.

## Grading model

- Per problem: 6 vectors (3 public, 3 random). `check-ta.sh` re-compiles from bundled SOURCE and re-runs — doctored outputs buy nothing.
- e2 has one structural check (a named PI) — it is stated in the stub; not a trick.
- Contract is a SUFFIX of the final line: prompts may share the line. If a student's prompt *contains* digits+equals that collide... it won't. Don't overthink; the grader shows both strings on WRONG.

## The session transcript (session.txt)

It is required in every bundle but **no automated check reads its content** — its job
is the audit trail. Grading judges outcomes; the transcript records *process*. When a
copy or freeriding question arises, open it: forty minutes of edit-compile-fail-fix
reads very differently from one paste with zero compile attempts. Inspect at your
discretion; it is also a natural anchor for Band B ("walk me through this part of
your session").

## Common failure modes

| Symptom | Cause | Nudge |
|---|---|---|
| "not your workspace" from check.sh | working in extract dir / home | the compass; then `mv` their `e*.c` into the workspace — teachable rescue |
| WRONG but output "looks the same" | spacing/case/decimals differ from contract | "the grader printed both strings — play spot-the-difference, character by character" |
| avg or qf prints 0.00 | integer division before the float context | Deck 07's trap: `(double)a/b`, or `/3.0` |
| e2 WRONG on randoms only | radius stored in double, spec says float | read the GIVEN aloud |
| scanf hangs forever | missing & or wrong specifier count | Ctrl-C, then p2's tinker table is the cure |
| e5 skips input | no space before %c | p3's tinker table |
| garbage huge numbers | reading uninitialized variable (scanf failed silently) | "what did scanf actually read? check its meaning" |
| COMPILE-FAIL cascade | one missing semicolon, many errors | "first error first; the rest are echoes" |

## Viva sampler

- "Your e3 prints qf correctly — walk me through why q and qf differ."
- "In e2, why did the spec insist PI be a named constant instead of typing 3.14159 twice?"
- "The checker gave you a random input you'd never seen. Why did your program still pass?"
  (The answer we want: "because it computes from the GIVEN, not from examples" — the whole course in one sentence.)

## Answers

`answers/e1.c … e5.c` are reference solutions. Morning dry-run: install on one machine per room,
copy answers in, `./check.sh` → expect all green + "vector failures: 0". That certifies the room.
