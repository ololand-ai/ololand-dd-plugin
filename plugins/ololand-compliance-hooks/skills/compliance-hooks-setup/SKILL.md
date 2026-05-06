---
name: compliance-hooks-setup
description: Use when the user asks to enable, configure, or troubleshoot OloLand compliance hooks for Claude Cowork finance plugins. Walks through MNPI guard, citation enforcer, and provenance writeback configuration.
---

# OloLand Compliance Hooks — Setup

This plugin populates the empty `hooks/hooks.json` scaffold that Anthropic's vertical finance plugins (`private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, `wealth-management`) ship with.

## What ships out of the box

- **PreToolUse → MNPI Guard** (Bash, Write, Edit, MultiEdit). Blocks tool calls whose input mentions material non-public information patterns without a `# mnpi:cleared` marker.
- **PostToolUse → Citation Enforcer** (matches `mcp__ololand__generate_investment_memo`, `generate_cim`, `export_deal_dossier`, plus all Write/Edit/MultiEdit). Scans for $-amounts, %, and multiples without an adjacent citation. Warns by default; set `OLOLAND_CITATION_BLOCK=1` to upgrade to a hard deny.
- **PostToolUse → Provenance Writeback**. Appends NDJSON to `~/.ololand/provenance/YYYY-MM-DD.ndjson` after every generative tool call. Mirrors to OloLand's audit API if `OLOLAND_AGENT_KEY` is set.
- **Pre + PostToolUse → Audit Log** (matches all `mcp__ololand__*`). Mirrors every OloLand MCP call into `~/.ololand/audit/YYYY-MM-DD.ndjson` with phase, tool name, and a 2KB payload head.
- **SessionStart → Banner**. Confirms hooks are armed and surfaces the env vars worth setting.

## Why this exists

Anthropic's `private-equity/hooks/hooks.json` ships as `[]`. Same for the other four vertical finance plugins. There is no compliance hook, no citation enforcement, no provenance writeback, no MNPI guard. For a regulated buy-side workflow this is unacceptable — you cannot defend a number to the IC if you cannot prove what ran, what it was sourced from, or that no MNPI leaked into a prompt.

## Environment variables

| Var | Default | Purpose |
|---|---|---|
| `OLOLAND_CITATION_BLOCK` | `0` | Set to `1` to make the citation enforcer block (exit 2) rather than warn. |
| `OLOLAND_AGENT_KEY` | unset | If set, provenance + audit lines are mirrored to `${OLOLAND_API_URL}/api/agent/audit`. |
| `OLOLAND_API_URL` | `https://app.ololand.ai` | Override the API base for self-hosted OloLand deployments. |

## Local logs

Both ledgers live in `~/.ololand/`:

```
~/.ololand/audit/YYYY-MM-DD.ndjson         # every mcp__ololand__* call
~/.ololand/provenance/YYYY-MM-DD.ndjson    # every generative output
```

Inspect with `jq -c '.' ~/.ololand/provenance/$(date -u +%Y-%m-%d).ndjson`.

## Composing with other plugins

This plugin is designed to run alongside `ololand-dd`, Anthropic's vertical finance plugins, and any custom plugin a firm installs. Hooks compose additively — multiple plugins' `PreToolUse` matchers all run for the same event.

## Troubleshooting

- **Hooks not firing**: confirm `claude plugin list` shows `ololand-compliance-hooks` enabled. Run `bash ~/.claude/plugins/cache/ololand-compliance-hooks/*/scripts/mnpi_guard.sh < /dev/null` to test the script directly.
- **Citation enforcer false positives**: the regex looks for $/%/x patterns without an inline citation. If your output has trailing footnotes instead of inline citations, the warning is expected; the enforcer warns rather than blocks by default for exactly this reason.
- **Audit log too noisy**: rotate or compress per-day; the file is NDJSON and append-only.
