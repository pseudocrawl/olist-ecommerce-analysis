--Revenue By Payment Type--
SELECT p.payment_type, SUM(p.payment_value) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY payment_type
ORDER BY revenue DESC;

--Average Installments by Category--
SELECT pct.product_category_1 AS category_name,
       ROUND(AVG(CAST(py.payment_installments AS REAL)),2) AS avg_installments
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
JOIN (SELECT order_id, MAX(payment_installments) AS [payment_installments]
      FROM olist_order_payments_dataset
      GROUP BY order_id) py
On o.order_id = py.order_id
JOIN product_category_name_translation pct
ON p.product_category = pct.product_category
WHERE o.order_status = 'delivered' AND p.product_category IS NOT NULL
GROUP BY pct.product_category_1
ORDER BY avg_installments DESC;


--Orders paid in 1 SHOT VS installments--
SELECT COUNT (DISTINCT CASE WHEN py.payment_installments = 1 
                 THEN o.order_id ELSE NULL END) AS one_inst,
       COUNT (DISTINCT CASE WHEN py.payment_installments > 1
                 THEN o.order_id ELSE NULL END) AS more_inst
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset py
ON o.order_id = py.order_id
WHERE o.order_status = 'delivered';







