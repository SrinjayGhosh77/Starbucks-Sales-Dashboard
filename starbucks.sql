create database  starbucks_2;
use starbucks_2;

select * from customers_star;
select * from items;
select * from sales;


-- How is the business performing overall?

CREATE VIEW total_transactions AS 
SELECT COUNT(DISTINCT transaction_id) AS total_transactions FROM sales;

CREATE VIEW  total_customers AS
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM sales;

CREATE VIEW total_sales AS 
SELECT ROUND(SUM(total_amount),2) AS total_sales FROM sales;

CREATE VIEW total_units_sold AS
SELECT SUM(quantity) AS total_units_sold FROM sales;

CREATE VIEW  avg_order_value AS
SELECT ROUND(AVG(total_amount),2) AS avg_order_value FROM sales;

-- Are sales growing or declining over time?

CREATE VIEW vw_monthly_sales_trend AS
SELECT 
YEAR(datetime) AS sales_year,
MONTH(datetime) AS sales_month,
ROUND(SUM(total_amount),2) AS revenue,
COUNT(transaction_id) AS transactions,
SUM(quantity) AS units_sold
FROM sales
GROUP BY
YEAR(datetime), MONTH(datetime);

-- Which category contributes most revenue?

CREATE VIEW category_performance AS
SELECT
i.type AS category,
ROUND(SUM(s.total_amount),2) AS revenue,
SUM(s.quantity) AS units_sold,
COUNT(s.transaction_id) AS transactions
FROM sales s
JOIN items i
ON s.item_id = i.ID
GROUP BY i.type;

-- What are the best-selling products?

CREATE VIEW top_products AS
SELECT
i.item, i.type,
SUM(s.quantity) AS total_quantity,
ROUND(SUM(s.total_amount),2) AS revenue
FROM sales s
JOIN items i
ON s.item_id = i.ID
GROUP BY
i.item, i.type
LIMIT 10;

-- Which customer segments generate most revenue?

CREATE VIEW customer_demographics AS
SELECT c.customer_gender,
ROUND(SUM(s.total_amount),2) AS revenue,
COUNT(DISTINCT s.customer_id) AS customers,
COUNT(s.transaction_id) AS transactions
FROM sales s
JOIN customers_star c
ON s.customer_id = c.customer_id
GROUP BY c.customer_gender;

-- Which age group spends the most?

CREATE VIEW age_group_analysis AS
SELECT
CASE
WHEN c.customer_age < 25 THEN 'Under 25'
WHEN c.customer_age BETWEEN 25 AND 34 THEN '25-34'
WHEN c.customer_age BETWEEN 35 AND 44 THEN '35-44'
WHEN c.customer_age BETWEEN 45 AND 54 THEN '45-54'
ELSE '55+'
END AS age_group,
ROUND(SUM(s.total_amount),2) AS revenue,
COUNT(DISTINCT s.customer_id) AS customers
FROM sales s
JOIN customers_star c
ON s.customer_id = c.customer_id
GROUP BY
CASE
WHEN c.customer_age < 25 THEN 'Under 25'
WHEN c.customer_age BETWEEN 25 AND 34 THEN '25-34'
WHEN c.customer_age BETWEEN 35 AND 44 THEN '35-44'
WHEN c.customer_age BETWEEN 45 AND 54 THEN '45-54'
ELSE '55+'
END
ORDER BY ROUND(SUM(s.total_amount),2) DESC;

-- How do customers prefer to pay?

CREATE VIEW payment_mode_analysis AS
SELECT payment_mode,
ROUND(SUM(total_amount),2) AS revenue,
COUNT(transaction_id) AS transactions
FROM sales
GROUP BY payment_mode
ORDER BY ROUND(SUM(total_amount),2) DESC ;

-- Which sales channel performs better?

CREATE VIEW Channel_Revenue_Comparison AS
SELECT customer_type,
ROUND(SUM(total_amount),2) AS revenue,
COUNT(transaction_id) AS transactions,
ROUND(AVG(total_amount),2) AS avg_order_value
FROM sales
GROUP BY customer_type;

-- Who are the highest-value customers?

CREATE VIEW customer_lifetime_value AS
SELECT s.customer_id, c.customer_name, c.customer_gender, c.customer_age,
ROUND(SUM(s.total_amount),2) AS lifetime_value,
COUNT(s.transaction_id) AS total_orders
FROM sales s
JOIN customers_star c
ON s.customer_id = c.customer_id
GROUP BY s.customer_id, c.customer_name, c.customer_gender, c.customer_age
LIMIT 10;

-- When should staffing be increased?

CREATE VIEW peak_hours AS
SELECT
HOUR(datetime) AS sales_hour,
COUNT(transaction_id) AS transactions,
ROUND(SUM(total_amount),2) AS revenue
FROM sales
GROUP BY HOUR(datetime)
ORDER BY ROUND(SUM(total_amount),2) DESC;

-- Do high-calorie products generate more revenue?

CREATE VIEW nutrition_sales_analysis AS
SELECT i.item, i.type, i.calories,
ROUND(SUM(s.total_amount),2) AS revenue,
SUM(s.quantity) AS quantity_sold
FROM sales s
JOIN items i
ON s.item_id = i.ID
GROUP BY i.item, i.type, i.calories;

-- RFM (Recency, Frequency, Monetary)

-- Recency (R)
-- 5 days ago  → Very Good
-- 30 days ago → Average
-- 180 days ago → Risky

-- Frequency (F)
-- 2 Orders  → Low
-- 15 Orders → Loyal
-- 50 Orders → VIP

-- Monetary (M)
-- $100 → Low Value
-- $1,000 → Good Customer
-- $10,000 → VIP Customer

CREATE VIEW rfm_segmentation AS
SELECT customer_id,
MAX(datetime) AS last_purchase_date,
DATEDIFF(CURDATE(), MAX(datetime)) AS recency,
COUNT(transaction_id) AS frequency,
ROUND(SUM(total_amount),2) AS monetary_value
FROM sales
GROUP BY customer_id;

CREATE VIEW customer_segments AS
SELECT *,
CASE
WHEN recency <= 30
AND frequency >= 10
AND monetary_value >= 1000
THEN 'VIP'

WHEN recency <= 60
AND frequency >= 5
THEN 'Loyal'

WHEN recency <= 180
THEN 'At Risk'

ELSE 'Lost'
END AS customer_segment
FROM rfm_segmentation;

select  customer_segment from customer_segments
order by 1 desc 


































































