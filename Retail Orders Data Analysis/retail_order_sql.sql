-- Find top 10 highest revenue generation products
SELECT product_id, sum(sale_price) as sales 
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC LIMIT 10

-- Find top 5 highest selling products in each region
WITH sales_ranked AS (
	SELECT region, product_id, SUM(sale_price) AS sales
	FROM df_orders
	GROUP BY region, product_id
) SELECT * FROM (
SELECT * , ROW_NUMBER()
OVER(PARTITION BY region
ORDER BY sales DESC) as rn
FROM sales_ranked) A
WHERE rn <=5

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS(
SELECT EXTRACT(YEAR FROM order_date) as order_year, 
EXTRACT(MONTH FROM order_date) as order_month,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
-- ORDER BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month

-- For each category which month had highest sales
WITH cte AS (
SELECT category, TO_CHAR(order_date, 'yyyyMM') as order_year_month,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, TO_CHAR(order_date, 'yyyyMM')
-- ORDER BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(
PARTITION BY category
ORDER BY sales DESC
) AS rn
FROM cte
) a
WHERE rn=1

-- Which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
SELECT sub_category, 
EXTRACT(YEAR FROM order_date) as order_year,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
),
cte2 AS (
SELECT sub_category,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
)
SELECT * , (sales_2023-sales_2022)
FROM cte2 
ORDER BY (sales_2023-sales_2022) DESC LIMIT 1