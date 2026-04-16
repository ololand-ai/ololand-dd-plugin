---
name: welcome
description: Show after first OloLand connection. Orients the user with available tools and a suggested first question. Triggered automatically on first successful MCP call.
---

# Welcome to OloLand

You're connected to OloLand's M&A intelligence engine — 39 tools for institutional-grade due diligence.

## What You Can Do

**Ask about deals:**
- "What are the top risks for the Paragon Flight School deal?"
- "Reconcile the revenue figures across the CIM and audited financials"
- "Run a risk-adjusted DCF with sensitivity analysis"

**Run analysis:**
- `/dd-analyze` — Full due diligence workflow (risk + valuation + forensic)
- `/valuation` — DCF, LBO, Monte Carlo, comps
- `/risk-report` — 246-category risk assessment
- `/similar-deals` — Find comparable transactions from deal history
- `/war-game` — Competitive strategy simulation

**CRE underwriting:**
- `run_cre_stress_test` — Multi-scenario stress on debt service coverage
- `run_cre_debt_sizing` — Size loans against DSCR / LTV / debt-yield constraints
- `verify_sponsor_assumptions` — Cross-check sponsor proforma against comps and market data

**Multi-turn conversations:**
- `create_conversation_session` / `list_conversation_sessions` / `get_conversation_session_summary` — Persist context across long-running deal investigations

**Generate documents:**
- `/talk-to-deal` — Conversational deal Q&A
- CIM and investment memo generation

## Try It Now

A sample deal (Paragon Flight School) is loaded in your workspace. Start with:

> "What are the key risks and opportunities for the Paragon Flight School acquisition?"

This will demonstrate OloLand's risk taxonomy, source provenance, and decision framework — the capabilities that generic LLMs can't replicate.
