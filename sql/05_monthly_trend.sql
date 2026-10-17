-- 05_monthly_trend.sql
-- Question: when did acquisition cost start rising, and what moved with it?
-- CAC = spend in the month / customers whose first order fell in that month.

WITH spend AS (
    SELECT substr(date, 1, 7) AS month,
           SUM(spend_idr)     AS spend,
           SUM(impressions)   AS impressions,
           SUM(clicks)        AS clicks,
           SUM(conversions)   AS conversions,
           SUM(revenue_idr)   AS reported_revenue
    FROM daily_performance
    GROUP BY 1
),
newc AS (
    SELECT substr(first_order_date, 1, 7) AS month, COUNT(*) AS new_customers
    FROM customers
    GROUP BY 1
),
net AS (
    SELECT substr(order_date, 1, 7) AS month,
           SUM(order_value_idr)     AS net_revenue
    FROM orders
    WHERE campaign_id IS NOT NULL AND status = 'Completed'
    GROUP BY 1
),
monthly AS (
    SELECT s.month,
           s.spend,
           n.new_customers,
           1.0 * s.spend / n.new_customers          AS cac,
           1000.0 * s.spend / s.impressions          AS cpm,
           100.0 * s.conversions / s.clicks          AS cvr_pct,
           1.0 * t.net_revenue / s.spend             AS roas_net
    FROM spend s
    JOIN newc n USING (month)
    JOIN net  t USING (month)
)
SELECT month,
       spend                                           AS spend_idr,
       new_customers,
       ROUND(cac, 0)                                   AS cac_idr,
       ROUND(100.0 * (cac / LAG(cac) OVER (ORDER BY month) - 1), 1) AS cac_change_pct,
       ROUND(cpm, 0)                                   AS cpm_idr,
       ROUND(cvr_pct, 2)                               AS cvr_pct,
       ROUND(roas_net, 2)                              AS roas_net
FROM monthly
ORDER BY month;
