-- Create the suppliers table
CREATE TABLE suppliers (
  supplier_id int PRIMARY KEY,
  supplier_name VARCHAR(50) NOT NULL,
  supplier_address VARCHAR(50)
);

-- Create the products table
CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  product_name VARCHAR(50) NOT NULL,
  product_description VARCHAR(50),
  product_price NUMERIC(10,2)
);

-- Create the customers table
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  customer_name VARCHAR(50) NOT NULL,
  customer_address VARCHAR(50)
);

-- Create the orders table
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  order_date DATE,
  order_quantity INTEGER
);

-- Create the production/manufacturing table
CREATE TABLE production_manufacturing (
  manufacturer_id SERIAL PRIMARY KEY,
	manufacturer_name VARCHAR(50) NOT NULL,
	manufacturer_address VARCHAR(50) NOT NULL,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  production_quantity INTEGER
);

-- Create the distribution table
CREATE TABLE distribution(
  distributor_id SERIAL PRIMARY KEY,
  distributor_name VARCHAR(50) NOT NULL,
  distributor_address VARCHAR(50),
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id)
);

-- Create the shipments table
CREATE TABLE shipments (
  shipment_id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  distributor_id INTEGER NOT NULL REFERENCES distribution(distributor_id),
  shipment_date DATE
);

--Create the invoice table
CREATE TABLE invoice(
	invoice_id int primary key,
	invoice_date DATE,
	total_amount numeric(10,2),
	order_id INT NOT NULL REFERENCES orders(order_id)
);



-- Insert suppliers data
INSERT INTO suppliers (supplier_id,supplier_name, supplier_address) VALUES
  (1,'Max Engg Works', 'Mumbai'),
  (2,'Sidharth Engg. works', 'Gujarat'),
  (3,'Purvi Industries', 'Surat');
  

-- Insert products data
INSERT INTO products (product_name, product_description, product_price) VALUES
  ('MS Steel', 'High-quality steel ', 1000),
  ('SS Steel', 'High-quality steel', 6499),
  ('H2SO4', 'Electro Plating for industrial applications', 100000);

-- Insert customers data
INSERT INTO customers (customer_name, customer_address) VALUES
  ('Mitesh Koladiya', 'Ahmedabad'),
  ('Khushi Gohil', 'Mumbai'),
  ('Vishal Singh', 'Anand');

-- Insert orders data
INSERT INTO orders (customer_id, product_id, order_date, order_quantity) VALUES
  (1, 1, '2023-1-03', 100),
  (2, 2, '2023-12-07', 1),
  (3, 3, '2023-08-10', 5);

-- Insert production/manufacturing data
INSERT INTO production_manufacturing (manufacturer_id,manufacturer_name,manufacturer_address, product_id, production_quantity) VALUES
  (1,'amozon','mumbai', 1, 100),
  (2, 'flipkart','surat',2, 1),
  (3, 'myntra','anand',3, 5);

-- Insert distribution centers data
INSERT INTO distribution (distributor_id,distributor_name, distributor_address,customer_id) VALUES
  (1,'Karnvati works', 'Ahmedabad',1),
  (2,'Vishal works', 'Mumbai',2),
  (3,'Kinjal Chemicals', 'Chennai',3);

-- Insert shipments data
INSERT INTO shipments (shipment_id,order_id, distributor_id, shipment_date) VALUES
  (1,1, 1, '2023-2-08'),
  (2,2, 2, '2023-12-08'),
  (3,3, 3, '2023-08-15');
  
  
  --Insert invoice data
  INSERT INTO invoice(invoice_id,invoice_date,total_amount,order_id) values
 (1,'2023-02-05',500,1),
   (2,'2023-02-02',600,2),
   (3,'2023-03-03',100,3);
  
  
 drop table invoice;
  
  -- Select all suppliers
SELECT * FROM suppliers;
truncate suppliers;



-- Select all products
SELECT * FROM products;

-- Select all customers
SELECT * FROM customers;

-- Select all orders
SELECT * FROM orders;

-- Select all production/manufacturing records
SELECT * FROM production_manufacturing;

-- Select all warehouses/distribution centers
SELECT * FROM distribution;

-- Select all shipments
SELECT * FROM shipments;

--Select all invoice
SELECT * FROM invoice;








--1. Select all orders for a specific customer
SELECT * FROM orders WHERE customer_id = 1;

--2. Select all orders shipped from the Ahmedabad warehouse
SELECT * FROM orders o
JOIN shipments s ON o.order_id = s.order_id
JOIN distribution d ON s.distributor_id = d.distributor_id
WHERE d.distributor_name = 'Karnvati works';

--3. Select the total quantity of each product produced
SELECT product_id, SUM(production_quantity) AS total_quantity
FROM production_manufacturing
GROUP BY product_id;

--4. Select the average order quantity for each customer
SELECT customer_id, AVG(order_quantity) AS average_order_quantity
FROM orders
GROUP BY customer_id;

--5.Get the total quantity of each product ordered:
SELECT product_id, SUM(order_quantity) AS total_ordered_quantity
FROM orders
GROUP BY product_id;

--6.List all customers along with the total amount they've spent (from invoices):
SELECT c.customer_name, SUM(i.total_amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN invoice i ON o.order_id = i.order_id
GROUP BY c.customer_name;


--7.Retrieve the distribution centers and the respective orders they've shipped:
SELECT d.distributor_name, o.order_id
FROM distribution d
INNER JOIN shipments s ON d.distributor_id = s.distributor_id
INNER JOIN orders o ON s.order_id = o.order_id;

--8.Get the product name, order date, and quantity ordered for a specific customer:
SELECT p.product_name, o.order_date, o.order_quantity
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_name = 'Mitesh Koladiya';

--9.Retrieve the average product price across all products:
SELECT AVG(product_price) AS average_price
FROM products;

--10.Find the total quantity produced by each manufacturer:
SELECT manufacturer_name, SUM(production_quantity) AS total_production
FROM production_manufacturing
GROUP BY manufacturer_name;



--Trigger
--1.Trigger to Update Total Quantity on Insert into Production_Manufacturing
CREATE OR REPLACE FUNCTION update_total_quantity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET total_quantity = total_quantity + NEW.production_quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_trigger
AFTER INSERT ON production_manufacturing
FOR EACH ROW
EXECUTE FUNCTION update_total_quantity();



--2.Trigger to Update Order Date on Order Update
CREATE OR REPLACE FUNCTION update_order_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_date = CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_date_trigger
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_date();



--3.Trigger to update total amount in invoice after an insertion into shipments:

CREATE OR REPLACE FUNCTION update_invoice_amount()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE invoice
    SET total_amount = total_amount + (SELECT product_price * NEW.order_quantity FROM products WHERE product_id = NEW.product_id)
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_invoice_trigger
AFTER INSERT ON shipments
FOR EACH ROW
EXECUTE FUNCTION update_invoice_amount();



--4.Trigger to update the order date in shipments when an order is placed:

CREATE OR REPLACE FUNCTION update_shipment_order_date()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE shipments
    SET shipment_date = NEW.order_date
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_shipment_date_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_shipment_order_date();


--5. Trigger to update total quantity in production_manufacturing after an insertion into orders:

CREATE OR REPLACE FUNCTION update_production_quantity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE production_manufacturing
    SET production_quantity = production_quantity + NEW.order_quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_production_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_production_quantity();







--Function
-- 1.Function to Calculate Total Quantity of Ordered Products for a Customer
CREATE OR REPLACE FUNCTION getTotalOrderedQuantityForCustomer(customer_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    total_quantity INTEGER;
BEGIN
    SELECT SUM(o.order_quantity) INTO total_quantity
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.customer_name = customer_name;

    RETURN total_quantity;
END;
$$ LANGUAGE plpgsql;



-- 2.Function to Retrieve Product Information by ID
CREATE OR REPLACE FUNCTION getProductByID(product_id INTEGER)
RETURNS TABLE (
    product_name VARCHAR,
    product_description VARCHAR,
    product_price NUMERIC
) AS $$
BEGIN
    RETURN QUERY SELECT product_name, product_description, product_price
    FROM products
    WHERE products.product_id = getProductByID.product_id;
END;
$$ LANGUAGE plpgsql;



--3.Function to Calculate Total Amount Spent by a Customer
CREATE OR REPLACE FUNCTION getTotalAmountSpentByCustomer(customer_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    SELECT SUM(i.total_amount) INTO total_amount
    FROM invoice i
    JOIN orders o ON i.order_id = o.order_id
    WHERE o.customer_id = getTotalAmountSpentByCustomer.customer_id;

    RETURN total_amount;
END;
$$ LANGUAGE plpgsql;

--4.Function to Get Latest Shipment Date for a Product
CREATE OR REPLACE FUNCTION getLatestShipmentDateForProduct(product_id INTEGER)
RETURNS DATE AS $$
DECLARE
    latest_date DATE;
BEGIN
    SELECT MAX(s.shipment_date) INTO latest_date
    FROM shipments s
    JOIN orders o ON s.order_id = o.order_id
    WHERE o.product_id = getLatestShipmentDateForProduct.product_id;

    RETURN latest_date;
END;
$$ LANGUAGE plpgsql;

select getLatestShipmentDateForProduct(1);

--5.Function to Retrieve Manufacturers and Their Production Quantities
CREATE OR REPLACE FUNCTION getManufacturersAndProductionQuantities()
RETURNS TABLE (
    manufacturer_name VARCHAR,
    production_quantity INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT manufacturer_name, production_quantity
    FROM production_manufacturing;
END;
$$ LANGUAGE plpgsql;



--Procedure
-- Procedure 1: Calculate Total Quantity of Ordered Products for a Customer
CREATE OR REPLACE PROCEDURE getTotalOrderedQuantityForCustomer(customer_name VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    total_quantity INTEGER;
BEGIN
    SELECT SUM(o.order_quantity) INTO total_quantity
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.customer_name = customer_name;

    RAISE NOTICE 'Total quantity of orders for %: %', customer_name, total_quantity;
END;
$$;

-- Procedure 2: Retrieve Product Information by ID
CREATE OR REPLACE PROCEDURE getProductByID(product_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    product_info RECORD;
BEGIN
    SELECT product_name, product_description, product_price
    INTO product_info
    FROM products
    WHERE products.product_id = getProductByID.product_id;

    RAISE NOTICE 'Product Name: %, Description: %, Price: %',
        product_info.product_name, product_info.product_description, product_info.product_price;
END;
$$;

-- Procedure 3: Calculate Total Amount Spent by a Customer
CREATE OR REPLACE PROCEDURE getTotalAmountSpentByCustomer(customer_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    SELECT SUM(i.total_amount) INTO total_amount
    FROM invoice i
    JOIN orders o ON i.order_id = o.order_id
    WHERE o.customer_id = getTotalAmountSpentByCustomer.customer_id;

    RAISE NOTICE 'Total amount spent by customer ID %: %', customer_id, total_amount;
END;
$$;

-- Procedure 4: Get Latest Shipment Date for a Product
CREATE OR REPLACE PROCEDURE getLatestShipmentDateForProduct(product_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    latest_date DATE;
BEGIN
    SELECT MAX(s.shipment_date) INTO latest_date
    FROM shipments s
    JOIN orders o ON s.order_id = o.order_id
    WHERE o.product_id = getLatestShipmentDateForProduct.product_id;

    RAISE NOTICE 'Latest shipment date for product ID %: %', product_id, latest_date;
END;
$$;

-- Procedure 5: Retrieve Manufacturers and Their Production Quantities
CREATE OR REPLACE PROCEDURE getManufacturersAndProductionQuantities()
LANGUAGE plpgsql
AS $$
DECLARE
    manufacturer_info RECORD;
BEGIN
    FOR manufacturer_info IN
        SELECT manufacturer_name, production_quantity
        FROM production_manufacturing
    LOOP
        RAISE NOTICE 'Manufacturer: %, Production Quantity: %',
            manufacturer_info.manufacturer_name, manufacturer_info.production_quantity;
    END LOOP;
END;
$$;

--Cursor
-- Procedure 1: Retrieve Orders by Customer Name using Cursor
CREATE OR REPLACE PROCEDURE getOrdersByCustomerName(customer_name VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    order_info RECORD;
    order_cursor CURSOR FOR
        SELECT o.order_id, p.product_name, o.order_date, o.order_quantity
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        JOIN products p ON o.product_id = p.product_id
        WHERE c.customer_name = customer_name;

BEGIN
    OPEN order_cursor;
    LOOP
        FETCH order_cursor INTO order_info;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Order ID: %, Product: %, Order Date: %, Quantity: %',
            order_info.order_id, order_info.product_name,
            order_info.order_date, order_info.order_quantity;
    END LOOP;

    CLOSE order_cursor;
END;
$$;


-- Procedure 2: Retrieve Invoices and Order Amounts using Cursor
CREATE OR REPLACE PROCEDURE getInvoicesAndOrderAmounts()
LANGUAGE plpgsql
AS $$
DECLARE
    invoice_info RECORD;
    invoice_cursor CURSOR FOR
        SELECT i.invoice_id, i.invoice_date, i.total_amount, o.order_id
        FROM invoice i
        JOIN orders o ON i.order_id = o.order_id;

BEGIN
    OPEN invoice_cursor;
    LOOP
        FETCH invoice_cursor INTO invoice_info;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Invoice ID: %, Invoice Date: %, Total Amount: %, Order ID: %',
            invoice_info.invoice_id, invoice_info.invoice_date,
            invoice_info.total_amount, invoice_info.order_id;
    END LOOP;

    CLOSE invoice_cursor;
END;
$$;
