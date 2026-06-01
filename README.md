# Olist E-Commerce Analysis (2016–2018)

This is an end-to-end data analysis project on Brazilian e-commerce using Olist public dataset from Kaggle covering ~99,400 orders across 2 years. The goal was to extract actionable business insights across revenue, delivery, customer satisfaction, seller performance, and customer segmentation.

[View Interactive Dashboard](https://public.tableau.com/app/profile/hira.sajid3988/viz/OlistEcommerceAnalysis_17801418957140/OlistEcommerceAnalysis)

Detailed findings and methodology: [findings.md](https://github.com/pseudocrawl/olist-ecommerce-analysis/blob/main/findings.md)

---

## Tools Used
- **SQL** (SQLite) —  data exploration, data cleaning, window functions, CTEs, sub-queries, cohort analysis, RFM segmentation
- **Tableau Public** — 6-chart interactive dashboard

---

## Dataset
- **Source:** [Kaggle — Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/)
- **Period:** September 2016 – October 2018
- **Scale:** 9 tables, ~99,400 orders
- **Setup:** Download the dataset from Kaggle, import CSV files into SQLite, run `data_cleaning.sql` before any analysis queries.
**Note:** All monetary values are in BRL (Brazilian Real).
  
---

## Key Business Questions and Findings
|Question|Finding|Insight|
|---|---|---|
|What is the scale and growth of revenue?|total: BRL ~13.2M , BRL ~40.4K (2016) -> BRL ~5.6M (2017) -> BRL ~7.5M (2018)| 34.8% YoY growth, consistent upward trend|
|What did cancellations cost?| BRL ~95K revenue lost| less than 1% of total revenue, low risk |
|What is the AOV?|BRL 137| suggests most purchases are single mid-range items rather than bulk buying|
|How do customers pay?| credit card dominance - high installments on expensive items| reflects parcelamento culture |
|Are deliveries on time?| 91.8% on time, 8% late | good percentage but late deliveries cost in satisfaction scores|
|Which state has the best delivery time?|SP (8.8 days)|76% local deliveries in SP|
|What is the average delivery time?| 12.6 days | fastest is 8.8 means average can be improved |
|Which states have worst delivery?|RR (29.4 days), AP (27.2 days) , AM (26.4 days) | zero local deliveries in these states |
|Does delivery speed affect satisfaction?| delivery review score - timely : 4.29 , late: 2.57| timely delivery is a crucial driver for customer satisfaction, late deliveries reduce customer satisfaction by 40%|
|How much does each extra week cost in ratings?|0-3 days : 4.48 , 21+ days : 3.12|the decline in rating is gradual upto 21 days, after that it drops to full one point, 3 weeks is customer patience threshold|
|How satisfied are customers overall?| average score: 4.16/5, 59% give 5 stars| generally positive, 9.7% give 1 star|
|Which sellers perform best by revenue?|top 10 identified with total revenue, orders, AOV and review score | high revenue doesn't always mean high review score|
|Which sellers have worst delivery rates?|top 10 worst identified (threshold: min 10 orders)|these sellers should be warned|
|Who is the truly highest rated seller?| 313 reviews ,4.31 score | raw average was statistically misleading, used Bayesian average preventing sellers with few reviews from ranking unfairly high.|
|Who are the most valuable customers?|Champions:721, High Value Dormant:29K,Lost:10k (full breakdown in dashboard)|Dormant class (29k) gives huge recoverable revenue opportunity|
|Are customers coming back?|Under 1% retention across all cohorts|business entirely acquisition dependent, retention strategy needed|
|When do customers shop most?|peak hours and days identified| Orders peak Monday at midday and 4pm, Sunday > Saturday, customers research on weekends, buy on Monday work breaks. Target Sunday evening for maximum conversion.|

---

### RFM Segments Explained
> RFM (Recency, Frequency, Monetary) segments customers based on purchase behavior. Here's what each segment means:

| Segment | RFM Pattern | Means |
|---|---|---|
| Champion | R:3 F:3 M:3 | Best customers: recent, frequent, high spenders |
| Loyal | R+F+M ≥ 6 | Strong overall, worth retaining |
| High Value Dormant | M:3 F:1 | Spent big once, never returned, prime re-engagement target |
| Promising | R≥2 F≥1 | Recent and active, potential loyals in the making |
| New Customer | R:3 F:1 M:1 | Just arrived, needs nurturing |
| At Risk | R:1 M:2 F:1 | Spent decently but going quiet, act before they're lost |
| Lost | R:1 F:1 M:1 | Low on everything, likely gone |
| Needs Attention | Everything else | Mixed signals|

---

## Project Structure

| File | Description |
|---|---|
| `data_exploration.sql` | Dataset overview, order status metrics, price ranges, peak hours/days, geographic distribution |
| `data_cleaning.sql` | Empty string handling, null checks, duplicate detection, invalid value checks, orphan record checks, zip code fixes |
| `revenue.sql` | Total/yearly/monthly/quarterly revenue, MoM growth, running total, AOV, top categories |
| `delivery.sql` | Average delivery time, on-time vs late analysis, delivery time by state |
| `satisfaction.sql` | Review score distribution, scores by category, delivery time vs satisfaction |
| `payment.sql` | Revenue by payment type, installment analysis, one-shot vs installment orders |
| `sellers.sql` | Top sellers by revenue, Bayesian average rating, late delivery rate by seller |
| `RFM.sql` | Recency, Frequency, Monetary scoring using PERCENT_RANK, customer segmentation |
| `cohort_retention.sql` | Monthly cohort analysis, retention at M1, M3, M6 |

---

## Dashboard Preview

<img width="1331" height="790" alt="dashboard_preview" src="https://github.com/user-attachments/assets/d7b37331-7808-4f6e-9341-45692a425904" />

---

## Data Quality Issues Found & Handled

| Issue | Action Taken |
|---|---|
| Empty strings and 'null' text values across all tables | Converted to real NULL using CASE WHEN TRIM() |
| Invalid dates (84 orders) | Excluded in date-sensitive queries |
| Zero freight values (383) | Excluded in freight analysis |
| Duplicate review IDs (789) | Handled naturally by GROUP BY |
|~23K customer zip codes and ~1K seller zip codes stored as INTEGER — lost leading zeros | Recreated both tables with TEXT type columns, then restored leading zeros using PRINTF('%05d')|
| 775 order items with no order | Dropped automatically via INNER JOIN |
| 610 products with missing category | Excluded from category analysis |

--- 

## What I Learned
Data cleaning took longer than the analysis itself — the dataset had 
silent errors that only surfaced when query results looked off. I learned 
to question every number before drawing conclusions. The most surprising 
finding was near-zero retention — it only became obvious when visualized, 
not when reading raw SQL output.

