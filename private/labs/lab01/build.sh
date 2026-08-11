#!/usr/bin/env bash
# Builds the two lab bundles from src/.
#   lab01.tar.gz     (student)  -> also copied to ../../materials/ for the site
#   lab01-ta.tar.gz  (staff)    -> stays here, private
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
STAGE="$(mktemp -d)"

mkdir -p "$STAGE/lab01"
cp -R "$HERE/src/student/." "$STAGE/lab01/"
chmod +x "$STAGE/lab01/install.sh" "$STAGE/lab01/clean.sh" "$STAGE/lab01/check.sh"
( cd "$STAGE" && tar czf "$HERE/lab01.tar.gz" lab01 )

mkdir -p "$STAGE/lab01-ta"
cp "$HERE/ta-guide.md" "$HERE/scoring.md" "$HERE/check-ta.sh" "$STAGE/lab01-ta/"
cp -R "$HERE/answers" "$STAGE/lab01-ta/answers"
( cd "$STAGE" && tar czf "$HERE/lab01-ta.tar.gz" lab01-ta )

PUB="$HERE/../../../labs"
mkdir -p "$PUB"
cp "$HERE/lab01.tar.gz" "$PUB/lab01.tar.gz" && echo "published: labs/lab01.tar.gz (same copy as staff)"
rm -rf "$STAGE"
echo "built: lab01.tar.gz ($(wc -c < "$HERE/lab01.tar.gz") bytes), lab01-ta.tar.gz"
