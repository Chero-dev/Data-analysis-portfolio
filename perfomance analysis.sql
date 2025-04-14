--Analyze the yearly performance of products by comparing each product sales to both its average sales
--performance and previous year sales
WITH yearly_product_sales as
(
select year(f.order_date)as order_year,p.product_name,
SUM(f.sales_amount )AS current_sales from [gold.fact_sales] f
left join [gold.dim_products] p
on f.product_key = p.product_key
group by year(f.order_date),p.product_name)

select order_year,product_name,current_sales,
AVG(current_sales) over (PARTITION BY product_name)avg_sales,
current_sales - AVG(current_sales) over (PARTITION BY product_name)as diff_avg,
CASE 
    WHEN current_sales - AVG(current_sales) over (PARTITION BY product_name) > 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) over (PARTITION BY product_name) < 0 THEN 'Below average'
	ELSE 'Avg'
END avg_change,
--YEAR over year analysis
LAG (current_sales) OVER (partition by product_name order by order_year)py_sales,
current_sales - LAG (current_sales) OVER (partition by product_name order by order_year) diff_py_sales,
CASE 
    WHEN current_sales - LAG (current_sales) OVER (partition by product_name order by order_year) > 0 THEN 'increase'
	WHEN current_sales - LAG (current_sales) OVER (partition by product_name order by order_year) < 0 THEN 'decrease'
	ELSE 'no_change'
END diff_py_change
from yearly_product_sales 
order by product_name,order_year
