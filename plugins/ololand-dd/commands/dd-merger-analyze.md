---
description: "Run a third-party merger analysis on an announced or rumored acquisition. Use when the user is not a principal in the deal (banker, equity analyst, merger-arb, antitrust counsel, target board, journalist). Pro+ subscription required."
---

# /dd-merger-analyze

You are creating a third-party merger-analysis deal for an announced or rumored acquisition. The user is an *outside observer*, not a principal — distinct from `/dd-analyze`, which assumes the user's firm is the acquirer.

## Required inputs

Ask the user for these if any are missing:

1. **target** — the company being acquired (free text, e.g. "Discover Financial").
2. **acquirer** — the buyer (free text, e.g. "Capital One").

Optional:
- **announced_date** — ISO date (YYYY-MM-DD) of the merger announcement. Used by Lane C to anchor the 8-K window.
- **target_cik** — SEC CIK if known (skips one entity-resolution round-trip).
- **acquirer_cik** — same for the acquirer.

If the user gave a natural-language phrasing ("examine Capital One's acquisition of Discover", "is the X-Y merger accretive?"), parse target + acquirer from it; only ask back if the two companies are not unambiguously identifiable.

## Action

1. Call the OloLand MCP tool `analyze_announced_merger` with `target`, `acquirer`, and optional `announced_date` / CIKs. The tool returns `{deal_id, task_ids, view_url}`.

2. Poll `get_merger_readiness(deal_id=...)` every ~30 seconds until all three sides (target / acquirer / combined) reach at least `medium` tier — or until two minutes pass, whichever is sooner.

3. Surface the deal_id, view_url, and per-side readiness to the user. If any side is still `low` or `missing` after polling, name the missing artifacts and suggest manual uploads (8-K, 10-K, S-4, audited financials, market research).

4. Direct the user to the cockpit (`view_url`) for the five hero tiles — deal terms, premium analysis, accretion/dilution, antitrust HHI, combined-DCF — plus per-side risk and financial tiles.

## Subscription

Pro+ subscription required. Plugin Free / Dev tier users see a tier-gated upgrade CTA at https://app.ololand.ai/settings/billing — surface that link in your reply when the call returns `tier_gated: true`.
