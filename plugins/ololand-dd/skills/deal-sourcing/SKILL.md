---
name: deal-sourcing
description: Use when sourcing M&A or PE deals — discovering target companies from criteria, enriching with contact data, deduping against CRM, and drafting personalized founder outreach. Persists every candidate as a lead so the system compounds across runs.
---

# Deal Sourcing

## Why this exists

Generic "sourcing" prompts produce a list of company names and end there. This skill closes the loop: discovery → dedupe → enrichment → personalized outreach → CRM persistence. The persistence step is what makes it compound — the next sourcing run avoids rework, response rates feed back into target scoring, and won deals close the loop on what criteria actually convert.

## Pipeline

### 1. Discovery
- Use `mcp__ololand__search_targets` with explicit filters (sector, geo, size, ownership type if PE-relevant).
- Cap initial set to 25 per run. Quality > quantity. If user wants more, run again with refined criteria.

### 2. Dedupe
- For each candidate, check the CRM (Salesforce via existing integration). If there's an existing account, classify as `dup` and skip outreach.
- Surface dups in the report — sometimes the user wants to see "we've talked to 12 of these already" as a signal.

### 3. Enrichment
- Firmographics: `apollo_organizations_enrich` (revenue, employees, funding, tech stack).
- Contact: `apollo_contacts_search` filtered by title (`founder`, `ceo`, `cfo`, `head of corporate development`). Pick ONE — don't spam.
- Priority: founder > CEO > CFO > head of corp dev.

### 4. Hook (signal sourcing)
- Use `mcp__ololand__deep_market_research` or `research_market` with the company name + recent timeframe (90 days).
- Look for: funding round, hiring spike, leadership change, product launch, news mention, expansion announcement.
- If no signal found, fall back to a thesis-based hook ("we focus on X, you operate in X") — but flag this row as "weak hook" so the user can decide whether to send.

### 5. Outreach drafting
Format constraints:
- 60-90 words. Hard cap at 100.
- Opens with the SPECIFIC signal ("Saw your Series B in March...").
- One sentence connecting it to the fund's thesis.
- One sentence proposing a 20-min call. No calendar links in the first email.
- Sign-off: from the user.

Save as Gmail draft. Do NOT send.

### 6. Persistence
Call `mcp__ololand__log_sourced_lead` for each candidate:
- `email` + `name` + `company` from Apollo enrichment
- `sourcing_hook` — the signal sentence used in the draft
- `sourcing_criteria` — the user's original criteria (for "what worked" analysis)
- `apollo_enrichment_data` — full Apollo payload (stored as JSON)

LeadService auto-dedupes on email+source. If the lead already exists, it merges
the new enrichment data. The next sourcing run will see this lead and skip it.

This is the compounding step. Do not skip it.

## Output format

Always produce a markdown table:

```
| Company | Contact | Hook | Status | Draft ID |
|---------|---------|------|--------|----------|
| ...     | ...     | ...  | new    | abc123   |
```

Plus a summary line: `Discovered N • New M • Dups K • Weak-hook L • Drafts created M`.

## Anti-patterns

- **Do not auto-send.** Drafts only. Always.
- **Do not enrich more than 1 contact per company.** Multi-touch on first email is spammy.
- **Do not use generic templates.** If you can't find a hook, flag the row instead of inventing one.
- **Do not skip dedupe.** Double-emailing a portfolio CEO is reputationally expensive.
