# Ad accounts: structure, naming, budgets

## Campaign tiers
| Tier | Purpose | Campaign name pattern | Bidding | Daily budget |
|---|---|---|---|---|
| Brand | Protect brand searches | `{{e.g. BRAND_*}}` | {{e.g. Target impression share}} | {{X}} |
| Core | High-intent non-brand | `{{...}}` | {{e.g. tCPA / tROAS}} | {{X}} |
| Prospecting | Broader discovery | `{{...}}` | | {{X}} |

Cross-tier rule: brand terms are negatives in non-brand tiers, and vice versa where relevant.

## Naming convention
{{e.g. CHANNEL_TIER_GEO_THEME, such as GADS_CORE_ES_contracts}}

## Irrelevant-intent themes (used by negatives-hunter)
Generic defaults. Add terms in your own language and industry.

| Theme | Example terms | Action |
|---|---|---|
| Students / education | student, homework, thesis, course, exam, university | Negative |
| Jobs | job, career, salary, internship, hiring | Negative |
| Free / DIY | free, download, template free, crack | Review, since some of this can be valid intent |
| Wrong product | {{other products that share your keywords}} | Negative |
| Competitors | {{competitor brands}} | Review: a strategic call, never auto-negate |
| {{YOUR THEME}} | {{terms}} | |
