# Customize

## Tune an agent
Ask in plain language. Claude edits the right file:
- *"Raise the spend anomaly threshold to 35%."* → `context/kpis.md`
- *"Weekend drops are normal, don't flag them."* → "Known normal patterns" in `context/kpis.md`
- *"Add 'curso' and 'gratis' to the irrelevant themes."* → `context/accounts.md`

## Add a channel
1. Load the channel's data into BigQuery with any loader.
2. Ideally, create a view with the normalized shape: `date, campaign_id, campaign_name, spend, clicks, impressions, conversions`.
3. Add a row in `context/data-dictionary.md`.
4. Add a block to `sql/pacing_daily.sql`, copying the commented Meta or Microsoft block, and add it to the final `UNION ALL`.

## Create a new agent
Create `.claude/agents/<name>.md`:

```markdown
---
name: budget-pacer
description: Forecasts end-of-month spend vs budget per channel. Use when asked about budget pacing or monthly spend.
disallowedTools: Bash
model: sonnet
memory: project
---

You forecast monthly spend.

## Before anything
Read context/kpis.md (monthly budget) and context/data-dictionary.md.

## Process
1. ...
2. Save reports/YYYY-MM-DD-budget.md.
3. Return 5 lines max.

## Rules
- Read-only SQL. Never estimate missing data.
```

Tips:
- **`description` decides when the agent gets used.** Make it specific, and add "Use proactively" for automatic delegation.
- **Put the process in the agent, and facts in `context/`.**
- **Use `model: haiku` for simple checks and `sonnet` for analysis.**
- **Start a new session after adding an agent**, so it gets loaded.

Reference: [Claude Code subagents docs](https://code.claude.com/docs/en/sub-agents)
