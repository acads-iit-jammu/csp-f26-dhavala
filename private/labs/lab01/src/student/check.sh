#!/usr/bin/env bash
# Lab 01 self-check: tests the ENSURES list of the lab sheet. Run inside your workspace.
# It tells you WHAT is missing, never HOW to make it.
# Usage: ./check.sh [--quiet] [--bundle]
set -u
QUIET=0; BUNDLE=0
for a in "$@"; do case "$a" in --quiet) QUIET=1;; --bundle) BUNDLE=1;; esac; done

pass=0; fail=0; bpass=0; bmiss=0
ok(){ pass=$((pass+1)); [ "$QUIET" = 1 ] || printf 'PASS  %s\n' "$1"; }
no(){ fail=$((fail+1)); [ "$QUIET" = 1 ] || printf 'FAIL  %s\n' "$1"; }
bok(){ bpass=$((bpass+1)); [ "$QUIET" = 1 ] || printf 'BONUS-PASS  %s\n' "$1"; }
bno(){ bmiss=$((bmiss+1)); [ "$QUIET" = 1 ] || printf 'bonus-open  %s (home practice — not required today)\n' "$1"; }

# 1. identity
if [ -s TEAM.txt ] && grep -q '^rolls: [A-Za-z0-9]' TEAM.txt; then ok "TEAM.txt names your team"; else no "TEAM.txt with your roll number(s)"; fi
# 2. passport (made by YOU, not the installer)
if [ -s passport.txt ] && [ "$(grep -c . passport.txt)" -ge 4 ]; then ok "passport.txt records the machine (4+ lines)"; else no "passport.txt with the machine's details (whoami, hostname, uname -a, df -h — four lines)"; fi
# 3. hello.c edited (the starter's placeholder must be gone)
if [ -f hello.c ] && ! grep -q 'CHANGE_ME' hello.c; then ok "hello.c edited — placeholder gone"; else no "hello.c edited so it prints YOUR name (the placeholder must disappear)"; fi
# 4. compiled by you, runs
if [ -x hello ] && ./hello >/dev/null 2>&1; then ok "hello compiles and runs"; else no "a compiled, runnable ./hello"; fi
# 5. output captured and faithful
if [ -s output.txt ] && [ -x hello ] && [ "$(./hello 2>/dev/null)" = "$(cat output.txt)" ]; then ok "output.txt matches ./hello exactly"; else no "output.txt matching ./hello — if you re-edited or recompiled, re-capture: ./hello > output.txt"; fi
# 6. notes
if [ -s notes/README.txt ]; then ok "notes/README.txt exists"; else no "notes/README.txt (one line: what lives where)"; fi
# 7. replayable diary
replay_ok=0
if [ -f replay.sh ] && [ -x replay.sh ] && ! grep -qE '(^|[[:space:]])(kill|ps)([[:space:]]|$)|loop *&' replay.sh; then
  if command -v timeout >/dev/null 2>&1; then timeout 15 ./replay.sh >/dev/null 2>&1 && replay_ok=1
  else ./replay.sh >/dev/null 2>&1 && replay_ok=1; fi
fi
if [ "$replay_ok" = 1 ]; then bok "replay.sh runs cleanly, end to end"; else bno "a replay.sh that actually RUNS (strip history numbers, #!/bin/sh first line, chmod +x, no kill/ps/loop)"; fi
# 8. session recorded
if [ -f session.txt ] && [ "$(wc -c < session.txt)" -gt 200 ]; then ok "session.txt recorded (script ran)"; else no "a session.txt of real size (did you start 'script session.txt' first?)"; fi
# 9. the runaway was fought
if [ -f session.txt ] && grep -q 'kill' session.txt; then ok "evidence of kill in your session (Act 4)"; else no "evidence you found and killed the runaway (pgrep, kill) in session.txt"; fi

echo "----------------------------------------"
echo "check: $pass passed, $fail failed (bonus: $bpass done, $bmiss open)"
if [ "$fail" -eq 0 ]; then echo "All green. Bundle and go: ./check.sh --bundle"; fi

if [ "$BUNDLE" = 1 ]; then
  if [ "$fail" -gt 0 ]; then echo "bundle: WARNING — bundling with $fail FAIL(s); your work is submitted as-is (the verdicts travel with it)"; fi
  rolls="$(sed -n 's/^rolls: //p' TEAM.txt | tr ' ' '_')"
  branch="$(sed -n 's/^branch: //p' TEAM.txt)"
  week="$(sed -n 's/^week: //p' TEAM.txt)"
  lab="$(sed -n 's/^lab: //p' TEAM.txt)"
  name="lab$(printf '%02d' "${lab:-1}")_${rolls}_${branch}_w$(printf '%02d' "${week:-0}").tar.gz"
  ws="$(basename "$PWD")"
  ( cd .. && tar czf "$name" "$ws" ) && echo "bundle: ../$name — copy it out (Moodle / USB / email yourself). The machine forgets; you must not."
fi
exit "$fail"
