# OloLand Plugins

> The verifier stack for buy-side underwriting, as Claude plugins.

This repo is OloLand's plugin marketplace for **Claude Cowork** (Claude Desktop) and **Claude Code** (CLI). It hosts the OloLand plugins that augment Anthropic's first-party finance plugin lineup (`private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, `wealth-management`).

> *Anthropic ships breadth. OloLand ships depth.*
> Same Cowork session. Deterministic computation. Defensible record.

---

## Plugins in this marketplace

| Plugin | Status | What it does |
|---|---|---|
| [`ololand-dd`](./plugins/ololand-dd) | v1.5.2 | Institutional due diligence: deterministic financial engines, 246-category risk taxonomy, cross-document reconciliation, war-game RL strategy simulation, and a flywheel that retrains from analyst corrections. |
| [`ololand-forensic-qoe`](./plugins/ololand-forensic-qoe) | v0.1.0 | Forensic Quality-of-Earnings primitives as a standalone wedge SKU: Beneish, Benford, EBITDA bridge, journal-entry testing, lapping detection, working-capital deep dive. The Pre-LOI Forensic Screen — $7,500 / 72 hours, IC-defensible, vs Big-4 QoE at $150-500K / 4-8 weeks. |
| [`ololand-compliance-hooks`](./plugins/ololand-compliance-hooks) | v0.1.0 | Drop-in compliance, citation, and provenance hooks for Anthropic's Claude Cowork finance plugins. PreToolUse MNPI guard, PostToolUse citation enforcer, audit-log writeback. Populates the empty `hooks/` scaffold Anthropic's verticals ship with. |

The plugins compose additively with each other and with Anthropic's first-party finance plugins.

---

## Prerequisites

The only thing you need is a free OloLand account. **No env var setup, no manual API key creation.** The plugins handle authentication via OAuth automatically when you install them.

### Two account rails

| Rail | Cost | Access |
|---|---|---|
| **Developer (free)** | Sign up at https://app.ololand.ai/signup | Sandbox-only — full MCP tool access against the included sample deal (`Paragon Flight School (Sample)`). Unlimited calls. No payment, no credit card. |
| **Platform (paid)** | Pro $199/mo, Firm $800/seat/mo, or per-deal SKUs (see [pricing](https://ololand.ai/pricing)) | Access to your own deals + cross-deal memory + outcome flywheel + production volumes |

You can install the plugins on a free Developer account and explore everything against the sample deal — DCF, LBO, Monte Carlo, forensic QoE, risk taxonomy, war-game, all of it. When you're ready to run on your own data, upgrade to a paid plan.

### What happens on first install (no env var setup needed)

1. Add the marketplace and install a plugin (steps in the Install sections below)
2. The plugin defines an `ololand` MCP connector that points at OloLand's backend
3. On first invocation, your Cowork / Claude Code prompts you to **Authorize** the connector via OAuth
4. Click Authorize — your browser opens to OloLand's auth page, you sign in, accept the scopes
5. OloLand's backend auto-provisions a scoped agent key, bound to your OAuth client. Cowork / Claude Code stores it for you
6. Subsequent calls use the stored credential. No env var, no manual setup.

That's it. The OAuth flow happens once and the connector is authenticated for that session and future ones.

### Power user / headless setup (optional)

If you're running the plugins in a headless environment (CI, server-side automation, custom MCP client that can't run OAuth), you can bypass OAuth with a manual agent key:

1. Sign in at https://app.ololand.ai
2. Settings → Agent keys → Create new key
3. Set the env var: `export OLOLAND_AGENT_KEY=olo_agent_sk_...`

The plugin's `.mcp.json` reads `${OLOLAND_AGENT_KEY}` as a Bearer header. If both OAuth and the env var are configured, OAuth takes precedence.

---

## Install — Claude Cowork (Claude Desktop)

The recommended path for analysts running deals through the Cowork UI.

### Step 1 — Open the plugin manager

1. Open **Claude Desktop**
2. Switch to the **Cowork** tab (top of window)
3. Click **Customize** in the left sidebar
4. Click **Plugins** in the Customize submenu

### Step 2 — Add the OloLand marketplace

1. Click the **`+`** button next to "Personal plugins" (or the equivalent button in the Plugins panel header)
2. Choose **Create plugin** → **Add marketplace**
3. In the URL field, enter:
   ```
   ololand-ai/ololand-plugins
   ```
4. Click **Sync**
5. After ~5-10 seconds, a new pill `ololand-plugins` appears with three plugin cards: `Ololand dd`, `Ololand forensic qoe`, `Ololand compliance hooks`.

### Step 3 — Install the plugins

Click the **`+`** button on each card to install. After all three installed, your Personal plugins sidebar should list:
- Ololand dd
- Ololand compliance hooks
- Ololand forensic qoe

### Step 4 — Verify

Click `Ololand dd` in the sidebar. The detail view should show:

| Field | Expected value |
|---|---|
| Source | Marketplace (`ololand-plugins`) |
| Version | **1.5.2** or higher |
| Author | OloLand |
| Skills tab | ~18 skills including `/playbook-recall`, `/calibrate-vs-history` |
| Agents tab | **3 agents**: `dd-analyst`, `forensic-screener`, `war-game-strategist` |
| Connectors tab | 1 connector named `ololand` |

If Agents shows 1 instead of 3, you're on an older version. Remove the marketplace and re-add following Step 2.

### Step 5 — Authorize the OloLand connector

The first time you invoke a command that calls OloLand's backend (e.g., `/ololand-dd:dd-analyze`), Cowork prompts you to authorize the `ololand` MCP connector. Click **Authorize** → sign in to OloLand if you haven't yet → accept the scopes. The connector stores the credential for subsequent calls. **No env var setup needed.**

If you're new to OloLand, signing in here also creates your free Developer account on the spot — you don't have to visit app.ololand.ai/signup separately.

---

## Install — Claude Code (CLI)

For developers, IT teams, and anyone running Claude Code locally.

### Step 1 — Add the marketplace

In any Claude Code chat session:

```
/plugin marketplace add ololand-ai/ololand-plugins
```

### Step 2 — Install the plugins

```
/plugin install ololand-dd@ololand-plugins
/plugin install ololand-forensic-qoe@ololand-plugins
/plugin install ololand-compliance-hooks@ololand-plugins
```

### Step 3 — Reload to activate

```
/reload-plugins
```

### Step 4 — Verify

```
/plugin
```

This opens the plugin manager TUI. Tab to the **Installed** tab and confirm all three OloLand plugins are listed and enabled. Open `ololand-dd` detail to verify version 1.5.2 and the three agents.

### Step 5 — Authorize the OloLand connector

The first time you invoke a command that calls OloLand's backend (e.g., `/ololand-dd:dd-analyze`), Claude Code triggers the OAuth flow for the `ololand` MCP connector. Your browser opens to OloLand's auth page → sign in → accept the scopes. Claude Code stores the credential. Subsequent calls authenticate automatically.

If you're new to OloLand, the auth page lets you sign up on the spot — no separate trip to app.ololand.ai/signup.

**For headless / CI use only**: set `OLOLAND_AGENT_KEY=olo_agent_sk_...` in your environment to bypass the OAuth flow. Get the key at app.ololand.ai → Settings → Agent keys → Create new key. OAuth takes precedence if both are configured.

---

## Usage — `ololand-dd`

The flagship due-diligence plugin. Skills are auto-fired when relevant; commands are explicit invocations.

### Commands

Type `/` in any chat to see autocomplete. Plugin commands are namespaced as `/ololand-dd:<command>`.

| Command | What it does |
|---|---|
| `/dd-analyze <deal_id>` | Full DD: financial extraction → risk assessment → valuation → forensic flags → IC-grade synthesis |
| `/new-deal <ticker_or_name>` | Create a new deal from a ticker (auto-fetches 10-K) or company name |
| `/risk-matrix <deal_id>` | Render the 246-category risk taxonomy as an interactive tile |
| `/risk-report <deal_id>` | Structured risk report — severity × likelihood × velocity, with $-impact |
| `/valuation <deal_id> [method]` | Run DCF / LBO / Monte Carlo / Comps with strict unit enforcement |
| `/war-game <deal_id> [scenarios]` | 16-quarter MaskablePPO competitive simulation across scenarios |
| `/similar-deals <deal_id>` | Cross-deal memory: find similar past deals, accuracy patterns, valuation ranges |
| `/playbook-recall <deal_id>` | What worked, what didn't, what was missed in similar past deals from your firm's history |
| `/calibrate-vs-history <deal_id>` | Apply your firm's historical projection bias to recalibrate the deal's headline numbers |
| `/talk-to-deal <deal_id>` | Conversational session: ask anything about the deal, voice-optimized output |
| `/deal-search <deal_id>` | Full-text + semantic search across a deal's data room |
| `/unit-economics <deal_id>` | SaaS cohort retention (NDR/GRR), LTV/CAC, payback, magic number, rule of 40 |
| `/source <criteria>` | Source new M&A/PE deals from criteria; enrich with contact data; dedupe vs CRM |

### Sub-agents

In Cowork, click an agent in the Agents tab and it loads as the lead agent for the conversation. In Claude Code CLI, agents auto-fire based on context, or invoke explicitly with `/agents` and pick one.

| Agent | Use when |
|---|---|
| `dd-analyst` | Full DD workflows, IC memo prep, deep deal investigation. The general-purpose specialist. |
| `forensic-screener` | Pre-LOI forensic deep-dive. Runs all 7 forensic primitives, reconciles findings against source hierarchy, produces an IC-defensible exclusion schedule with severity, $-impact, and citations. |
| `war-game-strategist` | Stress-testing the deal thesis against competitor responses. Runs 4-scenario MaskablePPO simulation, calibrates vs. similar-deal outcomes, overlays on deterministic DCF, recommends bid adjustment. |

### Example workflow — full Pre-LOI DD

In Cowork (or Claude Code), with a deal in your OloLand account:

```
/ololand-dd:new-deal ACME-Manufacturing
```
↓ creates the deal

```
/ololand-dd:dd-analyze deal_acme_2026
```
↓ runs the full multi-agent DD

Then for forensic depth:

```
/ololand-dd:risk-matrix deal_acme_2026
```
↓ renders the 246-category tile

```
@forensic-screener run a Pre-LOI screen on deal_acme_2026
```
↓ delegates to the forensic specialist sub-agent

For thesis stress-test:

```
@war-game-strategist test the buyout thesis on deal_acme_2026 across all 4 scenarios
```

---

## Usage — `ololand-forensic-qoe`

The standalone Pre-LOI Forensic Screen wedge. Use when you want forensic depth without the full DD plugin.

### Commands

| Command | What it does |
|---|---|
| `/forensic-screen <deal_id>` | Full battery: Beneish + Benford + EBITDA bridge + journal-entry + lapping + working-capital + revenue-quality. Returns severity-scored exclusion schedule. |
| `/beneish <deal_id>` | Beneish M-Score (private-company adjusted). 8-variable earnings-manipulation probability. |
| `/benford <deal_id>` | Benford's Law first-digit testing on GL transactions. χ² + MAD. |
| `/ebitda-bridge <deal_id>` | EBITDA bridge with adjustment classifier. Tags every add-back as accepted / recurring / questionable. |
| `/journal-test <deal_id>` | Journal-entry anomaly testing. Period-end concentration, round-numbers, posting authority, weekend entries. |
| `/lapping-check <deal_id>` | AR-lapping fraud detection. Customer-to-cash trace, application gap detection. |

### Required inputs

- **Beneish**: 2+ years of income statement + balance sheet data
- **Benford**: GL export with ≥1,000 line items
- **EBITDA bridge**: management adjustment schedule + 2-3 years historicals
- **Journal-entry tests**: GL with timestamps + posting user IDs
- **Lapping**: AR aging + cash receipts journal with customer-level detail
- **Full screen**: skip-and-report behavior — runs every primitive whose inputs are present, reports which were skipped and why

### Example workflow — $50M EBITDA target screen

```
/ololand-forensic-qoe:forensic-screen deal_target_2026
```

Returns in 60-90s an IC-defensible exclusion schedule with:
- Reported EBITDA $X.XM → defensible EBITDA $Y.YM (delta $Z.ZM)
- Each forensic primitive's verdict (pass / warning / fail)
- Adjustments table with $ impact and source citations
- Severity-scored findings (low / medium / high / critical)
- Recommendation: proceed / proceed with caveats / kill

---

## Usage — `ololand-compliance-hooks`

The drop-in hooks plugin. Most users don't invoke this directly — it runs automatically once installed.

### What it does (passive)

| Hook | Trigger | Action |
|---|---|---|
| **PreToolUse: MNPI guard** | Bash, Write, Edit, MultiEdit | Blocks tool calls referencing material non-public information patterns ("material non-public", "insider trading window", etc.) unless input contains `# mnpi:cleared` marker |
| **PostToolUse: citation enforcer** | After CIM / IC memo / dossier generation | Scans for $-amounts, %, multiples without source citation. Warns by default. |
| **PostToolUse: provenance writeback** | After every generative output | Appends NDJSON to `~/.ololand/provenance/YYYY-MM-DD.ndjson` + optional API mirror |
| **Pre + PostToolUse: audit log** | Every `mcp__ololand__*` call | Mirrors invocations to `~/.ololand/audit/YYYY-MM-DD.ndjson` |
| **SessionStart: banner** | New session | Confirms hooks armed |

### Configuration via env vars

| Variable | Default | Purpose |
|---|---|---|
| `OLOLAND_CITATION_BLOCK` | `0` | Set to `1` to upgrade citation enforcer from warn to deny |
| `OLOLAND_AGENT_KEY` | unset | Mirror provenance + audit lines to OloLand's API |
| `OLOLAND_API_URL` | `https://app.ololand.ai` | Override for self-hosted OloLand deployments |

### Local logs

Inspect provenance + audit ledgers any time:

```bash
jq -c '.' ~/.ololand/provenance/$(date -u +%Y-%m-%d).ndjson
jq -c '.' ~/.ololand/audit/$(date -u +%Y-%m-%d).ndjson
```

These ledgers are append-only NDJSON. Rotate or compress per-day as needed.

---

## Troubleshooting

### Cowork: "Marketplace sync failed. Check the repository URL and try again."

Most common cause: cached marketplace from a prior install attempt. Click `...` on the failing pill → Remove. Then re-add.

If still failing, fall back to the **Upload plugin** path (zip upload). Per [Cowork issue #38429](https://github.com/anthropics/claude-code/issues/38429), `source: "manual"` plugins are protected from the auto-removal bug that affects `source: "github"` plugins.

### Cowork: plugin disappears after restart

Known [issue #38429](https://github.com/anthropics/claude-code/issues/38429) and [#39274](https://github.com/anthropics/claude-code/issues/39274). RemotePluginManager removes 3rd-party github-sourced plugins on restart. Workarounds:
- Reinstall via "Upload plugin" (zip path) instead of "Add marketplace"
- Or wait for Anthropic to ship the fix

### Cowork: chat says "Unknown skill: plugin"

Cowork chat does NOT support `/plugin` slash commands. Plugin management is UI-only:
- Customize → Plugins → Browse / Add marketplace / Upload plugin

The `/plugin` command set works in **Claude Code CLI** only.

### Cowork: showing old version (1.4.x) instead of 1.5.x

Likely cached install from before the marketplace rename (was `ololand-dd-plugin`, now `ololand-plugins`). Remove the old marketplace pill, add `ololand-ai/ololand-plugins` fresh, install.

Verify v1.5.2 by clicking the plugin → Agents tab should show 3 agents (dd-analyst, forensic-screener, war-game-strategist).

### CLI: `/plugin install` fails with "marketplace not found"

```
/plugin marketplace update ololand-plugins
```

Or if that fails:

```
/plugin marketplace remove ololand-plugins
/plugin marketplace add ololand-ai/ololand-plugins
```

### Tools fail with auth errors ("OLOLAND_AGENT_KEY not set", "401 Unauthorized", etc.)

Most common cause: you skipped or canceled the OAuth flow on first invocation.

**Fix in Cowork**: Customize → Connectors → click the `ololand` connector → click **Reconnect** (or **Disconnect** then click the connector again to retrigger OAuth). Sign in to OloLand and accept scopes.

**Fix in Claude Code CLI**: run any `/ololand-dd:` command — Claude Code retriggers the OAuth flow when it detects an unauthenticated connector. Sign in in the browser when prompted.

**Headless / CI fallback**: if OAuth isn't possible (CI, scripts), generate an agent key at app.ololand.ai → Settings → Agent keys, then `export OLOLAND_AGENT_KEY=olo_agent_sk_...` in your environment.

### Plugin skills not appearing after install

Run:
```
/reload-plugins
```

If still missing, clear the plugin cache:
```bash
rm -rf ~/.claude/plugins/cache
```
Then re-install. Restart Claude Code / Claude Desktop after the cache clear.

---

## Why this exists

OloLand's thesis: Anthropic's finance plugins are *"reference templates — they get better when you tune them to how your firm works"* (their own README). That is exactly what we are: the institutional tuning.

Anthropic ships breadth — five vertical plugins, ten named agents, eleven read-only data connectors. We ship depth — deterministic computation, structured taxonomy, persistent memory, and the compliance hooks Anthropic's first-party plugins ship empty.

For the full positioning, see [the comparison page](https://ololand.ai/compare/vs-anthropic-plugins).

---

## Contributing

Each plugin lives under `plugins/<name>/` with its own `.claude-plugin/plugin.json`, README, and contents. The marketplace catalog at `.claude-plugin/marketplace.json` is the single source of truth for what's published.

Develop on `staging`, push to `origin/staging`, open a PR into `main`. Both `ololand-ai/olo5` and `ololand-ai/ololand-plugins` use **rebase merge only** to keep history linear.

To bump a plugin version, update both the plugin's `plugin.json` AND the marketplace.json entry — `scripts/check-version-sync.sh` (run pre-commit) will fail the commit if they drift.

## Support

- Email: support@ololand.ai
- Issues: https://github.com/ololand-ai/ololand-plugins/issues
- Docs: https://ololand.ai

## License

Apache-2.0. See [LICENSE](./LICENSE).
