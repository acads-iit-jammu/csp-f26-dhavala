#!/usr/bin/env bash
# Removes ONLY course workspaces from earlier (week,lab) sessions under BASE.
# Pattern-locked: wNN-lNN-{ee,me,mt}-sd with optional -N suffix. Touches nothing else.
# Usage:  ./clean.sh --auto CUR_WEEK CUR_LAB     (called by install.sh)
#         ./clean.sh CUR_WEEK CUR_LAB            (standalone: asks before each removal)
set -u
BASE="${CSP_BASE:-/home/student/csp_labs_f26}"
AUTO=0
[ "${1:-}" = "--auto" ] && { AUTO=1; shift; }
CURW="${1:?usage: clean.sh [--auto] CUR_WEEK CUR_LAB}"
CURL="${2:?usage: clean.sh [--auto] CUR_WEEK CUR_LAB}"

[ -d "$BASE" ] || exit 0
removed=0
for d in "$BASE"/w[0-9][0-9]-l[0-9][0-9]-ee-sd "$BASE"/w[0-9][0-9]-l[0-9][0-9]-me-sd "$BASE"/w[0-9][0-9]-l[0-9][0-9]-mt-sd \
         "$BASE"/w[0-9][0-9]-l[0-9][0-9]-ee-sd-* "$BASE"/w[0-9][0-9]-l[0-9][0-9]-me-sd-* "$BASE"/w[0-9][0-9]-l[0-9][0-9]-mt-sd-*; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  w="${name#w}"; w="${w%%-*}"; w=$((10#$w))
  l="${name#*-l}"; l="${l%%-*}"; l=$((10#$l))
  # earlier session = earlier week, or same week with an earlier lab number
  if [ "$w" -lt "$CURW" ] || { [ "$w" -eq "$CURW" ] && [ "$l" -lt "$CURL" ]; }; then
    if [ "$AUTO" != "1" ]; then
      read -r -p "remove old workspace $name ? [y/N] " a
      case "${a:-N}" in y|Y) :;; *) continue;; esac
    fi
    echo "clean: removing old workspace $name (work should already be bundled out)"
    rm -rf "$d"
    removed=$((removed+1))
  fi
done
[ "$removed" -gt 0 ] || echo "clean: nothing to remove"
