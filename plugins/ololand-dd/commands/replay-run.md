---
description: "Re-run an existing OloLand agent run against the current harness + skills (or byte-for-byte against the original methodology bytes). Admin / compliance role required. The regulator-grade reproducibility surface — used to demonstrate that a graded output can be reconstructed from snapshots, and to A/B the current prompt against last week's data."
---

# /replay-run

You are enqueueing a replay of an existing OloLand agent run. The original run's `root_prompt_snapshot` is replayed against either the *current* harness + skill catalog (`current_skills`) or the *original* methodology bytes (`byte_for_byte`).

**This command requires admin or compliance role.** Non-privileged users will get `error_code: "insufficient_role"`.

## Required inputs

1. **run_id** — the agent_runs row to replay. Confirm from the user that this is the run they want replayed; replays cost credits and a Celery worker.

Optional:
- **mode** — `current_skills` (default) or `byte_for_byte`. See "When to use which mode" below.
- **comment** — short reviewer note stored on the replay (e.g. "Re-run after grader fix 2026-05-17"). Strongly recommended for audit trail.

## Action

1. (Optional but recommended) Call `mcp__ololand__get_agent_run` first to confirm the run is replayable. The user should see at least: `agent_name`, `model_version`, `status`, `started_at`, `entry_point`. If `root_prompt_snapshot` is not present, the replay will fail with `error_code: "no_snapshot"` — surface that pre-emptively.

2. Call `mcp__ololand__replay_agent_run` with `run_id`, `mode`, optional `comment`.

3. On success, surface:
   ```
   Replay queued
     Replay run id:  <replay_run_id>
     Parent run id:  <parent_run_id>
     Status:         queued
     Compare:        <comparison_url>
   ```
   Tell the user to poll `mcp__ololand__get_agent_run <replay_run_id>` for completion. Typical end-to-end latency: 30–180 seconds depending on the original run's iteration count.

4. On error, surface the `error_code` verbatim and the explanation:
   - `not_found` — wrong run_id.
   - `access_denied` — run belongs to a different company.
   - `insufficient_role` — user is not admin/compliance.
   - `no_snapshot` — original run pre-dates snapshot capture (pre-2026-05-14 runs).
   - `bad_request` — invalid mode.
   - `dispatch_failed` — Celery rejection; the replay row is marked error.

## When to use which mode

| Mode | Use when |
|---|---|
| `current_skills` | "Would the *current* skill catalog have produced a different (better) answer for this run?" Validates a methodology improvement against historical data. Default for ad-hoc reviews. |
| `byte_for_byte` | "Reproduce this run identically." Used for regulator-grade reproducibility — the auditor needs to see that the exact same skills + prompt produce the same output. Requires `skill_pack_snapshot` and `subagent_definition_snapshot` on the original run. |

## When NOT to use

- For exploratory "what if" prompt changes — author a new run instead, don't replay an old one.
- To "fix" a wrong answer in a customer-facing output — replay creates a new audit-trail entry; the original stands. If the original is wrong, surface a claim correction via `/dd-correct`.
- For live in-flight runs — replay is only defined for runs in terminal status (`completed`, `error`). Queue / running runs aren't replayable; finish them first.

## Audit-trail discipline

Always pass `comment` when you can. The replay row is the regulator's tie between your reasoning ("why did you re-run this?") and the output. Sample comments:

- `"A/B test of v2 source-hierarchy skill against PR #1525 baseline"`
- `"Compliance review per SR-2026-04-22; reproducing run for the regulator"`
- `"Reviewer flagged inconsistent EBITDA; re-running with byte_for_byte"`

Companion commands: `/inspect-run`, `/regulator-export`.
