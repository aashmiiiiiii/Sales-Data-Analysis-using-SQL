-- ============================================================
-- Sales Analysis
-- MySQL Setup: Schema + Data Import
-- Source: https://www.kaggle.com/datasets/kyanyoga/sample-sales-data
-- ============================================================

CREATE DATABASE IF NOT EXISTS sales_analysis;
USE sales_analysis;

-- ------------------------------------------------------------
-- TABLE 1: customers
-- ------------------------------------------------------------
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    customer_name   VARCHAR(255),
    contact_first   VARCHAR(100),
    contact_last    VARCHAR(100),
    phone           VARCHAR(50),
    address1        VARCHAR(255),
    address2        VARCHAR(255),
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(20),
    country         VARCHAR(100),
    territory       VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/bhatt/Desktop/portfolio/data/sales/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ------------------------------------------------------------
-- TABLE 2: products
-- ------------------------------------------------------------
CREATE TABLE products (
    product_code    VARCHAR(20) PRIMARY KEY,
    product_line    VARCHAR(100),
    msrp            DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'C:/Users/bhatt/Desktop/portfolio/data/sales/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ------------------------------------------------------------
-- TABLE 3: orders
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_number    INT PRIMARY KEY,
    customer_id     INT,
    order_date      DATE,
    status          VARCHAR(50),
    quarter         INT,
    month           INT,
    year            INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

LOAD DATA LOCAL INFILE 'C:/Users/bhatt/Desktop/portfolio/data/sales/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ------------------------------------------------------------
-- TABLE 4: order_items
-- ------------------------------------------------------------
CREATE TABLE order_items (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    order_number        INT,
    order_line_number   INT,
    product_code        VARCHAR(20),
    quantity_ordered    INT,
    price_each          DECIMAL(10,2),
    sales               DECIMAL(10,2),
    deal_size           VARCHAR(20),
    FOREIGN KEY (order_number) REFERENCES orders(order_number),
    FOREIGN KEY (product_code) REFERENCES products(product_code)
);

LOAD DATA LOCAL INFILE 'C:/Users/bhatt/Desktop/portfolio/data/sales/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_number, order_line_number, product_code, quantity_ordered, price_each, sales, deal_size);

-- ------------------------------------------------------------
-- VERIFY
-- ------------------------------------------------------------
SELECT 'customers'   AS table_name, COUNT(*) AS rows_imported FROM customers  UNION ALL
SELECT 'products'    AS table_name, COUNT(*) AS rows_imported FROM products   UNION ALL
SELECT 'orders'      AS table_name, COUNT(*) AS rows_imported FROM orders     UNION ALL
SELECT 'order_items' AS table_name, COUNT(*) AS rows_imported FROM order_items;
