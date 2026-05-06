---
description: Run journal-entry anomaly testing — period-end concentration, round-number frequency, weekend/holiday entries, and unusual posting patterns.
---

# Journal-Entry Testing

Detects anomalous journal-entry patterns that frequently accompany earnings management or fraud: period-end concentration spikes, round-number frequency above baseline, entries posted by users without authority, weekend/holiday postings, and reversing entries that don't reverse.

## Usage

```
/journal-test <deal_id>
```

## Arguments

- `deal_id` (required) — The deal to test. Requires GL export with timestamps, posting user IDs, and account codes.

## Execution

1. Call `analyze_forensic_qoe` from the MCP server with `deal_id` and `primitives=["journal_entry"]`.
2. The engine runs five tests:
   - **Period-end concentration** — what % of revenue/expense entries land in the last 5 business days of the quarter? Compare to baseline.
   - **Round-number frequency** — what % of entries end in `,000` or `,500`? Above-baseline rates suggest estimation rather than transaction.
   - **Posting authority** — entries posted by users not in the standard authorization list.
   - **Weekend/holiday entries** — material entries posted outside business hours.
   - **Reversing-entry anomalies** — entries flagged "reversing" that never reverse, or that reverse in a different period.
3. Returns flagged entries with severity scoring and a list of the top 20 most anomalous postings.

## Why this matters

Journal-entry testing is the deepest forensic primitive in the QoE arsenal — and the one Big-4 charges the most for. Public-company audit literature (Center for Audit Quality) identifies anomalous JE patterns as the highest-yield fraud indicator. Surfacing them pre-LOI tells you whether the underlying books are reliable enough to bid on.

## Example

```
/journal-test deal_acme_2026
```
