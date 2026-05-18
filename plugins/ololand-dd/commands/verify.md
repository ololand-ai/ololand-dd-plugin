---
description: "Verify every number and citation in an OloLand artifact (CIM paragraph, IC memo, risk narrative, DCF write-up) against the deal's source documents and deterministic engine runs. Runs the four atomic-claim verifiers + optional citation-marker audit + cross-document reconciliation. The 'defend every number, cite every source' button."
---

# /verify

You are running OloLand's verifier stack against an artifact and a deal. This is the user-facing surface for the four atomic-claim verifiers that back the "verifiable outputs" guarantee.

## Required inputs

Ask the user for these if missing:

1. **deal_id** — the OloLand deal whose source documents back the verification.
2. **text** — the artifact text to verify. Accept any of:
   - A paragraph or section pasted inline.
   - A path to a local file (read it with your file tool, then pass the contents).
   - The output of a previous OloLand command (e.g., the IC memo body, a CIM section, a risk narrative).

Optional:
- **include_dcf_arithmetic** (default `true`) — also replay the DCF identity checks against the deal's stored `DCFRun`. Set to `false` if the artifact does not reference a DCF.
- **audit_markers** (default `true` when the artifact contains `[N]` markers) — also run `check_citation_coverage` to audit the `[N]` markers.

## Action

1. Call `mcp__ololand__run_atomic_verifiers` with `deal_id`, `text`, and `include_dcf_arithmetic`.
2. If the artifact contains any `[N]` markers, also call `mcp__ololand__check_citation_coverage` with the same `deal_id` and `text`. (Detect with a quick regex on the text — `\[\d+\]` excluding `[EK:N]`.)
3. If the user signals this is an IC memo or final report (i.e., wants a full audit, not just a spot-check), also call `mcp__ololand__reconcile_documents` with `deal_id`. This walks the CPA > tax > management > AI source hierarchy across the deal's stored financial observations.

## Output

Render a single human-readable verdict block, in this order:

```
Verifier verdict for <deal_id>:
  Inline numbers:      <supported>/<total> supported  [PASS|FAIL]
  Claim chunks:        <supported>/<total> supported  [PASS|FAIL]
  Citation existence:  <valid>/<total> valid          [PASS|FAIL|N/A]
  DCF arithmetic:      <status>                        [PASS|FAIL|N/A]
  [N] markers:         <in_range> in-range,
                       <out_of_range> out-of-range    [PASS|FAIL|N/A]
  Cross-doc reconcile: <reconciled>/<total> metrics   [optional, IC only]

Overall: <PASS|FAIL>
```

Then list up to 10 unsupported numbers and unsupported claims verbatim (the most damaging review-cycle items). For each unsupported number, quote the `raw` field. For each unsupported claim, quote the sentence.

If the artifact is going into IC or a regulator-facing deliverable and the verdict is FAIL, recommend the user:

1. Re-run `mcp__ololand__search_deal_documents` for any unsupported claim to locate the missing source.
2. Fix the citation with an inline `[N]` marker pointing at the retrieved chunk.
3. If a number cannot be sourced, remove the claim or downgrade it to qualitative language.

## When to use this

- Right before submitting an IC memo, CIM, or board-pack section.
- During a partner review when a number "looks off".
- As a pre-commit check on AI-generated risk narratives before they land in `analyst_corrections`.
- Mid-conversation, after any agent finishes generating a deal-bound artifact — `/verify` it against the same deal.

## When NOT to use this

- For prose that contains no numbers and no citations — the verifier has nothing to check.
- For non-deal artifacts (general M&A commentary, market color, methodology notes).
- Pre-ingestion — verifiers need a populated deal corpus to retrieve chunks against. If `citations_available` is 0, ingest documents first.

Companion skill: `verifier-stack` (auto-loads with this command and explains the methodology and the limits of each verifier).
