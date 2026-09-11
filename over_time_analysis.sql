/*
===============================================================================
Change Over Time Analysis
===============================================================================
Monthly Sales & Performance Aggregation Techniques
Purpose:
- Aggregate monthly sales performance metrics including revenue, customer
reach, and quantity sold.
- Demonstrate and compare three different T-SQL date-grouping approaches:
1. YEAR() and MONTH() functions.
2. DATETRUNC() for date truncation (SQL Server 2022+).
3. FORMAT() for custom formatted string representations.
*/
SELECT 
	 YEAR(order_date) AS order_year,
	 MONTH(order_date) AS order_month,
	 SUM(sales_amount) AS total_sales,
	 COUNT(DISTINCT customer_key) AS total_customers,
	 COUNT(quantity) AS total_quantity
 FROM gold.fact_sales
	 WHERE order_date IS NOT NULL
	 GROUP BY YEAR(order_date),MONTH(order_date) 
	 ORDER BY YEAR(order_date),MONTH(order_date)  DESC

-- USING DATETRUNC()
SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- USING FORMAT()
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
