# Install OloLand Plugins for Codex

Date: 2026-05-12

OloLand's three plugins (`ololand-dd`, `ololand-forensic-qoe`, `ololand-compliance-hooks`) ship to Codex CLI from the same marketplace repo as Claude Code and Claude Cowork. Same plugins, same MCP server, three surfaces.

## Prerequisites

- **Codex CLI installed.** See [openai/codex](https://github.com/openai/codex) for setup.
- **OloLand agent key** available as `OLOLAND_AGENT_KEY`. Get one at [`app.ololand.ai/settings/agent-keys`](https://app.ololand.ai/settings/agent-keys).

```bash
export OLOLAND_AGENT_KEY="olo_agent_sk_..."
```

## Steps

### 1. Add the OloLand plugin marketplace

```bash
codex plugin marketplace add ololand-ai/ololand-plugins --ref staging
```

> **Note on `--ref staging`:** required until the Codex marketplace artifacts merge to `main`. Once merged, drop the flag — see "After GA" at the bottom of this doc.

### 2. Enable the plugins in `~/.codex/config.toml`

```toml
[plugins."ololand-dd@ololand-plugins"]
enabled = true

[plugins."ololand-compliance-hooks@ololand-plugins"]
enabled = true

[plugins."ololand-forensic-qoe@ololand-plugins"]
enabled = true
```

### 3. Register the OloLand MCP server

```bash
codex mcp add ololand \
  --url https://ma-workbench-api-303576587005.us-central1.run.app/mcp \
  --bearer-token-env-var OLOLAND_AGENT_KEY
```

### 4. Verify the MCP server is registered

```bash
codex mcp list
```

Expected output:

```text
ololand  https://ma-workbench-api-303576587005.us-central1.run.app/mcp  OLOLAND_AGENT_KEY  enabled
```

### 5. Restart Codex

Restart Codex or start a new Codex session so the plugins + MCP server are loaded.

## Smoke test

```bash
codex exec "Use the ololand MCP server to list my deals. Return the count and first deal name."
```

Expected: Codex calls `ololand.list_deals` and returns your OloLand deals.

## What you installed

| Plugin | Purpose |
|---|---|
| **`ololand-dd`** | Institutional due diligence + middle-office assumption controls + IC approval gate. 16 commands. Three sub-agents (dd-analyst, forensic-screener, war-game-strategist). |
| **`ololand-forensic-qoe`** | Pre-LOI Forensic Screen wedge (Beneish, Benford, EBITDA bridge, journal-entry, lapping, covenant cascade). $7,500 / 72-hour SKU vs Big-4 QoE $150-500K / 4-8 weeks. |
| **`ololand-compliance-hooks`** | MNPI guard (PreToolUse), citation enforcer (PostToolUse on memo/CIM/dossier), audit log, tier-capacity warning, evidence-quality warning. Drops into Codex's hooks scaffold the same way it drops into Claude's. |

## After GA

Once the Codex marketplace artifacts merge to `main`, drop `--ref staging`:

```bash
codex plugin marketplace add ololand-ai/ololand-plugins
```

The rest of the install sequence is unchanged.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `codex mcp list` shows ololand as `disabled` | Bearer-token env var not set or empty | `export OLOLAND_AGENT_KEY="olo_agent_sk_..."` then restart Codex |
| `Unauthorized` errors on tool calls | Agent key expired or revoked | Generate a new key at [`app.ololand.ai/settings/agent-keys`](https://app.ololand.ai/settings/agent-keys) |
| Plugin commands not loading | `config.toml` block missing or not in `~/.codex/config.toml` | Re-add the `[plugins."ololand-*@ololand-plugins"]` entries |
| `Could not fetch marketplace` | `--ref staging` flag missing (during staging window) | Re-run step 1 with `--ref staging` |

## Related

- [Claude Code install](https://www.ololand.ai/connect/claude?method=cli)
- [Claude Cowork install](https://www.ololand.ai/connect/claude?method=cowork)
- [IC memo workflow](./cowork-ic-memo-workflow.md) — works identically across Codex, Claude Code, and Claude Cowork once installed
