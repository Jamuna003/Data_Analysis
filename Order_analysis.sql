--find top 10 highest reveue generating products 
select top 10 product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
;

--find top 5 highest selling products in each region
with cte as (
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month;


--for each category which month had highest sales 
WITH monthly_sales AS (
    SELECT 
        category,
        YEAR(order_date) AS year_,
        MONTH(order_date) AS month_,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY category, YEAR(order_date), MONTH(order_date)
),
ranked_sales AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rnk
    FROM monthly_sales
)
SELECT category, year_, month_, total_sales
FROM ranked_sales

WHERE rnk = 1;





select count(*) from df_orders;


--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc;
