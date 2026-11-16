# Safety

## Principles
1. **Read-only data access.** Agents only run SELECT queries.
2. **No account changes.** Agents never call ad-platform write APIs. They produce recommendations and CSVs that you apply.
3. **No guessing.** Missing data is reported as missing.

## Block the connector's write tool
Many BigQuery connectors expose two SQL tools: one read-only, one that can write. Instructions alone aren't a guarantee, so deny the write tool in `.claude/settings.json`.

1. In a session, ask: *"List the BigQuery connector's tools with their full names."*
2. Add the write tool to `deny` and the read-only tools to `allow`:

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep", "Edit(reports/**)", "WebSearch", "WebFetch",
      "mcp__<connector-id>__execute_sql_readonly",
      "mcp__<connector-id>__get_table_info",
      "mcp__<connector-id>__list_table_ids",
      "mcp__<connector-id>__get_query_results"
    ],
    "deny": [
      "Bash(rm:*)",
      "mcp__<connector-id>__execute_sql"
    ]
  }
}
```

`/setup-project` does this for you.

## Least privilege in Google Cloud
The strongest guarantee sits outside Claude. The account behind the connector should only have:
- **BigQuery Data Viewer** on the ad datasets
- **BigQuery Job User** on the project

## Public repo vs your copy
- This template contains no data.
- Once you fill `context/` with real values, **keep your copy private**.
- `reports/`, `.claude/agent-memory/` and `CLAUDE.local.md` are gitignored by default.
