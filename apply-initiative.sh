#!/usr/bin/env bash
# Adds the Initiative contract to Claude Code and Codex, and retires the dead gentle-ai rule in ~/.cursor/rules.
# Idempotent: running it twice changes nothing the second time. Backs up every file it touches.
set -euo pipefail
TS=$(date +%Y-%m-%d-%H%M)

BLOCK='<!-- local:initiative -->
## Initiative

Answering the question is HALF the job. On every substantive answer:
1. Answer what was asked, directly, first.
2. Then add a short "Próximos pasos" (or "Next steps") section with 1–3 proposals the user did NOT ask for but will likely want next: a risk you noticed, an inconsistency you found while reading, a test worth adding, a cheaper alternative.
3. Each proposal: what, why, and the exact command or file to start from.
4. Recommend ONE as the default. A recommendation, not a survey of every option.
5. If you hit something off while working, report it even if it is out of scope.
6. When you have enough information to act, act. Don'\''t ask permission for reversible, local, in-scope steps.
Skip the section only for trivial one-line answers.
<!-- /local:initiative -->'

add_block() {
  local file=$1
  if rg -q 'local:initiative' "$file"; then
    echo "$file: already has the Initiative block"
    return
  fi
  cp "$file" "$file.bak-$TS"
  printf '\n%s\n' "$BLOCK" >> "$file"
  echo "$file: Initiative block added (backup $file.bak-$TS)"
}

add_block ~/.claude/CLAUDE.md
add_block ~/.codex/agents.md

DEAD=~/.cursor/rules/gentle-ai.mdc
if [ -f "$DEAD" ]; then
  mv "$DEAD" "$DEAD.bak-$TS"
  echo "$DEAD: retired (moved to $DEAD.bak-$TS; Cursor's User Rule replaces it)"
else
  echo "$DEAD: not present"
fi
