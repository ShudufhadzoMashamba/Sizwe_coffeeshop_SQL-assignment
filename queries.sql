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
