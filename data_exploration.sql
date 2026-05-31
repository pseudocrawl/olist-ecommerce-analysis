--Timeline--
SELECT MIN(order_purchase_timestamp) AS first_order, MAX(order_purchase_timestamp) As last_order,
       ROUND(MAX(JULIANDAY(order_purchase_timestamp)) - MIN(JULIANDAY(order_purchase_timestamp)),0) AS total_time_in_days
FROM olist_orders_dataset;

--Order Status Metrics--
SELECT
       COUNT(order_id) AS total_orders,
       COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) As total_delivered,
       COUNT(CASE WHEN order_status = 'shipped' THEN 1 END) AS total_shipped,
       COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS total_cancelled,
       COUNT(CASE WHEN order_status = 'processing' THEN 1 END) AS total_processing,
       COUNT(CASE WHEN order_status = 'invoiced' THEN 1 END) AS total_invoiced,
       COUNT(CASE WHEN order_status = 'approved' THEN 1 END) AS total_approved,
       COUNT(CASE WHEN order_status = 'created' THEN 1 END) AS total_created,
       COUNT(CASE WHEN order_status = 'unavailable' THEN 1 END) AS total_unavailable
FROM olist_orders_dataset;

--Price Metrics (across all product catalog regardless of the status)---
SELECT MIN(price) AS [MIN Price], MAX(price) AS [MAX Price], ROUND(AVG(price),2) AS [Average Price] 
FROM olist_order_items_dataset;

--Best Performers--
--Most Recurring Customer--
SELECT c.customer_unique_id AS most_recurring_customer, COUNT(DISTINCT o.order_id) AS [total_orders]
FROM olist_customers_dataset c
JOIN olist_orders_dataset o 
ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY [total_orders] DESC
LIMIT 1;


--Top Selling Product--
SELECT oi.product_id AS top_selling_product, COUNT(*) AS total_units_sold
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY COUNT(*) DESC
LIMIT 1;

--- Orders By State--
SELECT c.customer_state AS state, COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o 
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_orders DESC;


--Peak Hours--
SELECT STRFTIME('%H', order_purchase_timestamp) AS hour_of_day, COUNT(order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY hour_of_day
ORDER BY total_orders DESC;

--Peak Days--
SELECT CASE CAST(STRFTIME('%w',order_purchase_timestamp) AS INTEGER)
       WHEN 0 THEN 'SUNDAY'
       WHEN 1 THEN 'MONDAY'
       WHEN 2 THEN 'TUESDAY'
       WHEN 3 THEN 'WEDNESDAY'
       WHEN 4 THEN 'THURSDAY'
       WHEN 5 THEN 'FRIDAY'
       WHEN 6 THEN 'SATURDAY'
       END AS day_of_week, 
       COUNT(order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY day_of_week
ORDER BY total_orders DESC;

