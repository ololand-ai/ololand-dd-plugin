---
name: ololand-dd-firm-playbook
description: "Use when the user asks about WACC ranges, IRR targets, max EV/Revenue or EV/EBITDA multiples, approval thresholds, preferred frameworks, or custom rules for an OloLand deal. Reads the firm's standing playbook via `mcp__ololand__recall_firm_playbook` — institutional preferences that are more authoritative than market-default heuristics."
---

# Firm playbook recall

For deals on OloLand, the **firm's standing playbook** encodes the institution's codified preferences: WACC range, target IRR, min MOIC, EV-multiple ceilings, approval thresholds, standard timelines, preferred frameworks, and custom rules (e.g. "flag top-customer concentration > 30%"). When answering deal questions that produce a number under the firm's name, **honor the playbook OR explicitly call out the deviation**.

## When to call

Call `mcp__ololand__recall_firm_playbook(deal_id)` at the start of any substantive turn that will:

- Quote a WACC, terminal growth rate, exit multiple, target IRR, or MOIC
- Compare a deal to a target/criteria threshold (revenue size, growth rate, EBITDA margin)
- Recommend an approval routing (partner / IC / board)
- Apply a custom rule (concentration, leverage, segment exposure)

Skip the call for trivial Q&A (greetings, identity, single-fact lookups) where no number is being committed.

## Distinct from playbook-recall

| Tool | Scope | Returns |
|---|---|---|
| `mcp__ololand__recall_firm_playbook` | THIS firm's standing config | WACC ranges, IRR targets, approval thresholds, rules |
| `mcp__ololand__find_similar_deals` (via `/playbook-recall`) | Patterns from past similar deals | What worked / what didn't / what got missed |

Both can be load-bearing — the first sets the constraint, the second informs how to apply it.

## Deviation discipline

When a playbook value constrains a number you're about to commit to:

1. **In range** — proceed; cite the playbook value as the basis.
2. **Out of range, justified** — quote the playbook value, explain why the deviation is warranted, recommend partner sign-off via `/partner-signoff` if the artifact is IC-bound.
3. **Out of range, unjustified** — adjust the number to fit the playbook range OR refuse to commit and ask the user to confirm the deviation.

Silent substitution of OloLand defaults when a playbook is configured is a discipline failure — the analyst loses the audit trail and the firm loses the confidence signal.

## Empty playbook

If the response is `playbook: null`, the tenant has no active playbook configured. Fall back to OloLand market-default methodology without commentary, AND surface a one-line note in the answer: "Note: no firm playbook configured — using OloLand defaults."
