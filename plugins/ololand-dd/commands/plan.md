---
description: "Get a structured plan from OloLand's planner agent BEFORE firing the executor — review the proposed steps, open questions, and tool-call estimate so you can correct course without burning tool calls. The pre-execution gate for non-trivial deal questions."
---

# /plan

You are running OloLand's planner agent in plan-mode. The planner reads the user's question, the active deal context, and produces a structured `PlanResponse` (steps, open_questions, escalation_required, reasoning, estimated tool calls) — without running any tools, doing any document search, or escalating to templates. It's a single Flash-class call; cheap relative to the executor run that follows.

## Required inputs

1. **deal_id** — the deal the conversation is about.
2. **session_id** — an active ADK conversation session. If the user doesn't have one, call `mcp__ololand__create_conversation_session(deal_id)` first and use the returned id.
3. **message** — the user's question that the planner should plan for. Quote it verbatim — don't paraphrase.

## Action

Call `mcp__ololand__submit_plan_for_approval` with the three inputs.

## Output

Render the plan in this shape:

```
Proposed plan for: "<message>"

Steps
  1. <step.title> — <step.description>
     Tools: <step.tools (if any)>
  2. ...

Open questions
  - <q1>
  - ...

Estimated tool calls: <n>
Escalation required: <true|false>
Reasoning: <reasoning>
```

Then ask the user:

> Approve this plan? Reply "yes" to execute, "no" to adjust, or rewrite any step.

On approval, continue the conversation via the normal message endpoint
(`mcp__ololand__ask_deal_agent` or `mcp__ololand__talk_to_deal`)
attaching the plan as context. *Quote the steps in your follow-up so the
executor sees what was approved.*

On rejection, ask what should change and re-plan.

## When to use

- **Before any non-trivial deal question.** "Write the IC memo" or "What are the top three risks" or "Run the DCF and compare to comps" should *always* be planned before execution.
- **When the user asked for something ambiguous.** The planner surfaces `open_questions` — let the user resolve those before tool calls fire.
- **When the user is cost-conscious.** Plan mode is one cheap call; the executor that follows is many. Approving a tight plan beats an executor that escalates because the prompt was vague.
- **Before any escalation to ic-memo, risk-chat, or forensic-chat templates.** The planner will signal `escalation_required: true` when appropriate.

## When NOT to use

- For lookup-style questions ("what's the deal id?", "how many documents are uploaded?"). These take one tool call regardless; planning is overhead.
- For corrections to a previous turn — use `/dd-correct` instead.
- For methodology questions ("how does the forensic QoE work?"). Use `/load-skill` (or `mcp__ololand__load_skill`) directly.

## Refusing to skip the plan

If a user repeatedly asks you to "just answer it" on a multi-step question, plan anyway and surface the plan in the response. The plan-mode discipline is what makes the executor's tool budget predictable. The agent runtime has a 12-iteration cap per turn; a planless 12-iteration spiral wastes the budget on backtracking.

Companion skill: `cmd-plan` (auto-loads).
