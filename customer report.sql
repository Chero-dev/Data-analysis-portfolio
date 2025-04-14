--Customer report
--purpose:
--this report consolidates key customer metricsand behaviors
--Highlights :
--1.Gather essentials fields such as  names ,ages and transactions details
--2. segments customers into category (VIP,regular,new)and age groups
--3. aggregates customers_levelmetrics:
--- total orders
---total sales
--- total quantity purchased
--- total products
---lifespan  (in months)
--4. calculate valuable KPIS
-- - recency (months since last order)
-- - average order value
-- -average monthly spend


--* basic query to obtain required columns
CREATE VIEW report_customers AS
WITH CTE AS (
select s.order_number,s.product_key,s.order_date,s.sales_amount,s.quantity,
c.customer_key,c.customer_number,
CONCAT(c.first_name,'',c.last_name) AS customer_name,
DATEDIFF(Year,c.birthdate,GETDATE())AS age
from [gold.fact_sales] s
left join  [gold.dim_customers] c
on s.customer_key =c.customer_key
Where order_date IS NOT NULL
) 
,
--Aggregations   of customers metrics 
customer_aggregation AS (
select 
    customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number)as total_orders,
	SUM(sales_amount)as total_sales,
	SUM(quantity)as total_quantity,
	COUNT(DISTINCT product_key) as total_products,
	MAX(order_date)AS last_order_date,
	DATEDIFF(month,MIN(order_date),MAX(Order_date))as lifespan 
from CTE
GROUP BY 
       customer_key,
       customer_number,
	   customer_name,
	   Age 
	   )


select
customer_key,
customer_number,
customer_name, Age,
CASE 
    WHEN  lifespan >= 12 AND total_sales >5000 THEN 'VIP'
	WHEN lifespan >=12 AND total_sales<=5000 THEN 'Regular'
	ELSE 'New '
END Customer_segment,
CASE 
    WHEN  Age < 20  THEN 'under 20'
	WHEN  Age BETWEEN 20 AND 29 THEN '20-29'
	WHEN  Age BETWEEN 30 AND 39 THEN '30-39'
	WHEN  Age BETWEEN 40 AND 49 THEN '40-49'
	ELSE 'Above 50 '
END Age_group,
 total_orders,
 total_sales,
 total_quantity,
 total_products,
last_order_date,
DATEDIFF(Month,last_order_date,GETDATE())AS recency,
lifespan,
--compute average of value
CASE WHEN total_orders = 0 THEN 0 
     ELSE total_sales/total_orders
END avg_order_value,
--compute average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales /lifespan
END AVG_monthly_spend
from customer_aggregation
	
	   







