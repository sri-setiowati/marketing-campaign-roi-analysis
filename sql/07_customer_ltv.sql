-- 07_customer_ltv.sql
-- Question: do cheap customers stay cheap once repeat purchases are counted?
-- Cohort: customers acquired January to April 2026, so each has at least five months to repurchase.
-- LTV here is Completed-order revenue per customer up to 30 Sep 2026. It is revenue, not margin.

WITH cohort AS (
    SELECT customer_id, acquisition_channel
    FROM customers
    WHERE first_order_date <= '2026-04-30'
),
per_customer AS (
    SELECT c.customer_id,
           c.acquisition_channel,
           COUNT(o.order_id)                                              AS orders,
           COALESCE(SUM(CASE WHEN o.status = 'Completed' THEN o.order_value_idr END), 0) AS net_revenue
    FROM cohort c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
),
ltv AS (
    SELECT acquisition_channel AS channel,
           COUNT(*)                                                   AS customers,
           ROUND(AVG(orders), 2)                                      AS orders_per_customer,
           ROUND(100.0 * AVG(CASE WHEN orders >= 2 THEN 1 ELSE 0 END), 1) AS repeat_rate_pct,
           ROUND(AVG(net_revenue), 0)                                 AS ltv_idr
    FROM per_customer
    GROUP BY acquisition_channel
),
cac AS (
    SELECT c.channel,
           1.0 * SUM(d.spend_idr) / (SELECT COUNT(*) FROM customers u
                                      WHERE u.acquisition_channel = c.channel
                                        AND u.first_order_date <= '2026-04-30') AS cac
    FROM daily_performance d
    JOIN campaigns c USING (campaign_id)
    WHERE d.date <= '2026-04-30'
    GROUP BY c.channel
)
SELECT l.channel,
       l.customers,
       l.orders_per_customer,
       l.repeat_rate_pct,
       l.ltv_idr,
       ROUND(a.cac, 0)               AS cac_idr,
       ROUND(l.ltv_idr / a.cac, 2)   AS ltv_to_cac
FROM ltv l
JOIN cac a USING (channel)
ORDER BY ltv_to_cac DESC;
