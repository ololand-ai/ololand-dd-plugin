# OloLand Plugins

> The verifier stack for buy-side underwriting, as Claude plugins.

This repo is OloLand's plugin marketplace for **Claude Code** and **Claude Cowork**. It hosts the OloLand plugins that augment Anthropic's first-party finance plugin lineup (`private-equity`, `financial-analysis`, `investment-banking`, `equity-research`, `wealth-management`).

> *Anthropic ships breadth. OloLand ships depth.*
> Same Cowork session. Deterministic computation. Defensible record.

## Plugins in this marketplace

| Plugin | Path | Status | What it ships |
|---|---|---|---|
| [`ololand-dd`](./plugins/ololand-dd) | `plugins/ololand-dd` | v1.4.3 | Institutional due diligence: deterministic financial engines, 246-category risk taxonomy, forensic QoE, cross-document reconciliation, and a flywheel that retrains from analyst corrections. |
| [`ololand-compliance-hooks`](./plugins/ololand-compliance-hooks) | `plugins/ololand-compliance-hooks` | v0.1.0 | Drop-in compliance, citation, and provenance hooks for Anthropic's Claude Cowork finance plugins. PreToolUse MNPI guard, PostToolUse citation enforcer, audit-log writeback. Populates the empty `hooks/` scaffold Anthropic's verticals ship with. |

## Install

Add this marketplace once, then install plugins individually:

```bash
claude plugin marketplace add ololand-ai/ololand-plugins
claude plugin install ololand-dd@ololand-plugins
claude plugin install ololand-compliance-hooks@ololand-plugins
```

The plugins compose additively with each other and with Anthropic's first-party finance plugins.

## Why this exists

OloLand's thesis: Anthropic's finance plugins are *"reference templates &mdash; they get better when you tune them to how your firm works"* (their own README). That is exactly what we are: the institutional tuning.

For the full positioning &mdash; what Anthropic ships, what OloLand adds, why they compose &mdash; see [the comparison page](https://ololand.ai/compare/vs-anthropic-plugins).

## Contributing

Each plugin lives under `plugins/<name>/` with its own `.claude-plugin/plugin.json`, README, and contents. The marketplace catalog at `.claude-plugin/marketplace.json` is the single source of truth for what's published.

Develop on `staging`, push to `origin/staging`, open a PR into `main`.

## License

Apache-2.0. See [LICENSE](./LICENSE).
