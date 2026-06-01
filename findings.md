# Olist E-Commerce Project Findings
> Personal working notes documenting results, decisions, and insights throughout the analysis.

---

## 1. Setup & Import

**Tables Imported: 9**

| Table | Rows |
|---|---|
| customers | 99,441 |
| orders | 99,441 |
| order_items | 112,650 |
| payments | 103,886 |
| reviews | 99,224 |
| products | 32,951 |
| sellers | 3,095 |
| prod_cat_trans | 71 |
| geo | 1,000,163 |

**Quick Observations**
1. More rows in `order_items` than `orders` — some orders contain multiple items
2. Reviews (~99K) ≈ orders (~99K), roughly one review per order, but ~200 orders unreviewed
3. More `payments` than `orders`, some orders are paid in installments
4. `geolocation` table has 1M rows, will JOIN only if absolutely necessary

---

## 2. Schema Understanding

**Table Relationships**

| Table | Linked To | Via |
|---|---|---|
| customers | orders | customer_id |
| order_items | orders | order_id |
| order_items | products | product_id |
| order_items | sellers | seller_id |
| payments | orders | order_id |
| reviews | orders | order_id |
| products | prod_cat_trans | product_category_name |

**Central table:** `orders`- connects to customers, order_items, payments, reviews

**What the schema enables:**
- Seller ratings → sellers → order_items → orders → reviews (via order_id) → review_score
- Category revenue → products → order_items (price) → orders (delivered status filter)

---

## 3. Basic Exploration

**Date Range**

| | |
|---|---|
| First Order | 2016-09-04 21:15:19 |
| Last Order | 2018-10-17 17:30:18 |
| Total Period | ~2 years |

**Order Status Breakdown**

| Status | Count |
|---|---|
| Total | 99,441 |
| Delivered | 96,478 |
| Shipped | 1,107 |
| Cancelled | 625 |
| Unavailable | 609 |
|Processing|301|
|Invoiced|314|
|Created|5|
|Approved|2|

**Price Range** *(order_items)*

| | |
|---|---|
| Min | 0.85 |
| Max | 6,735 |
| Average | 120.65 |

**Most Recurring Customer**
- ID: `8d50f5eadf50201ccdcedfb9e2ac8455`
- Orders: **15**
- *(counted by customer_unique_id)*

---

## 4. Data Quality

### NULLs

**orders table**
- Delivered orders with no delivery date: **8** 
- Delivered orders with no carrier date: **2**
> *Excluded from delivery time analysis*

**products table**
- 610 products with missing category names
- 1 product_id with no information at all (category + measurements)
- 1 product_id with missing measurements only

**reviews table**
- Missing review title: **87,657**
- Missing review message: **58,255**
> *Expected — most customers skip written comments*

---

### Duplicates

| Table | Column | Count |
|---|---|---|
| olist_order_reviews_dataset | review_id | 789 |

> Decision: `GROUP BY` naturally handles duplicate review_ids in aggregations

---

### Invalid Values

**orders**
| Issue | Count |
|---|---|
| Invalid dates (any) | 84 |
| Delivery before approval | 61 |
| Delivery before carrier pickup | 23 |

> Decision: filter with `WHERE order_delivered_customer_date > order_approved_at`

**order_items**
- Zero freight values: **383**
> Decision: exclude with `WHERE CAST(freight_value AS REAL) > 0` in freight analysis

**payments**
- Zero payment_value (voucher type): **6**
- Zero payment_value (undefined type): **3**
- Zero installments on credit card: **2**
- Overpayments detected — maximum overpayment: **182**
> Decision: use `payment_value` from payments table for revenue, not `total_amount`

**products**
- 4 products with zero weight despite having freight values

| product_id | freight | category |
|---|---|---|
| 36ba42dd... | 23.85 | bed_bath_table |
| 8038040e... | 14.49 | bed_bath_table |
| 81781c0f... | 19.89 | bed_bath_table |
| e673e90e... | 23.71 | bed_bath_table |

> Decision: exclude in weight-related queries only

---

### Orphaned Records

| Check | Count | Action |
|---|---|---|
| Orders without customers | 0 | Clean |
| Order items without orders | 775 | INNER JOIN drops automatically |
| Orders with no payment | 1 | Flagged, delivered order, no payment record |
| Orders with no reviews | 768 | Expected, not all customers review |
| Products with no translation | 623 | Use Portuguese name as fallback |

> Delivered order with no payment, order_id: `bfbd0f9bdef84302105ad712db648a6c`

---

### Zip Code Issues

**customers:** ~23,000 zip codes were 4 digits — leading zero stripped on CSV import
**sellers:** 1,027 zip codes affected

**Fix applied:**
- Deleted original table
- Recreated with `zip_code_prefix` as TEXT
- Used `PRINTF('%05d')` to pad leading zeros back
- Root cause: DB Browser imported numeric-looking columns as INTEGER — PRINTF can't pad integers

---

### Data Exclusion Policy
Raw tables never modified (except structural fixes). All invalid records excluded via WHERE filters in queries. This preserves raw data integrity throughout analysis.

---

## 5. Analysis

### Revenue

| Period | Revenue |
|---|---|
| Overall | 13,221,498.11 |
| 2016 | 41,087.17 *(partial, Sep–Dec only)* |
| 2017 | 5,612,817.85 *(full year)* |
| 2018 | 7,566,990.09 *(partial, Jan–Oct only)* |
| Cancelled orders | 95,235.27 |

- **Average Order Value:** 137.04
- Revenue excludes shipping cost — freight is a cost, not product revenue
- 2017 is the only complete year in the dataset

**Monthly trend:** Used `STRFTIME('%Y-%m')` for grouping. Applied `LAG()` for MoM growth %. Flagged months where revenue dropped. Running total calculated using `SUM() OVER()`.

### Quarterly Revenue Breakdown

| Quarter | Year | Revenue | Note |
|---|---|---|---|
| Q4 | 2016 | 40,470.98 | partial, Oct–Dec only |
| Q1 | 2017 | 568,394.62 | |
| Q2 | 2017 | 1,219,608.26 | |
| Q3 | 2017 | 1,570,799.28 | |
| Q4 | 2017 | 2,254,015.69 | |
| Q1 | 2018 | 2,493,188.79 | |
| Q2 | 2018 | 3,123,806.48 | peak quarter |
| Q3 | 2018 | 1,949,689.43 | |
| Q4 | 2018 | 275.40 | partial, Oct only |

**Insights:**
- Q2 2018: highest single quarter across entire dataset
- Q4 2017: strongest quarter of 2017, likely holiday season effect
- Consistent growth quarter over quarter from Q4 2016 → Q2 2018
- Sharp drop in Q4 2018, dataset ends early October, not a real decline
- Q1 2018 (2.49M) vs Q1 2017 (0.57M), 338% YoY growth in same quarter

**Top 3 Products per Category**
Calculated using `ROW_NUMBER()` partitioned by category, delivered orders only.
Full results in `revenue.sql`.

---

### Delivery

| Metric | Value |
|---|---|
| Average delivery time | 12.6 days |
| Timely deliveries | 91.8% |
| Late deliveries | 8.12%|
| Fastest state | SP — 8.7 days |
| Slowest state | RR — 28.2 days |

> excluded missing dates from late and timely deliveries

> excluded invalid dates from states avg delivery time

---

### Satisfaction

| Metric | Value |Note|
|---|---|---|
| Average review score | 4.16 / 5 ||
| Highest avg score | fashion_childrens_clothes 5.0|(7 orders) low volume |
| Lowest avg score | security_and_services 2.5 | (2 orders) low volume |

> Note: Portuguese category names used where English translation missing. Orders without category names excluded.

**Score Distribution**

| Score | Orders | % |
|---|---|---|
| ⭐⭐⭐⭐⭐ 5 | 57,066 | 59.22% |
| ⭐⭐⭐⭐ 4 | 18,987 | 19.70% |
| ⭐⭐⭐ 3 | 7,961 | 8.26% |
| ⭐⭐ 2 | 2,941 | 3.05% |
| ⭐ 1 | 9,406 | 9.76% |

> Insight: Distribution is strongly positive — 79% of customers gave 4 or 5 stars. However 9.76% gave 1 star — a significant unhappy minority worth investigating.

---

### Delivery vs Satisfaction

| Delivery | Avg Review Score |
|---|---|
| Late | 2.57 |
| On time | 4.29 |

> **Key insight: Late delivery lowers review score by 1.72 points on average.**
> Analysis extended to calculate avg review score across different delivery time buckets.

---

### Seller Performance

**Top 10 sellers by revenue**
Calculated with total orders, AOV, and average review score per seller.

**Sellers with highest late delivery rate**
- Formula: `(late deliveries / total deliveries) * 100`
- Minimum 10 orders threshold applied

**Highest rated seller**

Initial approach: sellers with 10+ orders ranked by avg rating
> Result: `48efc9d94a9834137efd9ea76b065a38` — 33 orders, 5.0 avg, Statistically suspicious

Solution: Switched to **Bayesian Average**

**Formula:** `(v / v+m) × R + (m / v+m) × C`

| Variable | Meaning |
|---|---|
| v | Seller's total reviews |
| m | Minimum threshold = 10 |
| R | Seller's own avg rating |
| C | Global avg rating across all sellers |

- m = 10 derived from distribution analysis — 60%+ sellers have fewer than 10 orders
- 10+ reviews → pulled toward seller's own rating (trusted more)
- <10 reviews → pulled toward global average (not fully trusted)

> **New result:** `c3cfdc648177fdbbbb35635a37472c53`
> 313 reviews | Raw avg: 4.45 | Bayesian avg: **4.31**

**Top selling product (by volume)**
- ID: `aca2eb7d00ea1a7b8ebd4e68314663af`
- 527 delivered orders

---

### RFM Segmentation

**Metrics calculated per customer:**

| Metric | Method |
|---|---|
| Recency | Days since last order using `JULIANDAY()` |
| Frequency | Total delivered orders using `COUNT(DISTINCT order_id)` |
| Monetary | Total spend using `SUM(price)` |

**Scoring methodology:**
- `PERCENT_RANK()` used instead of `NTILE(3)`
- Reason: NTILE splits tied values into different groups, PERCENT_RANK gives tied customers the same score
- Scores assigned 1–3: bottom 33% = 1, middle 33% = 2, top 33% = 3
- Recency scored inversely — fewer days since last order = score 3

**Segment definitions:**

| Segment | Rule | Business Action |
|---|---|---|
| Champion | R=3, F=3, M=3 | Reward |
| Loyal | F=3, M≥2 | Upsell |
| At Risk | R=1, F≥2 or M≥2 | Win back |
| New Customer | R=3, F=1 | Nurture |
| High Value Dormant | M=3, F=1 | Re-engage |
| Promising | R≥2, F≥2 | Encourage |
| Lost | R=1, F=1, M=1 | Deprioritise |
| Needs Attention | everything else | Monitor |

**Technical approach:**
- CTE 1 `rfm_base` — calculated raw R, F, M values
- CTE 2 `rfm_scores` — applied PERCENT_RANK scoring
- Final SELECT — assigned segment labels via CASE WHEN

---

### Cohort Retention

**Methodology:**
- Cohort = month of first delivered order per customer
- Tracked returning purchases at M+1, M+3, M+6
- Month difference calculated using SUBSTR() arithmetic, STRFTIME() failed on `%Y-%m` formatted strings

**Results:**

| Cohort | Size | M+1% | M+3% | M+6% |
|---|---|---|---|---|
| 2017-01 | 717 | 0.28% | 0.14% | 0.42% |
| 2017-08 | 4,057 | 0.69% | 0.27% | 0.30% |
| 2017-11 | 7,060 | 0.57% | 0.17% | 0.11% |
| 2018-01 | 6,842 | 0.34% | 0.29% | 0.18% |

**Key findings:**
- Retention is extremely low across all cohorts, average M+1 ~0.5%
- Vast majority of customers never return after first purchase
- Late 2018 cohorts show zero M+3/M+6, dataset ends Oct 2018, insufficient time elapsed
- 2017-08 to 2017-10 cohorts performed best historically

**Business insight:**
> Olist's biggest challenge is repeat purchases. Converting one-time buyers to returning customers is the single biggest growth lever. A 1% improvement in M+1 retention across 99K customers = ~990 additional repeat buyers.

**Recommendations:**
- Loyalty programme targeting the M+1 window
- Email re-engagement at 25–30 days after first purchase
- Focus acquisition on cohorts with historically higher retention

---

