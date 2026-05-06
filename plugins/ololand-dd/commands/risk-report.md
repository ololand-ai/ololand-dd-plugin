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
3. Query `get_deal/{deal_id}/similar-deals` for institutional patterns from past deals.
4. Build the report:
   - **Risk heatmap**: Probability vs. impact matrix for top 10 risks
   - **Category breakdown**: Risks grouped by dimension (Commercial, Financial, Legal, HR, Tech)
   - **Evidence citations**: Source documents for each risk
   - **Historical patterns**: "In 8 similar deals, this risk category was accurate 82% of the time"
   - **Deal-killer flags**: Risks where system severity <= 2 but analysts historically corrected to >= 4

## Report Format

Present as structured markdown with:
- Summary table (risk name, severity 1-5, probability %, dollar impact, evidence source)
- Color-coded severity indicators
- Institutional memory section (patterns from similar deals)
- Recommended mitigants for Critical/High risks
