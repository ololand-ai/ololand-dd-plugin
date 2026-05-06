---
description: Render the 246-category risk matrix as an interactive inline tile.
---

You have access to the `render_risk_matrix_tile` MCP tool from the OloLand server.

If the user has a deal loaded (check conversation context or call `list_deals`), invoke `render_risk_matrix_tile` with that `deal_id`. The tool's response is an MCP App — Claude will render it inline as an interactive iframe. No further action is required from you; acknowledge briefly and stop.

If no deal is loaded, ask the user which deal they want to analyze, or offer to run `/dd-analyze` first.
