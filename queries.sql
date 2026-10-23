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


TASK 6: Are sales representatives hitting the target?

SELECT 
    r.rep_name,
    r.territory,
    r.target_monthly,
    ROUND(COALESCE(SUM(sl.line_revenue), 0) / 12, 2) AS fy2025_monthly_avg,
    ROUND((COALESCE(SUM(sl.line_revenue), 0) / 12) / r.target_monthly * 100, 2) AS pct_of_target
FROM sizwe_reps AS r
LEFT JOIN sizwe_sales_orders AS o
    ON r.rep_id = o.rep_id
LEFT JOIN sizwe_sales_lines AS sl
    ON o.order_id = sl.order_id
    AND o.order_date > '2024-06-30'
GROUP BY 
    r.rep_name,
    r.territory,
    r.target_monthly
ORDER BY 
    pct_of_target DESC;

--comments--
-- There is a huge difference in performance. The top rep (Karabo van Wyk) 
-- is hitting over 250% of target, while others at the bottom are at 0%. 
-- The business should investigate why some territories are overperforming 
-- while others are missing their targets.


-- TASK 7: The shape of the year

SELECT 
    DATE_TRUNC('month', o.order_date) AS sales_month,
    SUM(sl.line_revenue) AS revenue,
    
    LAG(SUM(sl.line_revenue)) OVER (ORDER BY DATE_TRUNC('month', o.order_date)) AS previous_month_revenue,
    
    ROUND(
        (SUM(sl.line_revenue) - LAG(SUM(sl.line_revenue)) OVER (ORDER BY DATE_TRUNC('month', o.order_date))) 
        / LAG(SUM(sl.line_revenue)) OVER (ORDER BY DATE_TRUNC('month', o.order_date)) * 100
    , 2) AS pct_change_from_prev_month,
    
    ROUND(
        AVG(SUM(sl.line_revenue)) OVER (ORDER BY DATE_TRUNC('month', o.order_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    , 2) AS rolling_3_month_avg

FROM sizwe_sales_orders AS o
JOIN sizwe_sales_lines AS sl
    ON o.order_id = sl.order_id
GROUP BY 
    DATE_TRUNC('month', o.order_date)
ORDER BY 
    sales_month ASC;

-- Comments--
-- There is a clear seasonal pattern where revenue drops sharply in December 
-- (down 13% in Dec 2023) and bounces back in January


TASK 8: Why has the margins moved?

WITH yearly_margins AS (
    SELECT 
        p.product_line,
        
        -- FY2024 Calculations
        SUM(CASE WHEN o.order_date <= '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS fy2024_rev,
        SUM(CASE WHEN o.order_date <= '2024-06-30' THEN (sl.line_revenue - (sl.units * p.unit_cost)) ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN o.order_date <= '2024-06-30' THEN sl.line_revenue ELSE 0 END), 0) * 100 AS fy2024_margin,

        -- FY2025 Calculations
        SUM(CASE WHEN o.order_date > '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS fy2025_rev,
        SUM(CASE WHEN o.order_date > '2024-06-30' THEN (sl.line_revenue - (sl.units * p.unit_cost)) ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN o.order_date > '2024-06-30' THEN sl.line_revenue ELSE 0 END), 0) * 100 AS fy2025_margin

    FROM sizwe_sales_lines AS sl
    JOIN sizwe_products AS p
        ON sl.sku = p.sku
    JOIN sizwe_sales_orders AS o
        ON sl.order_id = o.order_id
    GROUP BY 
        p.product_line
)
SELECT 
    product_line,
    ROUND(fy2024_rev, 2) AS fy2024_revenue,
    ROUND(fy2024_margin, 2) AS fy2024_margin_pct,
    ROUND(fy2024_rev / SUM(fy2024_rev) OVER () * 100, 2) AS fy2024_rev_share_pct,
    
    ROUND(fy2025_rev, 2) AS fy2025_revenue,
    ROUND(fy2025_margin, 2) AS fy2025_margin_pct,
    ROUND(fy2025_rev / SUM(fy2025_rev) OVER () * 100, 2) AS fy2025_rev_share_pct

FROM yearly_margins
ORDER BY 
    fy2025_rev DESC;

--Comments--
--The company sold more of its lowest-margin product, Bulk Commercial 
-- (margin 18.9%). Bulk Commercial's share of total revenue grew from 25.02% in FY2024 
-- to 33.65% in FY2025. Meanwhile, higher-margin products like Single Origin (margin 44%) 
-- saw their share drop from 19.45% to 17.57%. Because the low-margin product now makes up 
-- a third of all revenue, it has dragged the company's total average margin down.
