# Food Delivery Data Insight SQL Project

## Project Overview

**Project Title**: Food Delivery SQL Project

This project analyzes a Food Delivery dataset using SQL to uncover insights about customer acquisition, order trends, promotions, and restaurant performance. 
It is designed as a practice project to strengthen SQL querying skills with real-world business use cases in the food delivery industry.

## Objectives
1. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

Food_delivery_sql_project.sql → Contains all SQL queries for analysis.

Dataset assumptions:

Table used: ORDERS

Key columns: Customer_code, Restaurant_id, Cuisine, Placed_at, Promo_code_Name
```sql

Create the orders table
DROP TABLE  IF EXISTS orders;
CREATE TABLE orders (
    Order_id VARCHAR(20),
    Customer_code VARCHAR(20),
    Placed_at DATETIME,
    Restaurant_id VARCHAR(10),
    Cuisine VARCHAR(20),
    Order_status VARCHAR(20),
    Promo_code_Name VARCHAR(20)
);
```

### 📊 Business Problems & SQL Solutions

1. **Find top 3 outlets by cuisine type**:
```sql
SELECT * FROM ORDERS;
WITH CTE AS (
SELECT Cuisine, Restaurant_id, COUNT(*) AS no_of_orders
FROM ORDERS
GROUP BY Cuisine, Restaurant_id)
SELECT *,
row_number() over(partition by cuisine order by no_of_orders desc) as rn
FROM CTE;
```

2. **Find the daily new customer count from the launch date (eveyday how many new customer are we aquiring)**:
```sql
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
```

3. **Count of all the users who are acquired in june 2025 and only one order in jun and did not place any other order**:
```sql
SELECT Customer_code, count(*) AS no_of_orders
FROM orders
WHERE MONTH(placed_at)=6 AND YEAR(placed_at)=2025
AND Customer_code NOT IN (SELECT DISTINCT Customer_code
FROM orders
WHERE NOT (MONTH(placed_at)=6 AND YEAR(placed_at)=2025)
)
GROUP BY Customer_code
HAVING count(*)=1;
```

4. **List the customer with no order in the last 7 days but were acquiring one month ago with their first order on promo**:
```sql
WITH cte AS 
(SELECT Customer_Code, MIN(Placed_at) AS first_order_date,
		MAX(Placed_at) AS latest_order_date
FROM orders 
GROUP BY Customer_code)
SELECT cte.*, o.Promo_code_Name AS first_order_promo 
FROM cte
INNER JOIN orders o ON cte.Customer_code=o.Customer_code 
					AND cte.first_order_date=o.Placed_at
WHERE latest_order_date < curdate() - INTERVAL 7 DAY
AND first_order_date < curdate() - INTERVAL 1 MONTH 
AND o.Promo_code_Name IS NOT NULL
;
```

5. **Growth team is planning to create a trigger that will target customers after their every
   3rd order with a personalized commmunication and they have asked you to create a query for this..**:
```sql
WITH cte AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Customer_code ORDER BY Placed_at) AS order_number
FROM orders
)
SELECT * FROM cte
WHERE order_number%3=0 
AND CAST(placed_at AS DATE) = CAST(CURDATE() AS DATE)
;
```

6. **list customers who placed more than 1 order and all their orders on a promo only**:
```sql
SELECT Customer_code, COUNT(*) AS no_of_orders, 
		COUNT(Promo_code_Name) AS promo_orders
FROM orders 
GROUP BY Customer_code
HAVING COUNT(*)>1 AND COUNT(*)=COUNT(Promo_code_Name)
;
```

7. **What % of customers were organically acquired in jan 2025. (placed their first Order without promo code)**:
```sql
WITH cte AS 
(
SELECT *,
ROW_NUMBER() OVER (partition BY Customer_code ORDER BY placed_at) AS rn
FROM orders
WHERE MONTH(placed_at)=6
)
SELECT 
COUNT(CASE WHEN  rn=1 AND Promo_code_Name IS NULL THEN Customer_code END)*100.0/COUNT(DISTINCT Customer_code)
FROM cte;
```

### 🛠️ SQL Concepts Used

CTEs (Common Table Expressions)

Aggregate Functions (COUNT, SUM)

Window Functions (ROW_NUMBER(), RANK())

Filtering & Date Functions (MONTH(), YEAR(), CURDATE())

Joins for promo tracking

### 💡 Key Insights

Identifies top-performing restaurants by cuisine.

Tracks customer acquisition trends and churn behavior.

Measures the impact of promotions on customer retention.

Helps growth teams with personalized engagement strategies.





