#1 Find top 3 outlets by cuisine type
SELECT * FROM ORDERS;
WITH CTE AS (
SELECT Cuisine, Restaurant_id, COUNT(*) AS no_of_orders
FROM ORDERS
GROUP BY Cuisine, Restaurant_id)
SELECT *,
row_number() over(partition by cuisine order by no_of_orders desc) as rn
FROM CTE;

-- 2 Find the daily new customer count from the launch date (eveyday how many new customer are we aquiring)
WITH CTE AS (
			SELECT
			Customer_code, cast(min(placed_at) as date) as first_order_date
			FROM ORDERS
			GROUP BY Customer_code
            )
SELECT first_order_date, COUNT(*) AS no_of_new_customer
FROM CTE
GROUP BY first_order_date
ORDER BY first_order_date;

-- 3 Count of all the users who are acquired in jan 2025 and only one order in jan and did not place any other order
SELECT Customer_code, count(*) as no_of_orders
FROM ORDERS
WHERE month(placed_at)=1 and year(placed_at)=2025
and Customer_code not in (select distinct Customer_code
from orders
where not (month(placed_at)=1 and year(placed_at)=2025)
)
GROUP BY Customer_code
having count(*)=1;

-- 4 List the customer with no order in the last 7 days but were acquiring one month ago with their first order 
-- on promo
with cte as 
(SELECT Customer_Code, MIN(Placed_at) as first_order_date,
MAX(Placed_at) as latest_order_date
FROM orders 
GROUP BY Customer_code)
select cte.*, o.Promo_code_Name as first_order_promo from cte
inner join orders o on cte.Customer_code=o.Customer_code and cte.first_order_date=o.Placed_at
where latest_order_date < curdate() - interval 7 day
and first_order_date < curdate() - interval 1 month and o.Promo_code_Name is not null
;

-- 5) Growth team is planning to create a trigger that will target customers after their every
-- 3rd order with a personalized commmunication and they have asked you to create a query for this.

with cte as (select *,
row_number() over(partition by Customer_code order by Placed_at) as order_number
from orders)
select * from cte
where order_number%3=0 and cast(placed_at as date) = cast(curdate() as date)
;


-- 6)list customers who placed more than 1 order and all their orders on a promo only
select Customer_code, count(*) as no_of_orders, count(Promo_code_Name) as promo_orders
from orders 
group by Customer_code
having count(*)>1 and count(*)=count(Promo_code_Name)
;

-- 7) What % of customers were organically acquired in jan 2025. (placed their first Order without promo code)
with cte as (select *,
row_number() over (partition by Customer_code order by placed_at) as rn
from orders
where month(placed_at)=6
)
select 
count(case when  rn=1 and Promo_code_Name is null then Customer_code end)*100.0/count(distinct Customer_code)
from cte;
