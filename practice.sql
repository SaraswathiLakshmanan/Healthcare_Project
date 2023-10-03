CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL
);

-- Create the orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


INSERT INTO customers (customer_id, customer_name, customer_email)
VALUES
    (1, 'John Doe', 'john.doe@example.com'),
    (2, 'Jane Smith', 'jane.smith@example.com'),
    (3, 'Michael Johnson', 'michael.johnson@example.com');

-- Insert data into the orders table
INSERT INTO orders (order_id, order_date, order_amount, customer_id)
VALUES
    (1001, '2023-08-01', 50.00, 1),
    (1002, '2023-08-02', 75.00, 1),
    (1003, '2023-08-02', 100.00, 2),
    (1004, '2023-08-03', 60.00, 1),
    (1005, '2023-08-03', 40.00, 3),
    (1006, '2023-08-04', 120.00, 2),
	(1007, '2023-08-04', 90.00, 1);
    
    
    
    with summary as (
    select customer_id,customer_name,customer_email,count(order_id) as totalorder,
    sum(order_amount) as totalamount,round(avg(order_amount),2) as avgamount,
    rank() over (order by count(order_id)) as order_rnk
    from
    customers join orders 
    using (customer_id)
    group by customer_id)
    select customer_id,customer_name,customer_email,totalorder,
    totalamount,avgamount ,lead (customer_name) over (order by order_rnk) as next_customer_name,
    lead(totalorder) over (order by order_rnk) as next_total_order,
    lead(totalamount) over (order by order_rnk) as next_total_amount,
    lead(avgamount) over (order by order_rnk) as next_avg_amount
    from summary
    order by customer_id;
    
    
select sale_id,sale_date,product_name,daily_sales,
lag(daily_sales) over (partition by product_name order by sale_date) as previous_day_sales,
daily_sales - lag(daily_sales) over ( partition by product_name order by sale_date) as daily_sales_change,
((daily_sales - lag(daily_sales) 
over ( partition by product_name order by sale_date))/lag(daily_sales) 
over ( partition by product_name order by sale_date))* 100 as daily_sales_change_percent
#rank() over (order by daily_sales - lag(daily_sales) over ( partition by product_name order by sale_date desc)) as raank
#dense_rank() over (order by daily_sales - lag(daily_sales) over ( partition by product_name order by sale_date desc )) as dense_raank
from sales
order by sale_date,product_name;




    
CREATE TABLE customers_ (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL
);

-- Insert data into the customers table
INSERT INTO customers_ (customer_id, customer_name, customer_email)
VALUES
    (1, 'John Doe', 'john.doe@example.com'),
    (2, 'Jane Smith', 'jane.smith@example.com'),
    (3, 'Michael Johnson', 'michael.johnson@example.com');

-- Create the orders table
CREATE TABLE orders_ (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert data into the orders table
INSERT INTO orders_ (order_id, order_date, order_amount, customer_id)
VALUES
    (1001, '2023-08-01', 50.00, 1),
    (1002, '2023-08-02', 75.00, 1),
    (1003, '2023-08-02', 100.00, 2),
    (1004, '2023-08-03', 60.00, 1),
    (1005, '2023-08-03', 40.00, 3),
    (1006, '2023-08-04', 120.00, 2),
    (1007, '2023-08-04', 90.00, 1);

-- Create the payments table
CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert data into the payments table
INSERT INTO payment (payment_id, payment_date, amount_paid, order_id)
VALUES
    (2001, '2023-08-01', 30.00, 1001),
    (2002, '2023-08-02', 40.00, 1002),
    (2003, '2023-08-02', 100.00, 1003),
    (2004, '2023-08-03', 50.00, 1002),
    (2005, '2023-08-04', 40.00, 1004),
    (2006, '2023-08-04', 90.00, 1005),
    (2007, '2023-08-05', 100.00, 1006),
    (2008, '2023-08-05', 80.00, 1007);
    
    
select order_id, customer_name, order_date, order_amount, amount_paid,
(order_amount-amount_paid) as balance_amount,
lead(amount_paid) over (partition by order_id order by payment_date) as next_payment
from orders_ join customers_ using (customer_id)
left join payment using(order_id)
order by order_id;



---------------------------------------------


CREATE TABLE employee_ (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL
);

-- Insert data into the employees table
INSERT INTO employee_ (employee_id, employee_name, department, salary)
VALUES
    (1, 'John Doe', 'Sales', 50000.00),
    (2, 'Jane Smith', 'Marketing', 45000.00),
    (3, 'Michael Johnson', 'Finance', 60000.00),
    (4, 'Emily Williams', 'Sales', 55000.00),
    (5, 'David Lee', 'Marketing', 48000.00);

-- Create the sales table
CREATE TABLE sale_ (
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES employee_(employee_id)
);

-- Insert data into the sales table
INSERT INTO sale_ (sale_id, sale_date, amount, employee_id)
VALUES
    (101, '2023-08-01', 1000.00, 1),
    (102, '2023-08-02', 2000.00, 1),
    (103, '2023-08-03', 1500.00, 2),
    (104, '2023-08-03', 1800.00, 3),
    (105, '2023-08-04', 1200.00, 1),
    (106, '2023-08-04', 2500.00, 2),
    (107, '2023-08-05', 900.00, 4),
    (108, '2023-08-05', 1300.00, 5);
    
    
select sale_id, employee_name, department, amount,
case when sum(amount) over(partition by department)=0 then null 
else (amount/sum(amount) over (partition by department))*100 
end as sales_percentage
from employee_ join sale_
using(employee_id);


    
SELECT
    s.sale_id,
    e.employee_name,
    e.department,
    s.amount,
    CASE 
        WHEN SUM(s.amount) OVER (PARTITION BY e.department) = 0 THEN NULL
        ELSE (s.amount / SUM(s.amount) OVER (PARTITION BY e.department)) * 100
    END AS sales_percentage
FROM
    sale_ s
JOIN
    employee_ e ON s.employee_id = e.employee_id;


create view sales_performance_report as 
	select employee_id, employee_name, department,
    sum(amount) as total_amount,
    amount/sum(amount) as avg_amt,
    rank() over (order by sum(amount) desc) as rnk
    from employee_ join sale_
    using (employee_id)
    group by employee_id,employee_name,department;

select * from sales_performance_report;

drop view sales_performance_report;


CREATE VIEW sales_performance_report1 AS
SELECT
    e.employee_id,
    e.employee_name,
    e.department,
    SUM(s.amount) AS total_sales_amount,
    AVG(s.amount) AS average_sale_amount,
    RANK() OVER (ORDER BY SUM(s.amount) DESC) AS rank_by_sales_amount
FROM
    employee_ e
LEFT JOIN
    sale_ s ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id, e.employee_name, e.department;
    
select * from sales_performance_report1;

create view updatable_view as
	select customerNumber, customerName, contactLastName, contactFirstName
    from customers;
update  updatable_view 
set customerName="Ask"
where customerNumber=1;

CREATE VIEW order_product_view AS
SELECT od.orderNumber, p.productName, od.quantityOrdered
FROM orderdetails od 
JOIN products p ON od.productCode = p.productCode;

update  order_product_view 
set productName="Iphone"
where orderNumber=10101;

create view readable as
select d.orderNumber,t.productName from
orderdetails d join (select productName,productCode from products) as t on d.productCode=t.productCode;

use practice;
delimiter //

create trigger after_insert
after insert on employee_
for each row
	begin 
		insert into audit (action,employee_id,action_timestamp)
        values ("insert",new.employee_id,now());
	end //
delimiter ;
#--------------------------------------


CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100)
);

CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    hours_worked INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);


INSERT INTO departments (department_id, department_name)
VALUES (1, 'Finance'), (2, 'Engineering'), (3, 'Marketing');

INSERT INTO employees (employee_id, employee_name, department_id)
VALUES (101, 'John Doe', 1), (102, 'Jane Smith', 2), (103, 'Bob Johnson', 3);

INSERT INTO projects (project_id, project_name)
VALUES (1001, 'Budget Analysis'), (1002, 'Software Development'), (1003, 'Product Launch');

INSERT INTO employee_projects (employee_id, project_id, hours_worked)
VALUES (101, 1001, 80), (101, 1002, 120), (102, 1002, 60), (103, 1003, 30);

#-----------

select department_name,project_name,employee_name,sum(hours_worked) as total_hours,
case 
	when sum(hours_worked) >=100 then "Highly Engaged"
    when sum(hours_worked) >=50 and sum(hours_worked) <100 then "Moderately Engaged"
    when sum(hours_worked) < 50 then "Less Engaged"
end as category
from departments d join employees e using (department_id)
join employee_projects using (employee_id)
join projects using (project_id)
group by department_id,project_id,employee_id;

#------------

SELECT 
    d.department_name,
    p.project_name,
    e.employee_name,
    SUM(ep.hours_worked) AS total_hours,
    CASE
        WHEN SUM(ep.hours_worked) >= 100 THEN 'Highly Engaged'
        WHEN SUM(ep.hours_worked) >= 50 THEN 'Moderately Engaged'
        ELSE 'Less Engaged'
    END AS engagement_classification
FROM
    departments d
JOIN
    employees e ON d.department_id = e.department_id
JOIN
    employee_projects ep ON e.employee_id = ep.employee_id
JOIN
    projects p ON ep.project_id = p.project_id
GROUP BY
    d.department_name, p.project_name, e.employee_name;