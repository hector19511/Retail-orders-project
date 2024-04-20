/*
Sales project sql +python
Hector de Leon
2024
*/



select * 
from df_orders;

-- find top 10 highest revenue generating products
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc;

--find top 5 highest selling products in each region
with cte as(
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from (
select * , ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte) A
where rn <= 5

-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023


with cte1 as (
	select month(order_date) as order_month, sum(sale_price) as sales 
	from df_orders 
	where year(order_date) = '2022'
	group by month(order_date)
),
cte2 as(
	select month(order_date) as order_month, sum(sale_price) as sales 
	from df_orders 
	where year(order_date) = '2023'
	group by month(order_date)
)
select cte1.order_month, cte1.sales as sales_2022, cte2.sales as sales_2023
from cte1
 join cte2
	on cte1.order_month = cte2.order_month
order by cte1.order_month


-- for each category which month had the highest sales

select * 
from df_orders

with cte as(
select category, format(order_date, 'yyyy-MM') as year_month, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyy-MM')
-- order by category, format(order_date, 'yyyy-MM')
)
select*
from(
select *, ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a
where rn = 1

-- which sub category had the highest growth by profit in 2023 compared to 2022




with cte as(
select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
)
, cte2 as(
select sub_category
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023 
from cte
group by sub_category
)
select top 1 *
,(sales_2023 - sales_2022)*100/sales_2022
from cte2
