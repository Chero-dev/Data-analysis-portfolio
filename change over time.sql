--Change over time
--total sales per year
select year(order_date)as order_year,SUM(sales_amount )AS total_sales
from [gold.fact_sales]
where order_date IS NOT NULL
GROUP BY year(order_date) 

--total sales per month
select month(order_date)as order_month,SUM(sales_amount )AS total_sales
from [gold.fact_sales]
where order_date IS NOT NULL
GROUP BY month(order_date)

--COUNT THE number of Customers and  the total quantity
select year(order_date)as order_year,SUM(sales_amount )AS total_sales
,COUNT(DISTINCT customer_key)as count_customers,SUM(quantity) AS total_quantity
from [gold.fact_sales]
where order_date IS NOT NULL
GROUP BY year(order_date) 