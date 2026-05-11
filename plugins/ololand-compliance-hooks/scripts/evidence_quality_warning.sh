#!/usr/bin/env bash
# OloLand Evidence Quality Warning — PostToolUse hook
# Reads tool result JSON on stdin. Detects two surfaces from the OloLand
# assumption-controls workflow that warrant a compliance flag (non-blocking):
#
# 1. IC package response carries `approval_evidence_snapshot.warnings` with
#    one or more high-priority assumptions whose evidence_strength is weak
#    or partial. These do NOT block IC approval but the analyst should
#    review them before signing off.
#
# 2. get_assumption_evidence_pack response carries quality_flags with
#    evidence_strength == "none" on tracked high/critical assumptions —
#    these WILL block IC approval (the new tier-2 blocker). Surfacing
#    here gives the compliance audit a session-level breadcrumb.
#
# Reportable, not blocking. The MCP layer already enforces blocker logic;
# this hook just adds an audit trail.

set -euo pipefail

input="$(cat)"

# Detection 1: weak/partial high-priority evidence (warnings, not blockers).
# approval_evidence_snapshot.warnings is a list of objects; if any element
# exists and the list isn't empty, we flag it.
if printf '%s' "$input" | grep -q '"approval_evidence_snapshot"'; then
  warning_count=$(printf '%s' "$input" \
    | grep -oE '"warning_count"\s*:\s*[0-9]+' \
    | head -1 \
    | grep -oE '[0-9]+' || echo "0")
  if [ "${warning_count:-0}" -gt 0 ]; then
    echo "[ololand-compliance-hooks] evidence-quality warning: IC package has ${warning_count} high-priority assumption(s) with weak or partial evidence. Review before approval." >&2
  fi
fi

# Detection 2: unsupported high-priority assumptions (tier-2 IC blocker).
# Pattern is "evidence_strength":"none" co-occurring with a high/critical
# priority in the same quality_flags entry. Cheap substring scan only —
# if the user wants stricter parsing, set OLOLAND_EVIDENCE_STRICT=1 to
# require jq and structured extraction.
if printf '%s' "$input" | grep -q '"quality_flags"'; then
  unsupported_critical=$(printf '%s' "$input" \
    | grep -oE '"evidence_strength"\s*:\s*"none"[^}]*"priority"\s*:\s*"(high|critical)"' \
    | wc -l | tr -d ' ')
  unsupported_critical_alt=$(printf '%s' "$input" \
    | grep -oE '"priority"\s*:\s*"(high|critical)"[^}]*"evidence_strength"\s*:\s*"none"' \
    | wc -l | tr -d ' ')
  total=$((unsupported_critical + unsupported_critical_alt))
  if [ "${total:-0}" -gt 0 ]; then
    echo "[ololand-compliance-hooks] evidence-quality BLOCKER: ${total} tracked high/critical assumption(s) have no evidence attached. IC approval will be blocked until evidence is linked or assumption is accepted with a memo." >&2
  fi
fi

exit 0
