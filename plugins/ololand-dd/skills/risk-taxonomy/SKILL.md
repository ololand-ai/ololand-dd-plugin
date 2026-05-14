---
name: risk-taxonomy
description: Use when assessing, categorizing, or quantifying deal risks — OloLand uses a 246-category institutional risk taxonomy across five dimensions; every surfaced risk must be classified per this framework and quantified rather than left as narrative.
---

# 246-Category Risk Taxonomy

Every risk surfaced from a deal must be classified along five dimensions. Narrative-only risk lists fail the verifier-stack standard.

## The five dimensions

1. **Risk family** — one of: Financial, Commercial, Operational, Legal/Regulatory, Strategic
2. **Risk category** — the specific subcategory within the family (one of the 246 leaf categories — full taxonomy is part of the OloLand backend; representative subset below)
3. **Severity** — Low (1-3), Medium (4-6), High (7-8), Deal-Killer (9-10) on a 10-point scale
4. **Likelihood** — Probability the risk materializes during a 3-year hold (Low / Medium / High)
5. **Financial impact** — Estimated dollar impact band: `<$1M` / `$1-5M` / `$5-25M` / `$25-100M` / `>$100M`

## Key categories by family (representative subset)

**Financial** — revenue concentration, working capital deterioration, covenant breach risk, deferred revenue recognition, related-party transactions, material weakness in controls, going concern, off-balance-sheet liabilities, tax exposure, ASC 606 misapplication

**Commercial** — customer concentration (>20% from one customer = High), pricing pressure, churn acceleration, market saturation, competitive moat erosion, channel partner dependency, regulatory exposure on revenue model

**Operational** — key-person risk, supply chain single-source, supplier concentration, manufacturing capacity, IT system fragility, cyber incident exposure, regulatory compliance gap, key contract auto-renewal exposure

**Legal/Regulatory** — pending litigation, regulatory investigation, IP infringement claims, employment class actions, environmental liability, antitrust scrutiny, change-of-control restrictions, indemnity caps inadequate

**Strategic** — technology disruption, business-model obsolescence, integration risk (for acquirer), retention of key contracts post-close, customer migration to competitor

## Industry overlays

Some categories materially shift severity by industry. The taxonomy carries industry overlays for SaaS, manufacturing, healthcare, services, retail, and financial services:

- **SaaS** — NDR decay, CAC payback, cohort economics, deferred revenue cliff, professional services dependency
- **Manufacturing** — LIFO liquidation, deferred maintenance, bill-and-hold, obsolete inventory
- **Healthcare** — reimbursement dependency, regulatory risk, M&A integration complexity, certificate-of-need exposure

## Output format

Every risk surfaced should look like this:

```
- Family: Financial
  Category: Revenue concentration
  Severity: 8 (High)
  Likelihood: High
  Impact: $5-25M
  Description: Top customer 28% of revenue with no long-term contract
  Source: 10-K p.14, Risk Factors
```

Never surface a risk without categorization. If you cannot classify a risk, the right output is "I observed a potential risk but could not classify it under the 246-category framework. The category that may apply is X; the missing input that would let me classify it is Y."

## Quantification over narrative

Narrative risks ("the company faces competitive pressure") are insufficient. Always:
- Anchor on a numeric severity score
- Anchor on a dollar-impact band
- Anchor on a documented source (use the `source-hierarchy` skill for ranking)

This is what makes a risk register useful in an IC meeting — not the prose around it.
