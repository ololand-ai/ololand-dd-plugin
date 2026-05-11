#!/usr/bin/env bash
# OloLand Tier Capacity Warning — PostToolUse hook
# Reads tool result JSON on stdin. Detects OloLand's platform-level circuit
# breaker (TierCapacityExhausted): when the entire tier (e.g. all Free
# accounts combined) has hit the monthly aggregate inference-cost ceiling.
#
# The MCP tool response shape is:
#   {"status": "error", "metadata": {"tier_capacity_exhausted": true,
#    "tier": "free", "current_cents": 9876, "cap_cents": 10000,
#    "upgrade_url": "https://app.ololand.ai/settings/billing"}}
#
# Surfaces a non-blocking compliance flag — Claude continues, the user sees
# the warning, can upgrade. Does NOT block — the underlying MCP call already
# returned an error, so the agent will surface it; this hook adds a
# session-level breadcrumb for compliance/audit.

set -euo pipefail

input="$(cat)"

# Cheap detection: substring match. jq not required.
if printf '%s' "$input" | grep -q '"tier_capacity_exhausted"\s*:\s*true'; then
  tier=$(printf '%s' "$input" | grep -oE '"tier"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  echo "[ololand-compliance-hooks] tier-capacity warning: tier='${tier:-unknown}' has hit the platform-level monthly aggregate ceiling. Upgrade to a paid tier for guaranteed capacity. See https://app.ololand.ai/settings/billing" >&2
fi

exit 0
