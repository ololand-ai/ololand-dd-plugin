---
name: deal-session-memory
description: Use when working on a deal across multiple conversation sessions, or when an analyst confirms a fact that should survive beyond the current turn — EBITDA confirmations, sponsor names, IC dates, modeling conventions, deal-specific assumptions. Explains the deal_session_memory store and the institutional pattern that drives "OloLand captures the institution, not the session".
---

# Deal Session Memory

`deal_session_memory` is the table that turns OloLand from a stateless reasoning engine into a persistent deal record. Every fact persisted via `remember_deal_fact` survives across conversation sessions, analyst handoffs, and even LLM-provider changes.

## Why it exists

The marketing claim "OloLand captures the institution, not the session" is load-bearing only if there is somewhere durable to capture *to*. Conversation history is per-session and stale within hours. Document ingestion is per-corpus and doesn't capture analyst judgment. Risk corrections and outcomes have dedicated tables but cover their own narrow domains.

`deal_session_memory` is the catch-all for analyst-confirmed facts. It is the place where you write:

- "FY24 EBITDA is $34.2M, confirmed against the CPA-audited statements" — `ebitda_fy24_confirmed: 34200000`.
- "Sponsor's lead partner is Jim from MidOcean" — `sponsor_lead_partner: "Jim Smith (MidOcean)"`.
- "We're normalizing WC against the 3-year average, not the trailing 12, after partner discussion 2026-05-12" — `wc_normalization_convention: "3yr_average"` with a note.
- "LOI signed 2026-05-20" — `loi_signed_date: "2026-05-20"`.

## Why it is not the conversation log

Conversations are noisy — they contain hypotheses, partial answers, dead-end branches. `deal_session_memory` is the curated subset: only facts an analyst has *confirmed*. The discipline matters; otherwise the recall surface fills with noise and stops being useful.

## Storage shape

| Field | Constraint |
|---|---|
| `deal_id` | Foreign key to `deals` — facts are deal-scoped, not user-scoped. |
| `company_id` | Inherited from the deal. Multi-tenant isolation. |
| `key` | ≤ 200 chars. Short, stable, kebab-case. |
| `value` | Any JSON value. Scalar, list, or small object. |
| `note` | ≤ 1000 chars. Optional provenance. |
| `updated_at` | Set on every write. |

Re-writing the same `(deal_id, key)` is idempotent — value and note are replaced.

## Institutional pattern

The right workflow on any non-trivial deal session:

1. **Open** — `recall_deal_facts(deal_id)` (or `/recall`) to load every confirmed fact before doing anything else.
2. **Cross-reference** — when the model says something that contradicts a recalled fact, the *fact* wins by default. Investigate the contradiction.
3. **Confirm** — when the user agrees that an AI-surfaced number or claim is correct, `remember_deal_fact` (or `/remember`) it. Don't wait until end-of-session.
4. **Close** — at session end, the next analyst (or you, next week) re-opens by step 1 and inherits everything.

## What NOT to put here

| Wrong table | Belongs in |
|---|---|
| Risks (severity, financial impact, materiality) | `deal_risks` — surfaced via `get_deal_risks`. |
| Materialized risks (post-close outcomes) | `materialized_risks` — surfaced via `record_materialized_risks`. |
| Deal outcome (IRR, MoIC, hold period, etc.) | `deal_outcomes` — surfaced via `record_deal_outcome`. |
| Claim-level AI errors | `analyst_corrections` — surfaced via `submit_agent_claim_correction`. |
| Assumption status (open/blocking/approved) | `deal_assumptions` — surfaced via `set_assumption_status`. |
| Conversation-scoped TODO list | `write_todo` / `update_todo` — turn-scoped, not persistent. |

Putting these in `deal_session_memory` muddies the dedicated surfaces; the flywheel can't train on miscategorized data.

## Companion tools

- `mcp__ololand__remember_deal_fact` — write.
- `mcp__ololand__recall_deal_facts` — read (with optional `keys` filter).
- `mcp__ololand__search_extracted_knowledge` — semantic search over AI-extracted insights (different surface; not analyst-confirmed).

Companion commands: `/remember`, `/recall`.
