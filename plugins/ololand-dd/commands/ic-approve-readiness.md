---
description: Pre-flight check before IC package approval. Surfaces both blocker tiers (open critical assumptions AND unsupported high-priority assumptions) plus weak-evidence warnings that won't block but should be reviewed.
---

# IC Approve Readiness

IC package approval is gated by two independent blocker tiers:

1. **Open blocking assumptions** — high or critical tracked assumptions still in an unresolved state.
2. **Unsupported high-priority assumptions** — high or critical tracked assumptions whose evidence_strength is `none` (no provenance attached at all).

A separate **weak-evidence warning** surface flags high/critical assumptions whose evidence_strength is `weak` or `partial`. These do NOT block approval, but the IC viewer surfaces them so the analyst knows what to defend.

This command runs the pre-flight check before the analyst attempts to approve.

## Usage

```
/ic-approve-readiness <deal_id>
```

## Arguments

- `deal_id` (required) — The deal whose IC package readiness to assess.

## Execution

1. Call `get_assumption_control_summary` with the `deal_id`.
2. Call `get_assumption_evidence_pack` to retrieve `quality_flags` for the deal.
3. Categorize:
   - **Tier-1 blockers** (resolution required): from `control_summary.blocking_assumptions` — high/critical, status not in {verified, mitigated, invalidated, accepted}.
   - **Tier-2 blockers** (provenance required): from `quality_flags` — high/critical tracked assumptions with `evidence_strength == "none"`.
   - **Warnings** (review recommended, not blocking): from `quality_flags` — high/critical tracked assumptions with `evidence_strength` in {weak, partial}.
4. Render:

   - **Overall readiness**: READY / BLOCKED
   - **Tier-1 blockers** (one row per blocker): `assumption_id`, `statement`, `status`, `priority`, recommended resolution
   - **Tier-2 blockers** (unsupported high-priority): `assumption_id`, `statement`, `missing_links`, recommended source to attach
   - **Warnings** (weak/partial evidence): `assumption_id`, `statement`, `evidence_strength`, why this is weak, what to add to strengthen it
   - **Counts**: `total`, `open`, `blocking`, by `evidence_strength`

5. If READY, also surface the latest IC package's `approval_evidence_snapshot.summary` field (returned on the IC package GET response) — that's the snapshot that will be captured at approval time.

## Why two tiers

The first tier (open blocking assumptions) catches "we still need to verify this." The second tier (unsupported high-priority) catches "we marked this assumption critical but never attached an evidence link" — a different failure mode where the workflow state is closed but the underlying provenance is empty. Both surface here so the analyst sees exactly what stands between the deal and an approved IC.

## Example

```
/ic-approve-readiness deal_acme_2026
```

Returns: "BLOCKED. Tier-1 (2): 'FY27 22% growth requires geo expansion' (unverified, critical) — schedule commercial DD; 'WC normalization $4M' (unverified, high) — pull A/R aging. Tier-2 (1): 'Customer concentration <30% by closing' (status=unverified, evidence_strength=none) — no provenance attached; link the customer-revenue table or mark it accepted with a memo. Warnings (1): 'EBITDA margin sustainable at 22%' (status=verified, evidence_strength=partial) — only one quarter of margin data; consider strengthening with comparables or normalization analysis."

## Related commands

- `/assumption-controls` — interactive review and status transitions for assumption controls
- `/dd-analyze` — full DD synthesis before IC

## Output URL Conventions (STRICT)

Domain is `app.ololand.ai`. Surfaces:
- IC package: `https://app.ololand.ai/deals/{deal_id}/ic-package`
- Assumption controls: `https://app.ololand.ai/deals/{deal_id}/analysis/assumptions`
