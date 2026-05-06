---
description: Search documents in a deal's data room — full-text + semantic search across uploaded PDFs, financials, legal docs.
---

# Deal Document Search

Search across all documents in a deal's data room using hybrid search (dense + sparse + rerank).

## Usage

```
/deal-search <deal_id> <query>
```

## Arguments

- `deal_id` (required) — The deal to search within.
- `query` (required) — Natural language search query.

## Execution

1. Call `search_deal_documents` with the deal_id and query.
2. Present results with:
   - Document name and page number
   - Relevant excerpt (highlighted match)
   - Relevance score
3. If the query implies a financial figure, cross-reference with `get_financial_snapshot` to check consistency.

## Examples

- `/deal-search deal123 customer concentration risk`
- `/deal-search deal123 revenue recognition policy`
- `/deal-search deal123 change of control provisions`
- `/deal-search deal123 EBITDA adjustments and add-backs`
