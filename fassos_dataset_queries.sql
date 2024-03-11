#Roll metrics
#1. How many rolls were ordered?
select count(roll_id) as roll_count from customer_orders;

#2 how many unique coustomer order roll
select count(distinct customer_id) as customer_count from customer_orders;

#3 how many successfull order deliverd by each driver
select driver_id,count(order_id) from driver_order where cancellation not like 'C%' group by driver_id;

#4 how many eachtypee of roll has been delivered
select roll_id,count(roll_id)  from customer_orders where order_id in
(select order_id from driver_order where cancellation not like 'C%' )
group by roll_id;

#5 how many type of rll each customer has ordered

select customer_id,roll_id,count(roll_id) as roll_count  from customer_orders
group by customer_id, roll_id order by customer_id;

#6 For each delivered order, How many have at least one change and how many had no changes?
WITH delivered_order AS (
    SELECT order_id
    FROM driver_order
    WHERE cancellation NOT LIKE 'C%'
),
temp_customer_orders as (
SELECT 
    order_id,customer_id,roll_id,order_date ,
       CASE WHEN not_include_items IS NULL  or not_include_items='' or not_include_items='NULL'THEN '0' 
       else not_include_items END AS new_not_include_items,
       CASE WHEN extra_items_included IS NULL or extra_items_included='' or extra_items_included='NaN' or extra_items_included='NULL' THEN '0' 
       else extra_items_included END AS new_extra_items_included
FROM customer_orders)
select customer_id,change_no_change, count(order_id) from 
(select *,CASE WHEN new_not_include_items ='0' and new_extra_items_included ='0' then 'No_change' else 'change' end as change_no_change
from temp_customer_orders 
where 
order_id IN (SELECT order_id FROM delivered_order)) a 
GROUP BY customer_id, change_no_change;

#7 what was the number of orders for each day of the week
select dow, count(order_id) from(
select *, DAYNAME(order_date) dow from customer_orders) a 
group by dow ;

    