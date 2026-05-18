---
name: merger-analysis
description: Use when the user asks to analyze an announced or rumored acquisition between two companies they are not a principal in (banker, equity analyst, merger-arb desk, antitrust counsel, target's board, journalist). Distinct from /dd-analyze, which assumes the user's firm is the acquirer.
---

# Merger Analysis (third-party perspective)

OloLand's `third_party_merger` perspective treats both the target and the acquirer as first-class entities. The user is an *outside observer* — never a principal — and every output frames evidence from both sides.

## Triggering phrases

Invoke `/dd-merger-analyze "<their phrasing>"` whenever the user says any of:

- "examine the acquisition of X by Y"
- "analyze the X-Y merger"
- "is the [deal] accretive?"
- "what's the premium on [deal]?"
- "what's the HHI on [deal]?"
- "could [deal] survive antitrust review?"

If the phrasing is ambiguous about which company is the target vs. acquirer, ask back; do not guess.

## What the deal looks like

`/dd-merger-analyze` creates a deal stamped `perspective=third_party_merger` and dispatches three ingestion lanes in parallel:

- **Lane A** — target-side ingestion (10-K, 10-Q, target market intel)
- **Lane B** — acquirer-side ingestion (same)
- **Lane C** — combined-entity artifacts (announcement 8-K, S-4 proxy if filed, antitrust filings)

Each side then carries a per-side data-readiness tier: `high`, `medium`, `low`, or `missing`. The four deterministic engines (premium, accretion/dilution, antitrust HHI, combined DCF) refuse to run when required inputs are missing — they never impute.

## Cockpit hero tiles

After ingestion, direct the user to the cockpit (`view_url`). It exposes five hero tiles plus per-side risk and financial tiles:

1. **Deal terms** — offer mix (cash / stock / mixed), enterprise value, exchange ratio.
2. **Premium analysis** — premium vs unaffected price, 52wk high, 30d VWAP, percentile within sector precedents.
3. **Accretion / dilution** — Year 1/2/3 EPS impact + breakeven synergy threshold.
4. **Antitrust HHI** — pre/post HHI per market definition, DOJ presumptive-challenge flag.
5. **Combined-entity DCF** — pro-forma valuation with synergy delta block.

## Engine usage discipline

- **Engines before prose.** Quote engine outputs; do not state premium / EPS impact / HHI from your own reasoning.
- **Cite per side.** Every numeric claim ends in a citation. Use `[T:N]`, `[A:N]`, `[C:N]` prefixes per the merger-mechanics skill (target / acquirer / combined-entity document).
- **Surface insufficiency.** When a `run_*` engine returns `INSUFFICIENT_DATA`, tell the user which fields are missing and where they would typically come from (e.g., "target unaffected price is unavailable — typically pulled from the 8-K Item 1.01 filing window").
- **Two-sided risk.** Scope every taxonomy-classified risk to a side; never lump "merger risk" without saying whose.
- **Don't pick a side.** Frame "should X have done this deal?" answers as "evidence for/against from each side's perspective." You are not advocating for either principal.

## Companion commands

- `/dd-merger-readiness <deal_id>` — per-side readiness tier + missing-data summary.
- `/dd-merger-rerun-math <deal_id> [--engine ...] [--overrides ...]` — re-run one or all four engines with input overrides (sensitivity analysis, e.g. halved synergies).

## Subscription

Pro+ subscription required for the four engine tools and `/dd-merger-analyze`. `/dd-merger-readiness` is zero-credit (works on any tier including Plugin Free). When a heavier tool returns `tier_gated: true`, surface the upgrade CTA at https://app.ololand.ai/settings/billing in your reply.
