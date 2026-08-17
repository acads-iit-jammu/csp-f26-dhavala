#!/usr/bin/env bash
# Batch-score submitted lab02 bundles -> CSV on stdout.
# Usage: ./check-ta.sh /path/to/dir-with-tarballs > results.csv
set -u
DIR="${1:?usage: check-ta.sh DIR_WITH_TARBALLS}"
echo "bundle,rolls,branch,week,auto_pass,auto_fail"
for tgz in "$DIR"/lab02_*.tar.gz; do
  [ -f "$tgz" ] || continue
  T="$(mktemp -d)"
  tar xzf "$tgz" -C "$T" 2>/dev/null || { echo "$(basename "$tgz"),UNREADABLE,,,,"; rm -rf "$T"; continue; }
  WS="$(find "$T" -maxdepth 1 -mindepth 1 -type d | head -1)"
  rolls="$(sed -n 's/^rolls: //p' "$WS/TEAM.txt" 2>/dev/null | tr ' ' '+')"
  branch="$(sed -n 's/^branch: //p' "$WS/TEAM.txt" 2>/dev/null)"
  week="$(sed -n 's/^week: //p' "$WS/TEAM.txt" 2>/dev/null)"
  out="$(cd "$WS" && bash ./check.sh --quiet 2>/dev/null)"; fails=$?
  passes="$(echo "$out" | sed -n 's/^check: \([0-9]*\) passed.*/\1/p')"
  echo "$(basename "$tgz"),${rolls:-?},${branch:-?},${week:-?},${passes:-0},${fails}"
  rm -rf "$T"
done
