---
name: dcf-methodology
description: Use when computing or discussing DCF valuation — establishes OloLand's deterministic DCF conventions (units, defaults, terminal value, WACC, sensitivity bands) so model output is reproducible and comparable across deals.
---

# DCF Methodology

OloLand's deterministic DCF engine has specific conventions. Use these when discussing, requesting, or interpreting DCF output from any OloLand MCP tool.

## Unit system

- **Storage** — `FinancialDataSnapshot` stores values in ABSOLUTE DOLLARS.
- **Calculation** — DCF engine internally works in MILLIONS.
- **Display** — format as smart B/M/K via `format_smart()` (the platform helper).
- Never mix units across periods or inputs without explicit conversion.

## Default assumptions (when not specified by the user or the deal)

- **Tax rate** — 17% (use the deal-specific effective tax rate when filings provide it)
- **CapEx % of revenue** — 5% (override with historical 3-year average when available)
- **Terminal growth rate** — 2.5%
- **WACC** — CAPM-calculated using a deal-specific beta from comps; default to 9.5% if comps unavailable
- **Projection horizon** — 5 years explicit + terminal value
- **Working capital** — % of revenue, projected at the historical average

## Terminal value

- Use Gordon Growth (perpetuity) as the primary method.
- Cross-check with the exit-multiple method (terminal year EBITDA × industry median EV/EBITDA).
- If the two methods diverge by **>25%**, surface the discrepancy and explain which anchor is more credible for this deal.

## Sensitivity

- Always report a sensitivity matrix on WACC (±1.5%) × terminal growth (±0.5%).
- For PE deal review, also report sensitivity on exit-year EBITDA (±20%).

## Interpretation guardrails

- DCF is a scenario, not truth. State the key assumption drivers (revenue growth, EBITDA margin trajectory, terminal multiple).
- If liquidity, covenant, control, or audit evidence contradicts the DCF, the deterministic engines (forensic QoE, scenario defense) override the DCF anchor. Use the `forensic-qoe` skill to find those signals first.
- Surface when a DCF is computed on data flagged for material weakness — that diminishes confidence regardless of the math. Use the `citation-discipline` skill to cite the material-weakness disclosure inline alongside the DCF output.

## Output format

When citing DCF output to a user, include:

- **EV** (smart-formatted, e.g. `$84.3M`)
- **Implied EV/EBITDA multiple**
- **Sensitivity band** (low / base / high EV)
- **Key assumptions used** (WACC, terminal growth, tax rate, CapEx %)
- **A one-sentence credibility note** tying back to evidence from filings — anchored with `[N]` citations to the source documents.

Example:

> DCF Enterprise Value: `$84.3M` base, `$67.1M` low / `$104.2M` high (WACC 9.5% ± 1.5%, terminal growth 2.5% ± 0.5%). Implied EV/EBITDA = 10.9x base. Key driver: revenue growth assumption of 4.5% (5-year CAGR from FY20-FY25 [1]). Credibility caveat: the FY25 financials carry a going-concern qualification [2]; the DCF is a useful scenario but covenant/liquidity evidence should override it for entry-price decisions.
