---
description: "Read the firm's standing institutional playbook attached to this deal — WACC ranges, EV/Revenue and EV/EBITDA ceilings, target IRR, min MOIC, approval thresholds, preferred frameworks, custom rules. Use at the start of any deal turn that produces a number under the firm's name."
---

# /firm-playbook

You are reading THIS firm's standing investment configuration for the deal's tenant. The playbook encodes institutional preferences the firm has codified — they are more authoritative than market-default heuristics. When a playbook value constrains a number you're about to commit to (WACC, exit multiple, target IRR), honor it OR explicitly call out the deviation.

This is distinct from `/playbook-recall`, which surfaces patterns from past similar deals (cross-deal learning). `/firm-playbook` returns the firm's STANDING CONFIG.

## Required inputs

1. **deal_id** — the OloLand deal whose tenant's playbook to recall.

## Action

Call `mcp__ololand__recall_firm_playbook` with the `deal_id`. Render the response in this format:

```
Firm playbook for <deal_id> (resolution: <deal_pin | tenant_default>)

Target criteria:
  Industries: <list>
  Geographies: <list>
  Revenue range: $<min> – $<max>
  Min EBITDA margin: <pct>
  Min growth rate: <pct>

Valuation thresholds:
  Max EV / Revenue: <x>
  Max EV / EBITDA: <x>
  Target IRR: <pct>
  Min MOIC: <x>

Approval thresholds:
  Partner: $<value>
  IC: $<value>
  Board: $<value>

Standard timelines:
  Initial review: <days>
  LOI → close: <days>
  DD period: <days>
  IC review: <days>

Preferred frameworks: <list>

Custom rules:
  - <name>: <condition>  [severity: <high | medium | low>]
```

## Empty-playbook handling

If the response is `playbook: null` (no active playbook configured for this tenant), say so explicitly and recommend the user configure one via the dashboard. **Do NOT fabricate a default playbook.** Fall back to OloLand's market-default methodology for the deal in question.

## Deviation discipline

If the user is about to commit to a number that conflicts with the playbook (e.g. WACC outside the firm's range, exit multiple above the firm's ceiling), surface the conflict before answering. Either:
- Adjust the number to fit the playbook range, OR
- Quote the playbook value and explain the deviation rationale

Silent substitution of OloLand defaults when a playbook is present is a discipline failure.

## Example

```
/firm-playbook deal_acme_2026
```
