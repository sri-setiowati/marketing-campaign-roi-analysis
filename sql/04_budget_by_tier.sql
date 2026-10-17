-- 04_budget_by_tier.sql
-- Question: how much money sits in each tier, and how much of it is not coming back?
-- "Net loss" is spend minus net revenue; it ignores product margin, so it is an upper bound on cash lost.

WITH scored AS (
    SELECT channel,
           spend,
           net_revenue,
           CASE WHEN 1.0 * net_revenue / spend >= 3   THEN 'Scale'
                WHEN 1.0 * net_revenue / spend >= 1.5 THEN 'Keep'
                WHEN 1.0 * net_revenue / spend >= 1   THEN 'Fix'
                ELSE 'Cut' END AS tier
    FROM v_campaign_summary
)
SELECT tier,
       COUNT(*)                                                    AS campaigns,
       SUM(spend)                                                  AS spend_idr,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 1)      AS spend_share_pct,
       SUM(net_revenue)                                            AS net_revenue_idr,
       ROUND(1.0 * SUM(net_revenue) / SUM(spend), 2)               AS roas_net,
       SUM(spend) - SUM(net_revenue)                               AS spend_minus_net_revenue_idr
FROM scored
GROUP BY tier
ORDER BY CASE tier WHEN 'Scale' THEN 1 WHEN 'Keep' THEN 2 WHEN 'Fix' THEN 3 ELSE 4 END;
