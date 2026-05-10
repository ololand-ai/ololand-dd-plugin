---
description: Prep for a diligence meeting — generate a one-page question list grounded in this deal's actual risks, evidence, and similar-deal patterns. Every question cites a source.
---

# Meeting Prep

Turn a deal's existing analysis into a tailored question list for management presentations, expert calls, customer references, or advisor sessions. Questions are deal-specific, not generic — each one links back to a risk, a document, or a pattern from a similar deal.

## Usage

```
/meeting-prep <deal_id> <meeting_type> [focus]
```

## Arguments

- `deal_id` (required) — The deal the meeting is about.
- `meeting_type` (required) — One of: `management`, `expert`, `customer`, `advisor`.
- `focus` (optional) — Narrow the prep to a workstream: `commercial`, `financial`, `operational`, `tech`. Default: full business.

## Execution

1. **Anchor the deal.** Call `get_deal`, `get_financial_snapshot`, and `get_deal_summary_tiles` to load company profile, current financial snapshot, and AI-generated executive summary / SWOT.
2. **Pull the red flags.** Call `get_deal_risks(severity="high")` and (if any returned) `get_deal_risks(severity="critical")`. For each risk, call `get_evidence_links` to attach the exact document + page that triggered it. These become the "must-ask, probe deeply" questions.
3. **Topic-specific document search.** Call `search_deal_documents` with queries matched to `meeting_type` and `focus`:
   - **management** — `revenue concentration`, `customer churn`, `working capital seasonality`, `EBITDA bridge adjustments`, `org chart and key hires`
   - **expert** — `competitive landscape`, `regulatory tailwinds`, `pricing power`, `substitution threats`
   - **customer** — `contract terms`, `pricing history`, `support quality`, `competing vendors evaluated`
   - **advisor** — `accounting policies`, `unusual treatments`, `restatement history`, `auditor changes`
   Pull 2-3 results per query — anything surprising becomes a question.
4. **Institutional pattern overlay.** Call `find_similar_deals`. For each similar deal, surface:
   - Risks that were systematically under-scored ("In 4/6 similar deals, customer concentration was flagged a tier too low")
   - Questions that caught real issues post-close
   - Valuation ranges to reference live (median EV/EBITDA, revenue multiples)
5. **Compose the one-page prep doc** in this exact structure:

   1. **Meeting logistics** — meeting type, duration suggestion (60-90 min), focus area
   2. **Top 3 objectives** — what you must learn, derived from the highest-severity risks + biggest unanswered question in the data room
   3. **Question list** (15-20 max, prioritized) — grouped by topic, each question annotated with:
      - `[★]` for must-asks (tied to Critical/High risks)
      - `(source: <doc>:<page>)` for questions traceable to a specific document
      - `(pattern: similar deal)` for questions surfaced by `find_similar_deals`
   4. **Benchmarks to reference** — comp valuation ranges from `find_similar_deals`, financial snapshot deltas vs comps from `get_deal_summary_tiles`
   5. **Red flags to probe** — bulleted list of risks with severity score and evidence citation
   6. **Follow-up requests** — documents or data still missing from the data room (derived from `data_quality.missing_critical_data` if surfaced by tools)

## Output Conventions

- Keep the question list to **15-20 questions max** — you won't get through more in a 60-90 min session.
- Lead with open-ended questions, then tighten with specifics ("Walk us through revenue by customer" before "Why did customer X drop 12%?").
- Never invent a citation. If a question can't be tied back to a tool response, mark it `(general)` not `(source: ...)`.
- Always close the question list with: *"What haven't we asked about that we should?"*

## Output URL Conventions (STRICT)

When linking back to OloLand views, the domain is **`app.ololand.ai`** — never `.com`. Use these canonical paths:

- Risks (probe red flags here after the meeting): `https://app.ololand.ai/deals/{deal_id}/risks`
- Data room (file follow-up requests here): `https://app.ololand.ai/deals/{deal_id}/dataroom`
- Deal summary: `https://app.ololand.ai/deals/{deal_id}/summary`

If a tool response gives a `view_url`, render it verbatim. Don't construct URLs the tool didn't return.

## Why This Matters

Generic prep templates produce generic questions. This command grounds every question in *this* deal's actual evidence and *your firm's* prior outcomes — the version of meeting prep an off-the-shelf LLM cannot produce because it has no access to your data room or your historical deal record.
