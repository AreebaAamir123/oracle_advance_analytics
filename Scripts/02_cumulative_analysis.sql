-- ---------------------------------------------------------------------
-- 1. Running total of sales per month (from the beginning)
-- ---------------------------------------------------------------------
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT
        TRUNC(order_date, 'MM') AS order_month,
        SUM(sales_amount)       AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY TRUNC(order_date, 'MM')
) t
ORDER BY order_month;


-- ---------------------------------------------------------------------
-- 2. Running sales, orders, and items (three measures at once)
-- ---------------------------------------------------------------------
SELECT
    order_month,
    total_sales,
    SUM(total_sales)             OVER (ORDER BY order_month) AS running_sales,
    total_orders,
    SUM(total_orders)            OVER (ORDER BY order_month) AS running_orders,
    total_items,
    SUM(total_items)             OVER (ORDER BY order_month) AS running_items
FROM (
    SELECT
        TRUNC(order_date, 'MM')      AS order_month,
        SUM(sales_amount)            AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(quantity)                AS total_items
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY TRUNC(order_date, 'MM')
) t
ORDER BY order_month;
