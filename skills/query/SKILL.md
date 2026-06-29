---
description: Turn a plain-language question into a SQL query (BigQuery / PostgreSQL / MySQL) so you can answer product questions yourself. Use when you know the question but not the SQL. Read-only by default; applies the security baseline.
disable-model-invocation: true
---

# Query (natural language to SQL)

Get the number yourself instead of waiting on an analyst. Describe the question; get a
correct, readable query for your database.

## When to use
- You have a product question ("how many users invoiced last week?") and data access, but want the SQL written or checked.

## Process
1. **Clarify:** which tables/columns, which dialect (BigQuery / PostgreSQL / MySQL), the exact question + time window.
2. Write a **read-only** query (SELECT). Clarity over cleverness; comment non-obvious logic.
3. Explain what it returns and the **assumptions** (timezone, dedup, how "active" is defined).
4. Note performance caveats (missing index, full table scan) if relevant.

## Safety rules (important, ties to the security baseline)
- **Read-only by default.** Never generate INSERT/UPDATE/DELETE/DROP or DDL unless the user explicitly asks and confirms; warn clearly if they do.
- Never concatenate untrusted input into SQL; parameterize values.
- No secrets/credentials in the query or connection string.

## Output
A commented SQL query + a plain-language explanation of the result and its assumptions.

## Example (PostgreSQL: active freelancers who invoiced at least once last week)
```sql
SELECT COUNT(DISTINCT u.id)
FROM users u
JOIN invoices i ON i.user_id = u.id
WHERE i.created_at >= date_trunc('week', now()) - interval '1 week'
  AND i.created_at <  date_trunc('week', now());
```

## Quality rules
- Read-only unless explicitly told otherwise; never silently mutate data.
- Clear over clever; comment the logic; state assumptions.
- No secrets in queries; no string-concatenated user input.
