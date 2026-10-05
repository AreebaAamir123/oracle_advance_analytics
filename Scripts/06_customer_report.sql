/*   
1.Gather essential customer fields — name, age, transaction details

2.Segment customers — VIP / Regular / New + age groups

3.Aggregate customer-level metrics — total orders, sales, quantity, products, lifespan

4.Calculate KPIs — recency, average order value, average monthly spen
*/

WITH base_query AS (
    -- Stage 1: join fact + dim, one row per sales line
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.birthdate,
        c.gender,
        c.country
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
    -- Stage 2: aggregate per customer
    SELECT
        customer_key,
        customer_number,
        customer_name,
        birthdate,
        gender,
        country,
        MIN(order_date)                                                              AS first_order,
        MAX(order_date)                                                              AS last_order,
        COUNT(DISTINCT order_number)                                                 AS total_orders,
        SUM(sales_amount)                                                            AS total_sales,
        SUM(quantity)                                                                AS total_quantity,
        COUNT(DISTINCT product_key)                                                  AS total_products,
        -- Lifespan in months (first order → last order)
        TRUNC(MONTHS_BETWEEN(MAX(order_date), MIN(order_date)))                      AS lifespan_months,
        -- Recency in months (last order → today)
        TRUNC(MONTHS_BETWEEN(SYSDATE, MAX(order_date)))                              AS recency_months
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, birthdate, gender, country
)
SELECT
    -- Basic info
    customer_key,
    customer_number,
    customer_name,

    -- Age and age group
    TRUNC(MONTHS_BETWEEN(SYSDATE, birthdate) / 12) AS age,
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, birthdate) / 12) < 30 THEN 'Under 30'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, birthdate) / 12) BETWEEN 30 AND 49 THEN '30-49'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, birthdate) / 12) BETWEEN 50 AND 69 THEN '50-69'
        ELSE '70+'
    END AS age_group,

    -- Country and gender
    country,
    gender,

    -- Segment based on lifespan and spending
    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000  THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        WHEN lifespan_months <  12                         THEN 'New'
        ELSE 'Unknown'
    END AS customer_segment,

    -- Aggregated metrics
    first_order,
    last_order,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_months,
    recency_months,

    -- KPIs
    ROUND(total_sales / NULLIF(total_orders, 0), 2)                AS avg_order_value,
    ROUND(total_sales / NULLIF(lifespan_months, 0), 2)             AS avg_monthly_spend

FROM customer_aggregation
ORDER BY total_sales DESC;
