-- SQL Retail Sales Analysis
CREATE DATABASE sql_project;

USE sql_project;

CREATE TABLE retail_sales(
      transactions_id INT PRIMARY KEY,
      sale_date DATE NULL,
      sale_time TIME NULL,	
      customer_id INT NULL,	
      gender VARCHAR(15) NULL,	
      age INT NULL,	
      category VARCHAR(15) NULL,	
      quantity INT NULL,	
      price_per_unit FLOAT NULL,	
      cogs FLOAT NULL,	
      total_sale FLOAT NULL
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/janan/Documents/Retail-Sales-Analysis-SQL-Project--P1/SQL - Retail Sales Analysis_utf .csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transactions_id,@sale_date,@sale_time,@customer_id,@gender,@age,@category,@quantity,@price_per_unit,@cogs,@total_sale)
SET 
	  sale_date = NULLIF(@sale_date, ''),
      sale_time = NULLIF(@sale_time, ''),	
      customer_id = NULLIF(@customer_id, ''),
      gender = NULLIF(@gender, ''),
      age = NULLIF(@age, ''),	
      category = NULLIF(@category, ''),
      quantity = NULLIF(@quantity, ''),
      price_per_unit = NULLIF(@price_per_unit, ''),
      cogs = NULLIF(@cogs, ''),
      total_sale = NULLIF(@total_sale, '');
      
SELECT * FROM retail_sales;

SELECT COUNT(*) FROM retail_sales;

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL;

SELECT * FROM retail_sales
WHERE
     transactions_id IS NULL
     OR 
     sale_date IS NULL
     OR
     sale_time IS NULL
     OR 
     gender IS NULL
     OR 
     category IS NULL
     OR 
     quantity IS NULL
     OR 
     cogs IS NULL
     OR 
     total_sale IS NULL
;

-- Deleting NULL values
DELETE FROM retail_sales
WHERE
     transactions_id IS NULL
     OR 
     sale_date IS NULL
     OR
     sale_time IS NULL
     OR 
     gender IS NULL
     OR 
     category IS NULL
     OR 
     quantity IS NULL
     OR 
     cogs IS NULL
     OR 
     total_sale IS NULL
;
SET SQL_SAFE_UPDATES = 0;

-- Data Exploration
-- How much sales we have
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- How many unique customers we have
SELECT COUNT(DISTINCT customer_id) AS No_of_customers FROM retail_sales;

-- How many unique categories we have
SELECT DISTINCT category FROM retail_sales
ORDER BY category;

-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05'
;

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' 
-- and the quantity sold is more than 10 in the month of Nov-2022
SELECT * FROM retail_sales
WHERE
     category = 'Clothing'
     AND
     EXTRACT(YEAR FROM sale_date) = '2022'
     AND
     EXTRACT(MONTH FROM sale_date) = '11'
     AND
     quantity>=4
     ;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category
SELECT category, SUM(total_sale) AS Net_sales, COUNT(*) AS Total_orders
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT category, ROUND(AVG(age),2) AS Average_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000
;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
SELECT category,gender, COUNT(*) AS Total_transactions FROM retail_sales
GROUP BY category, gender
ORDER BY category
;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT * FROM
(
SELECT YEAR(sale_date) AS year, MONTH(sale_date) AS month, AVG(total_sale) AS Average_sales,
RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
) as t1
WHERE sales_rank = 1;
-- ORDER BY YEAR, Average_sales DESC;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category
SELECT category, COUNT(DISTINCT customer_id) AS customers
FROM retail_sales
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH Hourly_sale
AS
(
SELECT * ,
CASE
     WHEN HOUR(sale_time)<12 THEN 'Morning'
     WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
     ELSE 'Evening'
END AS Shift
FROM retail_sales
)
SELECT Shift, COUNT(*) AS total_orders
FROM Hourly_sale
GROUP BY Shift;

