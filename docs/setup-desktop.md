# Setup in the Claude desktop app (step by step)

No terminal needed. The desktop app includes Claude Code in its **Code** tab.

## Before you start
- [ ] A Claude plan that includes Claude Code (Pro, Max, Team or Enterprise)
- [ ] A **BigQuery connector** connected at [claude.ai → Connectors](https://claude.ai/customize/connectors). Connectors you add in claude.ai are available in Claude Code automatically when you're signed in with that account. On Team and Enterprise plans, an admin adds them.
- [ ] Ad data in BigQuery

## 1. Put the folder on your computer
Clone the repo, or download the ZIP and unzip it (for example into `Documents`).
The `.claude` folder is hidden in Finder. That's normal; Claude finds it automatically.

## 2. Open the folder in the Code tab
1. Open the Claude desktop app and click **Code** in the sidebar.
2. Under the prompt box, click the environment selector and choose **Local**.
3. Click the folder control, choose **Open folder…**, and select this folder.

Check it worked by typing: *"Which folder are you working in? List all files, including hidden ones."* You should see `CLAUDE.md`, `.claude/`, `context/`, `sql/`, `reports/`.

## 3. Set the permission mode to Manual
Use the mode selector in the row under the prompt box (or **Cmd+Shift+M** on macOS). Claude will ask before editing files or running tools, so you see everything at first.

## 4. Check the agents and the connector
> Which subagents do you have? Can you see the BigQuery connector? List its tool names.

You should see 5 agents, and a read-only SQL tool (e.g. `execute_sql_readonly`).

## 5. Run `/setup-project`
Type `/setup-project`. It will:
1. ask about your business (5–10 short questions)
2. discover your datasets and tables
3. list your Google Ads conversion actions and ask you to classify them
4. fill every `{{PLACEHOLDER}}` in `CLAUDE.md`, `context/` and `sql/`
5. run the main query as a test
6. block the connector's write tool in `.claude/settings.json`

Approve the edits as they come.

## 6. First run
> Use the perf-analyst subagent to run the daily check.

It takes 1–3 minutes. Open `reports/<date>-pacing.md` when it's done.

## 7. Iterate
Read the report critically. Correct it in plain language, for example: *"Update perf-analyst: don't flag brand campaigns for CPC changes under 2 €."* Claude edits the agent or `context/kpis.md` for you. Expect 3–5 rounds before it's good.

## 8. Add the rest, one at a time
tracking-qa → negatives-hunter → report-writer → competitor-watcher.

## 9. Schedule it
See [scheduling.md](scheduling.md).
