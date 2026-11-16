# KPIs, conversion hierarchy and alert thresholds

## Conversion hierarchy
Map your real conversion action names (exactly as they appear in the ad platform) to three levels.

| Level | Meaning | Google Ads action name(s) | Other channels |
|---|---|---|---|
| **North star** | Revenue event | `{{e.g. purchase}}` | {{Meta: purchases}} |
| **Qualified** | Strong intent / ICP signal | `{{e.g. qualified_signup}}`, `{{...}}` | {{Meta: leads}} |
| **Volume** | Top-of-funnel | `{{e.g. sign_up}}` | {{Microsoft: conversions}} |

Copy the same names into the `params` block of `sql/pacing_daily.sql`.

## Targets
| Metric | Target | Notes |
|---|---|---|
| CPA (north star) | {{CURRENCY}} {{X}} | |
| CPA (qualified) | {{CURRENCY}} {{X}} | |
| Monthly paid budget | {{CURRENCY}} {{X}} | |
| Payback window | {{e.g. 6 months}} | |

## Alert thresholds (used by perf-analyst)
Defaults; tune them after the first runs.

| Alert | Rule | Default |
|---|---|---|
| Spend anomaly | D-1 spend vs 14-day average | ± 25% |
| CPC spike | D-1 CPC vs 14-day average | + 30% |
| Zero-conversion campaign | spend in D-7..D-4 with 0 key conversions | > {{CURRENCY}} 50 |
| Conversion drop | key conversions, window ending D-3 vs baseline | − 40% |
| Tracking break | a conversion action at 0 across ALL campaigns | 2+ days |

## Known normal patterns (don't alert on these)
- {{e.g. weekend spend drops ~40% on B2B campaigns}}
- {{e.g. brand CPC spikes on Mondays}}
