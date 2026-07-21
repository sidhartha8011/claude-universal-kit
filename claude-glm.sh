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
# Strip the Desktop app's OAuth-refresh vars — if they survive into this
# process, Claude Code authenticates with OAuth and z.ai rejects it (401).
exec env \
  -u CLAUDE_CODE_SDK_HAS_OAUTH_REFRESH \
  -u CLAUDE_CODE_SDK_HAS_HOST_AUTH_REFRESH \
  -u CLAUDE_CODE_OAUTH_SCOPES \
  -u CLAUDE_CODE_ENTRYPOINT \
  -u CLAUDE_CODE_CHILD_SESSION \
  -u CLAUDECODE \
  -u ANTHROPIC_AUTH_TOKEN \
  ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
  ANTHROPIC_API_KEY="$key" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7" \
  API_TIMEOUT_MS="3000000" \
  claude "$@"
