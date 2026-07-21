#!/usr/bin/env bash
# Toggle Claude Code between Anthropic models and GLM (Z.AI).
# Run once -> GLM. Run again -> back to Anthropic.
# Key is read from ~/.claude/.glm-key (never stored in this repo).
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
KEYFILE="$HOME/.claude/.glm-key"
BASE_URL="https://api.z.ai/api/anthropic"

# Opus alias -> flagship (driver, coherence work); Sonnet alias -> cheaper
# model, so /worker's sonnet|opus routing keeps meaning two different tiers.
OPUS_MODEL="glm-5.2"
SONNET_MODEL="glm-4.7"
HAIKU_MODEL="glm-4.7"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

write_settings() {  # stdin = new json
  local tmp; tmp="$(mktemp)"
  cat > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$SETTINGS"
}

current="$(jq -r '.env.ANTHROPIC_BASE_URL // ""' "$SETTINGS")"

if [ -n "$current" ]; then
  jq 'del(.env.ANTHROPIC_BASE_URL, .env.ANTHROPIC_AUTH_TOKEN,
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL, .env.ANTHROPIC_DEFAULT_SONNET_MODEL,
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL, .env.API_TIMEOUT_MS)' \
     "$SETTINGS" | write_settings
  echo "→ ANTHROPIC  (Fable / Opus / Sonnet, Remote Control available)"
else
  [ -f "$KEYFILE" ] || { echo "Missing $KEYFILE — put your Z.AI key in it (chmod 600)." >&2; exit 1; }
  key="$(tr -d '[:space:]' < "$KEYFILE")"
  [ -n "$key" ] || { echo "$KEYFILE is empty." >&2; exit 1; }
  jq --arg k "$key" --arg u "$BASE_URL" \
     --arg o "$OPUS_MODEL" --arg s "$SONNET_MODEL" --arg h "$HAIKU_MODEL" \
     '.env += {ANTHROPIC_BASE_URL:$u, ANTHROPIC_AUTH_TOKEN:$k,
               ANTHROPIC_DEFAULT_OPUS_MODEL:$o, ANTHROPIC_DEFAULT_SONNET_MODEL:$s,
               ANTHROPIC_DEFAULT_HAIKU_MODEL:$h, API_TIMEOUT_MS:"3000000"}' \
     "$SETTINGS" | write_settings
  echo "→ GLM  (/model opus = $OPUS_MODEL, /model sonnet = $SONNET_MODEL)"
  echo "  Note: Remote Control is disabled while on a non-Anthropic endpoint."
fi

echo "Applies to NEW sessions — restart Claude Code (or open a new terminal)."
