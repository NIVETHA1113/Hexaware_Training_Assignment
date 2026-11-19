CREATE DATABASE retail_sales;
use retail_sales;
SELECT DATABASE();

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);

SHOW TABLES;

INSERT INTO customers
(first_name, last_name, email, city)
VALUES
('Arun', 'Kumar', 'arun@gmail.com', 'Chennai'),
('Priya', 'Sharma', 'priya@gmail.com', 'Bangalore'),
('Rahul', 'Verma', 'rahul@gmail.com', 'Chennai'),
('Divya', 'Rajan', 'divya@gmail.com', 'Mumbai'),
('Karthik', 'Suresh', 'karthik@gmail.com', 'Bangalore'),
('Sneha', 'Ravi', 'sneha@gmail.com', 'Mumbai'),
('Vijay', 'Kumar', 'vijay@gmail.com', 'Chennai');

INSERT INTO products
(product_name, category, price)
VALUES
('Laptop', 'Electronics', 50000),
('Mobile', 'Electronics', 15000),
('Headphones', 'Electronics', 2000),
('Keyboard', 'Accessories', 1000),
('Mouse', 'Accessories', 500),
('Office Chair', 'Furniture', 5000),
('Study Table', 'Furniture', 8000);

INSERT INTO orders
(customer_id, order_date)
VALUES
(1, '2026-01-05'),
(2, '2026-01-10'),
(1, '2026-01-15'),
(3, '2026-02-02'),
(1, '2026-02-10'),
(5, '2026-02-15'),
(2, '2026-03-01'),
(1, '2026-03-05'),
(3, '2026-03-10'),
(5, '2026-03-15'),
(6, '2026-03-20'),
(2, '2026-03-25'),
(4, '2026-04-01'),
(5, '2026-04-05');

INSERT INTO order_items
(order_id, product_id, quantity, price)
VALUES
(1, 1, 1, 50000),
(1, 2, 2, 15000),
(2, 3, 2, 2000),
(2, 4, 1, 1000),
(3, 1, 1, 50000),
(3, 5, 2, 500),
(4, 2, 1, 15000),
(4, 6, 1, 5000),
(5, 1, 2, 50000),
(5, 3, 3, 2000),
(6, 4, 3, 1000),
(6, 5, 5, 500),
(7, 2, 2, 15000),
(7, 3, 1, 2000),
(8, 1, 1, 50000),
(8, 7, 1, 8000),
(9, 6, 2, 5000),
(9, 5, 4, 500),
(10, 2, 1, 15000),
(10, 4, 2, 1000),
(11, 3, 2, 2000),
(11, 5, 3, 500),
(12, 1, 1, 50000),
(12, 2, 1, 15000),
(13, 7, 2, 8000),
(13, 6, 1, 5000),
(14, 4, 4, 1000),
(14, 5, 2, 500);

INSERT INTO payments
(order_id, payment_date, amount)
VALUES
(1, '2026-01-05', 80000),
(2, '2026-01-10', 5000),
(3, '2026-01-15', 51000),
(4, '2026-02-02', 20000),
(5, '2026-02-10', 106000),
(6, '2026-02-15', 5500),
(7, '2026-03-01', 32000),
(8, '2026-03-05', 58000),
(9, '2026-03-10', 12000),
(10, '2026-03-15', 17000),
(12, '2026-03-25', 65000),
(13, '2026-04-01', 21000);

select * from customers;
select * from products;
select * from orders;
select * from order_items;
select * from payments;

select Product_Name, sum(oi.quantity * oi.price) as revenue from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
order by revenue desc
limit 5;

select date_format(o.order_date,'%M %Y') as sales_month,
sum(oi.quantity * oi.price) as Revenue
from orders o
join order_items oi on o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date,'%M %Y')
order by min(o.order_date);


select customer_id, count(order_id) AS total_orders
from orders
group by customer_id
having COUNT(order_id) > 3;

SELECT
    c.city,
    ROUND(AVG(ot.basket_value), 2) AS avg_basket_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(quantity * price) AS basket_value
    FROM order_items
    GROUP BY order_id
) ot
    ON o.order_id = ot.order_id
GROUP BY c.city;

select o.order_id, o.customer_id, o.order_date, p.payment_id, p.amount
from orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_id is null;

select  c.customer_id,
    concat(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.city from customers c left join orders o on c.customer_id = o.customer_id
where o.order_id is null;

SELECT p.category, SUM(oi.quantity * oi.price) AS category_revenue,
    ROUND((SUM(oi.quantity * oi.price) /(SELECT SUM(quantity * price)
         FROM order_items)) * 100,2) AS revenue_share
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category;

SELECT o.order_date, SUM(oi.quantity * oi.price) AS daily_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY daily_sales DESC
LIMIT 1;

SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    UPPER(c.city) AS customer_city,
    DATE_FORMAT(o.order_date, '%d-%M-%Y') AS order_date,
    DATEDIFF(CURDATE(), o.order_date) AS days_since_order,
    ROUND(SUM(oi.quantity * oi.price), 2) AS order_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    o.order_date
ORDER BY o.order_date;


SELECT
    o.order_id,
    COUNT(*) AS total_rows,
    COUNT(p.amount) AS non_null_payments,
    SUM(p.amount) AS total_payment,
    AVG(p.amount) AS average_payment FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id
ORDER BY o.order_id;

SELECT * FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-01-31';

SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 3;