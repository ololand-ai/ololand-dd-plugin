---
name: citation-discipline
description: Use when stating any dollar figure, multiple, ratio, or factual claim about a deal — every quantitative claim must cite its source with an inline `[N]` marker pointing at the retrieved chunk. Required for any IC-grade or audit-defensible output.
---

# Citation Discipline

Every dollar figure, percentage, multiple, ratio, name, date, or factual claim about a deal must cite the source.

## Inline citation format — `[N]` markers

When `search_deal_documents` (or any document-retrieval MCP tool) returns evidence, each chunk is prefixed with a stable reference number: `[1] Source: file=10-K.pdf, p.42`, `[2] Source: file=audit.pdf, p.8`, and so on.

After every claim you make in your final answer, write the corresponding `[N]` token. In OloLand-aware UIs (the AI Assistant, Claude Cowork, Claude Code with the plugin loaded), these become clickable links that open the source PDF at the cited page.

Examples:
- "SigmaTron's revenue declined 18.5% YoY to $304.7M in FY2025 [1]."
- "Auditors flagged a material weakness in revenue recognition [2], and the company has been in covenant default since August 2024 [3, 5]."
- "Combined leverage stands at 5.0x EBITDA [1, 4]."

Use multiple numbers in one bracket — `[1, 4]` — when a single claim is supported by multiple chunks. Order them ascending.

## Rules (hard)

1. **Never invent numbers.** Only cite `[N]` values that actually appeared in a tool result this turn. If you didn't retrieve chunk `[7]`, do not write `[7]`. OloLand-aware runtimes will strip out-of-range markers and log a warning when this happens — the answer looks worse, not better, with stale numbers.
2. **No citation, no figure.** If you cannot cite the source, do not state the number. Say what you searched and what is still missing.
3. **Reconcile conflicts explicitly.** If `[1]` reports $X and `[3]` reports $Y, surface the discrepancy and cite both. Use the `source-hierarchy` skill to decide which one leads.
4. **Computed metrics show the formula and cite each input.** "EBITDA margin = $7.7M ÷ $304.7M = 2.5% [1]" — the inputs come from `[1]`.
5. **No round-trip hallucination.** Don't restate a number you computed as if a source said it.
6. **Greetings and identity questions don't need citations.** This rule only applies when you're answering a factual deal question.

## Failure modes to avoid

- Plausible-sounding numbers without `[N]`. You know industry norms; don't substitute those for actual deal data.
- Stale citations. If `[3]` is an FY2023 figure and the user asked about FY2025, flag the staleness in prose AND keep the citation.
- The old free-form "Source: <filename>" block at the end of the answer is no longer the contract. Use inline `[N]` after each claim instead — the UI renders inline citations as clickable superscripts; trailing source blocks render as plain text and the user can't click through to the document.
