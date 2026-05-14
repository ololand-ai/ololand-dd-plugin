---
name: forensic-qoe
description: Use when performing forensic quality-of-earnings analysis before any IC-ready synthesis on a target — runs the deterministic OloLand forensic battery (Beneish, Benford, EBITDA bridge, revenue quality, working capital, journal entry testing, lapping) rather than inferring conclusions from prose.
---

# Forensic Quality of Earnings

Use deterministic OloLand tools for forensic checks. Do not infer forensic conclusions from prose alone — the verifier-stack premise is that every QoE conclusion comes from a tool with a documented methodology and inputs.

## Minimum screen — always run before IC

Each of these is available as an MCP tool / `/`-command in this plugin:

| Procedure | When required | Tool / command |
|---|---|---|
| **Beneish M-Score** | Every target. Earnings-manipulation probability. | `/cmd-beneish` |
| **Benford distribution review** | Whenever transaction-level GL data is available. Flags fabricated entries. | `/cmd-benford` |
| **EBITDA bridge and adjustment quality** | Every target. Walks from reported EBITDA to QoE-adjusted EBITDA with explicit adjustment categories. | `/cmd-ebitda-bridge` |
| **Revenue quality deep dive** | Whenever invoice-level or revenue-by-customer detail is available. | manual + tool stack |
| **Working capital anomaly review** | Every target. DSO/DIO/DPO trends + seasonality. | manual + tool stack |
| **Journal entry testing** | Whenever transaction-level data is available. Tests journal entries against fraud patterns (round numbers, period-end clustering, manual entries from privileged users). | `/cmd-journal-test` |
| **Lapping detection** | Whenever AR aging and cash receipts can be reconciled. | `/cmd-lapping-check` |

## When inputs are missing

State the limitation explicitly. Do not fabricate a conclusion from incomplete data:

- "Benford's review requires transaction-level GL data. The data room contains only summary financials; this procedure was not run."
- "Lapping detection requires AR aging matched with cash receipts. AR aging was provided; cash receipts were not. Procedure deferred."

A QoE that skips a procedure because the data is missing is not a QoE failure — but the IC memo must surface the gap as a diligence condition.

## Output format

For each procedure that ran:
- **Result** — Pass / Yellow / Red
- **Evidence basis** — what data was used (file, period)
- **Methodology note** — one sentence on what the procedure tests
- **Next-step recommendation** if Yellow or Red — what to ask management or what additional data to request

For each procedure that did NOT run:
- **Status** — Not run (reason)
- **Required input** — what would unlock this procedure

This output shape is what the `/cmd-forensic-screen` and `/cmd-dd-analyze` commands aggregate into a Pre-LOI Screen and full Forensic QoE respectively.
