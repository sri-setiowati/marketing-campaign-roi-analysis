-- 06_quarterly_cac_by_channel.sql
-- Question: is the rise in CAC spread across channels, or driven by a few?

WITH spend AS (
    SELECT c.channel,
           'Q' || ((CAST(substr(d.date, 6, 2) AS INTEGER) + 2) / 3) AS quarter,
           SUM(d.spend_idr) AS spend
    FROM daily_performance d
    JOIN campaigns c USING (campaign_id)
    GROUP BY 1, 2
),
newc AS (
    SELECT acquisition_channel AS channel,
           'Q' || ((CAST(substr(first_order_date, 6, 2) AS INTEGER) + 2) / 3) AS quarter,
           COUNT(*) AS new_customers
    FROM customers
    GROUP BY 1, 2
)
SELECT s.channel,
       s.quarter,
       s.spend                                   AS spend_idr,
       n.new_customers,
       ROUND(1.0 * s.spend / n.new_customers, 0) AS cac_idr,
       ROUND(100.0 * (1.0 * s.spend / n.new_customers
             / LAG(1.0 * s.spend / n.new_customers) OVER (PARTITION BY s.channel ORDER BY s.quarter) - 1), 1) AS cac_change_pct
FROM spend s
JOIN newc n USING (channel, quarter)
ORDER BY s.channel, s.quarter;
