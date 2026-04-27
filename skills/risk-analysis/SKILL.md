---
name: risk-analysis
description: Use when analyzing risks for M&A deals, evaluating risk severity, quantifying financial impact of risks, or building risk matrices. Provides the 246-category institutional risk taxonomy with forensic QoE methodology.
---

# Risk Analysis Framework

## 246-Category Risk Taxonomy

### Commercial Risks
Market position, competitive dynamics, customer concentration (top 10 revenue share), revenue sustainability (recurring vs one-time), pricing power, channel dependency, regulatory exposure, supply chain, geographic concentration.

**Industry overlays:**
- **SaaS**: NDR decay, CAC payback, cohort economics, deferred revenue cliff, professional services dependency
- **Manufacturing**: LIFO liquidation, deferred maintenance, bill-and-hold, obsolete inventory
- **Healthcare**: Reimbursement dependency, regulatory risk, M&A integration complexity

### Financial Risks
Liquidity (current ratio, quick ratio), debt capacity (leverage, coverage), profitability (margin trends, quality), revenue quality (recognition policy, deferrals), working capital (DSO/DIO/DPO trends), off-balance-sheet items.

### Legal Risks
Contract enforceability, change-of-control provisions, IP ownership, pending/threatened litigation, compliance (FCPA, GDPR, SOX), environmental liability, employee agreements.

### HR Risks
Key person dependency, management depth, retention risk (turnover trends), compensation benchmarking, cultural integration, union exposure, pending employment claims.

### Technology Risks
Architecture (monolith vs microservices), technical debt, security posture, scalability constraints, platform dependency, open-source licensing, data privacy compliance.

## Forensic Quality of Earnings

When evaluating financial risks, apply these deterministic tests:

1. **Beneish M-Score** (8-variable model): DSRI, GMI, AQI, SGI, DEPI, SGAI, TATA, LVGI. Score below -1.78 = likely manipulation.
2. **Benford's Law**: First-digit distribution test on transaction data. Chi-square goodness-of-fit. Deviations signal potential fraud.
3. **EBITDA Bridge**: Verify every add-back. Non-recurring items must be truly non-recurring.
4. **Revenue Quality Deep Dive**: Recognition timing, bill-and-hold, channel stuffing indicators.

## Risk Severity Scale

| Score | Label | Criteria |
|-------|-------|----------|
| 5 | Critical | Deal-killer. >20% probability of >25% EV impact. Requires structural mitigation or deal restructuring. |
| 4 | High | Material. >30% probability of 10-25% EV impact. Requires price adjustment or contractual protection. |
| 3 | Medium | Significant. Manageable with standard protections (reps & warranties, indemnification). |
| 2 | Low | Minor. Identifiable but unlikely to materially affect valuation or deal structure. |
| 1 | Minimal | Negligible. Standard industry risk, no specific mitigation needed. |

## Cross-Deal Risk Calibration

Before assessing risks, check historical patterns:
- Use `find_similar_deals` to see which risk categories materialized in similar past deals
- Check if the firm's predictions were systematically biased (e.g., underestimating customer concentration risk)
- Adjust severity accordingly — institutional calibration beats generic assessment
