-- 10_anomaly_checks.sql
-- Question: are there days where the numbers look like a setup error or a tracking problem
-- instead of real performance?

-- A. Spend far above the campaign's own average
WITH spend_check AS (
    SELECT campaign_id,
           date,
           spend_idr,
           conversions,
           1.0 * spend_idr / AVG(spend_idr) OVER (PARTITION BY campaign_id) AS spend_vs_avg
    FROM daily_performance
)
SELECT s.campaign_id,
       c.campaign_name,
       s.date,
       s.spend_idr,
       ROUND(s.spend_vs_avg, 1) AS spend_vs_campaign_avg,
       s.conversions
FROM spend_check s
JOIN campaigns c USING (campaign_id)
WHERE s.spend_vs_avg >= 3
ORDER BY s.spend_vs_avg DESC;
