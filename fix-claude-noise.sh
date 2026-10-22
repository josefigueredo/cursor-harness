#!/usr/bin/env bash
# Cleans up the overlapping instructions in Claude Code's global config.
set -euo pipefail
cd ~/.claude
TS=$(date +%Y-%m-%d-%H%M)
cp settings.json "settings.json.bak-$TS"
cp CLAUDE.md "CLAUDE.md.bak-$TS"

# 1. One output style only (Gentleman); disable the explanatory plugin.
# 4. Hide Claude Code's own commit/PR attribution (replaces deprecated includeCoAuthoredBy).
jq '.enabledPlugins["explanatory-output-style@claude-plugins-official"] = false
    | .attribution = {commit: "", pr: "", sessionUrl: false}' settings.json > settings.json.tmp
mv settings.json.tmp settings.json

# 2. Drop the Engram block: the engram plugin hook and its MCP instructions already inject it.
# 3. Scope superpowers' "invoke a skill before ANY response" rule (user instructions win over skills).
python3 - <<'EOF'
import re, pathlib
p = pathlib.Path.home() / ".claude/CLAUDE.md"
s = p.read_text()
s = re.sub(r"<!-- gentle-ai:engram-protocol -->.*?<!-- /gentle-ai:engram-protocol -->\n?", "", s, flags=re.S)
block = """
<!-- local:skill-scope -->
## Skill scope (overrides superpowers' "before ANY response")

- Invoke a process skill (brainstorming, debugging, TDD, plans) only when the task actually matches it.
- Questions, explanations, introspection and one-step lookups need no skill. Don't announce skills you didn't use.
- Engram memory protocol comes from the engram plugin and MCP; it is not repeated here.
<!-- /local:skill-scope -->
"""
if "local:skill-scope" not in s:
    s = s.rstrip() + "\n" + block
p.write_text(s)
EOF

echo "settings:"; jq '{explanatory: .enabledPlugins["explanatory-output-style@claude-plugins-official"], attribution}' settings.json
echo "CLAUDE.md: $(wc -l < CLAUDE.md) lines (was $(wc -l < "CLAUDE.md.bak-$TS"))"
rg -c 'Engram Persistent Memory' CLAUDE.md || echo "Engram block: removed"
echo "Backups: settings.json.bak-$TS, CLAUDE.md.bak-$TS. Restart Claude Code to apply."
