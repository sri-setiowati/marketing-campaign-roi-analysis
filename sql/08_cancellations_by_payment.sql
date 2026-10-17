-- 08_cancellations_by_payment.sql
-- Question: how much attributed revenue disappears through cancelled and returned orders,
-- and does payment method explain it?

SELECT c.channel,
       o.payment_method,
       COUNT(*)                                                                AS orders,
       ROUND(100.0 * AVG(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END), 1) AS cancelled_pct,
       ROUND(100.0 * AVG(CASE WHEN o.status = 'Returned'  THEN 1 ELSE 0 END), 1) AS returned_pct,
       SUM(CASE WHEN o.status <> 'Completed' THEN o.order_value_idr ELSE 0 END)  AS lost_revenue_idr
FROM orders o
JOIN campaigns c USING (campaign_id)
GROUP BY c.channel, o.payment_method
ORDER BY c.channel, cancelled_pct DESC;
