---
description: Compose an IC investment memo using the skeptical tile-stitching pattern — public-facts refresh, individual engine tiles, web fetches, and explicit gap-vs-finding framing. Refuses to render a memo against a stale stored deal record.
---

# Skeptical IC Memo

Compose an IC-defensible investment memo using OloLand's lower-level tile + web-fetch pattern. Designed to produce the output style that survives IC scrutiny — every $-figure cited, every engine output framed as `[finding]` or `[gap]`, no boilerplate gating conditions, no overtrusted simulation outputs.

This is the **preferred** memo entry point as of 2026-05-12. The high-level `run_due_diligence` + `generate_investment_memo` chain still works but is less defensive: it bundles auto-included engines (war-game), bypasses the public-facts freshness check, and lets the LLM invent verdict labels. `/ic-memo-skeptical` hard-codes the orchestration that produces tighter artifacts.

## Usage

```
/ic-memo-skeptical <deal_id>
```

## Arguments

- `deal_id` (required) — The deal to memo. Works on both public-target (ticker / CIK) and private deals; the public-facts gate only fires when applicable.

## Orchestration (every step is required; do not skip)

Execute in order. The model invoking this command must walk each step, log the result, and surface gaps as diligence asks rather than papering over them.

### Step 1 — Ground the deal record

1. Call `get_deal` to read the stored Deal.value, Deal.stage, ticker, and CIK.
2. **If ticker or CIK is set**, immediately call `fetch_public_deal_facts(deal_id)`. This is the freshness check — `compose_ic_memo(web_facts_required=True)` will refuse to run if you skip it.
3. Inspect the response's `staleness.is_stale`. When `true`, the stored row is older than a recent public 8-K announcement. Surface this as a banner ABOVE the executive summary; do not silently use the stored EV/stage as authoritative. Quote the announcement date and source URL.

### Step 2 — Build the financial spine from tiles, not from a black-box DD pipeline

Call each of these individually. Do NOT call `run_due_diligence`. The point of this command is that the model assembles the memo from explicit tile reads it can each skeptically frame:

- `export_deal_dossier(deal_id)` — financial snapshot, comparable companies, precedent transactions, deal metadata. Inspect `failed_sources`: if non-empty, name those gaps in the memo.
- `get_dcf_valuation(deal_id)` — DCF enterprise value, equity value, WACC, terminal growth. Note whether the run uses a Gordon Growth perpetuity or a transaction-multiple exit; both are valid but produce different EVs.
- `render_risk_matrix_tile(deal_id)` and `get_deal_indicators(deal_id)` — 246-category risk concentration + deal health score. Do NOT paste the raw 85+ risk count; use the ranked clusters that come back in the tile.
- `analyze_forensic_qoe(deal_id)` — Beneish M-Score, Benford's Law, EBITDA bridge, lapping detection. For each primitive, classify the output as `[finding]` (engine ran, result computed) or `[gap]` (status in `{insufficient_data, insufficient_sample, not_reliable, unavailable, not_computed}` — diligence ask, not clean bill of health).
- `find_similar_deals(deal_id)` — institutional memory check. If the response is `status: "no_usable_corpus"`, say so explicitly; do not fabricate a cohort.

### Step 3 — Web-fetch the current public record

For deals with a ticker:
- Fetch the most recent 10-K and Q-most-recent earnings release directly from SEC EDGAR or the company investor-relations page.
- Fetch the transaction announcement press release if `fetch_public_deal_facts.facts.inferred_stage == "announced"`.
- Cross-check the dossier's `revenue`, `ebitda`, `net_debt`, `cash` against the public filing. If they disagree by more than 2%, note as a reconciliation gap.

For private deals, skip this step. The freshness gate doesn't apply.

### Step 4 — Run Monte Carlo and forensic strictly as diligence prompts

- `run_monte_carlo_simulation(deal_id)` — inspect `assumption_provenance` per parameter. When `default_used` is true on 2+ of revenue_growth / ebitda_margin / wacc / terminal_growth, present the MC output as **sensitivity analysis ONLY** — do not cite mean / median / P5 / P95 / VaR / CVaR numerics in the main memo body. Caveat that the distribution reflects default priors and is not a defended forecast. Appendix-only.
- DO NOT invoke `run_war_game_simulation` from this command. War-game is opt-in; the user has to ask for it explicitly. The robustness score is a composite (35% EV stability + 35% path consistency + 30% tail resilience), not a probability, and pasting "base case is robust at 74%" as IC evidence is the exact failure mode this command exists to prevent.

### Step 5 — Generate the memo with the freshness gate ON

Call `compose_ic_memo(deal_id, web_facts_required=True)`. This is the gated replacement for `generate_investment_memo`. It will refuse to render if step 1's freshness check was skipped or expired.

Poll `check_task_status` until the task completes. When complete, fetch the memo and verify the following before presenting it to the user:

1. The Executive Summary opens with the staleness banner (if `staleness.is_stale` was true in step 1).
2. The Recommendation section opens with exactly one of `Pass:` / `Needs More Data:` / `Conditional Go:` / `Go:` (verbatim, with colon). The post-process audit will rewrite an invented label like "CONDITIONAL GO" to canonical casing, but flag if you see one.
3. Every headline $-figure (revenue, EBITDA, debt, EV, transaction value) is followed by a `[source: X]` suffix. Un-cited figures are logged to `metadata.citation_audit` — surface the count to the user.
4. The Conditions Precedent list under the Recommendation cites the engine signals each condition came from. No boilerplate "obtain legal opinion" unless tied to a specific finding.
5. Monte Carlo numerics do not appear in the main body if MC's `tool_treatment.placement` was "appendix".

If any of the five checks fail, regenerate the memo OR surface the violation to the user — do not paper over it.

### Step 6 — Hand off

Output the memo + a short skeptic's audit log:

- Freshness: `fetch_public_deal_facts` called at <timestamp>; staleness verdict.
- Reconciliation: any discrepancies the dossier vs public filings showed.
- Forensic: list of `[gap]` primitives that need data pulls before bid commitment.
- Citation audit: count of un-cited $-figures (target: 0).
- Derived gating conditions: count by source class (forensic / reconciler / assumption / judgment).

The user gets the memo body AND the audit — the audit is what differentiates this command from `/dd-analyze`.

## Why this command exists

The Project Atlas / GBTG IC memo (2026-05-11, deal4fdd2334a0bd) was generated via `/dd-analyze` → `dd-analyst` Opus sub-agent → `generate_investment_memo`. It shipped with:

- "Initial Outreach / $6.0B" stored deal facts a week after the public $6.3B announcement
- Monte Carlo Mean $1.08B pasted as evidence against deterministic DCF $4.34B (internally contradictory)
- War-game robustness 74% framed as IC evidence
- "CONDITIONAL GO" — an invented verdict label, no matching enum
- Boilerplate conditions precedent untied to engine signals

The root cause is structural: a single high-level template can't be retrofitted with skepticism after the fact. `/ic-memo-skeptical` enforces the orchestration that produces tighter artifacts — at the cost of more tokens per memo, more steps for the user to follow, and no "one command, one PDF" magic.

If the user explicitly asks for the "fast" or "old" path, route them to `/dd-analyze`. Otherwise this is the default.

## URL Conventions (STRICT)

- Domain is `app.ololand.ai`. Not `.com`. Not any other TLD.
- Deal summary: `https://app.ololand.ai/deals/{deal_id}/summary`
- Risks view: `https://app.ololand.ai/deals/{deal_id}/risks`
- Valuations: `https://app.ololand.ai/deals/{deal_id}/valuations`
- IC package: `https://app.ololand.ai/deals/{deal_id}/ic-package`

When a tool response includes a `view_url`, render verbatim — never construct a URL the tool didn't return.
