#!/usr/bin/env bash
# OloLand Citation Enforcer — PostToolUse hook
# Reads tool result JSON on stdin. Scans the output for unsourced numerical claims
# in M&A artifacts (IC memos, CIMs, dossiers, edited markdown).
#
# A "numerical claim" is a $-amount, %, or multiple (e.g. 2.7x). A claim is
# "sourced" if the same line contains a citation token: a markdown link,
# a [Source: ...] tag, a (p. NNN) page reference, or a deal-doc URL.
#
# Logs a warning on stdout when claims are unsourced. Does NOT block —
# enforcement is reportable, not blocking, in v0.1. Set OLOLAND_CITATION_BLOCK=1
# to upgrade to a blocking deny.

set -euo pipefail

input="$(cat)"

# Extract tool_response.content / tool_response.stdout / file content. We don't
# require jq — grep both possible payload fields.
content="$(printf '%s' "$input" | grep -oE '"(content|stdout|file_text|new_string)"\s*:\s*"[^"]*"' || true)"

if [ -z "$content" ]; then
  exit 0
fi

# Lines with a $-amount, percentage, or multiple — but no citation marker on
# the same line. The citation regex matches markdown links, "Source:" tags,
# page refs, and deal-doc URLs.
unsourced=$(printf '%s' "$content" \
  | tr '\\n' '\n' \
  | grep -E '(\$[0-9][0-9,.]*|[0-9]+(\.[0-9]+)?%|[0-9]+(\.[0-9]+)?x)' \
  | grep -vE '\[.*\]\(.*\)|\[Source:|\(p\. [0-9]+\)|app\.ololand\.ai/deal' \
  | head -3 || true)

if [ -n "$unsourced" ]; then
  if [ "${OLOLAND_CITATION_BLOCK:-0}" = "1" ]; then
    cat <<JSON
{"decision": "deny", "reason": "OloLand Citation Enforcer: numerical claims without source citation detected. Add a markdown link, [Source: ...] tag, or (p. NNN) page reference. Block-mode enabled (OLOLAND_CITATION_BLOCK=1)."}
JSON
    exit 2
  fi
  echo "[ololand-compliance-hooks] warning: numerical claims without citations detected. Sample:" >&2
  printf '%s\n' "$unsourced" >&2
fi

exit 0
