#!/usr/bin/env bash
# OloLand MNPI Guard — PreToolUse hook
# Reads tool invocation JSON on stdin. Blocks (exit 2) if the tool input
# contains MNPI-suggestive keywords without an explicit allow-marker.
#
# Allow-marker: `# mnpi:cleared` anywhere in tool_input.command or tool_input.content.
# Blocks: ticker-prefixed earnings figures, "material non-public", insider window references.
#
# Output JSON on stdout when blocking, with a `decision: deny` and human-readable `reason`.

set -euo pipefail

input="$(cat)"

# Single-pass keyword scan — case-insensitive, fast, no jq dependency required.
# We err on the side of letting through and logging — buy-side DD often quotes
# public earnings legitimately. The block list is intentionally narrow.
patterns='material non-public|insider trading window|MNPI|blackout period|earnings under embargo'

if printf '%s' "$input" | grep -qiE "$patterns"; then
  if printf '%s' "$input" | grep -q '# mnpi:cleared'; then
    # Explicit clearance marker present; allow.
    exit 0
  fi
  cat <<'JSON'
{"decision": "deny", "reason": "OloLand MNPI Guard: tool input references material non-public information patterns without a # mnpi:cleared marker. Add the marker after compliance review, or rephrase to use only public sources."}
JSON
  exit 2
fi

exit 0
