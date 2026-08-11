#!/usr/bin/env bash
set -u
SRC="/Users/somadhavala/work/iitjmu-acad/courses/CS-1-01-MO-F26-DHAVALA/private/labs/lab01/src/student"
T="$(mktemp -d)"; BASE="$T/csp_labs_f26"
chmod +x "$SRC/install.sh" "$SRC/clean.sh" "$SRC/check.sh"
pass=0; fail=0
ok(){ pass=$((pass+1)); echo "PASS $1"; }
no(){ fail=$((fail+1)); echo "FAIL $1"; }

inst(){ env CSP_BASE="$BASE" CSP_DATE="$1" CSP_HOSTNAME="$2" CSP_TEAM="$3" CSP_ASSUME_YES=1 ${4:+CSP_BRANCH="$4"} bash "$SRC/install.sh" </dev/null >/dev/null 2>&1; }

# t0: the placeholder token appears exactly once, on the printf line only
n=$(grep -c CHANGE_ME "$SRC/starters/hello.c")
occ=$(grep CHANGE_ME "$SRC/starters/hello.c" | grep -c printf)
[ "$n" -eq 1 ] && [ "$occ" -eq 1 ] && ok "t0 CHANGE_ME only in the printf line" || no "t0 token count=$n printf=$occ"

# t1: Tue Aug 11, lab4022 -> w02-l01-ee-sd
inst 2026-08-11 cse-lab4022-pc04 "2026UEE0001"
[ -d "$BASE/w02-l01-ee-sd" ] && ok "t1 Tue+4022 -> w02-l01-ee-sd" || no "t1 expected w02-l01-ee-sd, got: $(ls $BASE 2>/dev/null)"
grep -q "^rolls: 2026UEE0001$" "$BASE/w02-l01-ee-sd/TEAM.txt" && ok "t1b TEAM.txt rolls" || no "t1b TEAM.txt"

# t2: Wed Aug 12, 4022 -> me
inst 2026-08-12 cse-lab4022-pc07 "2026UME0002 2026UME0003"
[ -d "$BASE/w02-l01-me-sd" ] && ok "t2 Wed+4022 -> me (pair)" || no "t2"

# t3: drift — Wed Sep 2, 4021 -> w05-l01-mt-sd
inst 2026-09-02 cse-lab4021-pc01 "2026UMT0004"
[ -d "$BASE/w05-l01-mt-sd" ] && ok "t3 drift: Sep 2 Wed+4021 -> w05-l01-mt-sd" || no "t3 got: $(ls $BASE)"

# t4: unknown hostname, non-interactive -> needs CSP_BRANCH; without it fails
CSP_BASE="$BASE" CSP_DATE=2026-08-11 CSP_HOSTNAME=random-box CSP_TEAM=X CSP_ASSUME_YES=1 "$SRC/install.sh" </dev/null >/dev/null 2>&1
[ $? -ne 0 ] && ok "t4a unknown host refuses without branch" || no "t4a"
inst 2026-08-11 random-box "2026UEE0005" ee
[ -d "$BASE/w02-l01-ee-sd" ] && ok "t4b CSP_BRANCH fallback works" || no "t4b"

# t5: resume same team (t1 team again) -> no suffix dir
inst 2026-08-11 cse-lab4022-pc04 "2026UEE0005"
[ ! -d "$BASE/w02-l01-ee-sd-2" ] && ok "t5 same team resumes (no -2)" || no "t5"

# t6: different team same machine same week -> -2 suffix
inst 2026-08-11 cse-lab4022-pc04 "2026UEE0099"
[ -d "$BASE/w02-l01-ee-sd-2" ] && ok "t6 different team gets -2" || no "t6"

# t7: clean-safety — running lab in a later week removes old, keeps current+aliens
mkdir -p "$BASE/keep-me" "$BASE/w99-l99-not-a-real-pattern"
CSP_BASE="$BASE" "$SRC/clean.sh" --auto 5 1 >/dev/null 2>&1   # current = w05 l01
[ ! -d "$BASE/w02-l01-ee-sd" ] && [ ! -d "$BASE/w02-l01-ee-sd-2" ] && ok "t7a old-week workspaces removed" || no "t7a"
[ -d "$BASE/w05-l01-mt-sd" ] && ok "t7b current week preserved" || no "t7b"
[ -d "$BASE/keep-me" ] && [ -d "$BASE/w99-l99-not-a-real-pattern" ] && ok "t7c non-pattern dirs untouched" || no "t7c"

# t8: check.sh on a complete fabricated workspace -> all pass
WS="$BASE/w05-l01-mt-sd"
cd "$WS"
sed 's/CHANGE_ME/Testy Student/' hello.c > h.c && mv h.c hello.c
gcc hello.c -o hello 2>/dev/null
./hello > output.txt
mkdir -p notes && echo "everything lives here" > notes/README.txt
printf 'student\ncse-lab4021-pc01\nLinux cse-lab4021 6.8.0 GNU/Linux\n/dev/sda 40G free\n' > passport.txt
printf '#!/bin/sh\necho replayed\n' > replay.sh && chmod +x replay.sh
{ printf 'Script started\n$ ps aux | grep loop\n$ kill 12345\n'; head -c 300 /dev/zero | tr '\0' 'x'; } > session.txt
out="$("./check.sh" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && echo "$out" | grep -q '9 passed, 0 failed' && ok "t8 complete workspace: 9/9 PASS" || { no "t8"; echo "$out"; }

# t8b: replay.sh containing a kill/PID must FAIL the replayability check
printf '#!/bin/sh\nkill 12345\n./hello\n' > replay.sh && chmod +x replay.sh
out="$(./check.sh --quiet 2>&1)"; rc=$?
[ "$rc" -eq 1 ] && ok "t8b replay.sh with kill PID is rejected" || no "t8b rc=$rc"
# t8c: un-stripped history line numbers must fail (checker actually runs it)
printf '  501  ./hello\n  502  ls -l\n' > replay.sh && chmod +x replay.sh
out="$(./check.sh --quiet 2>&1)"; rc=$?
[ "$rc" -eq 1 ] && ok "t8c replay.sh with history numbers is rejected" || no "t8c rc=$rc"
printf '#!/bin/sh\necho replayed\n' > replay.sh && chmod +x replay.sh   # restore good replay

# t9: bundle naming
./check.sh --quiet --bundle >/dev/null 2>&1
[ -f "$BASE/lab01_2026UMT0004_mt_w05.tar.gz" ] && ok "t9 bundle named lab01_2026UMT0004_mt_w05.tar.gz" || { no "t9"; ls "$BASE"; }

# t10: degraded workspace -> failures counted, no bundle
rm replay.sh output.txt
out="$(./check.sh --quiet 2>&1)"; rc=$?
[ "$rc" -eq 2 ] && ok "t10a two regressions -> exit 2" || no "t10a rc=$rc: $out"
rm -f ../lab01_*.tar.gz
./check.sh --quiet --bundle >/dev/null 2>&1
ls ../lab01_*.tar.gz >/dev/null 2>&1 && ok "t10b bundle proceeds even with FAILs (submit-as-is)" || no "t10b"

# t11: practice mode — no CSP_BASE, no /home/student -> falls back to $HOME/csp_labs_f26
PH="$T/prachome"; mkdir -p "$PH/rundir"
( cd "$PH/rundir" && env -u CSP_BASE HOME="$PH" CSP_DATE=2026-08-11 CSP_HOSTNAME=somas-macbook CSP_TEAM="2026UEE0777" CSP_ASSUME_YES=1 CSP_BRANCH=ee bash "$SRC/install.sh" </dev/null >/dev/null 2>&1 )
[ -d "$PH/rundir/w02-l01-ee-sd" ] && ok "t11 practice mode installs where it is run from" || no "t11 $(ls -R $PH 2>/dev/null)"

# t12: flags work like env vars
env -u CSP_BASE -u CSP_BRANCH -u CSP_TEAM HOME="$PH" CSP_DATE=2026-08-12 CSP_HOSTNAME=somas-macbook CSP_ASSUME_YES=1 bash "$SRC/install.sh" --branch mt --team "2026UMT0778" --base "$PH/flagbase" </dev/null >/dev/null 2>&1
[ -d "$PH/flagbase/w02-l01-mt-sd" ] && ok "t12 --branch/--team/--base flags" || no "t12"

echo "======================================="
echo "lab tests: $pass passed, $fail failed"
exit $fail
