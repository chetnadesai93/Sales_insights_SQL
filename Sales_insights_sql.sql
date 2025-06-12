select * from orders;

#1 Get the sales by year. Which year post the highest sales?
select * from  orders1;                           
select extract(year from `order date`), `order date`, sales from orders1;
select extract(year from `order date`), round(sum(sales)) from orders1 group by 1;

# 2 Create 3 new columns - Year, Month and Day. Use DATE related Functions to derive these values from the Order Date column

select `order date` , 
extract(year from `order date`) as year,
extract(month from `order date`) as month,
extract(day from `order date`) as day
from orders
;

# 3 Find the Length of each sales person’s name

select `sales person`,
length (`sales person`)
from orders
;

#4 In a new column, concatenate Sales Person and Manager Name separated by a "-". It should be entirely in lower case

select 	`sales person` , manager,
lower(concat(`sales person` , '-', manager))as sales_person_manager
from `data-person`
;

# 5 Split the sales_person name into first name and last name

select 	`sales person`,
substring_index(`sales person`, ' ',1) as First_name,
substring_index(`sales person`, ' ',-1) as last_name
from `data-person`
;

# 6 Products are split into two categories. Category 1 has Product 1,2 and 3 while Category 2 has Product 4 and 5. Get revenue for each category

select
case when category in ('office supplies' , 'Furniture') then 'Group_1'
      when category in ('Technology') then 'group_2'
      else 'unknown'
end as new_category
, sum(sales) 
from orders1 group by 1;

# 7 Ensure you have “Orders”, “People” and “Returns” tables loaded into a schema. These are the same files that were used in previous lectures.
# done

# 8 Get the list of orders where sales value is less than the corresponding region’s average sales value

select region, avg(sales) from orders1 group by 1;

/*
Central	215.7726606973744
East	238.3361095505616
South	241.80364506172876
West	226.49323275054633
*/
select * from 
(select `row id` , `order id`, region 
, sales
, avg(sales) over (partition by region) avg_sales_by_region
, avg(sales) over() avg_sales_dataset
from orders1
) as c
where sales < avg_sales_by_region
;

# 9 Find the average sales value of Returned vs Non-Returned Sales Orders 

select coalesce(r.returned,'No') as is_returned, avg(o.sales)
from orders1 as o 
left join returns1 as r 
on o.`order id` = r.`order id`
group by 1 
;

# 10 Using EXISTS operator, find the list of orders that have been returned.

select * from orders1 as o where EXISTS (select `order id` from returns1 as r where r.`order id` = o.`order id`);

# 11 Using CTE & JOINS, find the total sales for each Regional Manager

select * from people1;

with new_table as 
(
select p.`regional manager` , sum(o.sales) as total_sales
from orders1 as o 
left join people1 as p
on o.region = p.region 
)

select reginal_manager , sum(sales)
from new_people1
group by 1
;

# 12 Using CTE, find the total average revenue per customer (ARPU) for each Segment (hint:ARPU = Total Revenue/Total Customers)

select segment, count(distinct `customer name`), sum(sales)
, sum(sales)/count(distinct `customer name`) as ARPU
from orders1
group by 1
; 

with segment_wise_sales as 
(
select segment, sum(sales) as seg_sales 
from orders1
group by 1 
)
,
segment_wise_custs as 
(
select segment, count(distinct `customer name`) as seg_cust
from orders1
group by 1 
)

select a.segment, a.seg-sales, b.seg_cust, a.seg_sales/b.seg_cust
from segment_wise_sales as a 
inner join segment_wise_custs  as b 	

on a.segment - b.segement
;

# 13 Using window functions, compare each order’s sales value with the average, minimum & maximum sales value of that ship mode

select `order id` , `ship mode` , avg(sales) from orders1 group by 1;	
    
#Standard Class	227.58306685656603
#First Class	228.49702399219805
#Second Class	236.08923876606698
#Same Day	236.39617863720076

select `order id` , `ship mode`, sales
, avg(sales) OVER (partition by `ship mode`) as avg_sales_in_shipmode
, min(sales) OVER (partition by `ship mode`) as min_sales_in_shipmode
, max(sales) OVER (partition by `ship mode`) as max_sales_in_shipmode
from orders1
;

# 14 Find the 2nd highest and 2nd lowest value order for each region

select * from 
(select `row id`, `order id` , region , sales 
, dense_rank() over(partition by region order by  sales desc) as rnk
from orders1
) as v
where rnk = 2 
;

#15 Use the LAG function to get Year-on-year sales change 	

with yearly_sales as 
(
select extract(year from `order date`) as year , round(sum(sales)) total_sales 
from orders1
group by 1
)

select year , total_sales
, lag(total_sales) over(order by year)
, total_sales/lag(total_sales) over(order by year) as yoy
from yearly_sales
;
	
#16 Find the total sales value of returned orders for each Category

select category, coalesce(r.returned, 'no') as is_returned 
, category 
, sum(sales)
from orders1 as o
left join returns1 as r 
on o.`order id` = r.`order id`
group by 1,2
order by 1 
;

#17 Using LEFT JOIN, Find the list of orders that have not been returned

select r.returned, o.*
from orders1 as o 
left join returns1 as r 
on o.`order id` = r.`order id`
where r.returned is null 
;

#18 Using Inner join, Find the list of orders that have been returned
select r.returned, o.*
from orders1 as o 
inner join returns1 as r 
on o.`order id` = r.`order id`
;

