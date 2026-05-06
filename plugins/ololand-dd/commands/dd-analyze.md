---
description: Run full due diligence analysis on a deal — financial extraction, risk assessment, valuation, and memo generation.
---

# Due Diligence Analysis

Run a comprehensive due diligence analysis on a deal using OloLand's institutional control system.

## Usage

```
/dd-analyze <deal_id> [scope]
```

## Arguments

- `deal_id` (required) — The deal ID to analyze.
- `scope` (optional) — Analysis scope: `full` (default), `financial`, `commercial`, `legal`, `hr`, `tech`.

## Execution

1. Verify the deal exists using the `get_deal` MCP tool.
2. Run `run_due_diligence` with the specified scope. This triggers a multi-agent analysis:
   - Financial statement extraction and validation
   - Risk extraction across 246 categories (5 dimensions: HR, Legal, Tech, Commercial, Financial)
   - Cross-document reconciliation with source hierarchy
   - Forensic QoE analysis (Beneish M-Score, Benford's Law)
3. Monitor progress with `check_task_status`.
4. When complete, summarize findings using `get_deal_summary_tiles`.

## After Completion

Report:
- Total risks extracted (by severity: Critical/High/Medium/Low)
- Top 5 risks with evidence citations
- Financial snapshot (revenue, EBITDA, margins)
- Any data reconciliation discrepancies
- Suggested next steps: `/valuation` for financial modeling, `/risk-report` for deep risk analysis
