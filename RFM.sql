---RFM Metrics--
WITH RFM_base AS (
SELECT c.customer_unique_id AS customer, ROUND(SUM(oi.price),2) AS spending,
       MAX(o.order_purchase_timestamp) AS last_order,
       CAST(JULIANDAY('2018-12-01')-JULIANDAY(MAX(o.order_purchase_timestamp)) AS INTEGER) AS days_since_last_order,
       COUNT(DISTINCT o.order_id) AS total_orders       
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY c.customer_unique_id
),
 
--- RFM scores--
RFM_scores AS (
  
  SELECT *,
         CASE WHEN PERCENT_RANK() OVER(ORDER BY spending) >=0.67 THEN 3
            WHEN PERCENT_RANK() OVER(ORDER BY spending) >=0.33 THEN 2
            ELSE 1 END
       AS monetary_score,
       CASE WHEN PERCENT_RANK() OVER(ORDER BY days_since_last_order DESC) >=0.67 THEN 3
            WHEN PERCENT_RANK() OVER(ORDER BY days_since_last_order DESC) >=0.33 THEN 2
            ELSE 1 END 
       AS recency_score,
       CASE WHEN PERCENT_RANK() OVER(ORDER BY total_orders) >=0.67 THEN 3
            WHEN PERCENT_RANK() OVER(ORDER BY total_orders) >=0.33 THEN 2
            ELSE 1 END
       AS frequency_score
  
  FROM RFM_base
  
  )
  
---RFM total scores--

SELECT customer, recency_score, frequency_score, monetary_score,
       CASE WHEN recency_score = 3 AND monetary_score = 1 AND frequency_score = 1
            THEN 'New Customer'
            WHEN recency_score + monetary_score + frequency_score = 9
            THEN 'Champion'
            WHEN recency_score + monetary_score + frequency_score = 3
            THEN 'Lost'
            WHEN monetary_score = 3 AND frequency_score = 1
            THEN 'High Value Dormant'
            WHEN recency_score + monetary_score + frequency_score >= 6 
            THEN 'Loyal'            
            WHEN recency_score >= 2 AND frequency_score >= 1
            THEN 'Promising'
            WHEN recency_score = 1 AND monetary_score = 2 AND frequency_score = 1
            THEN 'At Risk'
            ELSE 'Needs Attention' END
        AS class
FROM RFM_scores
ORDER BY recency_score + frequency_score + monetary_score DESC;
 

