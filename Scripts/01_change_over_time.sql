-- ---------------------------------------------------------------------
-- 1. Total sales by year
--    Answers: "How has the business grown year over year?"
-- ---------------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(sales_amount)             AS total_sales,
    COUNT(DISTINCT order_number)  AS total_orders,
    SUM(quantity)                 AS total_items_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY order_year;


-- ---------------------------------------------------------------------
-- 2. Total sales by month-of-year (Jan across all years, Feb across all, ...)
--    Answers: "Is there a seasonal pattern? Which months are strongest?"
-- ---------------------------------------------------------------------
SELECT
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT order_number)   AS total_orders,
    SUM(quantity)                  AS total_items_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY order_month;


-- ---------------------------------------------------------------------
-- 3. Total sales by year-month (proper time series)
--    Each row = one calendar month in chronological order.
-- ---------------------------------------------------------------------
SELECT
    TRUNC(order_date, 'MM')        AS order_month,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT order_number)   AS total_orders,
    SUM(quantity)                  AS total_items_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TRUNC(order_date, 'MM')
ORDER BY order_month;


-- ---------------------------------------------------------------------
-- 4. Monthly trend with month-over-month (MoM) change
--    Uses LAG() to compare each month to the previous one.
--    The first row's MoM columns will be NULL (no previous month).
-- ---------------------------------------------------------------------
SELECT
    order_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY order_month)                    AS prev_month_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY order_month)      AS mom_change,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY order_month), 0) * 100
    , 2)                                                            AS mom_pct_change
FROM (
    SELECT
        TRUNC(order_date, 'MM') AS order_month,
        SUM(sales_amount)       AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY TRUNC(order_date, 'MM')
) t
ORDER BY order_month;
