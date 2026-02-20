# Sales Analysis — SQL

A MySQL project built around a sample sales dataset from Kaggle. The goal was to practice writing real analytical queries — aggregations, multi-table joins, and window functions — against a normalised schema.

**Dataset:** [Sample Sales Data](https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)

---

## Schema

The raw CSV data is split into four tables:

| Table | Description |
|---|---|
| `customers` | Customer details — name, contact, location, territory |
| `products` | Product code, product line, and MSRP |
| `orders` | Order header — date, status, and link to customer |
| `order_items` | Line items — quantity, price, sales value, deal size |

`sales_setup.sql` creates the database, defines the tables with foreign keys, and loads data from CSV using `LOAD DATA LOCAL INFILE`.

---

## Queries

`sales_analysis.sql` is split into three sections:

**Aggregations**
- Revenue, order count, and average order value broken down by product line
- Revenue by country and by deal size (Small / Medium / Large)
- Order status breakdown with percentage of total using a window function

**Joins**
- Top 10 customers by total revenue, with country and territory
- Revenue cross-cut by territory and product line (4-table join)
- Average MSRP vs actual selling price per product line — shows how much of list price each line actually achieves

**Window Functions**
- Monthly revenue with a running YTD total and month-over-month growth %
- Customer revenue ranked within each country using `RANK() OVER (PARTITION BY ...)`
- Top-selling product line per territory
- 3-month rolling average revenue using `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`
