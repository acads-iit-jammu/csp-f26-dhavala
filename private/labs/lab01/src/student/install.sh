#!/usr/bin/env bash
# CS-1-01 (MO) Lab installer — creates this session's workspace.
# Usage: ./install.sh          (interactive)
# Env overrides (testing/fallback): CSP_BASE CSP_DATE CSP_HOSTNAME CSP_BRANCH CSP_TEAM CSP_ASSUME_YES
set -u

LAB=01                                   # <-- the one line that changes per lab
SEM_START="2026-08-03"                   # Monday of W01
INSTR="sd"

HERE="$(cd "$(dirname "$0")" && pwd)"

say(){ printf '%s\n' "$*"; }
die(){ say "install: $*" >&2; exit 1; }

# ---- flags (equivalent env vars in brackets) ----
while [ $# -gt 0 ]; do
  case "$1" in
    --branch) CSP_BRANCH="${2:?--branch needs ee|me|mt}"; shift 2;;   # [CSP_BRANCH]
    --base)   CSP_BASE="${2:?--base needs a directory}"; shift 2;;    # [CSP_BASE]
    --team)   CSP_TEAM="${2:?--team needs roll number(s)}"; shift 2;; # [CSP_TEAM]
    --yes)    CSP_ASSUME_YES=1; shift;;                               # [CSP_ASSUME_YES]
    -h|--help) say "usage: ./install.sh [--branch ee|me|mt] [--team 'ROLL1 [ROLL2]'] [--base DIR] [--yes]"; exit 0;;
    *) die "unknown option '$1' (try --help)";;
  esac
done

# ---- where workspaces live: lab default, else practice mode at home ----
LAB_BASE="/home/student/csp_labs_f26"
PRACTICE=0
if [ -n "${CSP_BASE:-}" ]; then
  BASE="$CSP_BASE"
elif [ -d /home/student ] && [ -w /home/student ]; then
  BASE="$LAB_BASE"
else
  BASE="$PWD"
  PRACTICE=1
fi
TODAY="${CSP_DATE:-$(date +%F)}"
HN="${CSP_HOSTNAME:-$(hostname)}"

# ---- date arithmetic (python3 on Ubuntu/macOS; GNU date fallback) ----
day_index(){ # days since SEM_START; and ISO weekday of TODAY
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$SEM_START" "$TODAY" <<'EOF'
import sys, datetime as d
a=d.date.fromisoformat(sys.argv[1]); b=d.date.fromisoformat(sys.argv[2])
print((b-a).days, b.isoweekday())
EOF
  else
    local s t
    s=$(date -d "$SEM_START" +%s) || die "need python3 or GNU date"
    t=$(date -d "$TODAY" +%s)
    echo "$(( (t-s)/86400 )) $(date -d "$TODAY" +%u)"
  fi
}

read -r DAYS DOW <<<"$(day_index)"
[ "$DAYS" -ge 0 ] || die "today ($TODAY) is before the semester start ($SEM_START)"
WEEK=$(( DAYS/7 + 1 ))
WW=$(printf 'w%02d' "$WEEK")
LL=$(printf 'l%02d' "$LAB")

# ---- branch inference: room (from hostname) + weekday ----
ROOM=""
case "$HN" in
  cse-lab*-pc*) ROOM="$(echo "$HN" | sed -n 's/^cse-lab\([0-9][0-9]*\)-pc[0-9][0-9]*$/\1/p')";;
esac
BRANCH="${CSP_BRANCH:-}"
if [ -z "$BRANCH" ] && [ -n "$ROOM" ]; then
  case "$DOW-$ROOM" in
    2-4022) BRANCH=ee;;   # Tuesday,  Lab 4022 -> Electrical
    3-4022) BRANCH=me;;   # Wednesday, Lab 4022 -> Mechanical
    3-4021) BRANCH=mt;;   # Wednesday, Lab 4021 -> Metallurgy & Materials
  esac
fi
if [ -z "$BRANCH" ]; then
  if [ -t 0 ]; then
    if [ -z "$ROOM" ]; then
      say "This doesn't look like a lab machine (hostname '$HN') — practice mode."
    else
      say "Could not infer your branch from hostname '$HN' and today's weekday."
    fi
    read -r -p "Which branch are you in? [ee/me/mt]: " BRANCH
  else
    die "cannot infer branch; use --branch ee|me|mt"
  fi
fi
case "$BRANCH" in ee|me|mt) :;; *) die "branch must be ee, me or mt (got '$BRANCH')";; esac

WSNAME="$WW-$LL-$BRANCH-$INSTR"
say "This looks like: week $WW, lab $LL, branch '$BRANCH' (host $HN, $TODAY)."
[ "$PRACTICE" = 1 ] && say "Practice mode: not a lab machine — the workspace will be created right here ($BASE)"
say "Workspace: $BASE/$WSNAME"
if [ "${CSP_ASSUME_YES:-0}" != "1" ] && [ -t 0 ]; then
  read -r -p "Proceed? [Y/n] " ans
  case "${ans:-Y}" in y|Y|"") :;; *) die "aborted";; esac
fi

# ---- clean earlier weeks' litter (pattern-locked, prints every removal) ----
if [ -x "$HERE/clean.sh" ]; then
  CSP_BASE="$BASE" "$HERE/clean.sh" --auto "$WEEK" "$LAB"
fi

# ---- team ----
TEAM="${CSP_TEAM:-}"
if [ -z "$TEAM" ]; then
  [ -t 0 ] || die "set CSP_TEAM='ROLL1 [ROLL2]'"
  read -r -p "Roll number(s) of the team at this machine (1 or 2, space-separated): " TEAM
fi
set -- $TEAM
[ "$#" -ge 1 ] && [ "$#" -le 2 ] || die "a team is one or two roll numbers (got $#)"
for r in "$@"; do
  case "$r" in *[!A-Za-z0-9]*|"") die "roll number '$r' may use letters and digits only";; esac
done
ROLLS="$*"

# ---- create / resume / suffix ----
mkdir -p "$BASE"
WS="$BASE/$WSNAME"
if [ -d "$WS" ]; then
  OLD="$(sed -n 's/^rolls: //p' "$WS/TEAM.txt" 2>/dev/null || true)"
  if [ "$(echo $OLD | tr ' ' '\n' | sort | tr '\n' ' ')" = "$(echo $ROLLS | tr ' ' '\n' | sort | tr '\n' ' ')" ]; then
    say "Same team found here — resuming existing workspace."
  else
    n=2
    while [ -d "$BASE/$WSNAME-$n" ]; do n=$((n+1)); done
    WS="$BASE/$WSNAME-$n"
    say "Another team already used $WSNAME on this machine — using $(basename "$WS")."
    mkdir -p "$WS"
  fi
else
  mkdir -p "$WS"
fi

# ---- populate ----
cp -f "$HERE/starters/"* "$WS/" 2>/dev/null || true
cp -f "$HERE/check.sh" "$WS/check.sh"
chmod +x "$WS/check.sh"
{
  echo "workspace: $(basename "$WS")"
  echo "rolls: $ROLLS"
  echo "date: $TODAY"
  echo "host: $HN"
  echo "user: $(whoami)"
  echo "lab: $LAB"
  echo "week: $WEEK"
  echo "branch: $BRANCH"
} > "$WS/TEAM.txt"

# ---- preflight ----
say ""
say "Preflight:"
if command -v gcc >/dev/null 2>&1; then say "  gcc: $(gcc --version | head -1)"; else say "  gcc: MISSING — call the instructor"; fi
say "  disk: $(df -h "$BASE" 2>/dev/null | awk 'NR==2{print $4" free"}')"
say ""
say "Workspace ready: $WS"
say "Next steps:"
say "  cd $WS"
say "  script session.txt        # start your session recorder FIRST"
say "  ...follow the lab sheet..."
