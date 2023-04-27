use new_schema1

select * from sstore;

-- 1 What percentage of total orders were shipped on the same date?

SELECT ((SUM(CASE WHEN Order_Date = Ship_Date THEN 1 ELSE 0 END) / COUNT(*)) * 100) 
AS percentage_same_date FROM sstore

-- 2 Name top 3 customers with highest total value of orders.

SELECT Customer_Name, SUM(Sales) AS total_order_value FROM sstore
GROUP BY Customer_Name 
ORDER BY total_order_value 
DESC LIMIT 3

-- 3 Find the top 5 items with the highest average sales per day.

SELECT product_name, AVG(quantity / (DATEDIFF(date_sold, date_purchased) + 1)) AS avg_sales_per_day
FROM sstore
GROUP BY product_name
ORDER BY avg_sales_per_day DESC
LIMIT 5;




-- 4 Give the name of customers who ordered highest and lowest orders from each city.

SELECT city, MAX(Sales) AS highest_order_total, MIN(Sales) AS lowest_order_total, 
(SELECT GROUP_CONCAT(customer_name) FROM sstore 
WHERE city = s.city AND Sales = MAX(s.Sales)) AS customer_with_highest_order,
(SELECT GROUP_CONCAT(customer_name) FROM sstore WHERE city = s.city AND Sales = MIN(s.Sales)) AS customer_with_lowest_order FROM sstore s 
GROUP BY city

-- 5 What is the most demanded sub-category in the west region?

SELECT Sub_Category, COUNT(*) AS demand
FROM sstore
WHERE region = 'West'
GROUP BY Sub_Category
ORDER BY demand DESC
LIMIT 1;


-- 6  Which order has the highest number of items? And which order has the highest cumulative value?

SELECT order_id, COUNT(*) AS num_items
FROM sstore
GROUP BY order_id
ORDER BY num_items DESC
LIMIT 1;



-- 7 Which order has the highest cumulative value?

SELECT order_id, SUM(sales) AS total_value FROM sstore 
GROUP BY order_id ORDER BY total_value
DESC LIMIT 1

-- 8 Which segment’s order is more likely to be shipped via first class?

SELECT segment, COUNT(*) AS total_orders, SUM(CASE WHEN Ship_Mode = 'first class' THEN 1 ELSE 0 END) AS first_class_orders, ROUND(SUM(CASE WHEN Ship_Mode = 'first class' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS first_class_percentage 
FROM sstore
GROUP BY segment ORDER BY first_class_percentage DESC LIMIT 1


-- 9  Which city is least contributing to total revenue?

SELECT city, SUM(sales) AS total_revenue
FROM sstore 
GROUP BY city 
ORDER BY total_revenue ASC LIMIT 1;

-- 10  What is the average time for orders to get shipped after order is placed?

 SELECT AVG(DATEDIFF(ship_date, order_date))  AS avg_ship_time 
FROM sstore
WHERE ship_date IS NOT NULL

SELECT (DATEDIFF(ship_date, order_date))  AS avg_ship_time 
FROM sstore

-- 11 Which segment places the highest number of orders from each state and which segment places the largest individual orders from each state?


SELECT 
    state, 
    segment, 
    COUNT(*) AS num_orders, 
    MAX(Sales) AS max_order_amount
FROM 
    sstore
GROUP BY 
    state, segment
HAVING 
    num_orders = (SELECT MAX(num_orders)
                  FROM (SELECT COUNT(*) AS num_orders
                        FROM sstore
                        GROUP BY state, segment) as T )



-- 12  Find all the customers who individually ordered on 3 consecutive days where each day’s total order was more than 50 in value. 


SELECT customer_id FROM 
( SELECT customer_id, order_date, SUM(sales) OVER (PARTITION BY customer_id, CAST(order_date AS DATE) ORDER BY order_date ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) 
AS total_order_amount FROM sstore ) t WHERE total_order_amount > 50 
GROUP BY customer_id HAVING COUNT(DISTINCT CAST(order_date AS DATE)) >= 3


-- 13  Find the maximum number of days for which total sales on each day kept rising


SELECT COUNT(*) AS max_rising_days FROM 
( SELECT order_date, sales, SUM(sales) OVER (ORDER BY order_date) AS cumulative_sales FROM sstore )
AS sales WHERE cumulative_sales - sales < cumulative_sales 
GROUP BY cumulative_sales
ORDER BY max_rising_days DESC LIMIT 1

