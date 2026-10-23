# Sizwe Coffee: SQL Analysis

## Project Overview
This repository contains the SQL analysis for the Sizwe Coffee year-end review. The purpose of this project was to answer eight specific business questions posed by the Financial Director (Nomsa Dlamini) and the National Sales Manager (Bongani Twala). The analysis explores channel performance, product profitability, debt collection slowdowns, sales rep targets, seasonal trends, and the sudden drop in the company's gross margin.

## Dataset
The analysis was performed using the Sizwe Coffee dataset, which contains information on 1,400 business customers and over 48,000 orders across FY2024 and FY2025. The key tables used in this project include:
* sizwe_sales_orders: Order-level data (dates, channels, reps).
* sizwe_sales_lines: Line-item data (revenue, units, SKU).
* sizwe_products: Product details (lines, unit costs).
* sizwe_customers: Customer details (segments, provinces).
* sizwe_reps: Sales representative details (targets, territories).
* sizwe_ar_ledger: Accounts receivable data (invoice and settlement dates).
* sizwe_trade_promotions: Data on promotional support given to customers.

## Skills Demonstrated
Throughout the eight tasks, the following SQL techniques were applied:
* Joins (INNER & LEFT): Used to connect disparate tables.
* Conditional Aggregation (CASE WHEN): Used to split revenue into FY2024 and FY2025 side-by-side in a single query.
* Anti-Joins (NOT EXISTS): Used in Task 5 to find customers who had never received a trade promotion.
* Window Functions: Used in Task 7 (LAG and ROWS BETWEEN) to calculate month-over-month growth and rolling averages.
* CTEs (Common Table Expressions): Used in Tasks 7 and 8 to break down complex calculations into readable, step-by-step queries.
* Date Manipulation: Used DATE_TRUNC and DATEDIFF to group data by month and calculate payment delays.

## Key Insights for the Year-End Review
Based on the queries in queries.sql, here are the main findings:
1. Channel Growth: Both Wholesale and Subscription channels grew at a healthy rate of approximately 8.8% year-over-year, pushing total revenue from R441m to R480m.
2. Profit Margins: While House Blend generates the highest total gross profit (R106m), Single Origin earns the highest margin percentage (44.02%).
3. Collections Slowing Down: Nomsa's suspicion was correct. The average days to pay jumped from 35.8 days in FY2024 to 46.8 days in FY2025.
4. Unpromoted Accounts: Several massive Wholesale accounts (e.g., Umhlanga Fresh 108) are generating over R62m without any trade promotions, representing an opportunity for account managers to step in.
5. Rep Performance: Performance varies wildly. Karabo van Wyk is achieving 250% of his monthly target, while some reps have generated zero revenue.
6. Margin Decline Mystery Solved: The overall company margin dropped because of a shift in product mix. Bulk Commercial (a low 18.9% margin product) grew from 25% to 33.6% of total revenue, while high-margin products made up a smaller share.

## How to Run
All queries are written in standard SQL (compatible with Databricks/PostgreSQL/DuckDB). To reproduce the results, open the queries.sql file in your SQL editor and run each query. Each query includes comments detailing the business answer.
