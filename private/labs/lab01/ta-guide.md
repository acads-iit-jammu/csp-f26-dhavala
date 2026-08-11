# Lab 01 — TA / Instructor Guide

Sessions: EE Tue Aug 11 (Lab 4022) · ME Wed Aug 12 (4022) · MT Wed Aug 12 (4021), all 2:00–4:00 pm.
Ungraded, but the full machinery runs at zero stakes. Teams of 1–2 per machine.

## Timing plan (120 min)

| Clock | Act | Watch for |
|---|---|---|
| 0:00–0:10 | Welcome + "third machine" framing; pairs assigned, roles explained | nobody opens a terminal yet |
| 0:10–0:20 | Act 0 install | see failure table below |
| 0:20–0:30 | Act 1 claim | `script` actually started (spot-check: `ls session.txt`) |
| 0:30–0:55 | Act 2 build | predictions said *aloud* before `ls` |
| 0:55–1:00 | **half-time whistle — pairs swap roles** | actually swap |
| 1:00–1:20 | Act 3 compile | both names in hello for pairs |
| 1:20–1:35 | Act 4 runaway | nobody `kill`s another team's PID |
| 1:35–1:55 | Act 5 lock/diary/bundle + check green | bundles actually leave the room |
| 1:55–2:00 | Reflect + close | collect the surprise-command answers verbally |

## Before the lab (morning-of, on ONE machine per room)

1. Copy `lab01.tar.gz` to the agreed place on every machine (or the shared location).
2. Dry-run the solution: extract, `CSP_TEAM=TESTRUN ./install.sh`, then run `answers/transcript.sh` inside the workspace, then `./check.sh` → must be **9/9 green**. If it is, the room is certified.
3. Delete your test workspace (`rm -rf .../w*-l01-*-sd` with care) or leave it — next install's clean pass sweeps it.
4. Confirm `gcc`, `nano`, `script`, `wget` exist. Confirm the course site loads on the lab network (fallback: tarballs are local anyway).

## Coaching rules

- Answer with Pólya: **"What have you tried? What did you expect? What did it print?"**
- Never touch a student's keyboard. Point at the sheet, not the screen.
- The check script says *what*, you may hint *where*, only the student does *how*.
- Encourage reading the error aloud. Half of all fixes happen during the reading.

## Common failure modes

| Symptom | Cause | Nudge |
|---|---|---|
| `install.sh: Permission denied` | not executable after copy | "how did we make check.sh runnable in Act 5? Same idea" (`bash install.sh` also fine) |
| Installer guesses wrong branch | make-up session / odd clock | just type the branch when asked; verify machine date! |
| Stuck in a full-screen thing | they ran `less`/`man` | "press q" (write it on the board pre-emptively) |
| Stuck in `vi`/`vim` | muscle memory from somewhere | `Esc :q!` — then "use nano today" |
| `./hello: No such file or directory` | typed `hello` without `./`, or gcc failed silently earlier | "$PATH question from Act 3 — and did gcc print anything?" |
| `session.txt` missing at check | forgot `script`, or ran it after work | restart recorder, redo Act 4 (fast) — the check needs kill-evidence in the recording |
| Locked themselves out (`chmod 000`) | Act 5 experimentation | teachable: `chmod 644` fixes it — *why* can they fix it? (owner!) |
| Killed the wrong PID | `ps` shows the whole shared machine | teachable moment: on shared systems, read before you kill; their neighbour will vividly agree |
| Two teams, one workspace quarrel | second team answered another team's rolls | re-run install with own rolls → gets `-2` suffix automatically |
| Bundle refuses | check not green | that is the design; read the FAILs top to bottom |
| check FAILs replay.sh though it runs | they left `kill <PID>` / `./loop &` in it | the log-vs-program lesson: a PID is true once; make them *say* why before trimming |
| `./replay.sh: Permission denied` | the **planned wall** — fresh files aren't executable | let them read the error aloud; `chmod +x` is Act 5's whole point |
| `501: command not found` on replay | history line-numbers not stripped | "read the error: what is 501? where have you seen it?" |

## Viva sampler (use at random, both pair members separately)

- "Line N of your session.txt — what did that command do, and why then?"
- "Your replay.sh has `chmod +x` — what exactly changed on disk?"
- "You ran `kill 4321` — where did 4321 come from?"
- "Decode `rw-r-----` into octal." (640 — connects to Deck 03)

## Answers

`answers/transcript.sh` is the full solution — a runnable command sequence from fresh workspace to 9/9 green. Read it before the session; replay it during the morning dry-run.
