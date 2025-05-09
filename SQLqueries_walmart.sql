SELECT * 
FROM `walmartsalesdata.csv`;
CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales (
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR (5) NOT NULL,
city VARCHAR (30) NOT NULL,
custumer_type VARCHAR (30) NOT NULL,
gender VARCHAR (10) NOT NULL,
product_line VARCHAR (100) NOT NULL,
unit_price DECIMAL (10,2) NOT NULL, 
quantity INT NOT NULL,
VAT FLOAT (6,4) NOT NULL,
total DECIMAL (12, 4) NOT  NULL ,
date DATETIME NOT NULL, 
time TIME NOT NULL,
payment_method VARCHAR (15) NOT NULL,
cogs DECIMAL (10, 2) NOT NULL, 
gross_margin_pct FLOAT (11,9) NOT NULL, 
gross_income DECIMAL (12,2) NOT NULL,
rating FLOAT (2,1) 
);


--------------------------------------------------
------------ FEATURE ENGINEERING -----------------

-- time_of_day (sales in the Morning, Afternoon and Evening) 

SELECT 
	time,
    (CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
   END ) AS time_of_date
FROM sales;

Alter TABLE sales ADD COLUMN time_of_day VARCHAR (20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END
);

-- day_name (days of the week : Mon, Tue, Wed, Thur, Fri)

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = (DAYNAME (date)
);
-- month_name (months of the year)

SELECT date,
MONTHNAME (date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR (10) ; 

UPDATE sales
SET month_name = MONTHNAME (date);

---- Business Questions To Answer ----
--------------------------------------
------------ Generic -----------------

-- How many unique cities does the data have? in which city is each branch? 
SELECT 
	DISTINCT city, branch
FROM sales;

--------------------------------------
------------ Product -----------------

-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?
SELECT product_line,
	COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month?
SELECT month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name AS month,
	SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,
	SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line,
	SUM(VAT) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	SUM(quantity)/ 6 AS average_sale
FROM sales;

SELECT product_line,
	SUM(quantity) AS total_sale,
    CASE 
		WHEN SUM(quantity)  >= 912 THEN "Good"
        ELSE "Bad"
	END AS product_evaluation
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS total_sale
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT SUM(quantity)/3 FROM sales);

-- What is the most common product line by gender?
SELECT product_line, 
	   gender,
       COUNT(*) 
FROM sales
GROUP BY product_line, gender
ORDER BY COUNT(*) DESC;

-- What is the average rating of each product line?
SELECT product_line,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

---------------------------------------
------------ Customer -----------------
-- How many unique customer types does the data have?
SELECT DISTINCT(customer_type)
FROM sales;

ALTER TABLE sales
CHANGE custumer_type customer_type VARCHAR(10);

-- How many unique payment methods does the data have?
SELECT DISTINCT(payment_method)
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type
ORDER BY COUNT(*)DESC;

-- What is the gender of most of the customers?
SELECT
	gender, 
    COUNT(*)
FROM sales
GROUP BY gender
ORDER BY COUNT(*)DESC;

-- What is the gender distribution per branch?
SELECT  
	   branch,
       gender,
       COUNT(*)
FROM sales
GROUP BY branch, gender
ORDER BY branch ASC;

-- Which time of the day do customers give most ratings?
SELECT  
	   time_of_day,
       Avg(rating) AS rate
FROM sales
GROUP BY time_of_day
ORDER BY avg(rating) DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day,
		branch,
       Avg(rating) AS rate,
       RANK () OVER (PARTITION BY branch ORDER BY Avg(rating) DESC)
FROM sales
GROUP BY time_of_day, branch
ORDER BY branch ASC;

-- Which day of the week has the best avg ratings?
SELECT  
	   day_name,
       Avg(rating) AS rate
FROM sales
GROUP BY day_name
ORDER BY avg(rating) DESC;

------------------------------------
------------ Sales -----------------

-- Number of sales made in each time of the day per weekday? 
SELECT time_of_day,
       SUM(quantity) AS total_sale
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY SUM(quantity) DESC;