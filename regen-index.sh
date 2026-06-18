#!/usr/bin/env bash
# Regenerate AGENT_INDEX.md after pulling source repos.
set -euo pipefail
K="$(cd "$(dirname "$0")" && pwd)"
OUT="$K/AGENT_INDEX.md"
TMP=$(mktemp)

find "$HOME/.claude/skills/wshobson-agents/plugins" -path "*/agents/*.md" | sort | while read -r f; do
  name=$(basename "$f" .md)
  desc=$(awk '/^description:/{sub(/^description: */,""); print; exit}' "$f" | cut -c1-150)
  echo "$name|$desc|$f"
done | awk -F'|' '!seen[$1]++' | sort > "$TMP"

{
echo "# Agent & Skill Library Index"
echo "_One line per resource. Orchestrator: pick by description, then Read the path for the full definition._"
echo ""
echo "## Specialist agents (wshobson library, deduped)"
awk -F'|' '{printf "- **%s** — %s → `%s`\n", $1, $2, $3}' "$TMP"
echo ""
echo "## Anthropic official skills"
for d in "$HOME"/.claude/skills/anthropic-skills-repo/skills/*/; do
  name=$(basename "$d")
  desc=$(awk '/^description:/{sub(/^description: */,""); print; exit}' "$d/SKILL.md" 2>/dev/null | cut -c1-150)
  echo "- **$name** — $desc → \`${d}SKILL.md\`"
done
} > "$OUT"
rm "$TMP"
echo "Indexed $(grep -c '^- ' "$OUT") resources -> $OUT"
