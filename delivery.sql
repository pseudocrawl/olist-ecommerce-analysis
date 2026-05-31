--AVG delivery time and ON Time VS Late deliveries--
SELECT COUNT(*) AS total_deliveries,
       ROUND(AVG(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)),1)
       AS [avg_delivery_time (days)],
       ROUND((100.0 * SUM(CASE WHEN JULIANDAY(order_estimated_delivery_date) - JULIANDAY(order_delivered_customer_date)
                     >= 0 THEN 1 ELSE 0 END))/COUNT(*),2) AS timely_deliveries_pct,
       ROUND((100.0 * SUM(CASE WHEN JULIANDAY(order_estimated_delivery_date) - JULIANDAY(order_delivered_customer_date) 
                     < 0 THEN 1 ELSE 0 END))/COUNT(*),2) AS late_deliveries_pct
FROM olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;


-- Customer state delivery time, total orders and local and non-local delivery affect
SELECT c.customer_state AS state,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(AVG(JULIANDAY(o.order_delivered_customer_date) - 
             JULIANDAY(o.order_purchase_timestamp)), 1) AS avg_delivery_time,
       COUNT(DISTINCT CASE WHEN s.seller_state = c.customer_state 
                           THEN o.order_id END) AS local_orders,
       COUNT(DISTINCT CASE WHEN s.seller_state != c.customer_state 
                           THEN o.order_id END) AS non_local_orders,
       ROUND(COUNT(DISTINCT CASE WHEN s.seller_state = c.customer_state 
                                 THEN o.order_id END) * 100.0 / 
             COUNT(DISTINCT o.order_id), 2) AS local_delivery_pct
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_time ASC;