#!/usr/bin/env bash
set -u
SRC="$(cd "$(dirname "$0")/../src/student" && pwd)"
ANS="$(cd "$(dirname "$0")/../answers" && pwd)"
T="$(mktemp -d)"
pass=0; fail=0
ok(){ pass=$((pass+1)); echo "PASS $1"; }
no(){ fail=$((fail+1)); echo "FAIL $1"; }

# t1: install (practice-ish via CSP_BASE) on a Tuesday lab4022 -> w03-l02-ee-sd
env CSP_BASE="$T/ws" CSP_DATE=2026-08-18 CSP_HOSTNAME=cse-lab4022-pc05 CSP_TEAM="2026UEE0042" CSP_ASSUME_YES=1 bash "$SRC/install.sh" </dev/null >/dev/null 2>&1
WS="$T/ws/w03-l02-ee-sd"
[ -d "$WS" ] && ok "t1 install -> w03-l02-ee-sd" || { no "t1: $(ls $T/ws 2>/dev/null)"; exit 1; }
[ -x "$WS/grader" ] && ok "t1b grader compiled by installer" || no "t1b grader missing"
[ -f "$WS/e1.c" ] && [ -f "$WS/p1_first_words.c" ] && ok "t1c stubs + playground present" || no "t1c"

cd "$WS"
# fabricate session for workspace checks
{ echo "Script started"; head -c 300 /dev/zero | tr '\0' '.'; } > session.txt

# t2: reference solutions all pass
cp "$ANS"/e*.c .
bash check.sh >/tmp/l2out 2>&1; rc=$?
grep -q "vector failures: 0" /tmp/l2out && [ $rc -eq 0 ] && ok "t2 reference solutions: all green (rc=0)" || { no "t2 rc=$rc"; tail -12 /tmp/l2out; }

# t3: hardcoded e1 (prints the public answer always) must fail random vectors
cat > e1.c <<'EOF'
#include <stdio.h>
int main(void){printf("sum=28 avg=9.33\n");return 0;}
EOF
bash check.sh e1 >/tmp/l2out 2>&1; rc=$?
grep -q "WRONG" /tmp/l2out && [ $rc -ne 0 ] && ok "t3 hardcoded e1 caught by random vectors" || { no "t3"; cat /tmp/l2out; }

# t4: syntax error -> COMPILE-FAIL
printf 'int main(void { broken' > e1.c
bash check.sh e1 >/tmp/l2out 2>&1
grep -q "COMPILE-FAIL" /tmp/l2out && ok "t4 syntax error -> COMPILE-FAIL with compiler message" || no "t4"

# t5: missing file -> MISSING
rm -f e3.c
bash check.sh e3 >/tmp/l2out 2>&1
grep -q "MISSING" /tmp/l2out && ok "t5 missing e3.c -> MISSING verdict" || no "t5"
cp "$ANS/e3.c" .

# t6: anti-litter guard — check.sh outside a workspace refuses with compass
cd "$T"
cp "$SRC/check.sh" .
bash check.sh >/tmp/l2out 2>&1; rc=$?
grep -q "not your workspace" /tmp/l2out && [ $rc -eq 2 ] && ok "t6 wrong-directory guard fires with compass message" || no "t6 rc=$rc"
cd "$WS"

# t7: e2 without a named PI -> STRUCT-FAIL
cat > e2.c <<'EOF'
#include <stdio.h>
int main(void){float r;scanf("%f",&r);
printf("area=%.3f circ=%.3f\n",3.14159*r*r,2*3.14159*r);return 0;}
EOF
bash check.sh e2 >/tmp/l2out 2>&1
grep -q "STRUCT-FAIL" /tmp/l2out && ok "t7 missing PI constant -> STRUCT-FAIL" || no "t7"
cp "$ANS/e2.c" .

# t8: restore all answers; bundle naming
cp "$ANS"/e*.c .
bash check.sh --quiet --bundle >/tmp/l2out 2>&1
ls ../lab02_2026UEE0042_ee_w03.tar.gz >/dev/null 2>&1 && ok "t8 bundle named lab02_2026UEE0042_ee_w03.tar.gz" || { no "t8"; ls ..; }

# t9: timeout (only where coreutils timeout exists)
if command -v timeout >/dev/null 2>&1; then
  cat > e5.c <<'EOF'
#include <stdio.h>
int main(void){while(1){} return 0;}
EOF
  bash check.sh e5 >/tmp/l2out 2>&1
  grep -q "TIMEOUT" /tmp/l2out && ok "t9 infinite loop -> TIMEOUT" || no "t9"
  cp "$ANS/e5.c" .
else
  echo "skip t9 (no timeout binary on this host)"
fi

echo "======================================="
echo "lab02 tests: $pass passed, $fail failed"
exit $fail
