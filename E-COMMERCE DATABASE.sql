-- Step 1: Create the database
CREATE DATABASE ecommerce_db;

-- Select the database
USE ecommerce_db;

-- Verify the database was created
SHOW DATABASES;

-- 2a: Users Table — stores all customer details
CREATE TABLE users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,   
phone VARCHAR(15),     
address TEXT,   
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2b: Products Table — stores items available for sale
CREATE TABLE products (
product_id  INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(150) NOT NULL,
description TEXT,
price DECIMAL(10,2) NOT NULL,
stock INT DEFAULT 0,      
category VARCHAR(50),   
created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
); 

-- 2c: Orders Table — one record per customer order
CREATE TABLE orders (
order_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
status ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
total_amount DECIMAL(10,2) DEFAULT 0.00,
FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 2d: Order Items Table — each product line within an order
CREATE TABLE order_items (
item_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT NOT NULL,
product_id INT NOT NULL,
quantity   INT NOT NULL DEFAULT 1,
unit_price DECIMAL(10,2) NOT NULL,
FOREIGN KEY (order_id)   REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 3a: Insert Users (Customers)
INSERT INTO users (name, email, phone, address) VALUES
('Alice Johnson', 'alice@email.com', '555-1001', 'New York, NY'),
('Bob Smith', 'bob@email.com', '555-1002', 'Los Angeles, CA'),
('Carol White', 'carol@email.com', '555-1003', 'Chicago, IL'),
('David Brown', 'david@email.com', '555-1004', 'Houston, TX'),
('Emma Davis', 'emma@email.com', '555-1005', 'Phoenix, AZ');

-- 3b: Insert Products
INSERT INTO products (name, description, price, stock, category) VALUES
('Samsung Galaxy A54', '6.4-inch AMOLED display smartphone', 650.00, 50, 'Mobile'),
('Nike Air Max 270', 'Premium cushioned running shoes', 85.00,  100, 'Footwear'),
('HP Laptop 15', 'Intel i5, 8GB RAM, 512GB SSD', 950.00, 30, 'Laptop'), 
('Wireless Earbuds', 'Bluetooth 5.0 noise-cancelling', 32.00, 200, 'Accessories'), 
('Cotton T-Shirt', '100% premium cotton, unisex fit', 15.00, 500, 'Clothing'),
('Smart Watch Pro', 'Fitness tracker with GPS & HR', 120.00,  75, 'Accessories');

-- 3c: Insert Orders
INSERT INTO orders (user_id, status, total_amount) VALUES
(1, 'Delivered',   735.00),   -- Alice
(2, 'Processing',  117.00),   -- Bob
(3, 'Pending',     950.00),   -- Carol
(4, 'Shipped',     152.00),   -- David  
(1, 'Delivered',   85.00);    -- Alice again

-- 3d: Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 650.00),   -- Alice ordered Galaxy A54
(1, 2, 1,  85.00),   -- Alice ordered Nike shoes
(2, 4, 2,  32.00),   -- Bob ordered 2x Earbuds
(2, 5, 1,  15.00),   -- Bob ordered T-Shirt
(2, 6, 1, 120.00),   -- Bob ordered Smart Watch
(3, 3, 1, 950.00),   -- Carol ordered HP Laptop
(4, 4, 1,  32.00),   -- David ordered Earbuds
(4, 6, 1, 120.00),   -- David ordered Smart Watch
(5, 2, 1,  85.00);   -- Alice ordered Nike shoes again

-- Adding or updating Foreign Keys with CASCADE behaviour
ALTER TABLE orders
ADD CONSTRAINT fk_orders_user
FOREIGN KEY (user_id) REFERENCES users(user_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE order_items
ADD CONSTRAINT fk_items_order
FOREIGN KEY (order_id) REFERENCES orders(order_id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_items_product
FOREIGN KEY (product_id) REFERENCES products(product_id)
ON UPDATE CASCADE;

-- Verify all foreign key relationships
SELECT
TABLE_NAME,
COLUMN_NAME,
CONSTRAINT_NAME,
REFERENCED_TABLE_NAME,
REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ecommerce_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 5a: View all users
SELECT * FROM users;

-- 5b: View all products sorted by category and price
SELECT product_id, name, price, stock, category
FROM products
ORDER BY category, price;

-- 5c: View all orders for a specific user (user_id = 1)
SELECT order_id, order_date, status, total_amount
FROM orders
WHERE user_id = 1;

-- 5d: View full order details with customer and product names
SELECT
o.order_id, 
u.name AS customer_name,
p.name AS product_name,
oi.quantity,
oi.unit_price,
(oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
JOIN orders   o  ON oi.order_id   = o.order_id
JOIN users    u  ON o.user_id     = u.user_id
JOIN products p  ON oi.product_id = p.product_id
ORDER BY o.order_id, oi.item_id;

-- 5e: View all items in a specific order (order_id = 2)
SELECT
p.name AS product,
oi.quantity,
oi.unit_price,
(oi.quantity * oi.unit_price) AS subtotal
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.order_id = 2;

-- 6a: Calculate the total bill for every order
SELECT
o.order_id, 
u.name AS customer,
COUNT(oi.item_id) AS total_items,
SUM(oi.quantity * oi.unit_price) AS total_bill,
o.status
FROM orders o
JOIN users       u  ON o.user_id     = u.user_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY o.order_id, u.name, o.status
ORDER BY total_bill DESC;

-- 6b: Top 5 best-selling products by units sold
SELECT 
p.name AS product_name,
p.category,
SUM(oi.quantity) AS total_units_sold,
SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY total_units_sold DESC
LIMIT 5;

-- 6c: Revenue breakdown by product category
SELECT 
p.category,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.quantity) AS units_sold,
SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
GROUP BY p.category
HAVING category_revenue > 100
ORDER BY category_revenue DESC;

-- 6d: Total spending per customer
SELECT
u.name,
u.email,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.quantity * oi.unit_price) AS total_spent
FROM users u
JOIN orders      o  ON u.user_id     = o.user_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY u.user_id, u.name, u.email
ORDER BY total_spent DESC;

-- 7a: AFTER INSERT trigger — automatically reduce stock
DELIMITER $$

CREATE TRIGGER trg_decrease_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    -- Get the current stock level for the product
    SELECT stock INTO current_stock
    FROM products 
    WHERE product_id = NEW.product_id;

    -- Raise an error if there is not enough stock
    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Insufficient stock for this product!';
    END IF;

    -- Deduct the ordered quantity from stock
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;

END$$

DELIMITER ;

-- 7b: AFTER DELETE trigger — restore stock when order item is removed
DELIMITER $$

CREATE TRIGGER trg_restore_stock
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN

    -- Add the quantity back to stock when an order is cancelled
    UPDATE products
    SET stock = stock + OLD.quantity
    WHERE product_id = OLD.product_id;

END$$

DELIMITER ;

-- Verify triggers were created
SHOW TRIGGERS FROM ecommerce_db;

-- 8a: Create the PlaceOrder stored procedure
DELIMITER $$

CREATE PROCEDURE PlaceOrder(
    IN  p_user_id INT,         -- Customer placing the order   
    IN  p_product_id INT,      -- Product being ordered   
    IN  p_quantity INT,        -- How many units 
    OUT p_order_id INT,        -- Returns the new order ID
    OUT p_message VARCHAR(200) -- Returns success or error message
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);

-- Fetch current price and stock for the product
    SELECT price, stock INTO v_price, v_stock
    FROM products WHERE product_id = p_product_id;
    
-- Check if enough stock is available
IF v_stock < p_quantity THEN
    SET p_order_id = 0;
    SET p_message  = 'Error: Not enough stock available!';
ELSE  
    SET v_total = v_price * p_quantity;

    -- Create the order header record
    INSERT INTO orders (user_id, status, total_amount)
    VALUES (p_user_id, 'Pending', v_total);

    SET p_order_id = LAST_INSERT_ID();

    -- Insert order line item (trigger fires automatically)
    INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);

    SET p_message = CONCAT(
        'Order placed! ID: ', p_order_id,
        ' | Total: $', v_total
    );
END IF;

END$$

DELIMITER ;

-- 8b: Call the procedure to place an order
-- User 2 (Bob) orders 3 units of product 5 (Cotton T-Shirt)

CALL PlaceOrder(2, 5, 3, @new_order_id, @result_msg);

SELECT @new_order_id AS order_id, @result_msg AS message;

-- 8c: List all stored procedures in the database
SHOW PROCEDURE STATUS 
WHERE Db = 'ecommerce_db';

-- 9a: List all tables in the database
SHOW TABLES;

-- 9b: View all customer records
SELECT * FROM users;

-- 9c: Check product stock levels after orders
SELECT product_id, name, price, stock, category
FROM products
ORDER BY stock ASC;

-- 9d: View all orders with customer names
SELECT
    o.order_id,
    u.name AS customer,
    o.order_date,
    o.status,
    o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.user_id
ORDER BY o.order_id;

-- 9e: Full order details — all orders with all items
SELECT
    o.order_id,
    u.name AS customer,
    p.name AS product,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN users u ON o.user_id = u.user_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, oi.item_id;

-- 9f: Confirm stock was reduced by the trigger
SELECT product_id, name, stock
FROM products
WHERE product_id IN (
    SELECT DISTINCT product_id FROM order_items
);


-- 10a: Database size and row summary
SELECT
    TABLE_NAME,
    TABLE_ROWS AS approx_rows,
    ROUND(DATA_LENGTH / 1024, 2) AS data_kb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ecommerce_db';

-- 10b: Best customer (highest total spending)
SELECT
    u.name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM users u
JOIN orders o  ON u.user_id  = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY u.user_id, u.name
ORDER BY total_spent DESC
LIMIT 1;

-- 10c: Best-selling product
SELECT
    p.name,
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY total_units_sold DESC
LIMIT 1;

-- 10d: Order status summary
SELECT
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;
