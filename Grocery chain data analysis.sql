-- Grocery chain data analysis

select *
from grocery_data

-- How many rows?
SELECT COUNT(*) AS total_rows FROM grocery_data;

-- How many unique customers?
SELECT COUNT(DISTINCT customer_id) AS unique_customers 
FROM grocery_data;

-- How many unique stores?
SELECT COUNT(DISTINCT store_name) AS unique_stores 
FROM grocery_data;

-- Date range of transactions
SELECT MIN(transaction_date) AS earliest, 
       MAX(transaction_date) AS latest 
FROM grocery_data;

-- Data standardization 
-- checking for inconsistent column names
select distinct aisle
from grocery_data
order by aisle

--Data cleaning
-- checking for null values
select 
    sum(case when customer_id is null then 1 else 0 end) as null_customer,
    sum(case when store_name is null then 1 else 0 end) as null_store,
    sum(case when transaction_date is null then 1 else 0 end) as null_date,
    sum(case when aisle is null then 1 else 0 end) as null_aisle,
    sum(case when product_name is null then 1 else 0 end) as null_product,
    sum(case when quantity is null then 1 else 0 end) as null_quantity,
    sum(case when unit_price is null then 1 else 0 end) as null_unit,
    sum(case when total_amount is null then 1 else 0 end) as null_total,
    sum(case when discount_amount is null then 1 else 0 end) as null_discount,
    sum(case when final_amount is null then 1 else 0 end) as null_final,
    sum(case when loyalty_points is null then 1 else 0 end) as null_points
from grocery_data;

-- deleting null values
delete from grocery_data
where customer_id is null
   or store_name is null
   or product_name is null
   or quantity is null
   or final_amount is null;

   -- checking for dupicates
   select customer_id,store_name,transaction_date,aisle,product_name,quantity,unit_price,total_amount,discount_amount,final_amount,loyalty_points, count(*) 
   from grocery_data
   group by  customer_id,store_name,transaction_date,aisle,product_name,quantity,unit_price,total_amount,discount_amount,final_amount,loyalty_points
   having count(*) > 1


-- Data Exploration
-- Q1. Top 10 highest transactions by final_amount
select top 10 customer_id, store_name, final_amount
from grocery_data
order by final_amount desc;

-- Q2. Total transactions per store
select store_name, count(*) as Total_transaction
from grocery_data
group by store_name;

-- Q3. Total revenue per product
 select product_name, 
       sum(total_amount) as gross_revenue,
       sum(final_amount) as net_revenue
from grocery_data
group by product_name
order by gross_revenue desc;

-- Q4. Customers with most transactions
select customer_id, count(*) as nos_transaction
from grocery_data
group by customer_id 
order by nos_transaction desc;

-- Q5. Average discount per store
select store_name,avg(discount_amount) avg_dis_amount
from grocery_data
group by store_name;

-- Q6. How many unique products are in the dataset?
select count(distinct product_name) 
from grocery_data;

-- Q7. What is the total discount given across all transactions?
select  sum(discount_amount)Total_discount
from grocery_data;

-- Q8. Which store has the most transactions?
select store_name,count(*) nos_transaction
from Grocery_data
group by store_name
order by nos_transaction desc;


-- Q9. What is the average transaction value per store?
select store_name, avg(final_amount) avg_transaction_value
from grocery_data
group by store_name;

-- Q10. Which aisle generates the most revenue?
select
    aisle,
    sum(total_amount) gross_rev_by_aisle,
    sum(final_amount) net_rev_by_aisle
from grocery_data
group by aisle
order by  aisle desc;

-- Q11. What is the total revenue per month?
select 
    month(transaction_date) as month,
    sum(total_amount) gross_revenue,
    sum(final_amount) net_revenue
from grocery_data
group by month(transaction_date)
order by 1 asc

-- Q12. Which customers have never used a discount?
select customer_id
from grocery_data
group by customer_id
having sum(discount_amount) = 0
order by customer_id asc;

-- Q13. What is the ratio of discount to total amount per product?
select 
    product_name,
    sum(discount_amount) as total_discount,
    sum(total_amount) as gross_revenue,
    round(sum(discount_amount) / sum(total_amount) * 100, 2) as discount_ratio
from grocery_data
group by product_name
order by discount_ratio desc;

-- Q14. Which store has the highest average transaction value?
select top 1 
    store_name,
    round(avg(final_amount), 2) as avg_transaction_value
from grocery_data
group by store_name
order by avg_transaction_value desc;

-- Q15. What is the total loyalty points earned per store?
Select store_name, sum(loyalty_points) TotaLpoints
from grocery_data
group by store_name;

-- Q16. Which product has the highest average unit price?
Select top 1 
product_name, 
round(avg(unit_price),2) Avg_unit_price
from grocery_data
group by product_name
order by 2 desc

-- Q17. What is the revenue contribution of each aisle in percentage?
Select
    aisle, 
    sum(final_amount) Revenue,
   round( sum(final_amount) / (select sum(final_amount) from grocery_data) * 100,2) as percentage_contribution
from grocery_data
group by aisle
order by percentage_contribution desc;

-- Q18. which customers spent above the overall average?
select 
    customer_id,
    round(sum(final_amount), 2) as total_spent,
    --round(avg(final_amount), 2) as avg_spent,
    round((select avg(final_amount) from grocery_data), 2) as overall_avg
from grocery_data
group by customer_id
having sum(final_amount) > (select avg(final_amount) from grocery_data)
order by total_spent desc;

-- Q19a. Rank customers by total spending using window functions
Select 
    customer_id,
    sum(final_amount) total_spent,
    rank() over( order by sum(final_amount) desc) spending_rank
    --dense_rank() over(order by sum(final_amount) desc) dense_spending_rank
from grocery_data
group by customer_id
order by spending_rank asc;

-- Q19b. Rank stores by total revenue using window functions
select 
    store_name,
    sum(final_amount) total_revenue,
    rank() over( order by sum(final_amount) desc) store_rank
from grocery_data
group by store_name
order by store_rank asc ;

-- Q20. Find the running total of revenue by date
select 
    transaction_date,
    round(sum(final_amount), 2) as daily_revenue,
    round(sum(sum(final_amount)) over (order by transaction_date asc), 2) as running_total
from grocery_data
group by transaction_date
order by transaction_date asc;

-- Q21. Which store had the highest revenue each month?
with revenue_rank as
(
Select
    store_name,
    month(transaction_date) month,
    round(sum(final_amount),2) Total_Revenue,
    rank() over(partition by month(transaction_date) order by sum(final_amount) desc) revenue_rank
from grocery_data
group by store_name, month(transaction_date)
--having rank() over( partition by month(transaction_date) order by sum(final_amount) desc) < 2
--order by 4 asc
)
select *
from revenue_rank
where revenue_rank = 1
order by month asc;

-- Q22. Find customers who bought from more than 3 different aisles
select
    customer_id,
    count(distinct aisle) as count_of_aisle
from grocery_data
group by customer_id
having count(distinct aisle) > 3
order by count_of_aisle desc;

--Q23. What is the month over month revenue growth percentage?
with monthly_revenue as
(
    select
        month(transaction_date) as month,
        round(sum(final_amount), 2) as total_revenue
    from grocery_data
    group by month(transaction_date)
)
select
    month,
    total_revenue,
    lag(total_revenue) over (order by month) as prev_month_revenue,
    (total_revenue - lag(total_revenue) over (order by month)) 
    / lag(total_revenue) over (order by month) * 100 as growth_percentage
from monthly_revenue
order by month asc;

-- Q24. Find the top 3 products per aisle by revenue
with product_rank as
(
    select
        aisle,
        product_name,
        round(sum(final_amount), 2) as revenue,
        rank() over (partition by aisle order by sum(final_amount) desc) as product_rank
    from grocery_data
    group by aisle, product_name
)
select *
from product_rank
where product_rank <= 3
order by aisle, product_rank asc;

-- Q25. Which customers have the highest loyalty points to spending ratio?
select
    customer_id,
    sum(loyalty_points) loyalty_points,
    round(sum(final_amount),2) total_spending,
    round(sum(loyalty_points) / sum(final_amount),2) AS loyalty_to_spending_ratio
from grocery_data
group by customer_id
order by  loyalty_to_spending_ratio desc;

-- Q26. Find stores where discount amount exceeds 10% of total amount
Select 
    store_name,
    round(sum(discount_amount),2) discount_amount,
    --sum(final_amount) total_amount,
    round(sum(total_amount) * 0.10,2) as discounted_percentage
from grocery_data
group by store_name
having  round(sum(discount_amount),2) > round(sum(total_amount) * 0.10,2)


-- Q27. Identify customers at risk of churning (no transaction in last 60 days)
select
    customer_id,
    max(transaction_date) as last_transaction,
    datediff(day, max(transaction_date), getdate()) as days_since_last_transaction
from grocery_data
group by customer_id
having datediff(day, max(transaction_date), getdate()) > 60
order by days_since_last_transaction desc;

-- end of project
