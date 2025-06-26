# Supply Chain Management System

**Database Management System (DBMS)**  

---

## 📌 Project Overview

Supply Chain Management (SCM) System aims to oversee and coordinate all processes involved in the flow of goods — from raw material acquisition to final delivery to the consumer. This project simulates a complete supply chain workflow using relational databases, DDL, queries, functions, triggers, procedures, and cursors.

---

## 🚀 Functional Features

- **Inventory Management**
- **Demand Forecasting**
- **Order Processing**
- **Supplier Relationship Management**

### ✅ Benefits
- Reduced inventory costs
- Efficient transportation
- Better supplier deals
- Minimized stockouts

---

## 🧩 ER Diagram
![image](https://github.com/user-attachments/assets/4dbb7858-b3e6-4b00-bf3b-201dc8b600fc)


---

## 🧮 Functional Dependencies & Normalization

Each relation has been normalized to **3NF** and includes the following entities:

- Manufacturer
- Products
- Supplier
- Distributor
- Customer
- Order
- Invoice
- Shipment

---

## 📘 Relational Schema

```text
Manufacturer(manufacturer_id, manufacturer_name, manufacturer_address, product_id)
Products(product_id, product_name, product_description)
Supplier(supplier_id, supplier_name, supplier_address)
Distributor(distributor_id, distributor_name, distributor_address, customer_id)
Customer(customer_id, customer_name, customer_address)
Order(order_id, order_date, quantity)
Invoice(invoice_id, invoice_date, total_amount, order_id)
Shipment(shipment_id, shipment_date, shipping_address, order_id)
