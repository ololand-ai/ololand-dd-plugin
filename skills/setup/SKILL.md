---
name: setup
description: Connect your OloLand account to Claude Code. Use when OLOLAND_AGENT_KEY is not set, when any /dd-* command fails with authentication error, or when the user mentions "setup", "connect", or "configure".
---

# OloLand Setup

The plugin authenticates with a long-lived agent key passed as a Bearer
token. This works in every MCP host (Claude Code, Claude Desktop, Cowork,
custom). OAuth (PKCE) is also supported but breaks in some hosts that
don't preserve client state across tool calls — agent-key auth bypasses
that entirely.

## Setup

1. Visit **https://api.ololand.ai/connect**
2. Sign in with email or Google
3. Click **Generate new key** — you'll see a string starting with `olo_agent_sk_`
4. Copy it and add to your shell profile:
   ```bash
   export OLOLAND_AGENT_KEY=olo_agent_sk_...
   ```
5. Reload your shell (`source ~/.zshrc`) and restart Claude Code

Test it by running any OloLand command:
- `/dd-analyze` — Run full due diligence on a deal
- `/similar-deals` — Find comparable transactions

If you see OloLand tools in your tools list, you're ready to go.

## Troubleshooting

- **"Authentication required" errors**: `OLOLAND_AGENT_KEY` isn't exported in the shell that launched Claude Code. Re-export and restart.
- **"Rate limit exceeded"**: Free tier allows 10 requests/minute. Contact sales@ololand.ai to upgrade.
- **MCP server unreachable**: Check https://status.ololand.ai or try again in 60 seconds (Cloud Run cold start).
- **Cowork users on plugin v1.4.2 or earlier**: OAuth flow loses PKCE state between tool calls. Upgrade to v1.4.3+ which uses agent-key auth, or set `OLOLAND_AGENT_KEY` manually as above.
