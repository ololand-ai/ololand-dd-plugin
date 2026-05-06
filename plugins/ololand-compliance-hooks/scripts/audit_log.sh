#!/usr/bin/env bash
# OloLand Audit Log — Pre/PostToolUse hook for mcp__ololand__* invocations
# Mirrors the call into a local NDJSON audit log so analysts can prove what ran
# during a deal. Argument: "pre" or "post" — the hook phase.

set -euo pipefail

phase="${1:-unknown}"
input="$(cat)"

audit_dir="${HOME}/.ololand/audit"
mkdir -p "$audit_dir"
audit="${audit_dir}/$(date -u +%Y-%m-%d).ndjson"

ts="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
tool="$(printf '%s' "$input" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || echo unknown)"

# Truncate input to first 2KB; the full payload may include large file contents.
trimmed="$(printf '%s' "$input" | head -c 2048 | tr -d '\n')"

printf '{"ts":"%s","phase":"%s","tool":"%s","payload_head":%s}\n' \
  "$ts" "$phase" "$tool" "$(printf '%s' "$trimmed" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '"<json-encode-failed>"')" \
  >> "$audit"

exit 0
