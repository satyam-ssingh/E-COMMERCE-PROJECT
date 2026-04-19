# 🛒 E-Commerce Database Project

## 📌 Overview
This project is a complete **E-Commerce Database Management System** built using **MySQL**. It simulates real-world online shopping operations such as managing users, products, orders, and order items.

---

## 🧱 Database Name
ecommerce_db


---

## 📊 Tables

### 1. Users
Stores customer details:
- user_id (Primary Key)
- name
- email (Unique)
- phone
- address
- created_at

### 2. Products
Stores product information:
- product_id (Primary Key)
- name
- description
- price
- stock
- category
- created_at

### 3. Orders
Stores order details:
- order_id (Primary Key)
- user_id (Foreign Key)
- order_date
- status
- total_amount

### 4. Order_Items
Stores items in each order:
- item_id (Primary Key)
- order_id (Foreign Key)
- product_id (Foreign Key)
- quantity
- unit_price

---

## 🔗 Relationships
- One user can place multiple orders  
- One order can have multiple products  
- One product can be part of multiple orders  

---

## ⚙️ Features

### Basic Operations
- Create database and tables  
- Insert sample data  
- Retrieve data using SELECT queries  

### Advanced Queries
- Total bill per order  
- Top-selling products  
- Revenue by category  
- Customer spending analysis  

### Triggers
- Automatically decrease stock after order  
- Restore stock when order item is deleted  

### Stored Procedure
**PlaceOrder**
- Inputs: user_id, product_id, quantity  
- Outputs: order_id, message  
- Validates stock before placing order  

---

## Sample Queries
- View all users  
- View all products  
- View orders of a user  
- Full order details (JOIN)  
- Best customer  
- Best-selling product  
- Order summary  

---

## How to Run

1. Open MySQL (Workbench / CLI)
2. Run:

```sql
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

