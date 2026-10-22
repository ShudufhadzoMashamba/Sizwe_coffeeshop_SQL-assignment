--TASK 1:Channel Performance

SELECT o.channel,
       SUM(CASE WHEN o.order_date <= '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS FY2024_revenue,
       SUM(CASE WHEN o.order_date > '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS FY2025_revenue
FROM Sizwe_sales_orders AS o
JOIN Sizwe_sales_lines AS sl
ON o.order_id=sl.order_id
    GROUP BY o.channel
    ORDER BY FY2025_REVENUE DESC;

    --comments--
    --Wholesale remains large channel from R308m to R335m, which is about 8.8% 
    --Subcription is the second largest channel with revenue from R132m to R144m, which is also about 8.8%
    --Both channels contributed to the total revenue growth from R441m to R480m


--TASK 2: Where the profit actually comes from

SELECT     
  p.product_line,
  SUM(sl.line_revenue) AS revenue,
  SUM(sl.units * p.unit_cost) AS cost_of_goods,
  SUM(sl.line_revenue)-SUM(sl.units * p.unit_cost) AS gross_profit,
  ROUND(
    (SUM(sl.line_revenue)-SUM(sl.units * p.unit_cost)) / SUM(sl.line_revenue) * 100, 2) AS gross_margin_pct
FROM Sizwe_sales_lines AS sl
JOIN Sizwe_products AS p
  ON sl.sku=p.sku
GROUP BY
  p.product_line
ORDER BY
  gross_profit DESC

  --Comments--
  --Highest profit is earned by House blend which makes about R106m in profit profit
  --The highest margin is earned by single origin which makes about 44.02% of the margin
       

--TASK 3: The collections problem

SELECT
  CASE
    WHEN invoice_date <= '2024-06-30' THEN 'FY2024'
    ELSE 'FY2025'
  END AS fiscal_year,
  COUNT(*) AS total_invoices,
  ROUND(AVG(DATEDIFF(settlement_date, invoice_date)), 1) AS avg_days_to_pay,
  ROUND(AVG(DATEDIFF(settlement_date, due_date)), 1) AS avg_days_overdue
FROM sizwe_ar_ledger
WHERE settlement_date IS NOT NULL
GROUP BY
  CASE
    WHEN invoice_date <= '2024-06-30' THEN 'FY2024'
    ELSE 'FY2025'
  END
ORDER BY
fiscal_year;

--comments--
--Nomsa is correct, in FY2024, the customers paid early, the average of 35.8 days
--In FY2025, payments slowed down, to an average of 46.8 days, they now pay late
--the business now waits roughly 11 days to get its cash


TASK 4: The TEN accounts that matter most

SELECT
 c.trading_name,
 c.segment,
 c.province,
 r.rep_name,
SUM(sl.line_revenue) AS total_revenue
FROM sizwe_customers AS c
LEFT JOIN Sizwe_reps AS r
 ON c.rep_id = r.rep_id
JOIN Sizwe_sales_orders AS o
 ON c.customer_id = o.customer_id
JOIN Sizwe_sales_lines AS sl
 ON o.order_id = sl.order_id
WHERE o.order_date > '2024-06-30'
GROUP BY
 c.trading_name,
 c.segment,
 c.province,
 r.rep_name
ORDER BY
 total_revenue DESC
LIMIT 10;

--Comments--
--the top 10 customers by FY2025 revenue are led by Halvane retail group with R38.4m
--All top 10 have sales representative assigned to them


TASK 5: A Commercial Gap

SELECT
 c.trading_name,
 c.segment,
 c.province,
 SUM(sl.line_revenue) AS total_revenue
FROM sizwe_customers AS c
JOIN sizwe_sales_orders AS o
 ON c.customer_id = o.customer_id
JOIN sizwe_sales_lines AS sl
 ON o.order_id = sl.order_id
WHERE c.channel = 'Wholesale'
 AND NOT EXISTS (
    SELECT 1
    FROM Sizwe_trade_promotions AS p
    WHERE p.customer_id = c.customer_id
)
GROUP BY
 c.trading_name,
 c.segment,
 c.province
ORDER BY
 total_revenue DESC 
 LIMIT 15;

--Comments--
--the top 3 accounts needs to be given a trade promotion
--they ard generating over R63m each without the trade promotions
--by doing this, these revenues will be protected from competitors

