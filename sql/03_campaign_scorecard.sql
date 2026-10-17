-- 03_campaign_scorecard.sql
-- Question: which campaigns earn their budget, and how much of the budget sits in the weak ones?
-- Tiers by net ROAS: Scale >= 3, Keep 1.5 to 3, Fix 1 to 1.5, Cut < 1.

WITH scored AS (
    SELECT campaign_id,
           campaign_name,
           channel,
           objective,
           spend,
           net_revenue,
           new_customers,
           ROUND(1.0 * net_revenue / spend, 2)    AS roas_net,
           ROUND(1.0 * spend / new_customers, 0)  AS cac_idr,
           CASE WHEN 1.0 * net_revenue / spend >= 3   THEN 'Scale'
                WHEN 1.0 * net_revenue / spend >= 1.5 THEN 'Keep'
                WHEN 1.0 * net_revenue / spend >= 1   THEN 'Fix'
                ELSE 'Cut' END                    AS tier
    FROM v_campaign_summary
)
SELECT campaign_id,
       campaign_name,
       channel,
       objective,
       spend                                                   AS spend_idr,
       net_revenue                                             AS net_revenue_idr,
       roas_net,
       cac_idr,
       tier,
       RANK() OVER (ORDER BY roas_net DESC)                    AS rank_overall,
       RANK() OVER (PARTITION BY channel ORDER BY roas_net DESC) AS rank_in_channel,
       ROUND(100.0 * spend / SUM(spend) OVER (), 1)            AS spend_share_pct
FROM scored
ORDER BY roas_net DESC;
