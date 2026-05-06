# ololand-compliance-hooks

> Drop-in compliance, citation, and provenance hooks for Anthropic's Claude Cowork finance plugins.

Anthropic's `private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, and `wealth-management` vertical plugins each ship `hooks/hooks.json` as an empty array. There is no compliance hook, no citation enforcement, no provenance writeback, no MNPI guard. For a regulated buy-side workflow this is unacceptable.

This plugin populates that scaffold.

## What you get

- **PreToolUse MNPI guard** — blocks tool calls whose input mentions material non-public information patterns without an explicit `# mnpi:cleared` marker.
- **PostToolUse citation enforcer** — scans CIM/IC-memo/dossier outputs for $-amounts, %, and multiples without source citations. Warns by default; blocks when `OLOLAND_CITATION_BLOCK=1`.
- **PostToolUse provenance writeback** — appends NDJSON to `~/.ololand/provenance/` and optionally mirrors to OloLand's audit API.
- **Pre + PostToolUse audit log** — mirrors every `mcp__ololand__*` call into `~/.ololand/audit/` for IC defensibility.
- **SessionStart banner** — confirms hooks are armed.

## Install

```bash
claude plugin install ololand-compliance-hooks
```

Or, if installing from this monorepo:

```bash
claude plugin marketplace add ./plugins
claude plugin install ololand-compliance-hooks@olo-plugins
```

## Composes with

- `ololand-dd` (the OloLand due-diligence plugin)
- Anthropic's finance vertical plugins (`private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, `wealth-management`)
- Any other plugin that uses Claude Code hooks

Hooks compose additively across plugins. Multiple `PreToolUse` matchers all fire for the same event.

## Configuration

| Env var | Default | Purpose |
|---|---|---|
| `OLOLAND_CITATION_BLOCK` | `0` | Set to `1` to upgrade citation enforcer from warn to deny. |
| `OLOLAND_AGENT_KEY` | unset | Mirror audit + provenance lines to the OloLand API. |
| `OLOLAND_API_URL` | `https://app.ololand.ai` | Override for self-hosted OloLand. |

## Why this exists

OloLand's thesis: Anthropic ships breadth, OloLand ships depth. The empty `hooks/` directory is the most visible depth gap in Anthropic's lineup. This plugin closes that gap on the same Cowork surface.

See `docs/superpowers/specs/2026-05-05-cowork-augment-plugins-design.md` in the OloLand monorepo for the full design.

## License

Apache-2.0.
