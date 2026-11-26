CREATE DATABASE retail1_db;
USE retail1_db;
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
)ENGINE = InnoDB;

-- InnoDB storage engine ensures transaction support,
-- ACID compliance, foreign key integrity and rollback.

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
)ENGINE = InnoDB;
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending'
)ENGINE = InnoDB;
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
)ENGINE = InnoDB;


-- Insertion
INSERT INTO categories (category_name)
VALUES
('Electronics'),
('Clothing'),
('Groceries');

INSERT INTO products
(product_name, category_id, price, stock)
VALUES
('Laptop', 1, 55000, 20),
('Mobile', 1, 25000, 40),
('Headphones', 1, 2000, 60),
('Keyboard', 1, 1500, 10),
('T-Shirt', 2, 500, 100),
('Jeans', 2, 1200, 50),
('Jacket', 2, 2500, 15),
('Rice', 3, 800, 200),
('Sugar', 3, 60, 150),
('Cooking Oil', 3, 150, 30);

INSERT INTO orders
(customer_name, order_date, status)
VALUES
('Arun', '2026-09-05', 'Completed'),
('Priya', '2026-09-15', 'Completed'),
('Rahul', '2026-10-10', 'Completed'),
('Divya', '2026-10-20', 'Completed'),
('Karthik', '2026-11-05', 'Completed'),
('Meena', '2026-11-15', 'Completed');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 2, 55000),
(1, 2, 3, 25000),
(1, 3, 5, 2000),
(2, 5, 10, 500),
(2, 6, 5, 1200),
(2, 8, 10, 800),
(3, 1, 3, 55000),
(3, 2, 5, 25000),
(3, 4, 4, 1500),
(4, 5, 15, 500),
(4, 7, 3, 2500),
(4, 9, 20, 60),
(5, 1, 4, 55000),
(5, 2, 6, 25000),
(5, 3, 8, 2000),
(6, 5, 20, 500),
(6, 6, 8, 1200),
(6, 10, 15, 150);

-- Verifying the data
SHOW TABLES;

SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;


-- Write a transaction that decrements stock, inserts the order and inserts the order lines; 
-- prove the rollback when stock is insufficient.
DELIMITER //

CREATE PROCEDURE reserve_inventory(
    IN p_customer_name VARCHAR(100),
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_order_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Get available stock and price
    SELECT stock, price
    INTO v_stock, v_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    -- Validate product and quantity
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found';
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid quantity';
    END IF;

    -- Insert the order
    INSERT INTO orders
    (customer_name, order_date, status)
    VALUES
    (p_customer_name, CURDATE(), 'Pending');

    SET v_order_id = LAST_INSERT_ID();

    -- Validate available stock
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    -- Decrement the stock
    UPDATE products
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;

    -- Insert order details
    INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
    VALUES
    (v_order_id, p_product_id, p_quantity, v_price);

    COMMIT;

    SELECT 'Inventory reserved successfully' AS Message;

END //

DELIMITER ;

-- Test Case 1: Successful transaction
CALL reserve_inventory('Ravi', 1, 5);
SELECT * FROM products WHERE product_id = 1;

-- Test Case 2: Failed transaction
CALL reserve_inventory('Sneha', 1, 50);

-- Task 2: Find products whose stock is below
-- the average stock of their respective category.

SELECT p.product_id, p.product_name,
       c.category_name, p.stock
FROM products p
INNER JOIN categories c
ON p.category_id = c.category_id
WHERE p.stock < (
    SELECT AVG(p2.stock)
    FROM products p2
    WHERE p2.category_id = p.category_id
);