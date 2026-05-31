-- Zip code columns were INTEGER type -- PRINTF('%05d') requires TEXT
-- Recreated both tables with TEXT type for zip_code_prefix
-- Run once, kept for reference

/*CREATE TABLE olist_customers_new (
  customer_id TEXT,
  customer_unique_id TEXT,
  customer_zip_code_prefix TEXT,
  
  
  customer_city TEXT,
  customer_state TEXT
 );
 
CREATE TABLE olist_sellers_new (
  seller_id TEXT,
  seller_zip_code_prefix TEXT,
  seller_city TEXT,
  seller_state TEXT
 );
 
INSERT INTO  olist_customers_new
SELECT * FROM olist_customers_dataset;

DROP TABLE olist_customers_dataset;

ALTER TABLE olist_customers_new
RENAME TO olist_customers_dataset;
 
INSERT INTO  olist_sellers_new
SELECT * FROM olist_sellers_dataset;

DROP TABLE olist_sellers_dataset;

ALTER TABLE olist_sellers_new
RENAME TO olist_sellers_dataset;

*/


-----------------------------------
--- Checking for Empty Strings ---
-----------------------------------
--olist_orders_dataset--

UPDATE olist_orders_dataset
SET order_id = CASE WHEN TRIM(order_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_id) END,
    order_status = CASE WHEN TRIM(order_status) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_status) END,
    order_purchase_timestamp = CASE WHEN TRIM(order_purchase_timestamp) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_purchase_timestamp) END,
    order_approved_at = CASE WHEN TRIM(order_approved_at) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_approved_at) END,
    order_delivered_carrier_date = CASE WHEN TRIM(order_delivered_carrier_date) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_delivered_carrier_date) END,
    order_delivered_customer_date = CASE WHEN TRIM(order_delivered_customer_date) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_delivered_customer_date) END,
    order_estimated_delivery_date = CASE WHEN TRIM(order_estimated_delivery_date) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_estimated_delivery_date) END;

--olist_order_items_dataset--
UPDATE olist_order_items_dataset
SET order_item_id = CASE WHEN TRIM(order_item_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(order_item_id) END,
    shipping_limit_date = CASE WHEN TRIM(shipping_limit_date) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(shipping_limit_date) END,
    price = CASE WHEN TRIM(price) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(price) END,
    freight_value = CASE WHEN TRIM(freight_value) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(freight_value) END;

--olist_products_dataset--
UPDATE olist_products_dataset
SET product_id = CASE WHEN TRIM(product_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_id) END,
    product_category = CASE WHEN TRIM(product_category) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_category) END,
    product_name_len = CASE WHEN TRIM(product_name_len) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_name_len) END,
    product_description_len = CASE WHEN TRIM(product_description_len) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_description_len) END,
    product_photos_qty = CASE WHEN TRIM(product_photos_qty) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_photos_qty) END,
    product_weight_g = CASE WHEN TRIM(product_weight_g) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_weight_g) END,
    product_length_cm = CASE WHEN TRIM(product_length_cm) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_length_cm) END,
    product_height_cm = CASE WHEN TRIM(product_height_cm) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_height_cm) END,
    product_width_cm = CASE WHEN TRIM(product_width_cm) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(product_width_cm) END;

--olist_customers_dataset--
UPDATE olist_customers_dataset
SET customer_id = CASE WHEN TRIM(customer_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(customer_id) END,
    customer_unique_id = CASE WHEN TRIM(customer_unique_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(customer_unique_id) END,
    customer_zip_code_prefix = CASE WHEN TRIM(customer_zip_code_prefix) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(customer_zip_code_prefix) END,
    customer_city = CASE WHEN TRIM(customer_city) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(customer_city) END,
    customer_state = CASE WHEN TRIM(customer_state) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(customer_state) END;

--olist_order_payments_dataset--
UPDATE olist_order_payments_dataset
SET payment_sequential = CASE WHEN TRIM(payment_sequential) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(payment_sequential) END,
    payment_type = CASE WHEN TRIM(payment_type) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(payment_type) END,
    payment_installments = CASE WHEN TRIM(payment_installments) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(payment_installments) END,
    payment_value = CASE WHEN TRIM(payment_value) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(payment_value) END;

--olist_order_reviews_dataset--
UPDATE olist_order_reviews_dataset
SET review_id = CASE WHEN TRIM(review_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_id) END,
    review_score = CASE WHEN TRIM(review_score) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_score) END,
    review_comment_title = CASE WHEN TRIM(review_comment_title) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_comment_title) END,
    review_comment_message = CASE WHEN TRIM(review_comment_message) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_comment_message) END,
    review_creation_date = CASE WHEN TRIM(review_creation_date) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_creation_date) END,
    review_answer_timestamp = CASE WHEN TRIM(review_answer_timestamp) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(review_answer_timestamp) END;

--olist_sellers_dataset--
UPDATE olist_sellers_dataset
SET seller_id = CASE WHEN TRIM(seller_id) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(seller_id) END,
    seller_zip_code_prefix = CASE WHEN TRIM(seller_zip_code_prefix) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(seller_zip_code_prefix) END,
    seller_city = CASE WHEN TRIM(seller_city) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(seller_city) END,
    seller_state = CASE WHEN TRIM(seller_state) IN ('', 'null', 'NULL') THEN NULL ELSE TRIM(seller_state) END;

---------------------------------------------------------      
--------------Checking Nulls-----------------------------
---------------------------------------------------------
SELECT 'orders' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id)                      AS missing_order_id,
    COUNT(*) - COUNT(customer_id)                   AS missing_customer_id,
    COUNT(*) - COUNT(order_status)                  AS missing_status,
    COUNT(*) - COUNT(order_purchase_timestamp)      AS missing_purchase_date,
    COUNT(*) - COUNT(order_approved_at)             AS missing_approved_at,
    COUNT(*) - COUNT(order_delivered_carrier_date)  AS missing_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS missing_estimated_date
FROM olist_orders_dataset;

SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered' AND 
      (order_delivered_customer_date IS NULL OR order_purchase_timestamp IS NULL OR order_delivered_carrier_date IS NULL
       OR order_estimated_delivery_date IS NULL);

SELECT 'order_items' AS table_name,
        COUNT(*) AS total_rows,
        COUNT(*) - COUNT(order_id)                  AS missing_order_id,
        COUNT(*) - COUNT(order_item_id)             AS missing_order_item_id,
        COUNT(*) - COUNT(product_id)                AS missing_product_id,
        COUNT(*) - COUNT(seller_id)                 AS missing_seller_id,
        COUNT(*) - COUNT(shipping_limit_date)       AS missing_shipping_limit_date,
        COUNT(*) - COUNT(price)                     AS missing_price,
        COUNT(*) - COUNT(freight_value)             AS missing_freight_value
FROM olist_order_items_dataset;

SELECT 'products' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(product_id)              AS missing_product_id,
    COUNT(*) - COUNT(product_category)        AS missing_category,
    COUNT(*) - COUNT(product_name_len)        AS missing_name_len,
    COUNT(*) - COUNT(product_description_len) AS missing_description_len,
    COUNT(*) - COUNT(product_photos_qty)      AS missing_photos_qty,
    COUNT(*) - COUNT(product_weight_g)        AS missing_weight,
    COUNT(*) - COUNT(product_length_cm)       AS missing_length,
    COUNT(*) - COUNT(product_height_cm)       AS missing_height,
    COUNT(*) - COUNT(product_width_cm)        AS missing_width
FROM olist_products_dataset;

SELECT 'payments' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id)                      AS missing_order_id,
    COUNT(*) - COUNT(payment_sequential)            AS missing_sequential,
    COUNT(*) - COUNT(payment_type)                  AS missing_payment_type,
    COUNT(*) - COUNT(payment_installments)          AS missing_installments,
    COUNT(*) - COUNT(payment_value)                 AS missing_payment_value
FROM olist_order_payments_dataset;

SELECT 'reviews' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(review_id)              AS missing_review_id,
    COUNT(*) - COUNT(order_id)               AS missing_order_id,
    COUNT(*) - COUNT(review_score)           AS missing_review_score,
    COUNT(*) - COUNT(review_comment_title)   AS missing_comment_title,
    COUNT(*) - COUNT(review_comment_message) AS missing_comment_message,
    COUNT(*) - COUNT(review_creation_date)   AS missing_creation_date,
    COUNT(*) - COUNT(review_answer_timestamp)AS missing_answer_timestamp
FROM olist_order_reviews_dataset;

SELECT 'customers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(customer_id)             AS missing_customer_id,
    COUNT(*) - COUNT(customer_unique_id)      AS missing_customer_unique_id,
    COUNT(*) - COUNT(customer_zip_code_prefix)AS missing_zip_code,
    COUNT(*) - COUNT(customer_city)           AS missing_city,
    COUNT(*) - COUNT(customer_state)          AS missing_state
FROM olist_customers_dataset;

SELECT 'sellers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(seller_id)              AS missing_seller_id,
    COUNT(*) - COUNT(seller_zip_code_prefix) AS missing_zip_code,
    COUNT(*) - COUNT(seller_city)            AS missing_city,
    COUNT(*) - COUNT(seller_state)           AS missing_state
FROM olist_sellers_dataset;


---------------------------------------------------------
---------------Duplicate Check---------------------------
---------------------------------------------------------
--olist_orders_dataset--
--primary key: order_id--
SELECT order_id, COUNT(*) AS duplicate_count_in_orders
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

--olist_order_items_dataset--
--primary key: order_id + order_item_id
SELECT order_id,
       order_item_id,
       COUNT(*) AS duplicate_count_in_order_items
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- olist_order_reviews_dataset --
-- primary Key: review_id
SELECT review_id,
       COUNT(*) AS duplicate_count_in_reviews
FROM olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;

--olist_order_payments_dataset--
--primary key: order_id
SELECT order_id, payment_sequential, COUNT(*) AS duplicate_count_in_payments
FROM olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- olist_customers_dataset --
-- Primary Key: customer_id
SELECT customer_id,
       COUNT(*) AS duplicate_count_in_customers
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- olist_sellers_dataset --
-- Primary Key: seller_id
SELECT seller_id,
       COUNT(*) AS duplicate_count_in_sellers
FROM olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;

------------------------------------------------------
----------------Invalid Values------------------------
------------------------------------------------------

--olist_orders_dataset--
--Checking impossible dates--
SELECT COUNT(*) AS total_invalid_dates, 
       SUM (CASE WHEN order_purchase_timestamp>order_delivered_customer_date THEN 1 ELSE 0 END) AS del_before_purch,
       SUM (CASE WHEN order_approved_at > order_delivered_customer_date THEN 1 ELSE 0 END) AS del_before_aprv,
       SUM (CASE WHEN order_delivered_carrier_date > order_delivered_customer_date THEN 1 ELSE 0 END) AS del_before_logs
FROM olist_orders_dataset
WHERE order_purchase_timestamp > order_delivered_customer_date or
      order_approved_at > order_delivered_customer_date OR
      order_delivered_carrier_date > order_delivered_customer_date;
    
--olist_order_items_dataset--
--Checking negative price and freight value--
SELECT SUM( CASE WHEN price GLOB '*[^0-9.]*' or CAST(price AS REAL) <= 0
                 THEN 1 ELSE 0 END) AS invalid_price,
       SUM( CASE WHEN CAST(freight_value AS REAL) <=0 THEN 1 ELSE 0 END) AS invalid_freight
FROM olist_order_items_dataset;

--olist_order_items_dataset--
--Checking invalid payment method--
SELECT SUM(CASE WHEN payment_value <= 0 THEN 1 ELSE 0 END) AS invalid_value,
       SUM(CASE WHEN payment_installments < 1 THEN 1 ELSE 0 END) AS invalid_inst,
       SUM(CASE WHEN payment_type NOT IN ('voucher', 'credit_card', 'boleto', 'debit_card') THEN 1 ELSE 0 END) AS invalid_type
FROM olist_order_payments_dataset;

--Checking total_paid amount and total_payable(expected) amount--                                          
SELECT p.order_id, p.payment_type,
       ROUND(SUM(oi.price + oi.freight_value),0)  AS total_payable,
       ROUND(SUM(p.payment_value),0) AS total_paid,
       ROUND(SUM(oi.price + oi.freight_value),0) - ROUND(SUM(p.payment_value),0) AS remaining
FROM olist_order_payments_dataset p
JOIN olist_order_items_dataset oi
ON p.order_id = oi.order_id
GROUP BY p.order_id
HAVING remaining < -10
ORDER BY remaining;

--olist_order_reviews_dataset--
--Checking negative review score and invalid review dates--
SELECT SUM(CASE WHEN CAST(r.review_score AS INTEGER) NOT IN (1, 2, 3, 4, 5) THEN 1 ELSE 0 END)  AS invalid_scores,
       SUM(CASE WHEN r.review_answer_timestamp < r.review_creation_date THEN 1 ELSE 0 END) AS invalid_rev_dates,
       SUM(CASE WHEN o.order_id ISNULL THEN 1 ELSE 0 END) AS orphaned_reviews
FROM olist_order_reviews_dataset r
LEFT JOIN olist_orders_dataset o
ON r.order_id = o.order_id;

--olist_products_dataset--
--Checking negative weight and measurements and photo quantity--
SELECT SUM(CASE WHEN CAST(product_weight_g AS REAL) <= 0 THEN 1 ELSE 0 END) AS invalid_weight,
       SUM(CASE WHEN CAST(product_length_cm AS REAL) <= 0 THEN 1 ELSE 0 END) AS invalid_len,
       SUM(CASE WHEN CAST(product_height_cm AS REAL) <= 0 THEN 1 ELSE 0 END) AS invalid_height,
       SUM(CASE WHEN CAST(product_width_cm AS REAL) <= 0 THEN 1 ELSE 0 END) AS invalid_width,
       SUM(CASE WHEN product_photos_qty < 0 THEN 1 ELSE 0 END) AS invalid_photo_qty
FROM olist_products_dataset;

---zero weight detected--uncomment below code to see details
/*
SELECT p.product_id, oi.freight_value,  cat.product_category_1 AS category, CAST(p.product_weight_g AS REAL) AS weight
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
JOIN product_category_name_translation cat
ON p.product_category = cat.product_category
WHERE product_weight_g <= 0
GROUP BY p.product_id;
*/ 

---olist_customers_dataset---
SELECT LENGTH(customer_zip_code_prefix) AS zip_length, COUNT(*)
FROM olist_customers_dataset
GROUP BY zip_length;

--Fixing zipcodes--
UPDATE olist_customers_dataset
SET customer_zip_code_prefix = PRINTF('%05d', customer_zip_code_prefix)
WHERE LENGTH(customer_zip_code_prefix) < 5;

--New Fixed Zips--
/*SELECT LENGTH(customer_zip_code_prefix) AS zip_length, COUNT(*)
FROM olist_customers_dataset
GROUP BY zip_length;*/


---olist_sellers_dataset--
SELECT LENGTH(seller_zip_code_prefix) AS zip_length, COUNT(*)
FROM olist_sellers_dataset
GROUP BY zip_length;

--Fixing zips--
UPDATE olist_sellers_dataset
SET seller_zip_code_prefix = PRINTF('%05d', seller_zip_code_prefix)
WHERE LENGTH(seller_zip_code_prefix) < 5;

--New Fixed zips--
/*SELECT LENGTH(seller_zip_code_prefix) AS zip_length, COUNT(*)
FROM olist_sellers_dataset
GROUP BY zip_length;*/

-------------------------------------------------
----------Orphaned Records-----------------------
-------------------------------------------------
SELECT COUNT(*) AS orphaned_orders
FROM olist_orders_dataset o 
LEFT JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphaned_items_no_order
FROM olist_orders_dataset o 
LEFT JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

SELECT COUNT(*) AS orphaned_items_no_product
FROM olist_order_items_dataset oi
LEFT JOIN olist_products_dataset p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS orphaned_items_no_seller
FROM olist_order_items_dataset oi
LEFT JOIN olist_sellers_dataset s
ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT COUNT(*) As payments_no_order
FROM olist_order_payments_dataset p
LEFT JOIN olist_orders_dataset o
ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphaned_reviews_without_order
FROM olist_order_reviews_dataset  r
LEFT JOIN olist_orders_dataset o
ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orders_no_payment
FROM olist_orders_dataset o
LEFT JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

/*SELECT * 
FROM olist_orders_dataset o
LEFT JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;*/

SELECT COUNT(*) AS orders_no_review
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r 
ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

SELECT COUNT(*) AS products_no_translation
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t 
ON p.product_category = t.product_category
WHERE t.product_category IS NULL;

---------------------------------------------
-------------Date Format---------------------
---------------------------------------------
SELECT order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, 
       order_delivered_customer_date, order_estimated_delivery_date
FROM olist_orders_dataset
WHERE (datetime(order_purchase_timestamp) IS NULL AND order_purchase_timestamp IS NOT NULL)
      OR (datetime(order_approved_at) IS NULL AND order_approved_at IS NOT NULL)
      OR (datetime(order_delivered_carrier_date) IS NULL AND order_delivered_carrier_date IS NOT NULL)
      OR (datetime(order_delivered_customer_date) IS NULL AND order_delivered_customer_date IS NOT NULL)
      OR (datetime(order_estimated_delivery_date) IS NULL AND order_estimated_delivery_date IS NOT NULL);



