[SKILL.md](https://github.com/user-attachments/files/34940255/SKILL.md)
---
name: setup-project
description: Interactive onboarding. Interviews the user about their business, discovers their BigQuery ad data through the BigQuery connector, and fills every {{PLACEHOLDER}} in CLAUDE.md, context/ and sql/. Run once after cloning the repo.
---

# Set up this project for a new user

Goal: replace every `{{PLACEHOLDER}}` with real values, then prove the pipeline works with one real query.
Work step by step. Ask a few questions at a time, never all at once.

## 1. Business (fills CLAUDE.md, context/kpis.md, context/accounts.md)
Ask:
- Company name and a one-line product description
- Funnel (e.g. sign-up → activation → purchase, or lead → MQL → SQL → won)
- Ideal customer, and who is NOT a customer (students, job seekers, …)
- Paid channels they run
- Owner name (the human who approves changes), currency, timezone
- Any current risk (migration, tracking change, new market)
- Campaign tiers and naming convention, if they have one

## 2. Data discovery (fills context/data-dictionary.md)
Use the BigQuery connector's read-only tools only.
1. Ask for the GCP project ID and the BigQuery region (e.g. `EU`, `US`, `europe-west1`).
2. List datasets. If the list-datasets tool returns nothing, run:
   `SELECT schema_name FROM \`<project>.region-<region>.INFORMATION_SCHEMA.SCHEMATA\``
3. List tables and columns:
   `SELECT table_schema, table_name, STRING_AGG(column_name, ', ') FROM \`<project>.region-<region>.INFORMATION_SCHEMA.COLUMNS\` GROUP BY 1, 2`
4. Detect the Google Ads Data Transfer dataset: tables named `ads_CampaignBasicStats_<10 digits>`. The digits are the customer ID.
5. List conversion action names from the last 30 days:
   `SELECT segments_conversion_action_name, segments_conversion_action_category, SUM(metrics_conversions) FROM ads_CampaignConversionStats_<id> WHERE segments_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) GROUP BY 1, 2 ORDER BY 3 DESC`
   Ask the user which ones are north star, qualified and volume. Write the mapping into `context/kpis.md`.
6. Detect other ad channels (Meta, Microsoft, LinkedIn…) and backend tables (sign-ups, purchases, GA4 `events_*`). Map their spend, clicks and conversion columns. Confirm with the user.

## 3. Fill the files
- `CLAUDE.md`, all `context/*.md`: replace placeholders. Delete rows for channels the user doesn't run.
- `sql/pacing_daily.sql`: replace project, dataset, customer ID, timezone and the conversion-action arrays in the `params` CTE. Uncomment and adapt the blocks for the other channels, or delete them.

## 4. Prove it works
Run `sql/pacing_daily.sql` wrapped in a summary (rows, campaigns, min/max date and total spend per channel). Show the result. If a channel returns 0 rows, fix the mapping before finishing.

## 5. Lock it down
1. List the BigQuery connector's tools with their full names.
2. Add the connector's write-capable SQL tool (e.g. `execute_sql`) to `deny` in `.claude/settings.json`. Add the read-only tools to `allow`.
3. Show the final settings file.

## 6. Finish
- List any placeholders still left.
- Remind the user: once `context/` holds real business data, keep their copy of the repo **private**.
- Suggest the first run: "Use the perf-analyst subagent to run the daily check."
