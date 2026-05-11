---
description: Generate a structured risk report for a deal — 246-category taxonomy with severity scoring, evidence links, and institutional patterns from similar deals.
---

# Risk Report

Generate a comprehensive risk assessment using OloLand's 246-category risk taxonomy.

## Usage

```
/risk-report <deal_id> [category]
```

## Arguments

- `deal_id` (required) — The deal ID to assess.
- `category` (optional) — Focus on a specific risk dimension: `commercial`, `financial`, `legal`, `hr`, `tech`. Default: all.

## Execution

1. Fetch existing risks with `get_deal_risks` from the MCP server.
2. For each risk, retrieve evidence with `get_evidence_links`.
3. Call `find_similar_deals` for institutional patterns from past deals. If it returns `status: "no_usable_corpus"`, omit the historical-patterns section entirely — do not fabricate one.
4. Build the report:
   - **Risk heatmap**: Probability vs. impact matrix for top 10 risks
   - **Category breakdown**: Risks grouped by dimension (Commercial, Financial, Legal, HR, Tech)
   - **Evidence citations**: Source documents for each risk
   - **Historical patterns** (only if usable cohort exists): "In 8 similar deals, this risk category was accurate 82% of the time"
   - **Deal-killer flags**: Risks where system severity <= 2 but analysts historically corrected to >= 4

## Probability rendering (STRICT)

`get_deal_risks` now returns three probability metadata fields per risk: `probability_source`, `probability_confidence`, and `probability_rendering`. Honor `probability_rendering`:

- `numeric` — render `probability_percent` as a percentage (e.g. "65%"). The probability is source-supported.
- `qualitative` — render as Low / Medium / High. The probability is a severity proxy, NOT a source-supported number. Do NOT show a percentage in this case.

Mixing severity-derived probabilities with source-supported ones in the same percentage column is a false-precision bug; the rendering field exists specifically to prevent that.

## Report Format

Present as structured markdown with:
- Summary table (risk name, severity 1-5, probability per the rendering rule above, dollar impact, evidence source)
- Color-coded severity indicators
- Institutional memory section (patterns from similar deals; omit if no usable cohort)
- Recommended mitigants for Critical/High risks

## Output URL Conventions (STRICT)

When linking to OloLand web app pages in your output, the domain is **`app.ololand.ai`** — never `.com`. Use these canonical paths:

- Risks view: `https://app.ololand.ai/deals/{deal_id}/risks`
- Data room: `https://app.ololand.ai/deals/{deal_id}/dataroom`
- Deal summary: `https://app.ololand.ai/deals/{deal_id}/summary`

Never construct URLs the MCP tool didn't return — if a tool response includes a `view_url` or `link` field, render it verbatim. Otherwise use the templates above.
