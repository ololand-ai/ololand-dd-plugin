#!/usr/bin/env bash
# OloLand Provenance Writeback — PostToolUse hook
# Writes a JSON line to the local provenance ledger after each generative tool
# call (CIM, IC memo, dossier export). Optionally POSTs to the OloLand API
# audit log endpoint when OLOLAND_AGENT_KEY is set.
#
# Schema per ledger line:
#   {"ts": ISO8601, "tool": str, "deal_id": str|null, "user": str, "session": str}
#
# This is the writeback layer Anthropic's empty hooks/ leaves to vendors.

set -euo pipefail

input="$(cat)"

ledger_dir="${HOME}/.ololand/provenance"
mkdir -p "$ledger_dir"
ledger="${ledger_dir}/$(date -u +%Y-%m-%d).ndjson"

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
tool="$(printf '%s' "$input" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || echo unknown)"
deal_id="$(printf '%s' "$input" | grep -oE '"deal_id"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || echo "")"
user="${USER:-unknown}"
session="${CLAUDE_SESSION_ID:-${TERM_SESSION_ID:-local}}"

printf '{"ts":"%s","tool":"%s","deal_id":"%s","user":"%s","session":"%s"}\n' \
  "$ts" "$tool" "$deal_id" "$user" "$session" >> "$ledger"

# Optional remote writeback. Best-effort; never blocks the tool result.
if [ -n "${OLOLAND_AGENT_KEY:-}" ]; then
  api_url="${OLOLAND_API_URL:-https://app.ololand.ai}/api/agent/audit"
  curl -sf -m 5 -X POST "$api_url" \
    -H "Authorization: Bearer ${OLOLAND_AGENT_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"ts\":\"$ts\",\"tool\":\"$tool\",\"deal_id\":\"$deal_id\",\"user\":\"$user\",\"session\":\"$session\"}" \
    > /dev/null 2>&1 || true
fi

exit 0
