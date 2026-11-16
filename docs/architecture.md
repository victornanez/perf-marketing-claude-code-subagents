# Context architecture

Every Claude Code session starts with an empty context window. What you put into it, and when, decides how good and how consistent the agents are.

## Three layers

### 1. Always loaded: `CLAUDE.md`
Loaded into the main session **and into every subagent**. Keep it under 100 lines.
- Business in five lines
- Golden rules (read-only, never estimate, owner approves)
- An index of the `context/` files and which agent reads which

### 2. On demand: `context/`
Reference knowledge. Each agent's instructions say which files to read first, so an agent only loads what its task needs.

| File | Content |
|---|---|
| `data-dictionary.md` | Tables, columns, joins, data gotchas |
| `kpis.md` | Conversion hierarchy (north star / qualified / volume), targets, alert thresholds, known normal patterns |
| `accounts.md` | Campaign tiers, naming, budgets, irrelevant-intent themes |
| `competitors.md` | Competitors and URLs |
| `decisions.md` | What you decided and why, so agents don't re-propose it |

> Why not `@import` them into CLAUDE.md? Imports load together with CLAUDE.md into *every* session, so they don't save context. Plain file references let each agent read only what it needs.

### 3. Learned: agent memory
Agents with `memory: project` in their frontmatter get a persistent folder at `.claude/agent-memory/<agent>/`. The first 200 lines of its `MEMORY.md` load each time the agent runs.
- Rule in every agent: **save only learnings the owner confirmed**, never guesses.
- Review it monthly. Delete anything stale.
- It's gitignored, because it can contain business data.

## What goes where

| Information | Home |
|---|---|
| A rule that always applies | `CLAUDE.md` |
| A fact about your data or business | `context/*.md` |
| How an agent does its job | `.claude/agents/<agent>.md` (process + output format, no facts) |
| A pattern an agent learned | agent memory |
| A decision you made | `context/decisions.md` |
| Results and history | `reports/` |
| Logic that must be identical every run | `sql/` |
| Your personal preferences | `CLAUDE.local.md` (gitignored) |

## Rules that keep it healthy

1. **Each fact lives in one place.** When an event name changes, update `kpis.md` once, and every agent picks it up.
2. **Agent files describe the process, not facts.** Facts go in `context/`.
3. **Tested SQL beats generated SQL** for recurring checks. Generated SQL is fine for ad-hoc questions.
4. **Session hygiene:**
   - Start a new session per unrelated task.
   - Type `/context` to see what's filling the window.
   - Type `/compact` when a session gets long.
   - Type `/memory` to review what Claude has learned.
