---
description: Find similar completed deals from your firm's history — transfer learning insights, accuracy patterns, and valuation benchmarks.
---

# Similar Deals

Find similar completed deals and extract institutional learning patterns.

## Usage

```
/similar-deals <deal_id>
```

## Arguments

- `deal_id` (required) — The current deal to find comparisons for.

## Execution

1. Call `find_similar_deals` from the MCP server.
2. For each similar deal, present:
   - **Deal profile**: Industry, size, type, outcome
   - **Similarity score**: Breakdown by industry (35%), size (25%), type (20%), margin (20%)
   - **Learning insights**:
     - Accuracy patterns: "Revenue projections were overestimated by 15% in 4/6 similar deals"
     - Common risks: "Customer concentration was flagged in 5/6 deals and materialized in 3"
     - Valuation ranges: "Median EV/EBITDA was 8.2x for similar deals"
3. Synthesize actionable recommendations:
   - Which risk categories to watch most carefully
   - Where historical predictions were systematically biased
   - How to calibrate financial assumptions based on past outcomes

## Why This Matters

This is institutional intelligence — knowledge that accumulates across your firm's deal history. It's the compounding advantage that a general-purpose AI cannot provide because it doesn't have access to your prior deal outcomes.
