# Lab 01 — TA / Instructor Guide

Sessions: EE Tue Aug 11 (Lab 4022) · ME Wed Aug 12 (4022) · MT Wed Aug 12 (4021), all 2:00–4:00 pm.
Ungraded, but the full machinery runs at zero stakes. Teams of 1–2 per machine.

## Timing plan (120 min) — v2 after the EE session

| Clock | Act | Watch for |
|---|---|---|
| 0:00–0:12 | Welcome + **the blackboard prologue** (below) — nobody touches a keyboard | draw the tree; say "you are always standing somewhere" twice |
| 0:12–0:22 | Act 0 install | see failure table below |
| 0:22–0:32 | Act 1 claim | `script` actually started (spot-check: `ls session.txt`) |
| 0:32–0:52 | Act 2 build | predictions said *aloud* before `ls` |
| 0:52–0:55 | **half-time whistle — pairs swap roles** | actually swap |
| 0:55–1:15 | Act 3 compile | both names in hello for pairs |
| 1:15–1:28 | Act 4 runaway (quiet loop, pgrep) | nobody `kill`s another team's PID |
| 1:28–1:50 | Act 5 permissions + check + bundle | bundles actually leave the room |
| 1:50–2:00 | Reflect + point at Act 6 (home bonus) | collect surprise-command answers verbally |

## The blackboard prologue (write these three things up BEFORE students arrive)

1. The tree: `/ → home → student → csp_labs_f26 → w02-l01-…` — "a folder is a box, a file is a page, a path is an address."
2. The compass, boxed: `pwd` (where am I) · `ls` (what's here) · `cd` (walk) — "when it says *No such file or directory*, run the compass."
3. Survival keys: `q` quits man/less · `Ctrl-C` stops a program · terminal paste is `Ctrl+Shift+V`.

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
| `session.txt` missing at check | forgot `script`, or ran it after work | restart recorder, redo Act 4 (fast) — the kill-evidence check reads the recording |
| "command not found" / "No such file" spiral | wrong directory | do NOT fix it for them: "run the compass" (pwd → ls → cd) |
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
