#!/usr/bin/env bash
# Launch Claude Code against GLM (Z.AI) — terminal only, per-process.
# Nothing is written to settings.json, so the Desktop app and every other
# session stay on Anthropic. Key is read from ~/.claude/.glm-key.
# Usage: claude-glm [any normal claude args]
set -euo pipefail

KEYFILE="$HOME/.claude/.glm-key"
[ -f "$KEYFILE" ] || { echo "Missing $KEYFILE — put your Z.AI key in it (chmod 600)." >&2; exit 1; }
key="$(tr -d '[:space:]' < "$KEYFILE")"
[ -n "$key" ] || { echo "$KEYFILE is empty." >&2; exit 1; }

# opus alias -> flagship (driver / coherence); sonnet -> cheaper worker tier,
# so /worker's sonnet|opus routing still means two different models.
exec env \
  ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7" \
  API_TIMEOUT_MS="3000000" \
  claude "$@"
