#!/usr/bin/env bash
# Lab 02 self-check. Run inside your workspace.
#   ./check.sh          all graded problems + workspace items
#   ./check.sh e3       just one problem
#   ./check.sh --bundle check everything, then bundle regardless
set -u
QUIET=0; BUNDLE=0; ONLY=""
for a in "$@"; do case "$a" in
  --quiet) QUIET=1;; --bundle) BUNDLE=1;;
  e1|e2|e3|e4|e5) ONLY="$a";;
  *) echo "usage: ./check.sh [e1..e5] [--bundle]"; exit 2;;
esac; done

# ---- the anti-litter guard: are we even in a workspace? ----
if [ ! -f TEAM.txt ]; then
  echo "STOP: this is not your workspace (no TEAM.txt here)."
  echo "Run the compass:  pwd  — then:  ls /home/student/csp_labs_f26"
  echo "and cd into your w??-l02-*-sd directory. ALL work happens there."
  exit 2
fi
echo "workspace: $(pwd)"

pass=0; fail=0; vfail=0
ok(){ pass=$((pass+1)); [ "$QUIET" = 1 ] || printf 'PASS  %s\n' "$1"; }
no(){ fail=$((fail+1)); [ "$QUIET" = 1 ] || printf 'FAIL  %s\n' "$1"; }

if [ -z "$ONLY" ]; then
  # workspace items
  if [ -s TEAM.txt ] && grep -q '^rolls: [A-Za-z0-9]' TEAM.txt; then ok "TEAM.txt names your team"; else no "TEAM.txt with your roll number(s)"; fi
  if [ -f session.txt ] && [ "$(wc -c < session.txt)" -gt 200 ]; then ok "session.txt recorded (script ran)"; else no "a session.txt of real size (start 'script session.txt' FIRST)"; fi
fi

# ---- grader engine ----
if [ ! -x grader ]; then
  if command -v gcc >/dev/null 2>&1 && [ -f grader.c ]; then gcc grader.c -o grader; fi
fi
if [ ! -x grader ]; then
  no "the grader engine (re-run install.sh, or: gcc grader.c -o grader)"
else
  PROBS="${ONLY:-e1 e2 e3 e4 e5}"
  for p in $PROBS; do
    echo "--- $p ---------------------------------"
    ./grader "$p"; f=$?
    vfail=$((vfail+f))
    if [ "$f" -eq 0 ]; then ok "$p: all vectors pass"; else no "$p: $f vector(s) failing"; fi
  done
fi

echo "----------------------------------------"
echo "check: $pass passed, $fail failed (vector failures: $vfail)"

if [ "$BUNDLE" = 1 ]; then
  [ "$fail" -gt 0 ] && echo "bundle: WARNING — bundling with $fail FAIL(s); submitted as-is (the verdicts travel with it)"
  rolls="$(sed -n 's/^rolls: //p' TEAM.txt | tr ' ' '_')"
  branch="$(sed -n 's/^branch: //p' TEAM.txt)"
  week="$(sed -n 's/^week: //p' TEAM.txt)"
  lab="$(sed -n 's/^lab: //p' TEAM.txt)"
  name="lab$(printf '%02d' "${lab:-2}")_${rolls}_${branch}_w$(printf '%02d' "${week:-0}").tar.gz"
  ws="$(basename "$PWD")"
  ( cd .. && tar czf "$name" "$ws" ) && echo "bundle: ../$name — carry it out (Moodle / email yourself). The machine forgets; you must not."
fi
exit "$fail"
