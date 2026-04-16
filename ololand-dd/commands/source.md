---
description: Source deals — discover targets, enrich contacts, dedupe against CRM, and draft personalized founder outreach.
argument-hint: "[criteria, e.g. 'industrial services in Texas $10-50M EBITDA']"
---

# Deal Sourcing

End-to-end sourcing pipeline that compounds: every sourced company persists as a lead in the system of record, so the next run dedupes and outcomes feed the flywheel.

## Usage

```
/source <criteria>
```

If no criteria provided, ask the user for sector, geography, size band (revenue or EBITDA), and any negative filters.

## Execution

Load the `deal-sourcing` skill, then run this pipeline:

1. **Discover targets** — `mcp__ololand__search_targets` with the user's criteria. Cap at 25 candidates per run.
2. **Dedupe against CRM** — for each candidate, check Salesforce (via Apollo or direct SF integration) for an existing account or open opportunity. Drop duplicates and surface "already in pipeline" matches separately.
3. **Enrich** — `mcp__claude_ai_Apollo_io__apollo_organizations_enrich` for firmographics; `mcp__claude_ai_Apollo_io__apollo_contacts_search` to find founder/CEO/CFO contacts (one per company, prioritize founder > CEO > CFO).
4. **Find a hook** — for each enriched company, look for a recent signal: funding round, hiring spike, leadership change, news mention. Pull from `mcp__ololand__deep_market_research` or `mcp__ololand__research_market` with company name + last 90 days.
5. **Draft outreach** — for each (company, contact, hook) tuple, draft a 60-90 word email that opens with the specific signal, ties it to the fund's thesis, and proposes a 20-min intro call. Save as Gmail draft via `mcp__gmail__gmail_send_email` with `draft: true` (or the equivalent draft tool).
6. **Persist** — log each candidate as a lead in the OloLand system: company, contact, hook, draft message ID, sourced_at timestamp. This is what compounds.

## Output

Report a table:

| Company | Contact | Hook | Status (new/dup) | Draft ID |

Plus a summary: N discovered, M new (after dedupe), K drafts created.

## After Completion

- Suggest `/dd-analyze <company>` for the most promising target.
- Remind the user: drafts are NOT sent automatically — review in Gmail before sending.
