---
name: financial-valuation
description: Use when performing financial valuations, building DCF/LBO models, running Monte Carlo simulations, or analyzing comparable transactions. Provides deterministic valuation framework with strict unit enforcement.
---

# Financial Valuation Methodology

## Deterministic Engines (Not LLM-Generated)

OloLand uses validated computation engines for all financial models. Never generate financial model outputs as prose — use MCP tools.

### DCF (Discounted Cash Flow)
- **Tool**: `get_dcf_valuation(deal_id)`
- **Engine**: EBITDA → Free Cash Flow projection (5-10 years) → Terminal value (perpetuity growth) → WACC discount
- **WACC**: CAPM-calculated (risk-free rate + beta * equity risk premium + size premium)
- **Sensitivity**: Revenue growth rate vs EBITDA margin vs terminal growth rate
- **Unit system**: `StrictFinancialValue` — ACTUAL dollars in storage, MILLIONS in calculation, Smart B/M/K in display

### LBO (Leveraged Buyout)
- Multi-tranche debt: Senior, Mezzanine, Subordinated, Revolver
- Cash sweep ordering: Revenue → Operations → Debt repayment → Equity
- PIK (Payment-in-Kind) toggle per tranche
- Leverage covenants: Total leverage ratio, interest coverage ratio
- Returns: IRR and MOIC at exit under multiple scenarios

### Monte Carlo Simulation
- **Tool**: `run_monte_carlo_simulation(deal_id, num_iterations)`
- Vectorized stochastic engine (not loop-bound)
- Distribution support: Normal, LogNormal, Triangular
- Gaussian copula for correlated variables
- Output: Full EV/equity distribution + P5/P25/P50/P75/P95 + VaR/CVaR

### Comparable Analysis
- Trading multiples: EV/Revenue, EV/EBITDA, P/E
- Precedent transactions: Recent M&A deal premiums
- Peer selection by industry, size, geography, margin profile

## Cross-Document Reconciliation

Before any valuation, verify input data consistency:
- Compare revenue/EBITDA across: CIM, audited financials, management model, tax returns
- Source hierarchy: CPA audited > tax return > management model > AI extracted
- Flag discrepancies > 2% spread
- Use reconciled (highest-confidence) values for models

## Risk-Adjusted Valuation

Every valuation must incorporate risk findings:
1. Identify top 3 risks from risk analysis
2. Quantify dollar impact per risk (which line items, how much, when)
3. Adjust base case assumptions accordingly
4. Run sensitivity analysis on risk-driven variables (not arbitrary)
5. Present risk-adjusted range alongside base case
