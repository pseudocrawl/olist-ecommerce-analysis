--Revenue Over Full Timeline--
SELECT ROUND(SUM(CAST(oi.price AS REAL)),2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

--Revenue oF Canceled Orders--
SELECT ROUND(SUM(CAST(oi.price AS REAL)),2) AS total_revenue_canceled
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'canceled';

--Yearly Revenue Growth--
SELECT order_year,
       total_revenue,
       LAG(total_revenue) OVER (ORDER BY order_year) AS prev_year_revenue,
       ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY order_year)) * 100.0 
             / LAG(total_revenue) OVER (ORDER BY order_year), 2) AS yoy_growth_pct
FROM (
  SELECT STRFTIME('%Y', o.order_delivered_customer_date) AS order_year,
         ROUND(SUM(CAST(oi.price AS REAL)),2) As total_revenue
  FROM olist_orders_dataset o
  JOIN olist_order_items_dataset oi
  ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
  GROUP BY order_year
);

--Monthly Revenue--
With monthly_revenue AS (
SELECT STRFTIME('%Y-%m', o.order_delivered_customer_date) AS month,
       ROUND(SUM(CAST(oi.price AS REAL)),2) As total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY Month
  )
  
SELECT month, total_revenue,
       CASE WHEN LAG(total_revenue, 1,NULL) OVER (ORDER BY month) is NULL THEN 'N/A'
            ELSE ROUND((total_revenue - LAG(total_revenue, 1, NULL) OVER (ORDER BY month))*100
                 /LAG(total_revenue, 1, NULL) OVER (ORDER BY month),2) END AS mom_growth_pct,
       CASE WHEN LAG(total_revenue, 1, NULL) OVER (ORdER BY month) is NULL THEN 'N/A'
            WHEN LAG(total_revenue, 1, NULL) OVER (ORdER BY month) > total_revenue THEN 'DROP' ELSE '-' END As trend,
       ROUND(SUM(total_revenue) OVER (ORDER BY month),2) As running_total
FROM monthly_revenue;



--Quaterly Revenue-
SELECT (((CAST(STRFTIME('%m', o.order_delivered_customer_date)AS Integer)-1)/3)+1) AS Quarter,
       STRFTIME('%Y', o.order_delivered_customer_date) AS order_year,
       ROUND(SUM(CAST(oi.price AS REAL)),2) As total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY Quarter,order_year
ORDER BY Quarter,order_year;


-- Average Order Value ---

SELECT ROUND(AVG(order_value),2) AS average_order_value
FROM 
  (SELECT o.order_id, SUM(oi.price) As order_value
   FROM olist_orders_dataset o
   JOIN olist_order_items_dataset oi
   ON o.order_id = oi.order_id
   WHERE o.order_status = 'delivered' 
   GROUP BY o.order_id) t;

--Top 10 product categories--
SELECT pct.product_category_1, ROUND(SUM(oi.price),2) AS revenue
FROM olist_products_dataset p
JOIN product_category_name_translation pct
ON p.product_category = pct.product_category

JOIn olist_order_items_dataset oi
ON p.product_id = oi.product_id

JOIN olist_orders_dataset o
ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'
GROUP BY p.product_category
ORDER BY revenue DESC
LIMIT 10;


---Top 3 products per category--
SELECT category, product_id, revenue
FROM (
  SELECT pct.product_category_1 AS category, oi.product_id AS product_id, ROUND(SUM(oi.price),2) AS revenue,
         ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY ROUND(SUM(oi.price),2) DESC) AS rnk 
  FROM olist_orders_dataset o
  JOIN olist_order_items_dataset oi
  ON o.order_id  = oi.order_id
  JOIN olist_products_dataset p
  ON oi.product_id = p.product_id
  JOIN product_category_name_translation pct
  ON p.product_category = pct.product_category
  WHERE o.order_status = 'delivered' AND p.product_category IS NOT NULL
  GROUP BY oi.product_id
)
WHERE rnk <= 3
ORDER BY category, rnk;

----cancelled orders details---
SELECT DISTINCT o.order_id, s.seller_id, o.order_purchase_timestamp AS purch, o.order_approved_at AS apr, 
       o.order_delivered_carrier_date AS logs, o.order_delivered_customer_date AS deliv,
       CASE WHEN (JULIANDAY(o.order_delivered_customer_date) <= JULIANDAY(o.order_estimated_delivery_date)) THEN 'timely_delivery'
            ELSE 'late_or_no_delivery' END AS delivery_status
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s
ON s.seller_id = oi.seller_id
WHERE o.order_status = 'canceled';


---Sellers linked to Canceled Orders---
WITH troubled_sellers AS

( SELECT DISTINCT o.order_id AS order_id_, s.seller_id AS troubled_seller_id, o.order_purchase_timestamp AS purch, o.order_approved_at AS apr, 
       o.order_delivered_carrier_date AS logs, o.order_delivered_customer_date AS deliv,
       CASE WHEN (JULIANDAY(o.order_delivered_customer_date) <= JULIANDAY(o.order_estimated_delivery_date)) THEN 'timely_delivery'
            ELSE 'late_or_no_delivery' END AS delivery_status
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s
ON s.seller_id = oi.seller_id
WHERE o.order_status = 'canceled' AND o.order_approved_at IS NOT NULL )


SELECT troubled_seller_id, COUNT(order_id_) AS total_orders
FROM troubled_sellers
GROUP BY troubled_seller_id
ORDER BY total_orders DESC;

---Products linked to Canceled Orders--
SELECT DISTINCT o.order_id, p.product_id, pct.product_category_1,
       CASE WHEN (JULIANDAY(o.order_delivered_customer_date) <= JULIANDAY(o.order_estimated_delivery_date)) THEN 'timely_delivery'
            WHEN o.order_delivered_customer_date IS NULL THEN 'no_delivery'
            ELSE 'late_delivery' END AS delivery_status
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_products_dataset p
ON p.product_id = oi.product_id
JOIN product_category_name_translation pct
ON p.product_category = pct.product_category
WHERE o.order_status = 'canceled';

