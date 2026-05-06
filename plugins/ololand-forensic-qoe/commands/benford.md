---
description: Run Benford's Law first-digit testing on a deal's general-ledger transactions to detect numeric fabrication or selective entry.
---

# Benford's Law

Benford's Law states that in many naturally-occurring datasets, the leading digit follows a logarithmic distribution: ~30% start with 1, ~17% with 2, etc. Significant deviation from this distribution is a classic forensic indicator of fabricated or selectively-entered transactions.

## Usage

```
/benford <deal_id>
```

## Arguments

- `deal_id` (required) — The deal whose GL transactions to test. Requires uploaded GL export with at least 1,000 line items for statistical validity.

## Execution

1. Call `analyze_forensic_qoe` from the MCP server with `deal_id` and `primitives=["benford"]`.
2. The engine pulls all GL transactions from the deal's data room (or from `forensic_extraction_service` if extraction has been run).
3. Computes observed first-digit distribution and compares to Benford expected via χ² goodness-of-fit and Mean Absolute Deviation (MAD).
4. Flags account categories with the most significant deviations.

## Interpretation

- **MAD < 0.012** — close conformity (green)
- **0.012 ≤ MAD < 0.015** — acceptable conformity (yellow)
- **MAD ≥ 0.015** — non-conformity (red — investigate the high-deviation accounts)

## Output

For each account category that deviates significantly from Benford expected:
- Observed vs. expected first-digit distribution (table + chart)
- χ² statistic and p-value
- Top transactions contributing to the deviation
- Suggested follow-up: which specific journal entries to examine

## Why this matters

Benford's Law is the deterministic statistical test most commonly cited in fraud forensics literature. It cannot be evaded by altering totals — it operates on the digit-level distribution of every transaction. Pre-LOI screening with Benford catches the deals where journal entries have been manipulated *before* you commit to fieldwork.

## Example

```
/benford deal_acme_2026
```
