# Lab 01 — Scoring Sheet

**Weight: 0% (setup lab).** Score it anyway — students see the system, we calibrate it.
From Lab 02, the same sheet carries the per-lab share of the 20% lab component.

## Band A · Auto (60 pts) — from `check-ta.sh` over submitted bundles

| # | ENSURES item (as tested by check.sh) | pts |
|---|---|---|
| 1 | TEAM.txt names the team | 5 |
| 2 | passport.txt records the machine | 5 |
| 3 | hello.c edited (placeholder gone) | 5 |
| 4 | hello compiles and runs | 10 |
| 5 | output.txt matches ./hello exactly | 10 |
| 6 | notes/README.txt | 5 |
| 7 | replay.sh executable *and* replayable (no one-time PID commands) | 10 |
| 8 | session.txt recorded (script ran) | 5 |
| 9 | kill-evidence in session (Act 4 done) | 5 |

## Band B · Observed in lab (20 pts) — tick-sheet while circulating

| Item | pts |
|---|---|
| Predictions made before running (heard at least once) | 5 |
| Pair swapped roles at half-time / solo narrated aloud | 5 |
| Used man/--help/Tab before calling for help | 5 |
| `rm -ri` used as instructed (no naked `rm -r` observed) | 5 |

## Band C · Viva (20 pts) — 2 questions per *member*, sampled

| Item | pts |
|---|---|
| Explains a random line of own session.txt | 10 |
| Explains one concept: PATH, PID, or octal permissions | 10 |

**Rule:** a member who cannot explain their own session log redoes the lab solo (no penalty in Lab 01; from Lab 02, band C scores individually).

**Recording:** one row per team in the CSV from `check-ta.sh` (band A auto-filled); B and C filled by hand; file the CSV in `private/labs/lab01/results/`.
