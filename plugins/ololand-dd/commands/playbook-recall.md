---
description: Pull your firm's playbook for deals like this — what worked, what didn't, what got missed in similar past deals. Wraps cross-deal learning + per-deal outcome metadata.
---

# Playbook Recall

Surfaces your firm's institutional memory on deals like this one. For each similar past deal, returns the playbook moves that worked, the moves that didn't, the risks that were correctly flagged, and (most usefully) the risks that were missed and materialized post-close.

## Usage

```
/playbook-recall <deal_id>
```

## Arguments

- `deal_id` (required) — The current deal to recall playbooks for. Similarity is computed against industry (35%), size (25%), deal type (20%), and margin profile (20%).

## Execution

1. Call `find_similar_deals` from the MCP server with the `deal_id`. Returns up to 8 most similar past deals.
2. **If the response is `status: "no_usable_corpus"`** — stop here. Tell the user explicitly that institutional memory cannot support this deal yet (strict deal-type / sector-family / size-ratio filters couldn't form a usable cohort). Do NOT fabricate a cohort from looser matching.
3. For each similar deal in a usable cohort, walk the `outcome` / `learning_insights` blocks that `find_similar_deals` returns directly:
   - The risk categories that were flagged during DD vs. the risks that materialized post-close
   - The accuracy patterns (where projections were systematically optimistic / pessimistic)
   - The valuation ranges that closed vs. the underwritten range
4. For deeper context on specific past deals, use `get_deal`, `get_deal_risks`, and `get_evidence_links` on the historical deal IDs returned in step 1.
5. Synthesize into a structured playbook recall:

   - **What worked** — moves that recurred across multiple similar deals with positive outcomes
   - **What didn't** — moves attempted but with poor outcomes; treat as anti-patterns
   - **What was missed** — risks that *weren't* flagged during DD but materialized post-close. This is the most valuable section: it surfaces the systematic blind spots in your firm's prior reads of this deal type.
   - **Calibration** — for each metric the current deal is presenting (revenue growth, EBITDA margin, leverage), the historical accuracy of similar deals' projections vs. realizations.

## Why this matters

This is the institutional-memory wedge. A general-purpose AI doesn't have access to your firm's deal history; it can only tell you industry averages. This command tells you what *your firm* learned the last 14 times you saw a deal shaped like this one — including the patterns that consistently get missed in DD and bite later.

## Example

```
/playbook-recall deal_acme_2026
```

Returns: "Across 6 similar industrial-services rollups your firm closed in 2022-2024: revenue projections were overestimated by avg 15%, customer concentration was flagged in 5/6 deals and materialized in 3, integration cost overruns averaged 1.4x management's estimate. Recommended DD pivots: deeper customer interviews, integration cost stress test at 1.5x management base case."

## Related commands

- `/similar-deals` — raw similarity output without playbook synthesis
- `/calibrate-vs-history` — applies historical accuracy patterns to adjust the current deal's projections
