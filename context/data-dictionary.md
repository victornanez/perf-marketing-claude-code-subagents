# Data dictionary

Every table the agents may query. Use fully qualified names: `{{GCP_PROJECT_ID}}.<dataset>.<table>`.

---

## Google Ads: BigQuery Data Transfer Service (standard schema)

These table names are **the same for every advertiser** who uses the native Google Ads → BigQuery transfer.
Only the dataset name and the customer ID suffix change.

- Dataset: `{{GOOGLE_ADS_DATASET}}` (e.g. `google_ads`)
- Customer ID suffix: `{{GOOGLE_ADS_CUSTOMER_ID}}` (10 digits, no dashes)
- The transfer creates `ads_<Report>_<CUSTOMER_ID>` **views** (use these) on top of `p_ads_...` partitioned tables.

| What | Table | Key columns |
|---|---|---|
| Campaign daily stats | `ads_CampaignBasicStats_{{GOOGLE_ADS_CUSTOMER_ID}}` | segments_date, campaign_id, metrics_cost_micros, metrics_clicks, metrics_impressions, metrics_conversions |
| Conversions by action | `ads_CampaignConversionStats_{{GOOGLE_ADS_CUSTOMER_ID}}` | segments_date, campaign_id, segments_conversion_action_name, segments_conversion_action_category, metrics_conversions, metrics_conversions_value |
| Search terms | `ads_SearchQueryStats_{{GOOGLE_ADS_CUSTOMER_ID}}` | segments_date, campaign_id, ad_group_id, search_term_view_search_term, segments_search_term_match_type, metrics_cost_micros, metrics_clicks |
| Search terms by action | `ads_SearchQueryConversionStats_{{GOOGLE_ADS_CUSTOMER_ID}}` | as above + conversion action segments |
| Keywords | `ads_KeywordStats_{{GOOGLE_ADS_CUSTOMER_ID}}` | keyword metrics |
| Campaign attributes | `ads_Campaign_{{GOOGLE_ADS_CUSTOMER_ID}}` | campaign_id, campaign_name, campaign_status, campaign_bidding_strategy_type, campaign_budget_amount_micros |

Rules:
- Cost: `metrics_cost_micros / 1e6`.
- Attribute tables (`ads_Campaign_...`) are daily snapshots. Filter `_DATA_DATE = _LATEST_DATE` for current names and budgets.

---

## Other channels: normalize to one shape

Every loader (Fivetran, Airbyte, Supermetrics, platform scripts…) names things differently. The simplest fix is one view per channel with the same columns:

```
{{DATASET}}.campaign_daily
  date DATE, campaign_id STRING, campaign_name STRING,
  spend FLOAT64, clicks INT64, impressions INT64, conversions FLOAT64
```

| Channel | Table / view | Spend col | Clicks col | Conversion col | Notes |
|---|---|---|---|---|---|
| Microsoft Ads | `{{MSADS_TABLE}}` | {{cost}} | {{clicks}} | {{conversions}} | |
| Meta Ads | `{{META_TABLE}}` | {{spend}} | {{link_clicks}} | {{e.g. leads / registrations / purchases}} | |
| LinkedIn Ads | `{{LINKEDIN_TABLE}}` | | | | |
| Other | | | | | |

Delete the rows for channels you don't run.

---

## Backend truth (optional, highly recommended)

What really happened in your product or CRM, independent of ad-platform attribution.

| What | Table | Key columns |
|---|---|---|
| Sign-ups / leads | `{{SIGNUPS_TABLE}}` | {{user_id, signup_date, source, medium, campaign}} |
| Purchases / subscriptions | `{{PURCHASES_TABLE}}` | {{customer_id, event_date, amount}} |
| GA4 raw export | `{{GA4_DATASET}}.events_*` | event_date, event_name, `_TABLE_SUFFIX` = YYYYMMDD |

---

## Data gotchas (read before analysing)

- **Google Ads `metrics_conversions` in BasicStats sums ALL primary conversion actions.** If sign-ups, micro-conversions and purchases are all primary, the "conversions" column mixes them and can be many times your real purchases. Always compute CPA from `ads_CampaignConversionStats_*` filtered by action name.
- **Conversion lag.** Ad-platform conversions for the last 2–3 days are incomplete and get restated. Use D-1 for spend and clicks; use windows ending D-3 for conversions and CPA.
- **GA4 raw export does not backfill**, but the Google Ads UI does. Don't compare them day by day.
- **GA4 `traffic_source.*` is user-scoped first touch**, not session source.
- {{ADD YOUR OWN GOTCHAS HERE AS YOU FIND THEM}}
