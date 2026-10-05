-- Product Segmentation
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
           WHEN cost < 100                 THEN 'Below 100'
WHEN cost BETWEEN 100 AND 500   THEN '100-500'
WHEN cost BETWEEN 500 AND 1000  THEN '500-1000'
ELSE                                 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Customer Segmentation 
/* VIP: Customers with at least 12 months of history AND spending more than €5,000

Regular: Customers with at least 12 months of history BUT spending €5,000 or less

New: Customers with a lifespan less than 12 months */

WITH customer_stats AS (
    SELECT
        c.customer_key,
        c.first_name || ' ' || c.last_name          AS customer_name,
        MIN(f.order_date)                            AS first_order_date,
        MAX(f.order_date)                            AS last_order_date,
        TRUNC(MONTHS_BETWEEN(MAX(f.order_date), MIN(f.order_date))) AS lifespan_months,
        SUM(f.sales_amount)                          AS total_spending
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
),
customer_segments AS (
    SELECT
        customer_key,
        customer_name,
        lifespan_months,
        total_spending,
        CASE
            WHEN lifespan_months >= 12 AND total_spending > 5000  THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            WHEN lifespan_months <  12                            THEN 'New'
            ELSE 'Unknown'
        END AS customer_segment
    FROM customer_stats
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;

