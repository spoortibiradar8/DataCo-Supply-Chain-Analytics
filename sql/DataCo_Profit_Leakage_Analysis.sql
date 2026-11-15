
/*
============================================================
PROJECT: THE HIDDEN COST OF GROWTH
A PROFIT LEAKAGE AUDIT OF DATACO

Business Question:
Where is DataCo losing money:
discounts, late deliveries, or weak categories?

Database: hidden_cost_growth
Table: dataco_orders

Dataset: DataCo SMART Supply Chain
Analysis Tool: MySQL Workbench

Author: Spoorti BIradar

IMPORTANT:
Each row represents an order item.
Use COUNT(DISTINCT `Order Id`) when counting orders.
Sales and profit are aggregated at order-item level.
============================================================
*/



-- SECTION 1: DATABASE SETUP AND DATA IMPORT


CREATE DATABASE IF NOT EXISTS hidden_cost_growth;

USE hidden_cost_growth;

-- Check whether local file import is enabled.
SHOW VARIABLES LIKE 'local_infile';


/*
DATA IMPORT

Run this section only when importing the CSV for the first time.
If reimporting, TRUNCATE removes all existing table records.
*/

-- TRUNCATE TABLE dataco_orders;

-- LOAD DATA LOCAL INFILE
-- 'C:/Users/Admin/Desktop/Hidden-Cost-of-Growth/datasets/cleaned/DataCo_cleaned.csv'
-- INTO TABLE dataco_orders
-- CHARACTER SET utf8mb4
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
-- IGNORE 1 ROWS;


-- SECTION 2: DATA QUALITY CHECKS
-- 2.1 Check total number of records.

SELECT
    COUNT(*) AS total_records
FROM dataco_orders;


-- 2.2 Check customer zipcode distribution.

SELECT
    `Customer Zipcode`,
    COUNT(*) AS occurrences
FROM dataco_orders
GROUP BY `Customer Zipcode`
ORDER BY occurrences DESC;


-- 2.3 Change zipcode data type to VARCHAR.

ALTER TABLE dataco_orders
MODIFY COLUMN `Customer Zipcode` VARCHAR(20);


-- 2.4 Identify possible repeated column headers in data.

SELECT *
FROM dataco_orders
WHERE `Customer Zipcode` = 'Customer Zipcode';

SELECT
    COUNT(*) AS repeated_header_rows
FROM dataco_orders
WHERE `Type` = 'Type';


-- 2.5 Examine transaction types.

SELECT
    `Type`,
    COUNT(*) AS row_count
FROM dataco_orders
GROUP BY `Type`
ORDER BY row_count DESC;


-- 2.6 Check invalid and missing zipcodes.

SELECT
    COUNT(*) AS total_records,
    SUM(`Customer Zipcode` = '0') AS zero_zipcodes,
    SUM(`Customer Zipcode` IS NULL) AS null_zipcodes
FROM dataco_orders;


-- 2.7 Inspect records with zero zipcodes.

SELECT
    `Type`,
    `Customer City`,
    `Customer State`,
    `Customer Zipcode`,
    `Order Id`,
    `Order Item Id`
FROM dataco_orders
WHERE `Customer Zipcode` = '0';


-- 2.8 Replace invalid zero zipcodes with NULL.

UPDATE dataco_orders
SET `Customer Zipcode` = NULL
WHERE `Customer Zipcode` = '0';


-- 2.9 Verify zipcode correction.

SELECT
    COUNT(*) AS total_records,
    SUM(`Customer Zipcode` = '0') AS zero_zipcodes,
    SUM(`Customer Zipcode` IS NULL) AS null_zipcodes
FROM dataco_orders;



-- SECTION 3: DATE CLEANING AND VALIDATION
-- 3.1 Add properly formatted datetime columns.

ALTER TABLE dataco_orders
ADD COLUMN order_datetime DATETIME,
ADD COLUMN shipping_datetime DATETIME;


-- 3.2 Convert order date text into DATETIME.

UPDATE dataco_orders
SET order_datetime =
    CASE
        WHEN `order date (DateOrders)` LIKE '%/%'
        THEN STR_TO_DATE(
            `order date (DateOrders)`,
            '%m/%d/%Y %H:%i'
        )

        WHEN `order date (DateOrders)` LIKE '%-%'
        THEN STR_TO_DATE(
            `order date (DateOrders)`,
            '%m-%d-%Y %H:%i'
        )
    END;


-- 3.3 Convert shipping date text into DATETIME.

UPDATE dataco_orders
SET shipping_datetime =
    CASE
        WHEN `shipping date (DateOrders)` LIKE '%/%'
        THEN STR_TO_DATE(
            `shipping date (DateOrders)`,
            '%m/%d/%Y %H:%i'
        )

        WHEN `shipping date (DateOrders)` LIKE '%-%'
        THEN STR_TO_DATE(
            `shipping date (DateOrders)`,
            '%m-%d-%Y %H:%i'
        )
    END;


-- 3.4 Validate date conversion.

SELECT
    COUNT(*) AS total_records,
    SUM(order_datetime IS NULL) AS missing_order_dates,
    SUM(shipping_datetime IS NULL) AS missing_shipping_dates,
    MIN(order_datetime) AS earliest_order,
    MAX(order_datetime) AS latest_order
FROM dataco_orders;


-- 3.5 Compare original shipping duration with calculated duration.

SELECT
    `Order Id`,
    order_datetime,
    shipping_datetime,
    `Days for shipping (real)`,
    DATEDIFF(
        shipping_datetime,
        order_datetime
    ) AS calculated_days
FROM dataco_orders
LIMIT 10;


-- 3.6 Validate shipping duration across all records.

SELECT
    COUNT(*) AS total_records,
    SUM(
        `Days for shipping (real)` <>
        DATEDIFF(shipping_datetime, order_datetime)
    ) AS mismatched_records
FROM dataco_orders;



-- SECTION 4: UNDERSTANDING DATA GRANULARITY

-- 4.1 Identify rows, unique orders, and unique order items.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Order Id`) AS unique_orders,
    COUNT(DISTINCT `Order Item Id`) AS unique_order_items
FROM dataco_orders;


-- 4.2 Check whether profit varies across items within an order.

SELECT
    `Order Id`,
    COUNT(*) AS item_count,
    MIN(`Order Profit Per Order`) AS minimum_profit,
    MAX(`Order Profit Per Order`) AS maximum_profit
FROM dataco_orders
GROUP BY `Order Id`
HAVING COUNT(*) > 1
LIMIT 10;


-- 4.3 Inspect individual items within a sample order.

SELECT
    `Order Id`,
    `Order Item Id`,
    `Order Item Product Price`,
    `Order Item Quantity`,
    `Order Item Total`,
    `Order Profit Per Order`,
    `Benefit per order`
FROM dataco_orders
WHERE `Order Id` = 2;


-- 4.4 Verify consistency between the two profit fields.

SELECT
    COUNT(*) AS total_records,
    SUM(
        ABS(
            `Order Profit Per Order` - `Benefit per order`
        ) > 0.01
    ) AS mismatched_profit_records
FROM dataco_orders;



-- SECTION 5: OVERALL BUSINESS PERFORMANCE
-- 5.1 Calculate baseline business KPIs.

SELECT
    COUNT(*) AS total_order_items,

    COUNT(DISTINCT `Order Id`) AS total_orders,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage,

    ROUND(
        AVG(`Order Item Discount Rate`) * 100,
        2
    ) AS average_discount_percentage

FROM dataco_orders;



-- SECTION 6: DISCOUNT VS. PROFITABILITY ANALYSIS
-- 6.1 Group orders into discount bands and compare profitability.

SELECT
    CASE
        WHEN `Order Item Discount Rate` = 0
            THEN '0% - No discount'

        WHEN `Order Item Discount Rate` <= 0.05
            THEN '0-5%'

        WHEN `Order Item Discount Rate` <= 0.10
            THEN '5-10%'

        WHEN `Order Item Discount Rate` <= 0.20
            THEN '10-20%'

        ELSE 'Above 20%'
    END AS discount_band,

    COUNT(*) AS total_items,

    ROUND(
        AVG(`Order Item Discount Rate`) * 100,
        2
    ) AS average_discount_percentage,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY discount_band

ORDER BY MIN(`Order Item Discount Rate`);



-- SECTION 7: CATEGORY PROFITABILITY ANALYSIS
-- 7.1 Identify categories with the lowest aggregate profit.

SELECT
    `Category Name`,

    COUNT(*) AS total_items,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY `Category Name`

ORDER BY total_profit ASC;


-- SECTION 8: PRODUCT-LEVEL LOSS ANALYSIS
-- 8.1 Identify products with negative aggregate profit.

SELECT
    `Product Name`,
    `Category Name`,

    COUNT(*) AS total_items,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY
    `Product Name`,
    `Category Name`

HAVING SUM(`Order Profit Per Order`) < 0

ORDER BY total_profit ASC

LIMIT 15;



-- SECTION 9: DELIVERY STATUS VS. PROFITABILITY
-- 9.1 Compare profitability across delivery statuses.

SELECT
    `Delivery Status`,

    COUNT(*) AS total_items,

    COUNT(DISTINCT `Order Id`) AS total_orders,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY `Delivery Status`

ORDER BY total_items DESC;



-- SECTION 10: SHIPPING MODE PERFORMANCE
-- 10.1 Compare late-delivery rates and profitability by shipping mode.

SELECT
    `Shipping Mode`,

    COUNT(*) AS total_items,

    SUM(
        CASE
            WHEN `Delivery Status` = 'Late delivery'
            THEN 1
            ELSE 0
        END
    ) AS late_items,

    ROUND(
        SUM(
            CASE
                WHEN `Delivery Status` = 'Late delivery'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY `Shipping Mode`

ORDER BY late_delivery_percentage DESC;



-- SECTION 11: REGIONAL PROFITABILITY ANALYSIS
-- 11.1 Compare profitability across markets and regions.

SELECT
    Market,
    `Order Region`,

    COUNT(*) AS total_items,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY
    Market,
    `Order Region`

ORDER BY profit_margin_percentage ASC;



-- SECTION 12: CUSTOMER SEGMENT PROFITABILITY
-- 12.1 Compare profitability across customer segments.

SELECT
    `Customer Segment`,

    COUNT(*) AS total_items,

    COUNT(DISTINCT `Order Id`) AS total_orders,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(`Order Profit Per Order`),
        2
    ) AS total_profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage

FROM dataco_orders

GROUP BY `Customer Segment`

ORDER BY profit_margin_percentage ASC;

