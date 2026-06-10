#!/usr/bin/env bash
# Universal Kit installer
# Usage:
#   ./install.sh global            -> agents + skills available in every project
#   ./install.sh project /path/to/project  -> scoped to one project
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-global}"

if [ "$MODE" = "global" ]; then
  AGENTS_DIR="$HOME/.claude/agents"
  SKILLS_DIR="$HOME/.claude/skills"
elif [ "$MODE" = "project" ]; then
  PROJ="${2:?Usage: ./install.sh project /path/to/project}"
  AGENTS_DIR="$PROJ/.claude/agents"
  SKILLS_DIR="$PROJ/.claude/skills"
else
  echo "Unknown mode: $MODE (use 'global' or 'project <path>')" >&2
  exit 1
fi

mkdir -p "$AGENTS_DIR" "$SKILLS_DIR"

for f in "$KIT"/agents/*.md; do
  ln -sf "$f" "$AGENTS_DIR/$(basename "$f")"
done

for d in "$KIT"/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "${d%/}" "$SKILLS_DIR/$name"
done

echo "Installed $(ls "$KIT"/agents/*.md | wc -l | tr -d ' ') agents -> $AGENTS_DIR"
echo "Installed $(ls -d "$KIT"/skills/*/ | wc -l | tr -d ' ') skills -> $SKILLS_DIR"
echo "Prompts live in $KIT/prompts/ — paste them, they are not auto-loaded."
