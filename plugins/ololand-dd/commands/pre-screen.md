---
description: Run a pre-NDA public-company screen — create the deal, ingest filings only (no web search, no news, no merger filings), extract risks, run Monte Carlo, and produce a 1-page pre-screen brief. Designed for "is this public target worth pursuing before we spend diligence dollars?"
---

# Pre-Announcement Public Screen

Run an end-to-end **stage-1** screening of a public company using only its public filings. No NDA, no management projections, no deal-side materials, no current news — by design.

This is the pre-NDA counterpart to `/ic-memo-skeptical`. Where that command refreshes against the latest public 8-K so a stored deal record can't drift stale, `/pre-screen` does the opposite: it deliberately constrains the evidence set to pre-cutoff filings so the output reflects what a sponsor would have seen *before* any transaction was announced. Use it when David's point applies — "would OloLand have told me to pursue this if I'd never heard of the deal?"

## Usage

```
/pre-screen <ticker or company name> [as-of YYYY-MM-DD]
```

## Arguments

- `<ticker or company name>` (required) — Free text. Examples: `GBTG`, `Amex GBT`, `SNOW`, `Snowflake`.
- `as-of <YYYY-MM-DD>` (optional) — Cutoff date. The screen will deliberately ignore any filing, news, or evidence dated after this. If omitted, defaults to today. Provide this whenever you're running a retrospective screen against a public target whose deal has already been announced.

## Why this command exists

`run_due_diligence` and `generate_investment_memo` both fan out to web search by default. That makes them useful for *announced* deals where the announcement IS the most important fact, and useless for *pre-screen* exercises where the announcement is the answer key you're not allowed to peek at.

The Project Atlas / GBTG screen attempt (2026-05-12, `deal554a83ba4a12` for pre-announcement / `deal4fdd2334a0bd` for post-announcement comparison) surfaced the gap:

- `run_due_diligence` populated 134 risks but did not fan out to DCF / LBO / summary tiles
- The post-announcement deal's precedent-transactions tile included the deal being screened as its own comp — direct contamination
- The Forensic Screen SKU correctly refused to run on public-only data, but no single command set up the user to expect this

`/pre-screen` enforces the orchestration that produces a clean stage-1 artifact. It assembles from explicit tile reads with web search explicitly off, frames the Monte Carlo P5↔P95 spread as the value-add (not as an appendix caveat), and tells the user where the public screen stops being enough so they go into stage-2 with the right expectations.

## Orchestration (every step is required; do not skip)

Execute in order. Surface gaps as diligence asks rather than papering over them.

### Step 1 — Resolve the company

1. Call `resolve_company` with the user's query. For clean tickers (`GBTG`, `MSFT`, `BRK.B`) pass `hint="public"`.
2. If multiple candidates come back above 0.7 confidence, list the top 3-5 and ask which one. Don't guess.
3. Capture the picked ticker + CIK + classification.

If the resolver returns `classification != "public"`, halt and tell the user: this command only handles public targets. Private-target pre-screening is a different workflow (no SEC filings, no FMP snapshot, no point pretending we have an audit trail we don't).

### Step 2 — Create the deal

Call `create_deal` with:

- `query` — the user's original text
- `ticker_override` — from step 1
- `cik_override` — from step 1
- `hint` — `"public"`
- `deal_mode` — `"screening"` (this is a screen, not a formal DD setup)

Watch ingestion with `check_task_status` until `state == "SUCCESS"`. Public-filer ingestion typically completes in 15-30s. Capture the resulting `deal_id`.

### Step 3 — Confirm the document set is pre-cutoff and pristine

Call `list_deal_documents(deal_id)`. Expected output: exactly the 10-K from EDGAR plus the FMP financial snapshot. Nothing else.

If you see ANY additional uploaded PDFs (proxy statements, merger communications, 8-K announcement decks, transaction press releases, news articles), halt and tell the user: this deal was pre-seeded with announcement-era materials and is not a clean pre-screen target. Recommend creating a fresh deal via `/new-deal` and trying again on the new ID.

If `as-of` was provided, also verify the 10-K's `filing_date` is before the cutoff. If the most recent available 10-K post-dates the cutoff, walk back to the prior fiscal year's 10-K (the resolver and `create_deal` don't yet support `as-of` natively — surface this as a known limitation and pause for the user's instruction).

### Step 4 — Read the financial spine from explicit tiles

Do NOT call `run_due_diligence` here. It silently fans out to `deep_research` which fires web search. Instead:

- `get_financial_snapshot(deal_id)` — base revenue, EBITDA, net debt, cash, CapEx, growth, margins. Source: FMP snapshot. Inspect the `as_of` date in the response and note in the brief.
- `get_deal_risks(deal_id, limit=150)` — pulls the auto-extraction risks from the 10-K ingestion (typically 100-140 for a public target). Every `source_excerpt` should reference the 10-K filename. If any risk's `file_name` is NOT the 10-K, that's a contamination signal — surface it as a `[gap]` and exclude that risk from the brief.

### Step 5 — Run Monte Carlo

Call `run_monte_carlo_simulation(deal_id, n_simulations=10000, seed=42)`. The fixed seed makes the run reproducible across demos.

In the brief, report:

- Mean / Median EV ($M)
- P5 / P25 / P75 / P95 EV ($M)
- VaR(5%) and CVaR(5%)
- Mean / Median equity value ($M)
- `assumption_provenance` breakdown — which parameters were sourced (revenue, growth, margin, capex, net debt) and which defaulted (typically WACC + terminal growth pre-NDA, because we don't have a comps set yet)
- `assumption_coverage` (target: ≥0.6 for the brief to carry weight)

UNLIKE `/ic-memo-skeptical`, the MC numerics belong in the BODY of this brief, not the appendix. Pre-NDA, the MC distribution **is** the value-add — it makes the cost of pre-NDA uncertainty explicit and lets the sponsor see whether the P95 upside even reaches the rumored or announced price. Caveat the defaulted assumptions inline; don't suppress the numbers.

### Step 6 — Pull the deal indicators tile

Call `get_deal_indicators(deal_id)` and `render_risk_matrix_tile(deal_id)`. These give the categorical risk distribution and deal health score without invoking the heavyweight summary-tile pipeline (which depends on web research).

Report:

- Total risks by severity (high / medium / low)
- Top 3-5 risk categories by count
- 246-taxonomy concentration (where the risks cluster — is this a "Liquidity + Synergies" target, a "Channel Concentration + Privacy" target, etc.)

### Step 7 — Skip Forensic Screen explicitly

Do NOT call `generate_forensic_screen_pdf`. It pre-flights for `financial_snapshot + audit_or_tax_return + management_projections` and will correctly refuse on public-only data. Tell the user this in one sentence:

> The Pre-LOI Forensic Screen (Beneish, Benford, EBITDA bridge, journal-entry testing, lapping detection) is a stage-2 product. It requires management-supplied transaction-level data and runs once the NDA is signed. Pre-NDA, the closest signal is the Revenue Quality risk class flagged from the 10-K — surface that in step 4's risk readout if present.

This isn't a gap; it's the platform design. Framing it as a product clarification is what separates this command from a hacky pre-screen attempt.

### Step 8 — Compose the pre-screen brief

Output a single-page artifact in this exact shape (don't deviate; this layout is what makes the comparison to `/ic-memo-skeptical` legible):

```
# Pre-Announcement Public Screen — {Company Name} ({Ticker})

**As-of:** {cutoff date or "today"}
**Sources:** 10-K dated {filing_date} (period: {period_of_report}) + FMP financial snapshot. No web search, no news, no transaction filings.
**Deal ID:** {deal_id}
**Run:** {ISO timestamp}

## Headline

{One sentence stating the Monte Carlo finding in terms the user asked about. Example: "10,000-scenario Monte Carlo P95 enterprise value: $2.41B. Any deal price above that level depends on assumptions outside what public filings support."}

## Financial spine

| Metric | Value | Source |
|---|---|---|
| Revenue (LTM) | $X.XB | FMP / 10-K |
| EBITDA (LTM) | $XM | FMP / 10-K |
| EBITDA margin | X.X% | derived |
| Net debt | $X.XB | balance sheet |
| Revenue growth (5yr CAGR) | X.X% | historical |
| CapEx % revenue | X.X% | FMP |

## Monte Carlo valuation (10,000 simulations)

| Percentile | Enterprise Value | Equity Value |
|---|---|---|
| P5 | $XXX M | $XX M |
| P25 | $XXX M | $XX M |
| Median | $X.XB | $XX M |
| Mean | $X.XB | $XXX M |
| P75 | $X.XB | $XXX M |
| P95 | $X.XB | $XXX M |

VaR(5%): $XXX M | CVaR(5%): $XXX M | Assumption coverage: XX% (sourced) / XX% (defaulted)

Defaulted assumptions (pre-NDA, no comps set): {list, e.g. "WACC, terminal growth"}. These widen the distribution and are the value-add to compress in stage 2.

## Risk concentration (134 categorized risks from 10-K only)

| Severity | Count |
|---|---|
| High | X |
| Medium | XX |
| Low | XX |

Top 5 risk clusters (by count + materiality):

1. **{Category}** — {one-line summary, sourced from the highest-severity risk in the cluster}. _Source: 10-K, page/section reference._
2. ...

## Where the public screen stops

The following diligence work requires the NDA + data room:

- Forensic QoE (Beneish, Benford, EBITDA bridge, journal-entry testing, lapping detection) — needs management transaction-level data
- Customer concentration top-20 list — 10-K only discloses ">10% of revenue" aggregates
- Covenant cascade modeling under stress — needs full credit agreement, not summary
- Management projections vs. consensus reconciliation — projections aren't public
- Real revenue quality test — needs multi-period transaction data

Each of these maps to a stage-2 workflow. The fact that they aren't here is design, not omission.

## Recommendation

Exactly one of:
- **Pass:** {one-sentence reason — typically "P95 EV below any plausible deal price" or "risk concentration in deal-killer categories"}
- **Pursue to NDA:** {one-sentence reason — typically "P95 EV competitive with reference pricing AND risk clusters look diligence-able"}
- **More public data needed:** {one-sentence reason — typically "assumption coverage below 0.6, surface ambiguity before committing to next step"}

## Stage-2 entry point

If the recommendation is "Pursue to NDA," the user's next command after the NDA closes is:
- `/dd-analyze {deal_id}` for the heavyweight DD pipeline, OR
- `/ic-memo-skeptical {deal_id}` for the defensive memo composition (preferred as of 2026-05-12)
- `/forensic-screen {deal_id}` once management financials are uploaded

Deal summary: https://app.ololand.ai/deals/{deal_id}/summary
```

### Step 9 — Hand off

After presenting the brief, output a short pre-screen audit log:

- **Source set verified:** list of documents in the data room (should be exactly the 10-K + FMP snapshot)
- **Contamination check:** number of risks whose `file_name` was NOT the 10-K (target: 0)
- **MC assumption coverage:** sourced / defaulted breakdown
- **Forensic Screen:** correctly refused (insufficient_inputs) — confirmed stage-2 boundary
- **Cutoff respected:** as-of date used + filing dates verified

The audit log is what differentiates this command from "an LLM read a 10-K and made up some numbers." Always surface it.

## URL Conventions (STRICT)

- Domain is `app.ololand.ai`. Not `.com`. Not any other TLD.
- Deal summary: `https://app.ololand.ai/deals/{deal_id}/summary`
- Risks view: `https://app.ololand.ai/deals/{deal_id}/risks`
- Valuations: `https://app.ololand.ai/deals/{deal_id}/valuations`
- Data room: `https://app.ololand.ai/deals/{deal_id}/dataroom`

When a tool response includes a `view_url`, render verbatim — never construct a URL the tool didn't return.
