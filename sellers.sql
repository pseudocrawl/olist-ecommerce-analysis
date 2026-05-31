--TOP 10 sellers by revenue--
SELECT oi.seller_id, 
       ROUND(SUM(oi.price),2) AS total_revenue,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS AOV,
       ROUND(AVG(CAST(r.review_score AS REAL)),2) AS avg_score
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_order_reviews_dataset r
ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;


--Top rated Sellers Review-wise--
SELECT oi.seller_id AS top_seller, 
       COUNT(r.review_score) AS total_reviews,
       ROUND(AVG(CAST(r.review_score AS REAL)),2) AS raw_avg,
       ROUND(ROUND(CAST(COUNT(r.review_score) AS REAL)/(COUNT(r.review_score)+10),2)
            * AVG(CAST(r.review_score AS REAL))
            + (10/(COUNT(r.review_score) + 10))
            * (SELECT AVG(CAST(r.review_score AS REAL)) FROM olist_order_reviews_dataset),2)
            AS Bayesian_Avg
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
GROUP BY oi.seller_id
HAVING total_reviews >= 10
Order BY Bayesian_Avg DESC
LIMIT 10;


--Sellers with Highest Late Delivery Rate--
SELECT oi.seller_id,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(CASE WHEN JULIANDAY(o.order_estimated_delivery_date) < JULIANDAY(o.order_delivered_customer_date)
                THEN 1 ELSE 0 END) As late_deliveries,
       ROUND(SUM(CASE WHEN JULIANDAY(o.order_estimated_delivery_date) < JULIANDAY(o.order_delivered_customer_date)
                THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id),2) AS late_delivery_rate
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL 
      AND o.order_estimated_delivery_date IS NOT NULL
GROUP By oi.seller_id
HAVING COUNT(DISTINCT o.order_id) >= 10
ORDER BY late_delivery_rate DESC
LIMIT 10;
