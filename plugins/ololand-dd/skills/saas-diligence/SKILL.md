---
name: ololand-dd-saas-diligence
description: "Use when the OloLand deal target is a SaaS, subscription, or recurring-revenue business. Loads SaaS-specific KPI definitions (ARR vs revenue, NRR/GRR, Rule of 40, magic number, CAC payback) and the verifier checklist for software-deal diligence."
---

# SaaS diligence

For SaaS / subscription deals, KPI definitions are load-bearing — wrong ones produce a wrong thesis.

## Canonical KPI definitions

| KPI | Definition | Mistake to avoid |
|---|---|---|
| **ARR** | Annualized contract value of subscription revenue at period end, excluding one-time, services, usage-overage | Counting bookings or TCV as ARR |
| **NRR** | Period-end ARR from prior-period cohort ÷ prior-period ARR (incl. upsell − churn − contraction) | Forgetting contraction |
| **GRR** | NRR but excluding upsell — ceiling 100% | Conflating with NRR |
| **CAC payback** | Fully-loaded S&M ÷ new ARR × gross margin (months) | Excluding marketing or capitalized sales comp |
| **Magic number** | Net new ARR × 4 ÷ prior-quarter S&M | Using gross new ARR (ignores churn) |
| **Rule of 40** | Revenue growth % + EBITDA margin % | Mixing GAAP and adjusted EBITDA |

## Verifier checklist

- [ ] ARR walk reconciles (opening + new + upsell − contraction − churn = closing)
- [ ] NRR cohort methodology disclosed (by dollar/logo, gross/net)
- [ ] ASC 606 revenue policy: multi-element split, ratable vs point-in-time, professional services
- [ ] Deferred revenue trend aligned with ARR
- [ ] Gross margin reconciliation: hosting + CS + 3p SaaS COGS
- [ ] Top-10 customer % of ARR
- [ ] Free-to-paid conversion trended (if PLG)
- [ ] Usage-based revenue volatility separated

## Common red flags

- ARR flat with NRR > 110% → implies massive logo churn
- Gross margin > 85% without breakdown of hosting/CS
- CAC payback < 12 months with growth < 30%
- "Committed ARR" or "ARR ex-pilots" (non-standard)
- One-time services in ARR
- Multi-year prepay treated as full-year ARR

Every KPI reported MUST cite source with `[N]` AND state the methodology used (cohort dollar vs logo, gross vs net). If methodology is not disclosed in source, mark the KPI as "methodology not confirmed."
