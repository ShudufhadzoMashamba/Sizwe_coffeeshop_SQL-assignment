--TASK 1:CHANNEL Performance

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

Task 2: Where the profit actually comes from

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

