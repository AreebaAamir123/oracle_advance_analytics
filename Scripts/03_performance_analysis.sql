-- ---------------------------------------------------------------------
-- Yearly performance per product vs its own average and previous year
-- ---------------------------------------------------------------------
SELECT
    sales_year,
    product_name,
    total_sales,

    -- Benchmark 1: product's own average across all years
    ROUND(AVG(total_sales) OVER (PARTITION BY product_key), 2) AS avg_sales,
     --Difference
    total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_key), 2) AS diff_vs_avg,

    -- Benchmark 2: previous year's sales for the same product
    LAG(total_sales) OVER (
        PARTITION BY product_key
        ORDER BY sales_year
    ) AS prev_year_sales, 
    total_sales - LAG(total_sales) OVER (
        PARTITION BY product_key
        ORDER BY sales_year
    ) AS diff_vs_prev_year,

FROM (
    SELECT
        EXTRACT(YEAR FROM f.order_date) AS sales_year,
        p.product_key,
        p.product_name,
        SUM(f.sales_amount)             AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_key, p.product_name
) t
ORDER BY product_name, sales_year;
