# Advanced Analytics — Oracle SQL

Business-focused analytics built on top of a curated star schema.
This folder contains six analytical patterns commonly used in real
Business Intelligence work — all written in **Oracle SQL** using
window functions, aggregations, and time-based grouping.


Every query here reads from `gold.fact_sales` and its associated
dimensions (`gold.dim_customers`, `gold.dim_products`) — the reporting
layer of an upstream Data Warehouse project built with the Medallion
Architecture.


(DWH Repo) [https://github.com/AreebaAamir123/sql-oracle-data-warehouse]
---

## 🎯 Purpose

The goal of this is to demonstrate **analytical SQL** 

Each script focuses on one analytics pattern:

| # | Pattern | Business Question |
|---|---|---|
| 1 | **Change Over Time** | Is the business growing? Shrinking? Seasonal? |
| 2 | **Cumulative Analysis** | How much have we sold so far? Are we on target? |
| 3 | **Performance Analysis** | Which products are above their average? Which are declining? |
| 4 | **Part-to-Whole** | What % of total sales does each category contribute? |
| 5 | **Data Segmentation** | How do we group customers/products into meaningful tiers? |
| 6 | **Reporting** | How do we summarize the business in a single view? |

## Repo 

├── 01_change_over_time.sql          
├── 02_cumulative_analysis.sql       
├── 03_performance_analysis.sql      
├── 04_part_to_whole.sql             
├── 05_data_segmentation.sql         
└── 06_customer_report.sql            
