---
name: verifier-stack
description: Use when an OloLand artifact (CIM section, IC memo paragraph, risk narrative, DCF write-up) needs to be verified against the deal's source documents and deterministic engine runs — e.g. before partner review, before IC submission, or to spot-check a number that "looks off". Explains the four atomic-claim verifiers, what each catches, what each misses, and the right interpretation of PASS/FAIL.
---

# Verifier Stack

OloLand's verifier stack mechanically checks that every number in an artifact is supported by the deal's source documents, that every citation marker points at a real retrievable chunk, and that the deal's stored DCF identities hold. It is the "defend every number, cite every source" guarantee in code, not in marketing copy.

## What the verifiers actually do

### `verify_inline_numbers`

Extracts every dollar amount and every percentage from the artifact text. For each number, checks whether it appears (within 5% relative / 0.5pt absolute tolerance) in at least one chunk retrieved from the deal corpus.

- **Catches:** fabricated revenue figures, transposed digits (e.g. $34.2M vs $32.4M), unit drift (`$304K` reported as `$304M`).
- **Misses:** numbers that happen to appear in the corpus by coincidence (e.g. a generic "$1M" mentioned in a risk factor section); numbers that are derived but never raw in the source (e.g. growth rates the analyst computed correctly but the chunk only shows the underlying revenues).

### `verify_claim_chunks`

Stricter than `verify_inline_numbers`. Splits the text into sentences containing financial numbers. A sentence passes only when **all** of its numbers can be matched in a single chunk.

- **Catches:** sentences that stitch together unrelated numbers from different sources (a tell for hallucinated synthesis).
- **Misses:** the same coincidence cases as above.

### `verify_citation_existence`

For artifacts that use the legacy `[Source: file=..., p.N]` block format: extracts every block and validates that the filename exists in the deal's document set (with fuzzy matching) and the cited page is in range.

- **Catches:** invented filenames, wrong page numbers.
- **Skipped:** when the artifact uses the modern `[N]` marker format only — that's audited by `check_citation_coverage`.

### `verify_dcf_arithmetic`

Replays the two DCF identities against the deal's most recent `DCFRun`:

1. `enterprise_value == pv_fcf_sum + pv_terminal_value`
2. `equity_value == enterprise_value - net_debt`

Tolerance: 0.1% relative.

- **Catches:** internally inconsistent DCF models — a load-bearing check, because every number cited from a broken DCF is suspect even if it appears verbatim in the source.
- **Status `no_data`** when the deal has no `DCFRun` — pass `include_dcf_arithmetic=false` if the artifact does not reference a DCF.

### `check_citation_coverage` (`[N]` marker audit)

Counts `[N]` markers in the artifact, retrieves the same chunk set the verifier uses, and reports markers that fall outside the available range. The orchestrator drops out-of-range markers at turn end; this lets external callers see the same view.

- **Catches:** markers the model invented (e.g. `[12]` when only 8 chunks were retrieved).
- **Misses:** markers that are in-range but cite the wrong chunk (use `verify_claim_chunks` for that).

### `reconcile_documents`

Walks the CPA > tax > management > AI source hierarchy across `FinancialDataSnapshot` and `AIExtractedFinancialMetric` observations. Returns per-metric reconciliation status (reconciled / discrepancy / unverified), recommended values, discrepancy spreads, and overall confidence.

- **Catches:** silent disagreements between CPA-audited financials and management-supplied numbers; AI-extracted figures that contradict primary sources.
- **Use when:** the artifact is going to IC or a regulator-facing deliverable. Skip for back-of-envelope work — it's heavier than the per-number verifiers.

## Interpreting the verdict

| Outcome | Meaning |
|---|---|
| `passed: true` | Every enabled verifier passed. The artifact is mechanically defensible. |
| `passed: false`, `citations_available: 0` | Verifier could not retrieve any chunks for the deal. **Not a fail of the artifact — a fail of the corpus.** Re-ingest documents and re-run. |
| Inline numbers FAIL, claim chunks PASS | Unusual — usually means a small number is uncited but each whole sentence is otherwise grounded. Investigate the specific `unsupported` entries. |
| Inline numbers PASS, claim chunks FAIL | A claim sentence mixes a verified number with an unverified one. Common in hallucinated synthesis. Fix the offending sentence. |
| DCF arithmetic `no_data` | No `DCFRun` for this deal. Either run DCF first, or pass `include_dcf_arithmetic=false`. |
| `out_of_range_dropped` non-empty | The model invented citation markers. Re-run the generator with stricter prompt grounding, or strip the invalid markers. |

## What the verifier is NOT

- **Not a fact-checker for prose.** It does not judge whether a qualitative claim ("the company has strong moats") is true. It only checks numbers and citations.
- **Not a grader.** It is a precondition for grading. A high grader score on an artifact with verifier-FAIL is structurally suspect.
- **Not a replacement for human IC review.** It catches the mechanical failure modes (fabricated numbers, dangling citations, broken DCF identities). Strategic, judgment-based review still belongs with the partner.

## Methodology references

- Atomic-claim verifiers: `backend/services/ai/scorers/inline_number_verifier.py`, `claim_chunk_verifier.py`, `citation_existence_checker.py`
- DCF identity check: `backend/services/harness/dd_tools.py::_verify_dcf_arithmetic`
- Source hierarchy + reconciliation: `backend/services/financial/cross_doc_reconciler.py`
- Citation-marker validation: `backend/services/agent_runtime/orchestrator.py::validate_citation_markers`

Companion command: `/verify`.
