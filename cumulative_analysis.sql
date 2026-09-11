/*
Cumulative & Yearly Trend Analysis
Purpose:
- Aggregate sales metrics by year from the sales fact table.
- Calculate running total of sales over time to track cumulative revenue growth.
- Calculate cumulative moving average price across consecutive years.
*/
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS total_runing_sales,
	AVG(avg_price) OVER(ORDER BY order_date ) AS avg_price

FROM
(
	SELECT 
	YEAR(order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	GROUP BY YEAR(order_date)
) t 


