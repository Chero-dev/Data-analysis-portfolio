--segment  products into cost ranges and count how many products falls into each segment
WITH CTE AS(
select  product_key,product_name,cost,
CASE WHEN cost < 100 THEN 'below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100 -500'
	 WHEN cost  BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'above 1000'
END cost_range
from [gold.dim_products])

select cost_range,COUNT(product_key)as total_count
from CTE
GROUP BY cost_range 
order by total_count desc


--GROUP customers into three segments based on their spending habits 
--vip : atleast 12 months of history and spending more than 5000 ponds
--regular:atleast 12 months of history but spendinf less the 5000 ponds
--new :mlifespan  less than 12 months
WITH CTE AS(
select c.customer_key,SUM(s.sales_amount)AS Total_spending,
MIN(order_date )as first_order,
MAX(order_date )as  Last_order,
DATEDIFF(month,MIN(order_date),MAX(order_date))as lifespan
from [gold.fact_sales] s
left join  [gold.dim_customers] c
on s.customer_key = c.customer_key
group by c.customer_key)
 
select customer_segment,COUNT(customer_key)as total_customers
from(
select customer_key,
CASE 
    WHEN  lifespan >= 12 AND Total_spending >5000 THEN 'VIP'
	WHEN lifespan >=12 AND Total_spending <=5000 THEN 'Regular'
	ELSE 'New '
END Customer_segment
from CTE)t
group by customer_segment
order by total_customers desc