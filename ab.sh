#!/usr/bin/env bash
# Runs the initiative A/B (pruebas.md) N times per case and saves each answer under resultados/<date>/runs/.
# Cost per round: 2 Cursor calls, 1 Claude Code call and 1 Codex call. Scoring stays manual (rubric in pruebas.md).
#   ./ab.sh [N] [cases]     e.g.  ./ab.sh 3   or   ./ab.sh 1 "codex claude"
set -euo pipefail
N=${1:-3}
CASES=${2:-"claude cursor-sonnet cursor-codex codex"}
PROMPT='¿Qué hace `Harness/run-in-cursor/ric.py hook`?'
ROOT=~/CurrentCode/SPECKIT
OUT="$(cd "$(dirname "$0")" && pwd)/resultados/$(date +%Y-%m-%d)/runs"
mkdir -p "$OUT"

run() {
  local case=$1 file=$2
  cd "$ROOT"
  case $case in
    claude)        claude -p --model sonnet "$PROMPT" 2>&1 | rg -v '^Permission allow rule' > "$file" ;;
    cursor-sonnet) cursor-agent -p --trust --model claude-sonnet-5-5-medium --output-format text "$PROMPT" > "$file" 2>&1 ;;
    cursor-codex)  cursor-agent -p --trust --model gpt-5.3-codex --output-format text "$PROMPT" > "$file" 2>&1 ;;
    codex)         codex exec --sandbox read-only --skip-git-repo-check -C "$ROOT" -o "$file" "$PROMPT" > /dev/null 2>&1 ;;
    *) echo "unknown case: $case" >&2; return 2 ;;
  esac
}

for i in $(seq 1 "$N"); do
  for case in $CASES; do
    file="$OUT/$case-$i.md"
    if run "$case" "$file"; then
      echo "$case #$i: $(wc -w < "$file" | tr -d ' ') words, next steps: $(rg -ci 'próximos pasos|next steps' "$file" || echo 0)"
    else
      echo "$case #$i: failed (see $file)"
    fi
  done
done
