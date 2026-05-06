---
description: Run a Pre-LOI Forensic Screen — full battery of Beneish M-Score, Benford's Law, EBITDA bridge, journal-entry testing, lapping detection, and working-capital deep dive on a deal. The $7,500 / 72-hour wedge product against Big-4 QoE.
---

# Pre-LOI Forensic Screen

Runs the full forensic-QoE battery on a deal and produces an IC-defensible exclusion schedule with severity-scored findings, dollar impact, and source citations. This is OloLand's wedge product — the deterministic statistical layer of QoE that Big-4 also runs (then layers fieldwork on top of) for 20-50x the price.

## Usage

```
/forensic-screen <deal_id>
```

## Arguments

- `deal_id` (required) — The deal to screen. The deal must have at least: an audited financial statement OR tax return, plus management projections. GL exports and AR aging are required for journal-entry testing and lapping detection.

## Execution

1. Call `analyze_forensic_qoe` from the MCP server with the `deal_id`.
2. The engine runs every primitive whose required inputs are present:
   - **Beneish M-Score** — earnings-manipulation probability, private-company adjusted
   - **Benford's Law** — first-digit anomaly testing on GL transactions
   - **EBITDA bridge** — adjustment classifier (one-time / pro-forma / questionable)
   - **Journal-entry testing** — period-end concentration, round-number anomalies
   - **Lapping detection** — AR cycle anomalies indicating receivables fraud
   - **Working-capital deep dive** — DSO/DPO/DIO trend + quality scoring
   - **Revenue quality deep dive** — concentration, hockey-stick, cut-off testing
3. Each finding includes severity (low/medium/high/critical), dollar impact estimate, and a citation back to the source document and page.
4. Output is the structured exclusion schedule — what gets excluded from headline EBITDA, what gets flagged for management Q&A, what kills the bid.

## Output structure

For each primitive:
- **Result** — pass / warning / fail
- **Numeric finding** — e.g. M-Score = -1.42 (low manipulation likelihood) or Benford χ² = 47.3 (significant deviation, p<0.001)
- **Adjustments** — line-by-line additions/subtractions to reported EBITDA with $ amounts
- **Evidence** — citations to source pages
- **Recommendation** — proceed / proceed with caveats / kill

## Why this matters

A Pre-LOI Forensic Screen catches the deals that should be killed *before* you spend $200K on full DD and 4-8 weeks on Big-4 QoE. The math layer is identical to what Big-4 runs in their Quality-of-Earnings opinion. You pay Big-4 for fieldwork, a partner sign-off, and E&O coverage — not the math. We sell the math at software margins, with full methodology disclosure.

## Example

```
/forensic-screen deal_acme_2026
```

Returns the full screen in 60-90 seconds, formatted as an IC-defensible exclusion schedule with citations.

## Related commands

- `/beneish` — run only Beneish M-Score
- `/benford` — run only Benford's Law on GL
- `/ebitda-bridge` — run only EBITDA bridge with adjustment classifier
- `/journal-test` — run only journal-entry anomaly tests
- `/lapping-check` — run only AR lapping detection
