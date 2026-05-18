---
description: "Read confirmed facts about an OloLand deal from deal_session_memory. Use at the start of any session about a deal to load the analyst-confirmed context — EBITDA, sponsor, IC date, conventions — without re-asking the user."
---

# /recall

You are reading the persistent fact store for an OloLand deal. Every fact returned was confirmed by an analyst at some point and survives across conversation sessions.

## Required inputs

1. **deal_id** — the OloLand deal whose facts to recall.

Optional:
- **keys** — list of specific keys to filter on (e.g. `["ebitda_fy24_confirmed", "sponsor_name"]`). Omit to recall every fact stored for the deal.

## Action

Call `mcp__ololand__recall_deal_facts` with the `deal_id` and (optionally) `keys`. Render the response in this format:

```
Confirmed facts for <deal_id>:
  <key>: <value>
    Provenance: <note if any>
    Last updated: <updated_at>
```

If the result is empty:

```
No confirmed facts for <deal_id>. Use /remember to start building the deal's persistent record.
```

## When to use

- **At the start of any new session about a deal.** Run `/recall` before doing anything else so you have the analyst-confirmed context loaded before the conversation drifts.
- **Before composing an IC memo or CIM section.** Cross-reference what the corpus says with what analysts have explicitly confirmed; conflicts are signal.
- **When a previous answer feels wrong.** A recalled fact may explain why — e.g. the model is quoting unaudited management figures when the analyst confirmed an adjusted number lives at key `ebitda_fy24_confirmed`.

## When NOT to use

- For information that's pulled from the deal corpus on demand (use `mcp__ololand__search_deal_documents` or `mcp__ololand__search_extracted_knowledge` for that).
- For deal-level metadata (use `mcp__ololand__get_deal` instead).
- As an audit trail for AI claim corrections (use the corrections endpoint — `mcp__ololand__submit_agent_claim_correction`).

## Pairing rule

`/recall` and `/remember` are companions. The institutional-memory pattern:

1. Open a session — start with `/recall <deal_id>`.
2. Do work; surface a fact that the corpus cannot give you.
3. Confirm with the user.
4. `/remember` it.
5. Future sessions start the loop again with `/recall`.

Companion skill: `cmd-recall` (auto-loads). Companion command: `/remember`.
