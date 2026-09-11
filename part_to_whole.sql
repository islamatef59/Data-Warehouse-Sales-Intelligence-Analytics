/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
- Evaluate how individual product categories contribute relative to total sales.
- Calculate proportion and percentage share of total revenue per category.
- Identify top-performing categories that drive overall revenue growth.
*/
	
-- Which categories contribute the most to overall sales?

WITH category_sales AS (
SELECT 
	p.category ,
	SUM(CAST(f.sales_amount AS BIGINT)) AS total_sales
FROM gold.fact_sales f
LEFT JOIN  gold.dim_products p
	ON p.product_key=f.product_key
GROUP BY p.category
)

SELECT 
category,
SUM(total_sales) OVER() AS overall_sales,
ROUND((CAST(total_sales AS FLOAT))/(SUM(total_sales) OVER()),2) AS category_percentage
FROM category_sales
ORDER BY overall_sales DESC
