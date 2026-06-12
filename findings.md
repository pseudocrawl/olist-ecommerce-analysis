<a id="top"></a>
# Olist E-Commerce Analysis — Findings

My personal working notes documenting results, decisions, and insights throughout the analysis and some recommendations at the end.

---

## Data Quality

### Nulls

| Issue | Count |
|---|---|
| Delivered orders with no delivery date | 8 |
| Delivered orders with no carrier date | 2 |
| Products with missing category and name | 610 |
| Products with missing measurements only | 1 |
| Reviews with missing title | 87,657 |
| Reviews with missing message body | 58,255 |

### Duplicates

| Issue | Count |
|---|---|
| Duplicate review IDs (`review_id`) | 789 |

Handled naturally by `GROUP BY` — no rows dropped.

### Invalid Values

**olist_orders_dataset**

| Issue | Count |
|---|---|
| Invalid dates (customer delivery before payment approval) | 61 |
| Invalid dates (customer delivery before carrier delivery) | 23 |
| Total invalid date records | 84 |

Excluded in all date-sensitive queries using `WHERE order_delivered_customer_date > order_approved_at`.

**olist_order_items_dataset**

| Issue | Count |
|---|---|
| Zero freight values | 383 |

Excluded in freight-related queries only.

**olist_order_payments_dataset**

| Issue | Count |
|---|---|
| Zero payment value on voucher type | 6 |
| Zero payment value on undefined type | 3 |
| Zero installments on credit card | 2 |

Some orders are overpaid — maximum overpayment found: BRL 182. Noted but not excluded.

**olist_products_dataset**

4 products with zero weight despite having freight values, all in the `bed_bath_table` category:

| product_id | freight | weight |
|---|---|---|
| 36ba42dd... | 23.85 | 0 |
| 8038040e... | 14.49 | 0 |
| 81781c0f... | 19.89 | 0 |
| e673e90e... | 23.71 | 0 |

Excluded in any weight-related queries only.

### Orphaned Records

| Issue | Count |
|---|---|
| Orphaned order_items (no matching order) | 775 |
| Orders with no payment | 1 *(delivered order, noted as anomaly)* |
| Orders with no reviews | 768 |
| Products with no translation | 623 |

**The 775 orphaned order_items** — these are orders that exist in the orders table but have no items attached in order_items. Of these, 1 is marked as `shipped`, something was physically sent with no record of what. All 775 are excluded automatically through `INNER JOIN` on order_items.

### Zip Code Fix

`olist_customers_dataset`: ~23,000 customer zip codes were stored as INTEGER, dropping leading zeros and producing 4-digit codes instead of the required 5-digit format. Fixed by recreating the table with `TEXT` type and restoring leading zeros using `PRINTF('%05d', zip_code_prefix)`.

Same issue affected `olist_sellers_dataset` — 1,027 seller zip codes fixed the same way.

---

## Analysis

### Revenue

**Total Revenue:** BRL 13,221,498.11

Summed from `order_items.price`, delivered orders only. Freight value excluded — shipping is a logistics cost, not product revenue.

| Year | Revenue (BRL) | YoY Growth |
|---|---|---|
| 2016 | 41,087.17 | — |
| 2017 | 5,612,817.85 | +34.8% |
| 2018 | 7,566,990.09 | +34.8% |

Consistent year-on-year growth of 34.8%. Monthly and quarterly trends were calculated using `STRFTIME` to extract periods, `LAG()` for month-on-month growth percentage, and `SUM() OVER` for running totals.

**Revenue from Cancelled Orders:** BRL 95,235.27, less than 1% of total revenue.

**Average Order Value:** BRL 137.04

Calculated as the average of per-order totals (summing items per order first, then averaging). The relatively low AOV suggests most purchases are single mid-range items rather than bulk orders.

**Top Revenue Category:** Health & Beauty (`beleza_saude`) — BRL 1,233,131.72

Top 10 categories and top 3 products per category were calculated. `ROW_NUMBER() OVER (PARTITION BY category)` was used for the per-category ranking.

---

### Cancelled Orders Breakdown

625 total cancelled orders, BRL 95K in lost revenue. Broken down by failure stage:

| Failure Stage | Count |
|---|---|
| Not approved by customer (payment/abandonment) | 141 |
| Delivered but labelled cancelled (likely returns) | 6 |
| Never handed to logistics (seller-side delay) | 409 |
| Lost in transit / never delivered by carrier | 69 |

The 409 seller-side failures were traced to 329 distinct sellers. The top offender delayed 9 orders. Product categories across cancelled orders were broadly random — no single category is responsible, ruling out a product quality issue.

---

### Delivery

**Average delivery time:** 12.6 days  
**On-time deliveries:** 88,705 (91.8%)  
**Late deliveries:** 7,765 (8.0%)  
*(Entries with missing or invalid dates excluded)*

**Delivery time by state (fastest to slowest):**

| State | Avg Delivery (days) | Local Delivery % |
|---|---|---|
| SP | 8.8 | 76% |
| ... | ... | ... |
| AM | 26.4 | 0% |
| AP | 27.2 | 0% |
| RR | 29.4 | 0% |

SP is the fastest because 76% of its orders are fulfilled locally. The three slowest states — RR, AP, AM — have zero local sellers, forcing every order through a long cross-country transit.

**Where the time is going:**
Average logistics handling time: 5 days. Average transit time: 25 days. The carrier/transit phase is the primary bottleneck, not seller preparation.

---

### Satisfaction

**Overall average review score:** 4.16 / 5

**Score distribution:**

| Score | Orders | % |
|---|---|---|
| 5 | 57,066 | 59.22% |
| 4 | 18,987 | 19.70% |
| 3 | 7,961 | 8.26% |
| 2 | 2,941 | 3.05% |
| 1 | 9,406 | 9.76% |

The 1-star spike (9.76%) is disproportionately high relative to 2-star and 3-star counts — a pattern typical of frustrated customers who skip middle ratings and go straight to the lowest.

**Delivery timing and satisfaction:**

| Delivery Status | Avg Review Score |
|---|---|
| On time | 4.29 |
| Late | 2.57 |

Late deliveries reduce review scores by 40%.

**Score by delivery window:**

| Delivery Time | Avg Score | Orders |
|---|---|---|
| 0–3 days | 4.48 | — |
| 4–7 days | — | — |
| 8–15 days | — | — |
| 16–21 days | — | — |
| 21+ days | 3.12 | — |

The score decline is gradual up to 21 days. Beyond that, it drops a full point. Three weeks is the customer patience threshold.

*Note: Review scores are whole numbers (1–5) in the raw data. `CAST(review_score AS REAL)` was used in all AVG calculations to force decimal division, without it, SQLite integer division truncates the result.*

---

### Payment

Credit card is the dominant payment method. Higher-priced categories show higher average installment counts, consistent with Brazil's parcelamento culture where large purchases are routinely split across months.

One-shot payments vs installments were compared across all delivered orders.

---

### Sellers

**Top 10 sellers by revenue** were identified with their total orders, average order value, and average review score. High revenue does not consistently correlate with high satisfaction scores.

**Sellers with the highest late delivery rate** — calculated as `late_deliveries / total_deliveries × 100`. Sellers with fewer than 10 orders were excluded to avoid distortion from single-order sellers.

**Highest rated seller — methodology:**

Initial approach: filter sellers with 10+ orders, rank by average rating.

> Result: `48efc9d94a9834137efd9ea76b065a38` — 33 orders, 5.0 average. Flagged as statistically suspicious, a perfect score across 33 orders is unusual.

Solution: switched to **Bayesian Average**.

**Formula:** `(v / v+m) × R + (m / v+m) × C`

| Variable | Meaning |
|---|---|
| v | Seller's total reviews |
| m | Minimum threshold = 10 |
| R | Seller's own average rating |
| C | Global average rating across all sellers |

The logic: sellers with more reviews get more weight on their own rating. Sellers with fewer reviews get pulled toward the global mean. A seller with exactly 10 reviews is trusted 50/50 — their own rating and the global average equally.

**Why m = 10:** The threshold wasn't chosen arbitrarily. A distribution analysis showed that over 60% of sellers (1,824 out of 3,095) have fewer than 10 orders. Setting m = 10 means the formula starts trusting a seller's own rating from the point where their volume becomes meaningful. The threshold and m are the same value deliberately — they represent the same decision.

> **Final result:** `c3cfdc648177fdbbbb35635a37472c53`  
> 313 reviews | Raw avg: 4.45 | Bayesian avg: **4.31**

The original suspicious seller dropped from 5.0 to 4.79 after Bayesian adjustment and no longer topped the ranking.

---

### RFM Segmentation

Customers were segmented using Recency, Frequency, and Monetary scores.

- **Recency** — days since last order, calculated using `JULIANDAY` against a reference date of 2018-12-01
- **Frequency** — total distinct orders per customer
- **Monetary** — total spend per customer

`PERCENT_RANK()` was used to score each dimension into three tiers (1–3). Combined scores were mapped to segments:

| Segment | RFM Pattern | Meaning |
|---|---|---|
| Champion | R:3 F:3 M:3 | Recent, frequent, high spenders |
| Loyal | R+F+M ≥ 6 | Strong overall, worth retaining |
| High Value Dormant | M:3 F:1 | Big spenders who never returned |
| Promising | R≥2 F≥1 | Recent and active, potential loyals |
| New Customer | R:3 F:1 M:1 | Just arrived, needs nurturing |
| At Risk | R:1 M:2 F:1 | Spent decently, going quiet |
| Lost | R:1 F:1 M:1 | Low on everything, likely gone |
| Needs Attention | Everything else | Mixed signals |

The query was structured as two CTEs: `RFM_base` to calculate raw metrics, `RFM_scores` to apply `PERCENT_RANK` and assign tier scores, then a final `SELECT` to apply segment labels.

**Key finding:** ~29,000 customers fall into the High Value Dormant segment, they spent significantly but never returned. This is the largest recoverable revenue opportunity in the dataset.

---

### Cohort Retention

Monthly cohorts were built by assigning each customer to the month of their first delivered order. Returning purchases in subsequent months were tracked and retention rates calculated at M1, M3, and M6.

Retention across all cohorts is under 1%. The business is almost entirely acquisition-dependent, the vast majority of customers purchase once and never return.

---

### Shopping Behaviour

Orders peak on **Monday** at midday and again at 4 PM. Sunday has higher order volume than Saturday, suggesting customers browse and research over the weekend and convert at the start of the working week.

---


## Recommendations

### 1. Fix the Cancellation Pipeline — Seller Accountability

625 orders were cancelled, costing BRL 95K. The breakdown tells you exactly where to intervene:

- **409 orders never reached logistics.** These are seller-side failures. The 329 implicated sellers should be flagged and the top ten with multiple missed orders should be warned. Introduce a dispatch SLA (e.g. 48-hour handoff window) and automate warnings when a seller misses it. Repeat offenders should face listing restrictions.
- **69 orders lost in transit.** This is a carrier problem. Audit the logistics partners on high-failure corridors and escalate or switch providers.
- **141 not approved by customers.** Likely payment failures or abandonments, monitor for patterns by payment method, region, and price point.
- **6 delivered but labelled cancelled.** Probable returns. Standardise how these are tagged to prevent them from polluting cancellation data.

---

### 2. Address the Logistics Bottleneck

8% of deliveries are late. The root cause is not distance alone, on average, orders experience a 5-day processing delay before undergoing a 25-day transit period.

The handling phase is the immediate lever. Work with logistics partners to reduce handling to 2–3 days. For the worst-performing states (RR, AP, AM) where delivery averages 26–30 days and local sellers are zero, explore regional fulfilment partnerships or incentivise sellers in those states to join the platform. Every day saved in handling directly reduces the late delivery rate and protects satisfaction scores.

---

### 3. Protect Revenue Through Satisfaction

Late deliveries reduce review scores from 4.29 to 2.57, a 40% drop. Beyond 21 days, scores fall a full additional point. Lower scores reduce future conversion.

- Prioritise fast-dispatch sellers in search ranking and visibility.
- Surface estimated delivery time prominently at checkout, customers who see a realistic date upfront give higher scores even when delivery is slow, because expectations are set correctly.
- Introduce a proactive delay notification system, customers informed early about delays consistently rate better than those who discover it themselves.

---

### 4. Re-engage the ~29K High Value Dormant Customers

These customers spent significantly but never returned. They are the largest single recoverable revenue opportunity in the dataset.

- Run a targeted re-engagement campaign with a time-limited discount (10–15%) sent within 60–90 days of their last purchase, before they fully disengage.
- Personalise outreach using their original purchase category, recommend related or complementary products rather than generic promotions.
- Track conversion from this segment separately from new customer acquisition to measure ROI cleanly.

---

### 5. Build a Retention Strategy, The Business Cannot Stay Acquisition-Only

Under 1% retention means every customer is effectively a one-time buyer. Acquisition spend is wasted if no one returns.

- Introduce a post-delivery follow-up, a discount on the next order sent 2–3 weeks after delivery, while the experience is still fresh.
- Test a first-repeat-purchase incentive: make the second order cheaper than the first. This is the highest-leverage point in the customer lifecycle.
- Longer term, build a loyalty programme. Customers who return twice are significantly more likely to return a third time, the goal is to engineer that second purchase at scale.

---

### 6. Shift Marketing to the Highest-Conversion Window

Orders peak Monday at midday and 4 PM. Sunday outperforms Saturday, customers research on weekends and convert at the start of the working week.

- Schedule promotional pushes for **Sunday evening** to catch customers in browse mode and position the offer for Monday morning conversion.
- Use Monday midday for flash sales or time-limited offers,  that is the peak purchase moment.
- Reduce spend on Saturday, which has lower purchase intent than Sunday despite also being a weekend day.

---

[↑ Back to Top](#top)
