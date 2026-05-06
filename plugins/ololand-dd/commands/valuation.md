---
description: Run financial valuation models (DCF, LBO, Monte Carlo, Comps) with risk-adjusted assumptions from OloLand's deterministic engines.
---

# Financial Valuation

Run deterministic financial valuation models using OloLand's computation engines.

## Usage

```
/valuation <deal_id> [method]
```

## Arguments

- `deal_id` (required) — The deal ID to value.
- `method` (optional) — Valuation method: `dcf` (default), `lbo`, `monte-carlo`, `comps`, `all`.

## Execution

1. Get current financials with `get_financial_snapshot`.
2. Fetch risk analysis with `get_deal_risks` to identify risk-adjusted assumptions.
3. Run the selected valuation:
   - **DCF**: `get_dcf_valuation` — WACC via CAPM, 5-year EBITDA projections, terminal value, sensitivity analysis
   - **Monte Carlo**: `run_monte_carlo_simulation` — Stochastic valuation with distribution output (P5/P25/P50/P75/P95, VaR, CVaR)
   - **LBO**: Available via deal analysis (entry/exit multiples, debt schedule, IRR/MOIC)
   - **Comps**: Trading multiples and precedent transactions from deal context
4. For `all`: run DCF + Monte Carlo + present combined football field range.

## After Completion

Report:
- Implied equity value range (low/mid/high)
- Key assumptions with sources (WACC, growth rate, terminal multiple)
- Sensitivity table (2-way: WACC vs terminal growth)
- Risk adjustments applied (from risk analysis)
- Comparison to deal price (premium/discount analysis)
- Football field visualization (text-based: DCF range, Monte Carlo P25-P75, Comps range)
