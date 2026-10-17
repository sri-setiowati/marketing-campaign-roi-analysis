-- 09_calendar_effects.sql
-- Question: do paydays, double dates and weekends change conversion rate?
-- Day types are exclusive and checked in this order: double date (1.1 to 9.9), payday window
-- (25th to the 2nd), weekend, regular weekday.

WITH typed AS (
    SELECT spend_idr, clicks, conversions, revenue_idr,
           CASE WHEN CAST(substr(date, 9, 2) AS INTEGER) = CAST(substr(date, 6, 2) AS INTEGER) THEN '1 Double date'
                WHEN CAST(substr(date, 9, 2) AS INTEGER) >= 25
                  OR CAST(substr(date, 9, 2) AS INTEGER) <= 2                                    THEN '2 Payday window'
                WHEN strftime('%w', date) IN ('0', '6')                                         THEN '3 Weekend'
                ELSE '4 Regular weekday' END AS day_type
    FROM daily_performance
)
SELECT substr(day_type, 3)                                  AS day_type,
       COUNT(*)                                             AS campaign_days,
       ROUND(100.0 * SUM(conversions) / SUM(clicks), 2)     AS cvr_pct,
       ROUND(1.0 * SUM(spend_idr) / COUNT(*), 0)            AS avg_spend_per_campaign_day,
       ROUND(1.0 * SUM(conversions) / COUNT(*), 2)          AS avg_conversions_per_campaign_day
FROM typed
GROUP BY day_type
ORDER BY day_type;
