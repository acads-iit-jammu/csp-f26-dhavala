#!/usr/bin/env bash
# Lab 01 SOLUTION transcript — run inside a freshly installed workspace.
# Doubles as the morning dry-run: afterwards ./check.sh must print 9/9 green.
# (session.txt is faked here because `script` needs a terminal; in the real lab
#  students run: script session.txt ... exit)
set -eu

# Act 1 — claim
whoami   >  passport.txt
hostname >> passport.txt
uname -a >> passport.txt
df -h .  >> passport.txt

# Act 2 — build
mkdir -p notes
echo "workspace for lab01: code at top level, notes/ for text" > notes/README.txt
mkdir -p practice/a practice/b
touch practice/a/one.txt
cp practice/a/one.txt practice/a/two.txt
mv practice/a/two.txt practice/b/one.txt 2>/dev/null || touch practice/b/one.txt
rm -r practice          # students use rm -ri; -r here for non-interactive replay

# Act 3 — speak
sed -i.bak 's/CHANGE_ME/The Instructor/' hello.c && rm -f hello.c.bak
gcc hello.c -o hello
./hello > output.txt
cat output.txt | wc -w

# Act 4 — runaway (compressed for replay; students do fg Ctrl-C first)
gcc loop.c -o loop
./loop & LOOPPID=$!
sleep 2
ps | grep -v grep | grep loop || true
kill "$LOOPPID"

# Act 5 — lock, diary
ls -l hello
chmod 600 passport.txt
printf '#!/bin/sh\n./hello\ncat output.txt | wc -w\n' > replay.sh
chmod +x replay.sh
./replay.sh

# fake the session recording for dry-run purposes only
{ echo "Script started (dry-run stand-in)"
  echo "\$ ps"; echo "\$ kill $LOOPPID"
  head -c 300 /dev/zero | tr '\0' '.'
  echo; echo "Script done"
} > session.txt

echo "--- transcript complete; now run: ./check.sh"
