-- pacing_daily.sql
-- Daily performance per channel × campaign, last 21 days (D-21 .. D-1).
-- Google Ads uses the standard BigQuery Data Transfer schema (same table names for every advertiser).
-- Other channels: uncomment and adapt the blocks at the bottom (see context/data-dictionary.md).
--
-- Placeholders to replace (or run /setup-project):
--   {{GCP_PROJECT_ID}}  {{GOOGLE_ADS_DATASET}}  {{GOOGLE_ADS_CUSTOMER_ID}}  {{TIMEZONE}}
--   and the conversion action names in the params CTE (see context/kpis.md)
--
-- Output columns:
--   date, channel, campaign, spend, clicks, impressions,
--   north_star_conv   Google: actions listed in north_star_actions
--   qualified_conv    Google: actions listed in qualified_actions
--   volume_conv       Google: actions listed in volume_actions
--   platform_conv     Other channels: their own conversion column | Google: NULL
-- NOTE: the last 3 days of conversions are provisional (conversion lag).

WITH params AS (
  SELECT
    DATE_SUB(CURRENT_DATE('{{TIMEZONE}}'), INTERVAL 21 DAY) AS d_from,
    DATE_SUB(CURRENT_DATE('{{TIMEZONE}}'), INTERVAL 1 DAY)  AS d_to,
    ['{{NORTH_STAR_ACTION}}']                         AS north_star_actions,  -- e.g. ['purchase']
    ['{{QUALIFIED_ACTION_1}}', '{{QUALIFIED_ACTION_2}}'] AS qualified_actions,   -- e.g. ['qualified_signup']
    ['{{VOLUME_ACTION}}']                             AS volume_actions       -- e.g. ['sign_up']
),

-- ---------- Google Ads (standard Data Transfer tables) ----------
google_cost AS (
  SELECT segments_date AS date, campaign_id,
         SUM(metrics_cost_micros) / 1e6 AS spend,
         SUM(metrics_clicks)            AS clicks,
         SUM(metrics_impressions)       AS impressions
  FROM `{{GCP_PROJECT_ID}}.{{GOOGLE_ADS_DATASET}}.ads_CampaignBasicStats_{{GOOGLE_ADS_CUSTOMER_ID}}`, params
  WHERE segments_date BETWEEN d_from AND d_to
  GROUP BY 1, 2
),
google_conv AS (
  -- Conversions by action. Never use BasicStats.metrics_conversions: it sums ALL primary actions.
  SELECT segments_date AS date, campaign_id,
         SUM(IF(segments_conversion_action_name IN UNNEST(north_star_actions), metrics_conversions, 0)) AS north_star_conv,
         SUM(IF(segments_conversion_action_name IN UNNEST(qualified_actions),  metrics_conversions, 0)) AS qualified_conv,
         SUM(IF(segments_conversion_action_name IN UNNEST(volume_actions),     metrics_conversions, 0)) AS volume_conv
  FROM `{{GCP_PROJECT_ID}}.{{GOOGLE_ADS_DATASET}}.ads_CampaignConversionStats_{{GOOGLE_ADS_CUSTOMER_ID}}`, params
  WHERE segments_date BETWEEN d_from AND d_to
  GROUP BY 1, 2
),
google_names AS (
  SELECT campaign_id, ANY_VALUE(campaign_name) AS campaign_name
  FROM `{{GCP_PROJECT_ID}}.{{GOOGLE_ADS_DATASET}}.ads_Campaign_{{GOOGLE_ADS_CUSTOMER_ID}}`
  WHERE _DATA_DATE = _LATEST_DATE
  GROUP BY 1
),
google AS (
  SELECT date, 'google' AS channel,
         COALESCE(n.campaign_name, CAST(campaign_id AS STRING)) AS campaign,
         IFNULL(c.spend, 0) AS spend, IFNULL(c.clicks, 0) AS clicks, IFNULL(c.impressions, 0) AS impressions,
         IFNULL(v.north_star_conv, 0) AS north_star_conv,
         IFNULL(v.qualified_conv, 0)  AS qualified_conv,
         IFNULL(v.volume_conv, 0)     AS volume_conv,
         CAST(NULL AS FLOAT64)        AS platform_conv
  FROM google_cost c
  FULL OUTER JOIN google_conv v USING (date, campaign_id)
  LEFT JOIN google_names n USING (campaign_id)
)

-- ---------- Other channels: uncomment and map columns ----------
-- , meta AS (
--   SELECT date, 'meta' AS channel, campaign_name AS campaign,
--          SUM(spend) AS spend, SUM(link_clicks) AS clicks, SUM(impressions) AS impressions,
--          CAST(NULL AS FLOAT64) AS north_star_conv, CAST(NULL AS FLOAT64) AS qualified_conv,
--          CAST(NULL AS FLOAT64) AS volume_conv,
--          SUM({{META_CONVERSION_COLUMN}}) AS platform_conv          -- e.g. leads, purchases
--   FROM `{{GCP_PROJECT_ID}}.{{META_DATASET}}.{{META_TABLE}}`, params
--   WHERE date BETWEEN d_from AND d_to
--   GROUP BY 1, 2, 3
-- )
-- , microsoft AS (
--   SELECT date, 'microsoft' AS channel, campaign_name AS campaign,
--          SUM(cost) AS spend, SUM(clicks) AS clicks, SUM(impressions) AS impressions,
--          CAST(NULL AS FLOAT64) AS north_star_conv, CAST(NULL AS FLOAT64) AS qualified_conv,
--          CAST(NULL AS FLOAT64) AS volume_conv,
--          SUM(conversions) AS platform_conv
--   FROM `{{GCP_PROJECT_ID}}.{{MSADS_DATASET}}.{{MSADS_TABLE}}`, params
--   WHERE date BETWEEN d_from AND d_to
--   GROUP BY 1, 2, 3
-- )

SELECT * FROM google
-- UNION ALL SELECT * FROM meta
-- UNION ALL SELECT * FROM microsoft
ORDER BY channel, campaign, date
