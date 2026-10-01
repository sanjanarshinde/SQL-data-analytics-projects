CREATE TABLE amazon_sales (
    orderid          VARCHAR(20),
     orderdate        DATE,
     year              INT,
     month             VARCHAR(10),
     customerid       VARCHAR(20),
     customername     VARCHAR(100),
     productid        VARCHAR(20),
     productname      VARCHAR(150),
     category          VARCHAR(50),
     brand             VARCHAR(50),
    quantity          INT,
     unitprice        DECIMAL(10,2),
    grosssales  DECIMAL(10,2),
     discount           DECIMAL(5,2),
     discountamount   DECIMAL(10,2),
     netsales         DECIMAL(10,2),
     tax               DECIMAL(10,2),
     shippingcost     DECIMAL(10,2),
     totalamount      DECIMAL(10,2),
    returnedamount   DECIMAL(10,2),
     paymentmethod    VARCHAR(30),
     orderstatus      VARCHAR(20),
     returnflag       VARCHAR(5),
	 city              VARCHAR(50),
     state            VARCHAR(50),
    country            VARCHAR(50),
     sellerid         VARCHAR(20)
 );

select * from amazon_sales 

-- ============================================================
-- 1. DATA EXPLORATION
-- ============================================================

-- Total records
SELECT COUNT(*) AS total_records
FROM amazon_sales;

-- Sample data
SELECT *
FROM amazon_sales
LIMIT 10;

-- Columns and data types (MySQL / information_schema)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'amazon_sales';

-- NULL checks (key columns)
SELECT
    SUM(CASE WHEN orderid IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customerid IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN productid IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN totalamount IS NULL THEN 1 ELSE 0 END) AS null_total_amount,
    SUM(CASE WHEN orderdate IS NULL THEN 1 ELSE 0 END) AS null_order_date
FROM amazon_sales;

-- Duplicate checks (order_id should be unique)
SELECT orderid, COUNT(*) AS cnt
FROM amazon_sales
GROUP BY orderid
HAVING COUNT(*) > 1;

-- Date range
SELECT MIN(orderdate) AS firstorder, MAX(orderdate) AS last_order
FROM amazon_sales;

-- Unique customers / products / categories
SELECT
    COUNT(DISTINCT customerid) AS unique_customers,
    COUNT(DISTINCT productid) AS unique_products,
    COUNT(DISTINCT category) AS unique_categories
FROM amazon_sales;

-- Distinct payment methods / statuses / countries / states
SELECT DISTINCT paymentmethod FROM amazon_sales;
SELECT DISTINCT orderstatus FROM amazon_sales;
SELECT DISTINCT country FROM amazon_sales;
SELECT DISTINCT state FROM amazon_sales;

-- Sellers / cities / brands
SELECT COUNT(DISTINCT sellerid) AS unique_sellers FROM amazon_sales;
SELECT COUNT(DISTINCT city) AS unique_cities FROM amazon_sales;
SELECT COUNT(DISTINCT brand) AS unique_brands FROM amazon_sales;


-- ============================================================
-- 2. DATA QUALITY CHECKS
-- ============================================================

-- Duplicate order IDs (full duplicate rows)
SELECT orderid, customerid, productid, orderdate, COUNT(*) AS cnt
FROM amazon_sales
GROUP BY 1,2,3,4
HAVING COUNT(*) > 1;

-- Missing values across key fields
SELECT
    SUM(CASE WHEN customername IS NULL OR customername = '' THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN productname IS NULL OR productname = '' THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN state IS NULL OR state = '' THEN 1 ELSE 0 END) AS missing_state
FROM amazon_sales;

-- Invalid / unexpected values
SELECT * FROM amazon_sales WHERE quantity <= 0;
SELECT * FROM amazon_sales WHERE unitprice < 0;
SELECT * FROM amazon_sales WHERE totalamount < 0;
SELECT * FROM amazon_sales WHERE discount < 0 OR discount > 1;


-- Basic data validation: recompute total and compare
SELECT orderid, netsales, tax, shippingcost, totalamount,
       (netsales + tax + shippingcost) AS recalculated_total,
       (totalamount - (netsales + tax + shippingcost)) AS diff
FROM amazon_sales
WHERE ROUND(totalamount,2) <> ROUND((netsales + tax + shippingcost),2);


-- ============================================================
-- 3. SELLER ANALYSIS
-- ============================================================

-- Seller-wise order count
SELECT sellerid, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY sellerid
ORDER BY total_orders DESC;

-- Seller performance (sales, average order value, returns)
SELECT
    sellerid,
    COUNT(*) AS total_orders,
    SUM(totalamount) AS total_sales,
    ROUND(AVG(totalamount),2) AS avg_order_value,
    SUM(CASE WHEN returnflag = 'yes' THEN 1 ELSE 0 END) AS total_returns
FROM amazon_sales
GROUP BY sellerid
ORDER BY total_sales DESC;


-- ============================================================
-- 4. CATEGORY ANALYSIS
-- ============================================================

-- Orders by category
SELECT category, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY category
ORDER BY total_orders DESC;

-- Sales by category
SELECT category, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY category
ORDER BY total_sales DESC;


-- ============================================================
-- 5. PRODUCT ANALYSIS
-- ============================================================

-- Product-wise sales
SELECT productid, productname, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY productid, productname
ORDER BY total_sales DESC;

-- Top products by sales
SELECT productid, productname, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY productid, productname
ORDER BY total_sales DESC
LIMIT 10;

-- Top products by quantity
SELECT productid, productname, SUM(quantity) AS total_quantity
FROM amazon_sales
GROUP BY productid, productname
ORDER BY total_quantity DESC
LIMIT 10;


-- ============================================================
-- 6. CUSTOMER ANALYSIS
-- ============================================================

-- Top customers by sales
SELECT customerid, customername, SUM(totalamount) AS total_spend
FROM amazon_sales
GROUP BY customerid, customername
ORDER BY total_spend DESC
LIMIT 10;

-- Top customers by order count
SELECT customerid, customername, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY customerid, customername
ORDER BY total_orders DESC
LIMIT 10;


-- ============================================================
-- 7. GEOGRAPHICAL ANALYSIS
-- ============================================================

-- State-wise sales / orders
SELECT state, COUNT(*) AS total_orders, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY state
ORDER BY total_sales DESC;

-- City-wise sales / orders
SELECT city, COUNT(*) AS total_orders, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY city
ORDER BY total_sales DESC;


-- ============================================================
-- 8. PAYMENT & ORDER STATUS ANALYSIS
-- ============================================================

-- Payment method analysis
SELECT paymentmethod, COUNT(*) AS total_orders, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY paymentmethod
ORDER BY total_sales DESC;

-- Order status analysis
SELECT orderstatus, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY orderstatus
ORDER BY total_orders DESC;

-- Average order value by payment method
SELECT paymentmethod, ROUND(AVG(totalamount),2) AS avg_order_value
FROM amazon_sales
GROUP BY paymentmethod
ORDER BY avg_order_value DESC;

-- Combined status summary (status + payment method)
SELECT orderstatus, paymentmethod, COUNT(*) AS total_orders, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY orderstatus, paymentmethod
ORDER BY orderstatus, total_sales DESC;


-- ============================================================
-- 9. QUANTITY ANALYSIS
-- ============================================================

-- Quantity by category
SELECT category, SUM(quantity) AS total_quantity
FROM amazon_sales
GROUP BY category
ORDER BY total_quantity DESC;

-- Quantity by product
SELECT productid, productname, SUM(quantity) AS total_quantity
FROM amazon_sales
GROUP BY productid, productname
ORDER BY total_quantity DESC;

-- Quantity by year
SELECT year, SUM(quantity) AS total_quantity
FROM amazon_sales
GROUP BY year
ORDER BY year;


-- ============================================================
-- 10. TIME-BASED ANALYSIS
-- ============================================================

-- Year-wise sales / orders / quantity
SELECT year,
       COUNT(*) AS total_orders,
       SUM(totalamount) AS total_sales,
       SUM(quantity) AS total_quantity
FROM amazon_sales
GROUP BY year
ORDER BY year;

-- Monthly sales / orders
SELECT year, month,
       COUNT(*) AS total_orders,
       SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY year, month
ORDER BY year,
  CASE month
    WHEN 'Jan' THEN 1 WHEN 'Feb' THEN 2 WHEN 'Mar' THEN 3
    WHEN 'Apr' THEN 4 WHEN 'May' THEN 5 WHEN 'Jun' THEN 6
    WHEN 'Jul' THEN 7 WHEN 'Aug' THEN 8 WHEN 'Sep' THEN 9
    WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
  END;

-- Category-wise yearly analysis
SELECT year, category, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY year, category
ORDER BY year, total_sales DESC;


-- ============================================================
-- 11. DISCOUNT, TAX & SHIPPING ANALYSIS
-- ============================================================

-- Average discount by category
SELECT category, ROUND(AVG(discount),4) AS avg_discount
FROM amazon_sales
GROUP BY category
ORDER BY avg_discount DESC;

-- Products with highest average discount
SELECT productid, productname, ROUND(AVG(discount),4) AS avg_discount
FROM amazon_sales
GROUP BY productid, productname
ORDER BY avg_discount DESC
LIMIT 10;

-- Average tax by category
SELECT category, ROUND(AVG(tax),2) AS avg_tax
FROM amazon_sales
GROUP BY category
ORDER BY avg_tax DESC;

-- Average shipping cost by category
SELECT category, ROUND(AVG(shippingcost),2) AS avg_shipping_cost
FROM amazon_sales
GROUP BY category
ORDER BY avg_shipping_cost DESC;

-- Category performance summary (sales, discount, tax, shipping together)
SELECT
    category,
    SUM(totalamount) AS total_sales,
    ROUND(AVG(discount),4) AS avg_discount,
    ROUND(AVG(tax),2) AS avg_tax,
    ROUND(AVG(shippingcost),2) AS avg_shipping_cost
FROM amazon_sales
GROUP BY category
ORDER BY total_sales DESC;


-- ============================================================
-- 12. SUBQUERIES
-- ============================================================

-- Basic subquery: customers who spent more than the overall average
SELECT customerid, customername, SUM(totalamount) AS total_spend
FROM amazon_sales
GROUP BY customerid, customername
HAVING SUM(totalamount) > (SELECT AVG(totalamount) FROM amazon_sales);

-- Scalar subquery: difference from overall average order value
SELECT orderid, totalamount,
       totalamount - (SELECT AVG(totalamount) FROM amazon_sales) AS diff_from_avg
FROM amazon_sales;

-- IN: orders from top 5 best-selling categories
SELECT *
FROM amazon_sales
WHERE category IN (
    SELECT category
    FROM amazon_sales
    GROUP BY category
    ORDER BY SUM(totalamount) DESC
    LIMIT 5
);

-- NOT IN: orders from countries other than the top-selling country
SELECT *
FROM amazon_sales
WHERE country NOT IN (
    SELECT country
    FROM amazon_sales
    GROUP BY country
    ORDER BY SUM(totalamount) DESC
    
);

-- EXISTS: sellers who have at least one returned order
SELECT DISTINCT s.sellerid
FROM amazon_sales s
WHERE EXISTS (
    SELECT 1 FROM amazon_sales r
    WHERE r.sellerid = s.sellerid AND r.returnflag = 'yes'
);

-- NOT EXISTS: sellers with zero returned orders
SELECT DISTINCT s.sellerid
FROM amazon_sales s
WHERE NOT EXISTS (
    SELECT 1 FROM amazon_sales r
    WHERE r.sellerid = s.sellerid AND r.returnflag = 'yes'
);

-- Correlated subquery: customer's orders above their own average spend
SELECT a.orderid, a.customerid, a.totalamount
FROM amazon_sales a
WHERE a.totalamount > (
    SELECT AVG(b.totalamount)
    FROM amazon_sales b
    WHERE b.customerid = a.customerid
	limit 10
);

-- Subquery in FROM: average sales per category, then rank
SELECT category, total_sales,
       RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM (
    SELECT category, SUM(totalamount) AS total_sales
    FROM amazon_sales
    GROUP BY category
) AS category_totals;


-- ============================================================
-- 13. COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================================

-- Yearly sales via CTE, then compute share of total
WITH yearly_sales AS (
    SELECT year, SUM(totalamount) AS total_sales
    FROM amazon_sales
    GROUP BY year
)
SELECT year, total_sales,
       ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS pct_of_total
FROM yearly_sales
ORDER BY year;

-- Top customer per state using a CTE + window function
WITH customer_state_sales AS (
    SELECT state, customerid, customername, SUM(totalamount) AS total_spend,
           RANK() OVER (PARTITION BY state ORDER BY SUM(totalamount) DESC) AS rnk
    FROM amazon_sales
    GROUP BY state, customerid, customername
)
SELECT state, customerid, customername, total_spend
FROM customer_state_sales
WHERE rnk = 1;


-- ============================================================
-- 14. CASE STATEMENTS
-- ============================================================

-- Order value segmentation
SELECT orderid, totalamount,
    CASE
        WHEN totalamount < 50 THEN 'Low Value'
        WHEN totalamount BETWEEN 50 AND 200 THEN 'Medium Value'
        ELSE 'High Value'
    END AS order_segment
FROM amazon_sales;

-- Discount tier classification
SELECT orderid, discount,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.10 THEN 'Low Discount'
        WHEN discount > 0.10 AND discount <= 0.25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_tier
FROM amazon_sales;


-- ============================================================
-- 15. WINDOW FUNCTIONS
-- ============================================================

-- RANK: rank products by total sales
SELECT productid, productname, total_sales,
       RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM (
    SELECT productid, productname, SUM(totalamount) AS total_sales
    FROM amazon_sales
    GROUP BY productid, productname
) AS product_totals;

-- ROW_NUMBER: first order per customer
SELECT *
FROM (
    SELECT orderid, customerid, orderdate, totalamount,
           ROW_NUMBER() OVER (PARTITION BY customerid ORDER BY orderdate ASC) AS rn
    FROM amazon_sales
) AS ranked
WHERE rn = 1;

-- Running total of sales by date
SELECT orderdate,
       SUM(totalamount) AS daily_sales,
       SUM(SUM(totalamount)) OVER (ORDER BY orderdate) AS running_total
FROM amazon_sales
GROUP BY orderdate
ORDER BY orderdate;

-- LAG: month-over-month sales change
WITH monthlysales AS (
    SELECT year, month,
           CASE month
               WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
               WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
               WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
               WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
           END AS month_num,
           SUM(totalamount) AS total_sales
    FROM amazon_sales
    GROUP BY year, month
)
SELECT year, month, total_sales,
       LAG(total_sales) OVER (ORDER BY year, month_num) AS prev_month_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY year, month_num) AS mom_change
FROM monthlysales
ORDER BY year, month_num;

-- ============================================================
-- 16. BUSINESS CASE ANALYSIS
-- ============================================================

-- Business Case 1: Year-over-year sales growth
WITH yearly AS (
    SELECT year, SUM(totalamount) AS total_sales
    FROM amazon_sales
    GROUP BY year
)
SELECT year, total_sales,
       LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
       ROUND(
           (total_sales - LAG(total_sales) OVER (ORDER BY year)) * 100.0
           / LAG(total_sales) OVER (ORDER BY year), 2
       ) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- Business Case 2: Top 5 products (by sales)
SELECT productid, productname, SUM(totalamount) AS total_sales
FROM amazon_sales
GROUP BY productid, productname
ORDER BY total_sales DESC
LIMIT 5;

-- Business Case 3: Top-selling product in each category
WITH product_category_sales AS (
    SELECT category, productid, productname, SUM(totalamount) AS total_sales,
           RANK() OVER (PARTITION BY category ORDER BY SUM(totalamount) DESC) AS rnk
    FROM amazon_sales
    GROUP BY category, productid, productname
)
SELECT category, productid, productname, total_sales
FROM product_category_sales
WHERE rnk = 1;

-- Business Case 4: Top 10 customers (by spend)
SELECT customerid, customername, SUM(totalamount) AS total_spend
FROM amazon_sales
GROUP BY customerid, customername
ORDER BY total_spend DESC
LIMIT 10;

-- Business Case 5: Repeat vs one-time customers
WITH customer_orders AS (
    SELECT customerid, COUNT(*) AS order_count
    FROM amazon_sales
    GROUP BY customerid
)
SELECT
    CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS customer_type,
    COUNT(*) AS num_customers
FROM customer_orders
GROUP BY customer_type;

-- Business Case 6: Highest average order value category
SELECT category, ROUND(AVG(totalamount),2) AS avg_order_value
FROM amazon_sales
GROUP BY category
ORDER BY avg_order_value DESC
LIMIT 1;

-- Business Case 7: Payment method performance
SELECT paymentmethod,
       COUNT(*) AS total_orders,
       SUM(totalamount) AS total_sales,
       ROUND(AVG(totalamount),2) AS avg_order_value
FROM amazon_sales
GROUP BY paymentmethod
ORDER BY total_sales DESC;

-- Business Case 8: Top 10 sellers
SELECT sellerid, SUM(totalamount) AS total_sales, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY sellerid
ORDER BY total_sales DESC
LIMIT 10;

-- Business Case 9: High-discount orders (above 25%)
SELECT orderid, customerid, productid, discount, totalamount
FROM amazon_sales
WHERE discount > 0.25
ORDER BY discount DESC;

-- Business Case 10: High-value repeat customers (spend > avg AND more than 1 order)
WITH customer_summary AS (
    SELECT customerid, customername,
           COUNT(*) AS order_count,
           SUM(totalamount) AS total_spend
    FROM amazon_sales
    GROUP BY customerid, customername
)
SELECT customerid, customername, order_count, total_spend
FROM customer_summary
WHERE order_count > 1
  AND total_spend > (SELECT AVG(totalamount) FROM amazon_sales)
ORDER BY total_spend DESC;

















