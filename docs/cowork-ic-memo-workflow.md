# Claude Cowork IC Memo Workflow with OloLand

Canonical recommendation for running an end-to-end investment committee memo workflow in Claude Cowork (or Claude Code), and where each OloLand plugin fits.

## Plugins to install

From the OloLand marketplace (`ololand-ai/ololand-plugins`):

- **`ololand-dd`** v1.6.1 — core diligence + middle-office assumption controls + IC approval gate
- **`ololand-forensic-qoe`** v0.2.0 — Pre-LOI Forensic Screen wedge
- **`ololand-compliance-hooks`** v0.2.0 — MNPI guard, citation enforcer, audit log, tier-capacity warning, evidence-quality warning (drops into Anthropic's empty `hooks/` scaffold)

Optional shells: Anthropic's `private-equity`, `investment-banking`, `financial-analysis` natives for template scaffolding.

---

## End-to-end workflow

### Phase 0 — Setup (one-time)

- Install plugins from `ololand-ai/ololand-plugins` marketplace
- Connect data sources via Cowork's MCP catalog (per-phase recommendations below)

### Phase 1 — Target intake + market context

Goal: form the initial deal hypothesis with sourcing data and an industry frame.

| Tool | Role |
|---|---|
| PitchBook Premium / CB Insights | M&A transaction comps, sponsor activity, target deal history |
| IBISWorld / S&P Global / LSEG | Industry sizing, growth rates, structure, regulatory backdrop |
| ZoomInfo / D&B | Org structure, key contacts, signal data |
| **ololand-dd: `resolve_company`** | Disambiguate target name → canonical entity ID |
| **ololand-dd: `research_market`** | Market context blended with target-specific search |
| **ololand-dd: `deep_market_research`** | Extended web research + structured synthesis |
| **ololand-dd: `search_targets`** | OloLand's M&A target database for similar companies |
| **ololand-dd: `search_ma_deals`** | Precedent transaction lookup |

### Phase 2 — Document ingest (OloLand IS the pipeline)

Goal: turn a raw VDR — sometimes thousands of documents — into structured, source-attributed, query-able intelligence.

**This is where OloLand's depth shows.** Competing AI tools handle per-document Q&A. OloLand handles corpus-scale ingest with structured extraction.

**OloLand's ingest pipeline:**

- `upload_deal_document` — single-doc upload (PDF, XLSX, DOCX, etc., via URL or base64)
- `run_due_diligence` — kicks off the full corpus extraction pipeline (PDF → Tika → smart-chunking → table classification → Qdrant indexing → multi-extractor pass)
- `list_deal_documents` — VDR index
- `search_deal_documents` — hybrid dense + sparse → RRF fusion → Cohere rerank

**Capabilities competing tools lack:**

- **Smart-chunking with post-chunk table classification** — financial-statement tables aren't naively split mid-cell
- **Cross-document reconciliation** with a hard source hierarchy: CPA audited > tax return > management model > AI extracted. When numbers conflict, the higher-authority source wins; conflicts surface as risks rather than getting silently averaged.
- **Fine-tuned Qwen 3 4B risk extractor** on Vertex AI (model-first, Claude fallback) → feeds the 246-category risk taxonomy
- **Per-extraction provenance attached:** `evidence_strength`, `source_excerpt`, `file_name`, page references — populates the evidence pack the IC approval gate later reads

**Source connectors that FEED OloLand's pipeline (these are inputs, not the pipeline):**

- **Egnyte** — sponsor VDR access
- **Google Drive / SharePoint** — supplementary management decks, side letters
- **Daloopa / Aiera** — SEC filings + earnings transcripts as pre-normalized inputs

### Phase 3 — Financial extraction + valuation models

Goal: build defensible valuations grounded in extracted financials.

| Tool | Role |
|---|---|
| Daloopa / Aiera | Pre-normalized public-company line items + transcript signal |
| FactSet / LSEG / FMP | Comps, precedent transactions, macro |
| **ololand-dd: `get_financial_snapshot`** | Cross-doc reconciled financials with source hierarchy |
| **ololand-dd: `get_dcf_valuation`** | Deterministic DCF with sensitivity tables |
| **ololand-dd: `run_monte_carlo_simulation`** | Stochastic DCF with **per-parameter `assumption_provenance`** (default_used flagged per input) |
| **ololand-dd: `analyze_unit_economics`** | LTV/CAC, cohort retention, ARR mechanics |

**Critical rule from `dd-analyst` agent:** Monte Carlo with `default_used=true` on 2+ of {revenue_growth, ebitda_margin, wacc, terminal_growth} is **sensitivity analysis**, not a defended valuation distribution. Don't promote default-heavy MC output into the IC narrative.

### Phase 4 — Forensic QoE + risk

Goal: catch earnings-quality red flags and surface the 246-category risk register with evidence-graded probabilities.

| Tool | Role |
|---|---|
| **ololand-forensic-qoe** | Beneish M-Score, Benford's Law, EBITDA bridge, journal-entry testing, lapping detection, covenant-cascade analysis. **The Pre-LOI Forensic Screen wedge** — $7,500 / 72 hrs vs Big-4 QoE at $150-500K / 4-8 weeks |
| **ololand-dd: `get_deal_risks`** | 246-category risk taxonomy with `probability_source` / `probability_confidence` / `probability_rendering` (qualitative vs numeric) |
| **ololand-dd: `get_evidence_links`** | Risk → source document mapping |
| **ololand-dd: `analyze_forensic_qoe`** | Aggregated forensic findings tile |
| Moody's / D&B Risk Analytics | External credit signal (optional) |

**Probability discipline rule:** when `get_deal_risks` returns `probability_rendering == "qualitative"`, render Low/Medium/High — never as a percentage. The number is a severity proxy, not a source-supported probability.

### Phase 5 — Memo drafting + IC approval gate

Goal: produce an IC memo that defends every $-figure and survives the approval gate.

**This is where OloLand's middle-office layer is non-substitutable.**

**Mandatory pre-IC workflow (HARD RULE in the `dd-analyst` agent):**

1. **`get_assumption_control_summary(deal_id)`** — if `ic_blocked` is true, do NOT proceed to memo generation. Walk blockers and either resolve via `set_assumption_status` or flag for the analyst.
2. **`get_assumption_evidence_pack(deal_id)`** — inspect `quality_flags`. Any high/critical with `evidence_strength == "none"` will be blocked server-side (tier-2 blocker). Weak/partial high-priority surfaces as a warning in the memo narrative.
3. **`get_ic_package(deal_id)`** — read `approval_evidence_snapshot.warnings` and pre-empt them in the memo.

Then generate:

- **`generate_investment_memo`** — 8-section IC memo
- **`generate_cim`** — sell-side CIM if needed (14 sections)
- **`export_deal_dossier`** — consolidated export

| Plugin Surface | Role |
|---|---|
| **ololand-dd: `/assumption-controls <deal_id>`** | Interactive ledger review + status transitions |
| **ololand-dd: `/ic-approve-readiness <deal_id>`** | Two-tier blocker pre-flight + warnings + snapshot summary |
| **ololand-dd: `/dd-analyze <deal_id>`** | Full DD synthesis |
| Notion | Collaborative memo drafting + circulation |
| Docusign | IC sign-off (optional) |

### Phase 6 — Compliance + audit (cross-cutting)

**`ololand-compliance-hooks` v0.2.0** runs across every phase as PreToolUse / PostToolUse / SessionStart hooks:

| Hook | When | Purpose |
|---|---|---|
| `mnpi_guard.sh` | PreToolUse on Bash/Write/Edit | Block writes/commands that touch MNPI markers |
| `citation_enforcer.sh` | PostToolUse on memo/CIM/dossier + Write/Edit | Flag unsourced $-amounts, percentages, multiples |
| `audit_log.sh` | Pre + Post on `mcp__ololand__*` | Write tool call to local audit trail |
| `tier_capacity_warning.sh` | PostToolUse on `mcp__ololand__*` | Detect `TierCapacityExhausted` platform circuit breaker |
| **`evidence_quality_warning.sh`** *(new v0.2.0)* | PostToolUse on assumption + IC tools | Flag weak/partial high-priority evidence (warning) + unsupported tracked assumptions (tier-2 IC blocker) |
| `session_banner.sh` | SessionStart | Compliance banner on session start |

This plugin populates the **empty `hooks/` scaffold** Anthropic's `private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, and `wealth-management` plugins ship with.

Optional adjuncts:

- **Harvey** — legal review for material risk language
- **Vanta** — security/SOC2 posture for tech deals

---

## Why this stack (vs. Anthropic-natives-only)

Anthropic's native finance plugins ship workflow templates and connectors. They get the analyst to **"draft memo."** They do NOT:

1. Ingest a thousand-doc VDR with structured extraction (per-document Q&A only)
2. Reconcile conflicting numbers across CPA-audited / tax-return / management-model versions with a hard source hierarchy
3. Attach extracted financial values to deterministic DCF / LBO / Monte Carlo engines
4. Emit evidence links with `evidence_strength` classification
5. Enforce server-side IC approval gating based on assumption controls
6. Populate the empty `hooks/` directory with MNPI / citation / audit / evidence-quality enforcement

OloLand adds the **verifier stack** that turns "draft memo" into **"memo that defends every $-figure at IC."**

---

## One-line workflow summary

> **Sourcing data flows in → OloLand ingests + extracts at corpus scale → deterministic engines value the deal → forensic primitives catch red flags → assumption controls gate the IC memo → approval evidence snapshot captures the audit state.**

Every step is verifiable. Every claim is cited. Every assumption is owned. Every approval is auditable.
