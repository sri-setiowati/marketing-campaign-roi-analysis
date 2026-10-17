-- 11_zero_conversion_streaks.sql
-- Question: which campaigns kept spending for several days in a row with no conversions
-- although they normally convert every day?
-- Gaps-and-islands: consecutive dates share the same (julian day - row number) value.
-- Threshold: at least 4 days in a row. A campaign that averages 2.5 conversions a day has about an 8%
-- chance of a zero day by luck. Across roughly 2,450 campaign-days, a run of 3 produces about one false
-- alarm, while a run of 4 produces about 0.1.

WITH base AS (
    SELECT campaign_id,
           date,
           spend_idr,
           conversions,
           AVG(conversions) OVER (PARTITION BY campaign_id) AS avg_daily_conversions
    FROM daily_performance
),
zero_days AS (
    SELECT *,
           julianday(date) - ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY date) AS island
    FROM base
    WHERE conversions = 0 AND avg_daily_conversions >= 2
)
SELECT z.campaign_id,
       c.campaign_name,
       MIN(z.date)                     AS first_day,
       MAX(z.date)                     AS last_day,
       COUNT(*)                        AS days,
       SUM(z.spend_idr)                AS spend_idr,
       ROUND(MAX(z.avg_daily_conversions), 1) AS normal_daily_conversions
FROM zero_days z
JOIN campaigns c USING (campaign_id)
GROUP BY z.campaign_id, c.campaign_name, z.island
HAVING COUNT(*) >= 4
ORDER BY days DESC;
