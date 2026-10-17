-- 12_flag_sensitivity.sql
-- Question: do the repaired rows change the channel picture?
-- Compare net ROAS on all data with net ROAS when every campaign-day that contains
-- a repaired daily row or a repaired order is left out of both spend and revenue.

WITH flagged_days AS (
    SELECT campaign_id, date FROM daily_performance WHERE dq_flags IS NOT NULL AND dq_flags <> ''
    UNION
    SELECT campaign_id, order_date FROM orders
    WHERE campaign_id IS NOT NULL AND dq_flags IS NOT NULL AND dq_flags <> ''
),
spend_all AS (
    SELECT c.channel, SUM(d.spend_idr) AS spend
    FROM daily_performance d JOIN campaigns c USING (campaign_id)
    GROUP BY c.channel
),
spend_clean AS (
    SELECT c.channel, SUM(d.spend_idr) AS spend
    FROM daily_performance d
    JOIN campaigns c USING (campaign_id)
    LEFT JOIN flagged_days f ON f.campaign_id = d.campaign_id AND f.date = d.date
    WHERE f.campaign_id IS NULL
    GROUP BY c.channel
),
rev_all AS (
    SELECT c.channel, SUM(o.order_value_idr) AS rev
    FROM orders o JOIN campaigns c USING (campaign_id)
    WHERE o.status = 'Completed'
    GROUP BY c.channel
),
rev_clean AS (
    SELECT c.channel, SUM(o.order_value_idr) AS rev
    FROM orders o
    JOIN campaigns c USING (campaign_id)
    LEFT JOIN flagged_days f ON f.campaign_id = o.campaign_id AND f.date = o.order_date
    WHERE o.status = 'Completed' AND f.campaign_id IS NULL
    GROUP BY c.channel
)
SELECT sa.channel,
       ROUND(1.0 * ra.rev / sa.spend, 2)  AS roas_net_all_rows,
       ROUND(1.0 * rc.rev / sc.spend, 2)  AS roas_net_without_repaired_days,
       ROUND(100.0 * (1.0 * rc.rev / sc.spend) / (1.0 * ra.rev / sa.spend) - 100, 1) AS difference_pct,
       ROUND(100.0 * sc.spend / sa.spend, 1) AS share_of_spend_kept_pct
FROM spend_all sa
JOIN spend_clean sc USING (channel)
JOIN rev_all ra USING (channel)
JOIN rev_clean rc USING (channel)
ORDER BY sa.channel;
