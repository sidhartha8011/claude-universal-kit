#!/usr/bin/env bash
# migrate.sh — one-shot cleanup for machines that bootstrapped before ECC was removed.
# Safe to run multiple times.
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
KIT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Claude Universal Kit — migration"
echo ""

# 1. Remove ECC plugin if still in skills
ECC_DIR="$CLAUDE_DIR/skills/ecc"
DISABLED_DIR="$HOME/ecc-disabled"
if [ -d "$ECC_DIR" ]; then
  echo "[1/3] Moving ECC out of ~/.claude/skills/ -> ~/ecc-disabled"
  mv "$ECC_DIR" "$DISABLED_DIR"
  echo "      Done. ECC will no longer load on session start."
else
  echo "[1/3] ECC not found in ~/.claude/skills/ — already removed or never installed."
fi

# 2. Remove ECC from skills source clone if present (prevents regen-index from indexing it)
ECC_CLONE="$CLAUDE_DIR/skills/ecc"
if [ -d "$ECC_CLONE/.git" ]; then
  echo "[2/3] Found ECC source clone at $ECC_CLONE, removing..."
  rm -rf "$ECC_CLONE"
  echo "      Done."
else
  echo "[2/3] No ECC source clone found — skipping."
fi

# 3. Regenerate AGENT_INDEX.md without ECC entries
echo "[3/3] Regenerating AGENT_INDEX.md..."
"$KIT/regen-index.sh"

echo ""
echo "Migration complete."
echo "  - ECC moved to ~/ecc-disabled (safe to delete if you don't need it)"
echo "  - AGENT_INDEX.md regenerated without ECC paths"
echo "  - Restart Claude Code to apply changes"
