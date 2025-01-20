with pain as (select 
employees.employee_id
, trim(CONCAT(CONCAT(first_name, ' '), last_name)) as seller  
, count (*) as operations
, sum (products.price*sales.quantity) as income
from sales  
join products on products.product_id=sales.product_id 
join employees on employees.employee_id=sales.sales_person_id 
group by employees.employee_id, trim(CONCAT(CONCAT(first_name, ' '), last_name))
order by sum (products.price*sales.quantity) desc
limit 10)
select 
seller
, operations
, income
from pain 
order by pain desc;

with PAIN as (select 
employees.employee_id
, trim(CONCAT(CONCAT(first_name, ' '), last_name)) as seller  
, count (*) as operations
, floor(sum (products.price*sales.quantity)) as income
, floor(AVG (products.price*sales.quantity)) as average_income
from sales  
join products on products.product_id=sales.product_id 
join employees on employees.employee_id=sales.sales_person_id
group by employees.employee_id, trim(CONCAT(CONCAT(first_name, ' '), last_name))),
avg_test as (
select 
AVG(products.price*sales.quantity) as avg_lead
from sales  
join products on products.product_id=sales.product_id 
join employees on employees.employee_id=sales.sales_person_id 
)
select 
seller 
, average_income
from PAIN
where average_income < (select avg_lead from avg_test)
order by average_income asc;


with PAIN as (select 
employees.employee_id
, trim(CONCAT(CONCAT(first_name, ' '), last_name)) as seller 
, sale_date
, products.price*sales.quantity as income 
, to_char(sale_date, 'day') AS day_of_week 
, CASE
          WHEN extract (DOW from sale_date) = 0 THEN 7
          else extract (DOW from sale_date)
     END as sort
from sales  
join products on products.product_id=sales.product_id 
join employees on employees.employee_id=sales.sales_person_id),
final as (select 
employee_id
,seller
, day_of_week
, FLOOR(sum(income)) as income
, sort
from PAIN
group by seller, employee_id, day_of_week, sort
order by sort, seller)
select seller
, day_of_week
, income 
from final;

WITH cust AS (
    SELECT
          CASE 
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)
SELECT 
    age_category,
    COUNT(DISTINCT customer_id) AS age_count
FROM cust
WHERE customer_id IN (SELECT customer_id FROM sales)
GROUP BY age_category
ORDER BY age_category;

with 
/*собираем всех исходные данные в витрину*/
PAIN as (select 
 to_char(sale_date, 'YYYY-MM') AS selling_month
, sales.customer_id as customer_id
, quantity*price as lead_sale
from sales 
join employees on sales.sales_person_id=employees.employee_id
join customers on customers.customer_id=sales.customer_id
join products on products.product_id=sales.product_id)
/* размечаем под поиск новых клиентов*/
select
selling_month 
, count (distinct customer_id) as total_customers 
, FLOOR(sum (lead_sale)) as income 
from PAIN
group by selling_month 
order by selling_month;
/* не забыть спросить почему у меня поехала сортировка на графике в пресет*/

with 
/*собираем всех исходные данные в витрину*/
PAIN as (select 
 sales.customer_id 
, trim(CONCAT(CONCAT(employees.first_name, ' '), employees.last_name)) as seller 
, sale_date
, MIN(sale_date) over (partition by sales.customer_id) as frst_date
, sales.customer_id as customer_id
, trim(CONCAT(CONCAT(customers.first_name, ' '), customers.last_name)) as customer
, price
from sales 
join employees on sales.sales_person_id=employees.employee_id
join customers on customers.customer_id=sales.customer_id
join products on products.product_id=sales.product_id 
order by customer_id)
/* не забыть спросить сохранится ли сортировка, при использовании CTE*/
select 
distinct customer
, sale_date
, seller
from pain
where sale_date=frst_date and price=0
with 
/*собираем всех исходные данные в витрину*/
PAIN as (select 
 sales.customer_id 
, trim(CONCAT(CONCAT(employees.first_name, ' '), employees.last_name)) as seller 
, sale_date
, MIN(sale_date) over (partition by sales.customer_id) as frst_date
, sales.customer_id as customer_id
, trim(CONCAT(CONCAT(customers.first_name, ' '), customers.last_name)) as customer
, price
from sales 
join employees on sales.sales_person_id=employees.employee_id
join customers on customers.customer_id=sales.customer_id
join products on products.product_id=sales.product_id 
order by customer_id)
/* не забыть спросить сохранится ли сортировка, при использовании CTE*/
select 
distinct customer
, sale_date
, seller
from pain
where sale_date=frst_date and price=0;

