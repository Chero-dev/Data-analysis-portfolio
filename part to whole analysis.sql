--which category  contributes the most overall sales 
WITH CTE AS (
select category,SUM(sales_amount) AS total_sales
from [gold.fact_sales] s
left join [gold.dim_products] p
on s.product_key = p.product_key
group by category)

select category,total_sales,
SUM(total_sales) over () as overall_total_sales,
CONCAT(ROUND((CAST(total_sales AS float)/ SUM(total_sales) over ())*100,2),'%') as percentage
from CTE
order by total_sales desc