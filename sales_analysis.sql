-- ============================================================
-- Sales Analysis — Queries
-- ============================================================
USE sales_analysis;


-- ============================================================
-- 1. AGGREGATIONS
-- ============================================================

-- Total revenue, orders, and avg order value by product line
SELECT
    p.product_line,
    COUNT(DISTINCT o.order_number)          AS total_orders,
    SUM(oi.sales)                           AS total_revenue,
    ROUND(AVG(oi.sales), 2)                AS avg_order_item_value,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT o.order_number), 2) AS avg_order_value
FROM order_items oi
JOIN orders o ON oi.order_number = o.order_number
JOIN products p ON oi.product_code = p.product_code
GROUP BY p.product_line
ORDER BY total_revenue DESC;


-- Revenue by country
SELECT
    c.country,
    COUNT(DISTINCT o.order_number)  AS total_orders,
    SUM(oi.sales)                   AS total_revenue
FROM order_items oi
JOIN orders o  ON oi.order_number = o.order_number
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;


-- Revenue by deal size
SELECT
    oi.deal_size,
    COUNT(*)            AS total_line_items,
    SUM(oi.sales)       AS total_revenue,
    ROUND(AVG(oi.sales), 2) AS avg_sale
FROM order_items oi
GROUP BY oi.deal_size
ORDER BY total_revenue DESC;


-- Order status breakdown
SELECT
    o.status,
    COUNT(*)                        AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders o
GROUP BY o.status
ORDER BY order_count DESC;


-- ============================================================
-- 2. JOINS
-- ============================================================

-- Top 10 customers by revenue with their country and territory
SELECT
    c.customer_name,
    c.country,
    c.territory,
    COUNT(DISTINCT o.order_number)  AS total_orders,
    SUM(oi.sales)                   AS total_revenue
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_number = oi.order_number
GROUP BY c.customer_id, c.customer_name, c.country, c.territory
ORDER BY total_revenue DESC
LIMIT 10;


-- Revenue by product line and territory (cross-cut)
SELECT
    c.territory,
    p.product_line,
    SUM(oi.sales)   AS total_revenue
FROM order_items oi
JOIN orders o       ON oi.order_number = o.order_number
JOIN customers c    ON o.customer_id = c.customer_id
JOIN products p     ON oi.product_code = p.product_code
GROUP BY c.territory, p.product_line
ORDER BY c.territory, total_revenue DESC;


-- Average MSRP vs actual average selling price per product line
SELECT
    p.product_line,
    ROUND(AVG(p.msrp), 2)       AS avg_msrp,
    ROUND(AVG(oi.price_each), 2) AS avg_selling_price,
    ROUND(AVG(oi.price_each) / AVG(p.msrp) * 100, 2) AS pct_of_msrp
FROM order_items oi
JOIN products p ON oi.product_code = p.product_code
GROUP BY p.product_line
ORDER BY pct_of_msrp DESC;


-- ============================================================
-- 3. WINDOW FUNCTIONS
-- ============================================================

-- Monthly revenue with running total and month-over-month growth
WITH monthly AS (
    SELECT
        o.year,
        o.month,
        SUM(oi.sales) AS monthly_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_number = o.order_number
    GROUP BY o.year, o.month
)
SELECT
    year,
    month,
    ROUND(monthly_revenue, 2)                                                           AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (PARTITION BY year ORDER BY month), 2)              AS ytd_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month), 2)       AS mom_change,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month))
        / LAG(monthly_revenue) OVER (ORDER BY year, month) * 100
    , 2)                                                                                AS mom_growth_pct
FROM monthly
ORDER BY year, month;


-- Rank customers by revenue within each country
SELECT
    c.country,
    c.customer_name,
    SUM(oi.sales)                                                           AS total_revenue,
    RANK() OVER (PARTITION BY c.country ORDER BY SUM(oi.sales) DESC)       AS rank_in_country
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_number = oi.order_number
GROUP BY c.country, c.customer_id, c.customer_name
ORDER BY c.country, rank_in_country;


-- Top product per territory using window function
WITH ranked AS (
    SELECT
        c.territory,
        p.product_line,
        SUM(oi.sales)                                                           AS revenue,
        RANK() OVER (PARTITION BY c.territory ORDER BY SUM(oi.sales) DESC)     AS rnk
    FROM order_items oi
    JOIN orders o    ON oi.order_number = o.order_number
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p  ON oi.product_code = p.product_code
    GROUP BY c.territory, p.product_line
)
SELECT territory, product_line, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rnk = 1;


-- 3-month rolling average revenue
WITH monthly AS (
    SELECT
        o.year,
        o.month,
        SUM(oi.sales) AS monthly_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_number = o.order_number
    GROUP BY o.year, o.month
)
SELECT
    year,
    month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3m_avg
FROM monthly
ORDER BY year, month;
