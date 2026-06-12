# Olist E-Commerce Analysis (2016–2018)
 
End-to-end data analysis of Brazilian e-commerce using the Olist public dataset from Kaggle — covering ~99,400 orders across 2 years. The goal was to extract actionable business insights across revenue, delivery, customer satisfaction, seller performance, and customer segmentation.
 
**[View Interactive Dashboard](https://public.tableau.com/views/EcommerceDataAnalysis_17810834157140/OlistEcommerceAnalysis?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)** | **[Full Findings & Methodology](findings.md)**
 
---
 
## Tools Used
 
**SQL** (SQLite) — data exploration, cleaning, window functions, CTEs, cohort analysis, RFM segmentation  
**Python** (Jupyter Notebook) — cohort heatmap visualization  
**Tableau Public** — 6-chart interactive dashboard
 
---
 
## Dataset
 
**Source:** [Kaggle — Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/)  
**Period:** September 2016 – October 2018  
**Scale:** 9 tables, ~99,400 orders  
**Note:** All monetary values are in BRL (Brazilian Real).
 
**Setup:** Download the dataset from Kaggle, import CSV files into SQLite, run `data_cleaning.sql` before any analysis queries.
 
---
 
## Key Findings
 
**Revenue**
- Total revenue: BRL 13.2M across 2 years | BRL 40.4K (2016) → BRL 5.6M (2017) → BRL 7.5M (2018) — **34.8% YoY growth**
- Average order value: BRL 137 — most purchases are single mid-range items
- Credit card dominates payments; expensive items show high installment usage, reflecting Brazil's parcelamento culture
  
**Cancellations**
- 625 cancelled orders, BRL 95K in lost revenue (< 1% of total)
- Broken down: 141 not approved by customers, 6 delivered but labelled cancelled (likely returns), **409 never handed to logistics** (329 seller-side delays identified), 69 lost in transit
- Root cause is mostly seller-side failure to hand off to logistics, not product quality
  
**Delivery**
- Average delivery time: 12.6 days | 91.8% on time, 8% late
- Logistics handling averages 5 days; transit averages 25 days — the bottleneck is the logistics/carrier phase
- SP (São Paulo) is fastest at 8.8 days due to 76% local deliveries; RR, AP, AM are slowest (26–30 days) with zero local deliveries
  
**Satisfaction**
- Average review score: 4.16 / 5 | 59% give 5 stars, 9.7% give 1 star
- Timely delivery avg score: 4.29 | Late delivery avg score: 2.57 — **late deliveries cut satisfaction by 40%**
- 3 weeks is the customer patience threshold — scores drop a full point beyond 21 days
  
**Sellers**
- Top 10 sellers identified by revenue, orders, AOV, and review score — high revenue does not always mean high satisfaction
- Top-rated seller by Bayesian average: 313 reviews, 4.31 score (raw average was statistically misleading without volume weighting)
- Top 10 worst late-delivery-rate sellers identified (minimum 10 orders threshold)
  
**Customer Segmentation (RFM)**
- Champions: 721 | High Value Dormant: ~29K | Lost: ~10K
- The 29K dormant high-spenders are the single largest recoverable revenue opportunity
- Retention across all cohorts is under 1% — the business is entirely acquisition-dependent
  
**Shopping Behaviour**
- Orders peak on **Monday at midday and 4 PM**
- Sunday traffic is higher than Saturday — customers browse on weekends, convert on Monday
- Best conversion window: **Sunday evening push → Monday morning**
  
---
 
## Project Structure
 
| File | Description |
|---|---|
| `data_exploration.sql` | Dataset overview, order status metrics, price ranges, peak hours/days, geographic distribution |
| `data_cleaning.sql` | Empty string handling, null checks, duplicate detection, invalid value checks, orphan record checks, zip code fixes |
| `revenue.sql` | Total/yearly/monthly/quarterly revenue, MoM growth, running total, AOV, top categories, cancelled order breakdown |
| `delivery.sql` | Average delivery time, on-time vs late analysis, delivery time by state, local vs non-local impact |
| `satisfaction.sql` | Review score distribution, scores by category, delivery time vs satisfaction |
| `payment.sql` | Revenue by payment type, installment analysis, one-shot vs installment orders |
| `sellers.sql` | Top sellers by revenue, Bayesian average rating, late delivery rate by seller |
| `RFM.sql` | Recency, Frequency, Monetary scoring using PERCENT_RANK, customer segmentation |
| `cohort_retention.sql` | Monthly cohort analysis, retention at M1, M3, M6 |
| `olist_ecommerce_analysis.ipynb` | Cohort retention heatmap |
 
---
 

<img width="1542" height="864" alt="tableau" src="https://github.com/user-attachments/assets/eeb8559a-b7f9-4d97-a1e8-d194250495e1" />

----number before drawing conclusions. The most surprising finding was near-zero retention — it only became obvious when visualized, not when reading raw SQL output.

