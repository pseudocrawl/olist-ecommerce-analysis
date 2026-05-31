---Average Review Score Overall--
SELECT ROUND(AVG(CAST(r.review_score AS REAL)),2) AS average_overall_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL;


--Average Review Score by Product Category--
SELECT (CASE WHEN pct.product_category_1 IS NULL THEN p.product_category ELSE pct.product_category_1 END)
       AS category_name, 
       ROUND(AVG(CAST(r.review_score AS REAL)),2) AS avg_rev_score,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
JOIN olist_order_items_dataset oi
ON oi.order_id = o.order_id
JOIN olist_products_dataset p
ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pct
ON pct.product_category = p.product_category
WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL AND p.product_category IS NOT NULL
GROUP BY category_name
ORDER BY avg_rev_score DESC;

--Distribution of scores over orders---
SELECT COUNT(o.order_id) AS number_of_orders, 
       ROUND((100.0 * COUNT(o.order_id))/ 
       (SELECT COUNT(*)
        FROM olist_orders_dataset o
        JOIN olist_order_reviews_dataset r
        ON o.order_id = r.order_id
        WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL
       ),2) AS percentage,
       r.review_score  AS score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.review_score Is NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;


--Average review score for late and on-time deliveries--

SELECT ROUND(AVG(CASE WHEN JULIANDAY(o.order_estimated_delivery_date) - JULIANDAY(o.order_delivered_customer_date) >= 0
             THEN CAST(r.review_score AS REAL) ELSE NULL END),2) AS timely_delivery_score,
       ROUND(AVG(CASE WHEN JULIANDAY(o.order_estimated_delivery_date) - JULIANDAY(o.order_delivered_customer_date) < 0
             THEN CAST(r.review_score AS REAL) ELSE NULL END),2) AS late_delivery_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL;


-- Average review score for different delivery times---
SELECT CASE WHEN JULIANDAY(o.order_delivered_customer_date)-JULIANDAY(o.order_purchase_timestamp) <= 3
            THEN '0-3'
            WHEN JULIANDAY(o.order_delivered_customer_date)-JULIANDAY(o.order_purchase_timestamp) <= 7
            THEN '4-7'
            WHEN JULIANDAY(o.order_delivered_customer_date)-JULIANDAY(o.order_purchase_timestamp) <= 15
            THEN '8-15'
            WHEN JULIANDAY(o.order_delivered_customer_date)-JULIANDAY(o.order_purchase_timestamp) <= 21
            THEN '16-21'
            ELSE '21+'
            END AS delivery_time_period,
            ROUND(AVG(CAST(r.review_score AS REAL)),2) AS review_score,
        COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.review_score IS NOT NULL 
      AND o.order_purchase_timestamp IS NOT NULL AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_time_period
ORDER BY MIN(JULIANDAY(o.order_delivered_customer_date)-JULIANDAY(o.order_purchase_timestamp));


