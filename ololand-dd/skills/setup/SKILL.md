---
name: setup
description: Connect your OloLand account to Claude Code via OAuth. Use when OLOLAND_AGENT_KEY is not set, when any /dd-* command fails with authentication error, or when the user mentions "setup", "connect", or "configure".
---

# OloLand Setup

## Automatic Setup (Recommended)

If you installed this plugin via `claude mcp add ololand`, authentication was handled automatically via OAuth. Your connection is already configured.

Test it by running any OloLand command:
- `/dd-analyze` — Run full due diligence on a deal
- `/similar-deals` — Find comparable transactions

If you see "OloLand connected" in your tools list, you're ready to go.

## Manual Setup (Fallback)

If OAuth didn't work (corporate firewall, offline environment):

1. Visit https://ololand.ai/connect
2. Sign up or log in
3. Copy your agent key (starts with `olo_agent_sk_`)
4. Run: `export OLOLAND_AGENT_KEY=<your-key>`

## Troubleshooting

- **"Authentication required" errors**: Run `/setup` to reconnect
- **"Rate limit exceeded"**: Free tier allows 10 requests/minute. Contact sales@ololand.ai to upgrade.
- **MCP server unreachable**: Check https://status.ololand.ai or try again in 60 seconds (Cloud Run cold start).
