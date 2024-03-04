create database walmart;
use walmart;

/*Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);*/

select * from sales;

---------------------------------------------------- ### Generic Question----------------------------------------------
-- 1. How many unique cities does the data have?
select distinct(city) as unique_city
from sales;

-- 2. In which city is each branch?
 select city,count(branch) as branchcount
from sales
group by city
order by  branchcount desc;

------------------------------------------------------------- ### Product ---------------------------------------------------------------------
-- 1. How many unique product lines does the data have?
select distinct(product_line) as unique_prodline
from sales;

-- 2. What is the most common payment method?
SELECT 
    payment, COUNT(payment) AS mostly_used_mode
FROM
    sales
GROUP BY payment
ORDER BY mostly_used_mode DESC
LIMIT 1;

-- 3. What is the most selling product line?
SELECT 
    product_line, COUNT(product_line) AS most_selling_line
FROM
    sales
GROUP BY product_line
ORDER BY most_selling_line DESC
LIMIT 1;

-- 4. What is the total revenue by month?
SELECT 
    MONTH(date) AS month, SUM(total) AS total_revenue
FROM
    sales
GROUP BY MONTH(date)
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?
SELECT 
    MONTH(date) AS month, SUM(cogs) AS largest_COGS
FROM
    sales
GROUP BY MONTH(date)
ORDER BY largest_COGS DESC;

-- 6. What product line had the largest revenue?
SELECT 
    product_line, SUM(total) AS largest_revenue
FROM
    sales
GROUP BY product_line
ORDER BY largest_revenue DESC
LIMIT 1;

-- 5. What is the city with the largest revenue?
SELECT 
    city, SUM(total) AS city_with_largest_rev
FROM
    sales
GROUP BY city
ORDER BY city_with_largest_rev DESC;




alter table sales 
add column VAT decimal(10,2);

update sales 
set VAT = total * tax_pct / 100;

-- 6. What product line had the largest VAT?
SELECT 
    product_line, SUM(VAT) AS largest_VAT
FROM
    sales
GROUP BY product_line
ORDER BY largest_VAT DESC
LIMIT 1;

-- 7. Fetch each product line and add a column to those product line showing "Good", "Bad".
--  Good if its greater than average sales

SELECT 
    product_line
FROM
    sales;
    
SELECT 
    product_line,
    CASE 
        WHEN total > (SELECT AVG(total) FROM sales s2 WHERE s2.product_line = sales.product_line) THEN 'Good'
        ELSE 'Bad'
    END AS sales_category
FROM 
    sales;


 SELECT s1.product_line, AVG(s2.total) AS average_total
FROM sales s1
JOIN sales s2 ON s1.product_line = s2.product_line
GROUP BY s1.product_line;

 SELECT s1.product_line,AVG(s2.total) FROM sales s2 
 join sales s1
 WHERE s2.product_line = s1.product_line;


-- 8. Which branch sold more products than average product sold?
select branch, sum(quantity)
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);


-- 9. What is the most common product line by gender?
WITH ranked_lines AS (
    SELECT gender,
           product_line,
           COUNT(product_line) AS product_line_count,
           ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(product_line) DESC) AS rnk
    FROM sales
    GROUP BY gender, product_line
)
SELECT gender, 
       product_line,
       product_line_count
FROM ranked_lines
WHERE rnk = 1;



-- 10. What is the average rating of each product line?

SELECT 
    product_line, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY product_line
ORDER BY avg_rating ASC;


--------------------------------------------- ### Sales-------------------------------------

-- 1. Number of sales made in each time of the day per weekday
select  dayname(date) as week_day, hour(time) as daily_hr, count(total) as sales
from sales
group by week_day, daily_hr
order by sales;

SELECT
  DAYNAME(time) AS day_of_week,
  DATE_FORMAT(time, '%H:%i') AS time_of_day,
  COUNT(total) AS no_of_sales
FROM sales
GROUP BY day_of_week, time_of_day
ORDER BY day_of_week, time_of_day;


-- 2. Which of the customer types brings the most revenue?
select customer_type, sum(total) as most_revenue
from sales
group by customer_type
order by most_revenue;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
select city , sum(VAT) as large_vat
from sales
group by city
order by large_vat desc;

-- 4. Which customer type pays the most in VAT?
select customer_type, sum(vat) as most_vat
from sales
group by customer_type
order by most_vat desc;

-- -------------------------Customer ------------------------------------------

-- 1. How many unique customer types does te data have?

select count(distinct(customer_type))
from sales;

-- 2 How many unique payment methods does the data have?
select count(distinct(payment))
from sales;

-- 3 What is the most common customer type?
select customer_type, count(customer_type) as commn_cust
from sales
group by customer_type
order by commn_cust desc
limit 1;

-- 4 which customer type buys the most?
select customer_type , sum(total) as max_buy
from sales
group by customer_type
order by max_buy desc
limit 1;

-- 5.What is the gender of most of customer?
select gender, count(gender) as common_gender
from sales
group by gender
order by common_gender desc
limit 1;

-- 6. What is the gender distribution per branch?
select branch, count(gender) as gen_dis
from sales
group by branch
order by gen_dis desc;

-- 7. Which time of the day do customers give most ratings?
select  DATE_FORMAT(time, '%H:%i') AS time_of_day, count(rating) as most_rating_time
from sales 
group by DATE_FORMAT(time, '%H:%i') 
order by most_rating_time desc
limit 1;

-- 8. which time of a day to customer give most rating per brach?
select  DATE_FORMAT(time, '%H:%i') AS time_of_day, branch, count(rating) as most_rating_time
from sales 
group by DATE_FORMAT(time, '%H:%i') ,branch
order by most_rating_time desc
limit 1;

-- 9. Which day fo the week has the best avg ratings?

select  Dayname(date) AS day_of_week ,avg(rating) as avg_rating_time
from sales 
group by dayname(date) 
order by avg_rating_time desc;

-- 10. Which day of the week has the best average ratings per branch?
select  distinct(branch),dayname(date) AS day_of_week ,avg(rating) as avg_rating_time
from sales 
group by dayname(date) , branch
order by branch , avg_rating_time desc
limit 1;


select  * from sales;