-- 01_views.sql
-- Reusable views on top of the four clean tables.
-- Conventions
--   net revenue = order_value_idr of orders with status 'Completed'
--   new customers = customers whose acquisition_campaign_id is the campaign
--   orders without a campaign_id are organic repeat orders and never count toward ad revenue

DROP VIEW IF EXISTS v_campaign_summary;
CREATE VIEW v_campaign_summary AS
WITH perf AS (
    SELECT campaign_id,
           SUM(spend_idr)    AS spend,
           SUM(impressions)  AS impressions,
           SUM(clicks)       AS clicks,
           SUM(add_to_cart)  AS add_to_cart,
           SUM(conversions)  AS conversions,
           SUM(revenue_idr)  AS reported_revenue,
           COUNT(*)          AS active_days
    FROM daily_performance
    GROUP BY campaign_id
),
ord AS (
    SELECT campaign_id,
           COUNT(*) AS orders,
           SUM(CASE WHEN status = 'Completed' THEN order_value_idr ELSE 0 END) AS net_revenue,
           SUM(CASE WHEN status <> 'Completed' THEN 1 ELSE 0 END)              AS non_completed_orders
    FROM orders
    WHERE campaign_id IS NOT NULL
    GROUP BY campaign_id
),
cust AS (
    SELECT acquisition_campaign_id AS campaign_id, COUNT(*) AS new_customers
    FROM customers
    GROUP BY acquisition_campaign_id
)
SELECT c.campaign_id,
       c.campaign_name,
       c.channel,
       c.objective,
       c.start_date,
       c.end_date,
       p.active_days,
       p.spend,
       p.impressions,
       p.clicks,
       p.add_to_cart,
       p.conversions,
       p.reported_revenue,
       o.net_revenue,
       o.orders,
       o.non_completed_orders,
       COALESCE(u.new_customers, 0) AS new_customers
FROM campaigns c
JOIN perf p ON p.campaign_id = c.campaign_id
LEFT JOIN ord  o ON o.campaign_id = c.campaign_id
LEFT JOIN cust u ON u.campaign_id = c.campaign_id;
