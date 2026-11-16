# {{COMPANY}} — Performance Marketing Agents

Loaded into EVERY session and EVERY subagent. Keep it under 100 lines.
Reference knowledge lives in `context/` and is read on demand (see the index below).

> Placeholders look like `{{THIS}}`. Run `/setup-project` to fill them in interactively.

## Business
- Product: {{ONE_LINE_PRODUCT_DESCRIPTION}}
- Business model / funnel: {{e.g. PLG: sign-up → activation → purchase | Lead gen: lead → MQL → SQL → won}}
- Ideal customer (ICP): {{WHO_YOU_WANT}}
- Not ICP: {{WHO_YOU_DONT_WANT, e.g. students, job seekers}}
- Paid channels: {{e.g. Google Ads, Microsoft Ads, Meta Ads, LinkedIn Ads}}
- Owner (approves every change): {{OWNER_NAME}}
- Current risks: {{e.g. site migration, tracking changes, new market launch}}

## Golden rules
1. READ-ONLY. Agents never change anything in ad accounts or the data warehouse. SELECT queries only.
2. Agents propose. {{OWNER_NAME}} approves and executes.
3. Never estimate missing data. Write "data missing" and name the table.
4. Currency {{CURRENCY}}. Timezone {{TIMEZONE}} (e.g. America/New_York).
5. Save every output to `reports/` with the date in the filename.
6. Reports: numbers first, bullets, no fluff.
7. Mark the last 3 days of ad-platform conversions as provisional (conversion lag).

## Data access
- Warehouse: BigQuery project `{{GCP_PROJECT_ID}}`, region `{{BQ_REGION}}`.
- Query through your BigQuery MCP connector's **read-only** SQL tool (on Google's BigQuery connector it is `execute_sql_readonly`).
- Never use a SQL tool that can write. Block it in `.claude/settings.json` (see `docs/safety.md`).
- If the connector fails, say so and stop. Never guess numbers.

## Context index (read on demand)
| File | What's in it | Read by |
|---|---|---|
| `context/data-dictionary.md` | Tables, columns, joins, data gotchas | perf-analyst, negatives-hunter, tracking-qa, report-writer |
| `context/kpis.md` | Conversion hierarchy, targets, alert thresholds | perf-analyst, tracking-qa, report-writer |
| `context/accounts.md` | Campaign tiers, naming, budgets, irrelevant-intent themes | perf-analyst, negatives-hunter |
| `context/competitors.md` | Competitor list and URLs | competitor-watcher, report-writer |
| `context/decisions.md` | Log of decisions and why | all agents, before recommending |

## Tested queries
- `sql/pacing_daily.sql`: channel × campaign × day, last 21 days. Read the file and run it with the read-only SQL tool.
