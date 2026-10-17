-- 02_channel_performance.sql
-- Question: how does each channel perform across the funnel, from impression to net revenue?
-- Ratios are computed from summed totals, not by averaging campaign ratios.

SELECT channel,
       SUM(spend)                                                        AS spend_idr,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 1)            AS spend_share_pct,
       SUM(impressions)                                                  AS impressions,
       SUM(clicks)                                                       AS clicks,
       ROUND(100.0 * SUM(clicks) / SUM(impressions), 2)                  AS ctr_pct,
       ROUND(1.0 * SUM(spend) / SUM(clicks), 0)                          AS cpc_idr,
       ROUND(100.0 * SUM(conversions) / SUM(clicks), 2)                  AS cvr_pct,
       SUM(new_customers)                                                AS new_customers,
       ROUND(1.0 * SUM(spend) / SUM(new_customers), 0)                   AS cac_idr,
       ROUND(1.0 * SUM(reported_revenue) / SUM(spend), 2)                AS roas_reported,
       ROUND(1.0 * SUM(net_revenue) / SUM(spend), 2)                     AS roas_net,
       ROUND(100.0 * SUM(non_completed_orders) / SUM(orders), 1)         AS non_completed_pct
FROM v_campaign_summary
GROUP BY channel
ORDER BY roas_net DESC;
