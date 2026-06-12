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

---Late Delivery Analysis---

SELECT DISTINCT o.order_id, s.seller_state, c.customer_state, r.review_score,
       ROUND(JULIANDAY(o.order_delivered_carrier_date) - JULIANDAY(o.order_approved_at),1)  AS handled_to_logistics,
       ROUND(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_delivered_carrier_date),1) AS delivery_time
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s
ON s.seller_id = oi.seller_id
JOIN olist_customers_dataset c
ON c.customer_id = o.customer_id
JOIN olist_order_reviews_dataset r
ON r.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date > o.order_estimated_delivery_date
ORDEr BY handled_to_logistics DESC;
