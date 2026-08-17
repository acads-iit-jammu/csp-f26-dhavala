#!/usr/bin/env bash
# Builds the two lab bundles from src/.
#   lab02.tar.gz     (student)  -> also copied to ../../materials/ for the site
#   lab02-ta.tar.gz  (staff)    -> stays here, private
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
STAGE="$(mktemp -d)"

mkdir -p "$STAGE/lab02"
cp -R "$HERE/src/student/." "$STAGE/lab02/"
chmod +x "$STAGE/lab02/install.sh" "$STAGE/lab02/clean.sh" "$STAGE/lab02/check.sh"
( cd "$STAGE" && tar czf "$HERE/lab02.tar.gz" lab02 )

mkdir -p "$STAGE/lab02-ta"
cp "$HERE/ta-guide.md" "$HERE/scoring.md" "$HERE/check-ta.sh" "$STAGE/lab02-ta/"
cp -R "$HERE/answers" "$STAGE/lab02-ta/answers"
( cd "$STAGE" && tar czf "$HERE/lab02-ta.tar.gz" lab02-ta )

PUB="$HERE/../../../labs"
mkdir -p "$PUB"
cp "$HERE/lab02.tar.gz" "$PUB/lab02.tar.gz" && echo "published: labs/lab02.tar.gz (same copy as staff)"
rm -rf "$STAGE"
echo "built: lab02.tar.gz ($(wc -c < "$HERE/lab02.tar.gz") bytes), lab02-ta.tar.gz"
