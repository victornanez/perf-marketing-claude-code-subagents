# Run the agents on a schedule

Get the output right manually first. Then automate it.

## Option A: local scheduled task (simplest)
Runs on your computer, directly in this folder.
- Needs the desktop app open and the computer awake. If it was asleep, one catch-up run happens on wake.
- Reports land straight in `reports/`.

**Create it:** in a Code session in this folder, type:
> Create a scheduled task: weekdays at 8:40, in this folder, that runs "Use the perf-analyst subagent to run the daily check."

Then open the task (Code tab → **Scheduled**), click **Run now** once, and choose **always allow** for each prompt. Future runs won't stop to ask.

## Option B: cloud scheduled task (always on)
Runs on Anthropic's cloud, even with your computer off.
- The repo must be on GitHub (private, since it contains your context). Each run clones it fresh.
- Reports don't persist in the clone, so tell the task where to deliver them: email (Gmail connector), Slack, or a commit to a branch.
- Runs in auto mode. Keep only the connectors the task needs (BigQuery + your delivery channel).
- The connector's tool names can differ in the cloud. Check on the first run that the write tool is still blocked.

**Create it:** in a Code session, type `/schedule` and describe it, e.g.:
> Weekdays at 8:40, repo `<your-private-repo>`, prompt: "Use the perf-analyst subagent to run the daily check and email me the summary."

## Suggested cadence
| Agent | When |
|---|---|
| perf-analyst | Weekdays, morning |
| tracking-qa | Daily (hourly during a migration) |
| negatives-hunter | Weekly, Monday |
| competitor-watcher | Weekly |
| report-writer | Weekly, Monday after the others |
