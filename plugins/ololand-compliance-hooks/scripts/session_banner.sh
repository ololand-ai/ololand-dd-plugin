#!/usr/bin/env bash
# OloLand session banner — SessionStart hook
# Prints a one-line confirmation that compliance hooks are armed.
# Output is added as conversation context (Claude Code reads stdout from
# SessionStart hooks as additionalContext).

set -euo pipefail

cat <<'BANNER'
[ololand-compliance-hooks armed] PreToolUse MNPI guard active. PostToolUse citation enforcer active (warn mode; set OLOLAND_CITATION_BLOCK=1 to deny). Provenance ledger writing to ~/.ololand/provenance/. Audit log writing to ~/.ololand/audit/. Set OLOLAND_AGENT_KEY to mirror to the OloLand audit API.
BANNER
