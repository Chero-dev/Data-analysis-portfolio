--cumulative analysis
--calculate the total sales per month and running total over time

select order_month,total_sales,
SUM (total_sales) over ( order by order_month)as running_sales
from
(
select year(order_date)as order_year,month(order_date)as order_month,SUM(sales_amount) AS total_sales
from [gold.fact_sales]
where order_date IS NOT NULL
group by month(order_date),year(order_date))t

--average of the price
select order_month,total_sales,
SUM (total_sales) over ( order by order_month)as running_sales,
AVG(avg_price) over (order by order_month)as moving_avg
from
(
select year(order_date)as order_year,month(order_date)as order_month,SUM(sales_amount) AS total_sales,
AVG(price)as avg_price
from [gold.fact_sales]
where order_date IS NOT NULL
group by month(order_date),year(order_date))t


