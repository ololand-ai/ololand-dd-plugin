---
name: observability-audit-trail
description: Use when working with OloLand's observability stack — agent_runs, agent_spans, regulator_exports — to inspect a run, replay it, or generate a compliance-framework export. Explains the M1+M2 audit trail, the role-based gating, and the chain-of-custody discipline that makes the trail regulator-defensible.
---

# Observability Audit Trail

OloLand's M1+M2 observability surface is what turns the marketing claim "verifiable end-to-end" from aspiration into shipping artifact. Every agent run produces immutable rows in `agent_runs` and `agent_spans`. Every generated artifact (CIM, IC memo, forensic PDF) gets a lineage row in `output_artifacts`. Every regulator-grade export is a tarball whose SHA-256 is recorded at generation time.

## What is captured

| Table | What | Use |
|---|---|---|
| `agent_runs` | One row per top-level agent invocation. Captures `root_prompt_snapshot`, `skill_pack_snapshot`, `subagent_definition_snapshot`, model + harness versions, tokens, cost, status, grader verdict. | The unit of replay. The unit of cost accounting. The unit the regulator wants. |
| `agent_spans` | One row per observable step inside a run — model call, tool call, compaction event, SSE event. Captures parent_span_id (tree structure), tool_name, model_version, latency_ms, is_error. | The "show me what actually happened" surface. |
| `output_artifacts` | One row per artifact produced (CIM PDF, IC memo, forensic screen). Captures content hash, lineage to the producing run. | Tamper-evidence on generated deliverables. |
| `regulator_exports` | Tarball metadata — framework, window, deal scope, SHA-256, signed-URL, expiry. | The deliverable for regulators / compliance reviewers. |

## Role gating

Read paths (`list_agent_runs`, `get_agent_run`, `list_agent_spans`, `get_grader_verdict`, `get_regulator_export`) are tenant-scoped — any active member of the company can call them.

Write paths (`replay_agent_run`, `request_regulator_export`) require the **admin or compliance role** in the calling user's `CompanyMember` row, OR one of the privileged permissions (`agent_runs`, `manage_agent_runs`, `replay_agent_runs`, `regulator_exports`, `manage_regulator_exports`, `compliance_exports`). Superusers bypass the check globally.

Surfaced as `error_code: "insufficient_role"` on the MCP rail. If a user hits this and shouldn't, they need their company admin to grant the role on `CompanyMember` — *not* a new API key.

## Replay modes

`current_skills` (default) re-runs the captured `root_prompt_snapshot` against today's harness + skill catalog. Use when validating that a methodology change still produces a correct answer on yesterday's data.

`byte_for_byte` reproduces the run identically — same skills, same subagent definitions, same prompt. Required when a regulator wants the exact output reproduced and verified. Only works for runs that captured *both* `skill_pack_snapshot` and `subagent_definition_snapshot` — pre-2026-05-14 runs return `error_code: "no_snapshot"` and cannot be replayed byte-for-byte.

## Chain-of-custody discipline

For regulator exports, the user's responsibility is to **record the `tarball_sha256` separately from the OloLand system at the moment of download**. The hash is what makes the tarball tamper-evident to a downstream regulator — if it changes by even one bit, the chain-of-custody is broken.

The reviewer should:

1. Download the tarball via `tarball_uri` (signed link).
2. Compute the SHA-256 locally with a trusted tool.
3. Compare to `tarball_sha256` from `get_regulator_export`.
4. Record the (export_id, sha256, download_timestamp, reviewer_id) tuple in their compliance system.

That tuple is the audit-defense artifact, not the tarball itself.

## What this is NOT

- **Not real-time monitoring.** The observability tables are post-hoc. For live agent progress, use the SSE stream (`/api/sse/conversation/{session_id}`).
- **Not a replacement for application logs.** `agent_spans` captures the agent loop's *intent* (this tool was called, this model returned this many tokens). Application-level errors still go to Sentry / Cloud Logging.
- **Not the only audit surface.** Analyst corrections (`analyst_corrections` table, surfaced via `submit_agent_claim_correction`) and deal outcomes (`deal_outcomes`, surfaced via `record_deal_outcome`) are separate audit trails for *user judgement on AI output* vs *agent runtime telemetry*.

## Companion tools (MCP)

- `mcp__ololand__list_agent_runs` — discover run_ids.
- `mcp__ololand__get_agent_run` — header + span counts + grader.
- `mcp__ololand__list_agent_spans` — full step list.
- `mcp__ololand__get_grader_verdict` — grader_passed + rationale.
- `mcp__ololand__replay_agent_run` — admin/compliance only.
- `mcp__ololand__request_regulator_export` — admin/compliance only.
- `mcp__ololand__get_regulator_export` — poll status.

Companion commands: `/inspect-run`, `/replay-run`, `/regulator-export`.
