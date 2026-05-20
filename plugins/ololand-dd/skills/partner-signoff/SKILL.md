---
name: ololand-dd-partner-signoff
description: "Use before any OloLand deal artifact leaves the platform under the firm's name — IC memo, regulator export, RWI underwriter packet, LP-bound deal dossier, or any signed PDF that carries deterministic valuation numbers. Enforces an explicit partner approval step before the artifact is finalized."
---

# Partner sign-off gate

A deal output that leaves OloLand with the firm's name attached is no longer an AI artifact — it is the firm's work product. Before any such artifact is finalized, the agent MUST surface a structured sign-off prompt and refuse to mark the artifact "final" until a human with partner-or-above role has approved.

This is the M&A analog of the legal-tech rule that "agents do not operate without lawyer agreement." Translated to private equity, investment banking, and M&A advisory: **agents do not commit a number under the firm's letterhead without partner-or-above approval.**

## When this skill applies

Trigger the sign-off gate when the user requests, or the agent is about to produce, any of:

- An IC memo intended for committee distribution
- A regulator export via `request_regulator_export` / `get_regulator_export`
- An RWI (representations & warranties insurance) underwriter packet
- A final deal dossier intended for LPs, lenders, or insurance counterparties
- A signed PDF that includes a deterministic valuation number (DCF, LBO IRR, MOIC, accretion/dilution figure) under the firm's name
- A merger-readiness sign-off (`get_merger_readiness` → committed export)

Skip the gate for in-platform exploratory artifacts: draft memos still being edited, scratch valuations, internal-only risk reviews, and anything labeled "draft" or "preview".

## The sign-off contract

Before finalizing, emit a structured sign-off prompt with four elements:

1. **Artifact summary** — one sentence describing what is about to be finalized
2. **Load-bearing numbers** — every dollar figure, multiple, IRR, MOIC, or ratio that appears in the artifact, each with its `[N]` citation
3. **Open items** — any reconciliation gap, missing source, estimated input, or unverified assumption (cite from `check_citation_coverage` and `reconcile_documents` if available)
4. **Partner ask** — an explicit request: "Partner approval required before this artifact is committed. Reply APPROVE, REJECT, or REQUEST CHANGES."

## Discipline

- **Do not auto-approve.** Synthesized acknowledgments ("ok looks good", "fine") are not sign-off — the user must type the approval token explicitly.
- **Do not silently downgrade severity.** If the artifact carries a Beneish or JE finding at severity ≥ 7, the sign-off prompt MUST name it.
- **Do not finalize on partial reconciliation.** If `check_citation_coverage` reports any claim without a source, OR if `reconcile_documents` flags an unresolved cross-document conflict, the sign-off prompt MUST list each open item before asking for approval.
- **Re-prompt on material change.** A previously-approved artifact whose numbers, sections, or assumptions changed needs a new sign-off.
