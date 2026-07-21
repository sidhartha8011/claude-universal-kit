#!/usr/bin/env bash
# Show remaining Z.AI GLM Coding Plan quota.
# Usage: glm-quota.sh [--json]
# Key is read from ~/.claude/.glm-key.
set -euo pipefail

KEYFILE="$HOME/.claude/.glm-key"
[ -f "$KEYFILE" ] || { echo "Missing $KEYFILE — put your Z.AI key in it (chmod 600)." >&2; exit 2; }
KEY="$(tr -d '[:space:]' < "$KEYFILE")"
[ -n "$KEY" ] || { echo "$KEYFILE is empty." >&2; exit 2; }

RESP="$(curl -s -m 20 "https://api.z.ai/api/monitor/usage/quota/limit" \
  -H "Authorization: Bearer $KEY" -H "Accept: application/json")" || {
    echo "Could not reach the Z.AI quota API." >&2; exit 1; }

if [ "${1:-}" = "--json" ]; then echo "$RESP"; exit 0; fi

command -v jq >/dev/null || { echo "$RESP"; exit 0; }

echo "$RESP" | jq -r '
  if .success != true then "Z.AI error: \(.msg // "unknown")"
  else
  def bar(p): (p/5|floor) as $f
    | "[" + ("#"*$f) + ("."*(20-$f)) + "]";
  def when(ms): ((ms/1000) - now) as $s
    | if $s <= 0 then "now"
      elif $s < 3600 then "in \(($s/60)|floor)m"
      elif $s < 86400 then "in \(($s/3600)|floor)h \((($s%3600)/60)|floor)m"
      else "in \(($s/86400)|floor)d \((($s%86400)/3600)|floor)h" end;
  # Label a window by how far away its reset is — robust to unit-code changes.
  def wname(ms): ((ms/1000) - now) as $s
    | if $s < 21600 then "5-hour window"
      elif $s < 691200 then "weekly quota"
      else "monthly quota" end;

  "GLM Coding Plan — \(.data.level | ascii_upcase)",
  "",
  ( .data.limits[]
    | if .type == "TOKENS_LIMIT" then
        "\(wname(.nextResetTime) | . + (" " * (14 - length)))  \(bar(.percentage)) \(.percentage)% used   resets \(when(.nextResetTime))"
      else
        "MCP tools      \(bar(.percentage)) \(.remaining)/\(.usage) left     resets \(when(.nextResetTime))"
      end
  ),
  "",
  ( [ .data.limits[] | select(.type=="TOKENS_LIMIT") | .percentage ] | max ) as $worst
  | if $worst >= 90 then "⚠  Nearly exhausted — expect worker runs to fail mid-task."
    elif $worst >= 70 then "⚠  Running low — keep delegated tasks small."
    else "Headroom is fine." end
  end'
