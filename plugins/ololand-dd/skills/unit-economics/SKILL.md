---
name: unit-economics
description: Use when analyzing SaaS unit economics, cohort retention (NDR/GRR), LTV/CAC, CAC payback, magic number, or rule of 40. Computes deterministic metrics from customer-month transaction data and flags anomalies vs. the seller's stated narrative.
---

# Unit Economics & Cohort Analysis

## What this is (and isn't)

This is **deterministic computation**, not prose. The cohort triangle, retention metrics, and unit-economics ratios come from numpy/pandas in `services/financial/cohort_analyzer.py`. The LLM's job is interpretation, not calculation.

The killer feature is **reconciliation**: when the CIM claims 115% NDR but the cohort data shows 92%, that 23-point spread is the kind of finding that closes IC memos. The `analyze_unit_economics` MCP tool detects these automatically when you pass `stated_*` parameters.

## When to use

- Reviewing a SaaS or recurring-revenue deal
- Validating CIM claims about retention, churn, or sales efficiency
- Building cohort triangles for a quality of revenue analysis
- Stress-testing the LBO base case (does the model assume retention the cohorts don't support?)

## How to use

### Step 1 — Get the stated narrative
Read what the seller claims. Look in:
- The CIM's "key metrics" or "unit economics" section
- Management presentations
- Data room metrics dashboards

Capture:
- NDR (e.g. "115%")
- GRR (e.g. "94%")
- CAC payback months
- LTV/CAC ratio

If the seller doesn't state these, that's itself a finding — note it.

### Step 2 — Load transactions
Format: `[{customer_id, period: 'YYYY-MM-DD', revenue}, ...]` — one row per customer per month.

Sources, in order of preference:
1. Customer-level revenue export from the seller (cleanest)
2. Subscription/billing system export (Stripe, Chargebee, Recurly)
3. Reconstructed from CRM + invoice data
4. Aggregated cohort data (less ideal — you lose granularity)

If you only have aggregated cohort data, the raw cohort triangle CAN'T be recomputed; you'll have to trust the seller's triangle and just compare the headline metrics.

### Step 3 — Estimate LTV/CAC inputs
Pull from financials:
- `sales_marketing_spend` — last 12 months
- `new_customers_in_period` — count of new logos in the same period
- `gross_margin` — as decimal (0.75, not 75)
- `new_arr_in_period` — for magic number (uses quarter-annualized formula)
- `ebitda_margin` and `revenue_growth_yoy` — for rule of 40

If any are missing, the tool returns `None` for that metric — that's fine, partial analysis is still valuable.

### Step 4 — Call the tool
`mcp__ololand__analyze_unit_economics(deal_id, transactions, ...)` with all the inputs.

### Step 5 — Interpret

**On retention spreads:**
- 0-5pp: probably timing/methodology difference, not a finding
- 5-10pp: medium severity, ask the seller about it
- >10pp: high severity, this is a flag for the IC memo

**On payback/LTV ratios:**
- Within ±20% of stated: reconciles
- ±20-50%: medium
- Beyond ±50%: high — the unit economics narrative is broken

**On decay fit:**
- R² > 0.85: clean exponential decay, the cohort behavior is predictable
- R² < 0.7: cohorts behave differently — could be product-market fit changes, segment shifts, pricing changes. Worth investigating.

**On rule of 40:**
- >40: strong
- 20-40: typical
- <20: weak — model the LBO with conservative assumptions

## Anti-patterns

- **Don't compute cohorts in your head from monthly summaries.** Use the engine.
- **Don't ignore anomalies because they're "small."** Even a 5pp NDR spread on a $50M ARR business is $2.5M of phantom revenue in the model.
- **Don't assume LTV-CAC is meaningful for sub-12-month-old cohorts.** The decay fit needs history.
- **Don't blend B2B and B2C cohorts.** Run them separately if the deal has both.
