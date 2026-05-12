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
4. **Classify each primitive output as `gap` vs `finding` before composing the analyst-facing summary.** This is the single most important narrative step — and the one the Project Atlas Claude memo got wrong by presenting `Not computed` Beneish/Benford results as if the engine had concluded "no anomalies." Use this taxonomy verbatim:
    - **`finding`** — the primitive ran end-to-end on adequate input data and returned a quantitative result (M-Score = -1.42, Benford χ² = 47.3, lapping rate = 3.2%). The result is IC-evidence: pass/warning/fail, cited, can be argued.
    - **`gap`** — the primitive returned a status in `{insufficient_data, insufficient_sample, not_reliable, unavailable, not_computed}`. This is NOT a clean bill of health and MUST NOT be presented as one. It is a **diligence ask** — name the missing data class (e.g. "GL extract ≥30 line items", "two comparable annual periods", "AR sub-ledger with customer aging") and surface it as a gating condition.
   The narrator MUST label each primitive at the top of its section with `[finding]` or `[gap]`. Memos that pattern-match `Result: Not computed → Implication: cannot rely on M-Score` are correct (gap framing); memos that pattern-match `Beneish M-Score: -2.0 (low likelihood)` when status was insufficient_data are wrong (false-clean framing).
5. Output is the structured exclusion schedule — what gets excluded from headline EBITDA, what gets flagged for management Q&A, what kills the bid. Gaps (from step 4) appear in the Open Questions section, NOT the exclusion schedule.

## Output structure

For each primitive:
- **Classification** — `[finding]` (engine ran, result computed) or `[gap]` (engine returned insufficient_data / not_reliable / unavailable)
- **Result** — pass / warning / fail (for findings) OR data-pull ask (for gaps)
- **Numeric finding** — e.g. M-Score = -1.42 (low manipulation likelihood) or Benford χ² = 47.3 (significant deviation, p<0.001). Gaps have no numeric finding; state the missing input class instead.
- **Adjustments** — line-by-line additions/subtractions to reported EBITDA with $ amounts. Gaps contribute zero adjustments; they contribute open questions.
- **Evidence** — citations to source pages (findings) OR a list of the document classes that would unblock the primitive (gaps)
- **Recommendation** — proceed / proceed with caveats / kill (findings) OR request-data-then-rerun (gaps)

## Why this matters

A Pre-LOI Forensic Screen catches the deals that should be killed *before* you spend $200K on full DD and 4-8 weeks on Big-4 QoE. The math layer is identical to what Big-4 runs in their Quality-of-Earnings opinion. You pay Big-4 for fieldwork, a partner sign-off, and E&O coverage — not the math. We sell the math at software margins, with full methodology disclosure.

## Example

```
/forensic-screen deal_acme_2026
```

Returns the full screen in 60-90 seconds, formatted as an IC-defensible exclusion schedule with citations.

## When the user wants the PDF deliverable

If the user asks for "the Pre-LOI Screen PDF," "the IC deliverable,"
"a downloadable forensic report," "send me the PDF," or any phrasing
that implies they want a paste-into-IC document rather than just
structured analysis:

1. Invoke `generate_forensic_screen_pdf(deal_id, with_scenario_defense=True)`.
2. The tool returns `{"job_id": "...", "status": "queued"}`. Poll status
   with the standard forensic job-status endpoint until status becomes
   `completed`.
3. When complete, the response includes a `pdf_url` signed URL the user
   can download.

The PDF includes 7 sections:

1. **Cover** — deal name, run ID, source-document inventory
2. **Executive Summary** — 3-5 bullet deal-killer findings, severity-ordered
3. **Cross-Doc Reconciliation Receipts** — the hero. Every line item with
   source-hierarchy provenance: CPA-audited > tax-return > management >
   AI-extracted
4. **Forensic Findings** — Beneish M-Score, Benford's Law, EBITDA bridge,
   lapping detection
5. **Scenario Defense Insert** — P10/P50/P90 IRR distribution + covenant
   cascade graph + top-3 falsifying scenarios (Pillar 2)
6. **Risk Taxonomy** — top 10 of 246 risk-taxonomy hits, severity-ordered
7. **Methodology + Provenance** — methodology footer with input hash and
   model versions for reproducibility

Credit cost: **50** (vs. 10-15 for engine-only tools — this is the
premium SKU; the $7,500/72-hr price is sold via the HTTP route + Stripe).

The PDF is the IC-paste-ready artifact. `analyze_forensic_qoe` (the
older tool) returns structured findings text — useful for in-conversation
analysis but NOT the SKU deliverable. When in doubt, ask the user
whether they want "the analysis" (use `analyze_forensic_qoe`) or "the
PDF" (use `generate_forensic_screen_pdf`).

## Related commands

- `/beneish` — run only Beneish M-Score
- `/benford` — run only Benford's Law on GL
- `/ebitda-bridge` — run only EBITDA bridge with adjustment classifier
- `/journal-test` — run only journal-entry anomaly tests
- `/lapping-check` — run only AR lapping detection
