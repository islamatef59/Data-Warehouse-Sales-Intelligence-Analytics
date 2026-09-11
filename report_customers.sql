/*
Customer Report View Creation
Purpose:
- Creates or updates the 'gold.report_customers' view to consolidate core
customer demographics, transaction metrics, and behavioral KPIs.
- Features:
1. Base data joining (sales fact + customer dimension) and age calculation.
2. Customer-level aggregate statistics (orders, sales, quantity, lifespan).
3. Demographic categorization (Age Groups) and Customer Segmentation (VIP/Regular/New).
4. Derived KPIs (Recency, Average Order Value, Average Monthly Spend).  
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================

IF OBJECT_ID('gold.report_customers','V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	CONCAT(c.First_name,' ',c.Last_name) AS Full_name,
	DATEDIFF(YEAR,c.birthdate,GETdATE()) AS Age
FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key= c.customer_key
	WHERE order_date IS NOT NULL),

	/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
 customer_aggregation AS (

SELECT 
	customer_key,
	Full_name,
	Age,
	COUNT(DISTINCT order_number) AS customer_total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	MAX(order_date) AS 	last_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span,
	COUNT(DISTINCT product_key) AS total_products
FROM base_query
GROUP BY 
	customer_key,
	Full_name,
	Age

	)
SELECT
    customer_key,
	Full_name,
	Age,
	CASE WHEN Age<20 THEN 'under_20'
		 WHEN Age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN Age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN Age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN Age BETWEEN 40 AND 49 THEN '30-39'
	     ELSE '50 OR ABOVE'
	END AS Age_group,
    CASE 
		WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
   END AS customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	customer_total_orders,
	total_sales,
	total_quantity,
	total_products
	lifespan,
		-- Compuate average order value (AVO)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / customer_total_orders
	END AS avg_order_value,
	-- Compuate average monthly spend
	CASE WHEN life_span = 0 THEN total_sales
		 ELSE total_sales / life_span
	END AS avg_monthly_spend
FROM customer_aggregation

