--Product  report
--purpose:
--this report consolidates key customer metricsand behaviors
--Highlights :
--1.Gather essentials fields such as  product name,category,subcategory and cost
--2. segments product per revenue to identify ,higher performer,mid_range or lolow performers
--3. aggregates product_levelmetrics:
--- total orders
---total sales
--- total quantity sold
--- total customer(unique)
---lifespan  (in months)
--4. calculate valuable KPIS
-- - recency (months since last Sale)
-- - average order Revenue
-- -average monthly revenue
CREATE VIEW report_products AS
WITH base_query AS(
select s.order_number,s.order_date,s.customer_key,s.price,s.quantity,s.sales_amount,s.product_key,
p.product_name,p.category,p.subcategory,p.cost
from[gold.fact_sales] s
left join [gold.dim_products] p
on s.product_key = p.product_key
where order_date is not null
)
,
product_aggregation AS(
select 
    product_name,
	category,
	subcategory,
	cost,
	COUNT(order_number)AS total_orders,
	SUM (sales_amount)AS  total_sales,
	SUM(quantity)AS total_quantity,
	COUNT(DISTINCT customer_key)AS  total_customers,
	MAX(order_date)AS Last_order,
	DATEDIFF(month,MIN(order_date),MAX(order_date))AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT )/ NULLIF(quantity,0)),1) as Avg_sellingprice
from base_query
group by
	product_name,
	category,
	subcategory,
	cost
	)
	

	
select
product_name,
category,
subcategory,
cost,
total_orders,
total_sales,
total_quantity,
total_customers,
Last_order,
DATEDIFF(month,last_order,GETDATE())AS recency,
CASE 
    WHEN   total_sales >50000 THEN 'High_Performer'
	WHEN  total_sales<=15000THEN 'Mid_range'
	ELSE 'low _perfomer '
END product_segment,
lifespan,
Avg_sellingprice,
--AVERAGE ORDER REVENUE
CASE 
    WHEN total_sales = 0 THEN 0
	ELSE total_sales/total_orders
END AS avg_order_revenue,
--average monthly revenue
CASE 
    WHEN lifespan = 0 THEN total_sales
	ELSE  total_sales/lifespan
END AS avg_monthly_revenue
from product_aggregation