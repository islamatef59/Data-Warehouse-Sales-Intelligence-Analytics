/*
===============================================================================
Product Report View Creation
===============================================================================
Purpose:
    - Creates or updates the 'gold.report_products' view to consolidate key 
      product metrics, sales performance classifications, and financial KPIs.
    - Features:
        1. Base data joining (sales fact + product dimension).
        2. Product-level aggregated sales statistics (orders, customers, quantity, lifespan).
        3. Product segmentation by revenue (High Performance, Mid-Range, Low Performance).
        4. Performance KPIs (Average Selling Price, Average Order Revenue, Average Monthly Revenue).
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID ('gold.report_products','V') IS NOT NULL
	DROP VIEW gold.report_products
GO 
CREATE VIEW gold.report_products AS 

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
SELECT 
P.product_key,
p.product_name, 
p.category,
p.subcategory,
p.cost,
f.order_date,
f.sales_amount,
f.quantity,
f.order_number,
f.customer_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key=p.product_key
WHERE order_date IS NOT NULL  -- only consider valid sales dates
),
product_aggregations AS (
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
	MAX(order_date) AS last_order_date,
	MIN(order_date) AS first_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
	FROM base_query
	GROUP BY 
	product_key,
    product_name,
    category,
    subcategory,
    cost
	)

 /*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	CASE WHEN total_sales > 50000 THEN 'High performance'
		 WHEN  total_sales >= 10000 THEN 'Mid_Range'
		 ELSE 'Low Performance'
	END AS product_performance,
	life_span,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE WHEN total_orders=0 THEN 0
	     ELSE total_sales/total_orders
	END AS avg_order_revenu,
	-- Average Monthly Revenue
	CASE WHEN life_span=0 THEN total_sales
		ELSE total_sales/life_span
	END AS avg_monthly_revenu
FROM product_aggregations 

