DataCo Supply Chain: Profit Leakage Analysis
An end-to-end analysis of sales, profit, discounting, and delivery performance using MySQL and Power BI.

This project evaluates revenue retention, margin erosion, and fulfillment performance across 180,519 transaction records from the DataCo Smart Supply Chain dataset covering January 2015 to January 2018. By combining MySQL validation, Power Query transformations, DAX modeling, and an interactive three-page Power BI dashboard, this analysis pinpoints structural profit leakage across discounting tiers, geographic markets, product portfolios, and fulfillment operations.

Business Problem
A business can report strong sales and still lose money through heavy discounting, loss-making products, and delivery inefficiencies. This project examines the DataCo Supply Chain dataset to find where profit is retained and where it leaks.

Key business questions addressed:

How much revenue and profit does the business generate, and what is the overall profit margin?
How do discounts relate to profitability?
Which markets, customer segments, and product categories contribute most and least profit?
Which products generate negative profit?
How does sales performance change over time?
How reliable is delivery, and which shipping modes carry the most late-delivery risk?
Objectives
Audit gross revenue, net profitability, and baseline margin performance across all recorded transactions.
Analyze the correlation between discount levels and margin degradation.
Evaluate profit contribution across geographic markets, customer segments, and product categories.
Isolate products and order lines with negative profit to quantify profit leakage.
Track monthly sales and profit trends between January 2015 and January 2018.
Assess delivery reliability across shipping modes and identify fulfillment risk factors.
Design an interactive three-page Power BI report with clear operational drill-downs.
Tools and Technologies
Tool	Purpose
MySQL	Data validation, cleaning, aggregation, and analysis
Power Query	Date correction and data transformation
DAX	Measures and calculated columns
Microsoft Power BI	Interactive three-page dashboard
Excel	Initial data inspection and preparation
Dataset
Source: DataCo Smart Supply Chain dataset (Public Source on Kaggle)
Database: hidden_cost_growth
Table: dataco_orders
Grain: One row per order line item
Records: 180,519
Distinct orders: 65,752
Distinct products: 118
Order date range: 1 January 2015 to 31 January 2018
The original dataset underwent data cleaning and preprocessing as part of this analysis. Due to GitHub's file size limitations, a reduced version containing fewer records was uploaded to the repository. The complete dataset is available from the original Kaggle source.

Data Preparation
The data preparation sequence followed these steps in order:

Inspected columns and data types.
Validated total record count and distinct order count.
Found two inconsistent date formats in the order date column: MM/DD/YYYY HH:MM and DD-MM-YYYY HH:MM.
Standardised dates in MySQL using the expression below, and in Power Query for the Power BI model.
Confirmed zero invalid date rows after parsing.
Created calculated columns in Power BI: Month Start, Month_Year, Month_Sort, and Discount Band (Low below 10 percent, Medium 10 to below 20 percent, High 20 percent and above).
Date standardization expression:

COALESCE(
    STR_TO_DATE(`order date (DateOrders)`, '%m/%d/%Y %H:%i'),
    STR_TO_DATE(`order date (DateOrders)`, '%d-%m-%Y %H:%i')
)
SQL Analysis
The following queries were executed in MySQL to audit baseline values and extract trend data:

-- Total records
SELECT COUNT(*) AS total_records FROM dataco_orders;

-- Distinct orders
SELECT COUNT(DISTINCT `Order Id`) AS total_orders FROM dataco_orders;

-- Total sales
SELECT SUM(Sales) AS total_sales FROM dataco_orders;

-- Total profit
SELECT SUM(`Order Profit Per Order`) AS total_profit FROM dataco_orders;

-- Monthly sales and profit
SELECT
    DATE_FORMAT(
        COALESCE(
            STR_TO_DATE(`order date (DateOrders)`, '%m/%d/%Y %H:%i'),
            STR_TO_DATE(`order date (DateOrders)`, '%d-%m-%Y %H:%i')
        ), '%Y-%m') AS month,
    SUM(Sales) AS monthly_sales,
    SUM(`Order Profit Per Order`) AS monthly_profit
FROM dataco_orders
WHERE COALESCE(
        STR_TO_DATE(`order date (DateOrders)`, '%m/%d/%Y %H:%i'),
        STR_TO_DATE(`order date (DateOrders)`, '%d-%m-%Y %H:%i')
      ) IS NOT NULL
GROUP BY month
ORDER BY month;
DAX Measures
The analytical model relies on the following core DAX measures:

Measure	Definition
Total Sales	SUM(DataCo_Orders[Sales])
Total_Profit	SUMX(DataCo_Orders, DataCo_Orders[Order Profit Per Order])
Profit_Margin	DIVIDE([Total_Profit], [Total Sales], 0)
Total_Orders	DISTINCTCOUNT(DataCo_Orders[Order Id])
Avg_Discount_Percentage	AVERAGE(DataCo_Orders[Order Item Discount Rate])
Late_Orders	Distinct orders where Late_delivery_risk = 1
On_Time_Orders	Distinct orders where Late_delivery_risk = 0
Late_Delivery_Percentage	Late_Orders divided by Total_Orders
Loss Order %	Distinct orders with at least one line where Order Profit Per Order < 0, divided by Total_Orders
Verified Baseline Metrics
The following headline metrics were recomputed directly from the 180,519-row table with no slicer filters applied:

Metric	Value
Total sales	36,784,735.01
Total profit	3,966,902.97
Profit margin (profit divided by gross Sales)	10.78%
Average discount rate	10.17%
Distinct orders	65,752
Late orders	36,048 (54.82% of orders)
On-time orders	29,704 (45.18% of orders)
Methodology notes:

The margin is calculated on gross Sales, which is before discount. Calculated on Order Item Total (net of discount, 33,054,402.38) the same profit gives 12.00%. The dashboard uses gross Sales as its basis.
On_Time_Orders includes 2,855 orders with status "Shipping canceled", because they carry Late_delivery_risk = 0.
24,649 distinct orders (37.49%) contain at least one line item with negative profit. Across individual line items, 18.71% of order lines have negative profit. The dashboard measure Loss Order % uses the first definition (distinct orders with at least one loss-making line).
Profit by Market
Market	Sales	Profit
Europe	10,872,396.80	1,169,442.96
LATAM	10,277,612.84	1,123,321.61
Pacific Asia	8,273,743.74	857,753.44
USCA	5,066,528.71	564,313.78
Africa	2,294,452.93	252,071.18
Profit by Customer Segment
Segment	Sales	Profit
Consumer	19,095,790.16	2,073,487.67
Corporate	11,168,406.84	1,202,574.96
Home Office	6,520,538.02	690,840.34
Orders by Delivery Status
Delivery status	Distinct orders
Late delivery	36,048
Advance shipping	15,127
Shipping on time	11,722
Shipping canceled	2,855
Loss-Making Products
Only 3 of 118 products have negative total profit:

Product	Total profit	Total sales	Orders
SOLE E35 Elliptical	-965.12	29,999.85	15
Bushnell Pro X7 Jolt Slope Rangefinder	-255.95	6,599.89	8
SOLE E25 Elliptical	-169.56	9,999.90	10
The remaining products in the ten lowest-profit list are profitable but low-margin in absolute terms (for example GoPro HERO3+ Black Edition Camera at 245.63 and Diamondback Girls' Clarity 24 Hybrid Bike at 284.42). The dashboard chart displays the "10 Lowest-Profit Products" and does not represent all ten as loss-making.

Dashboard (with screenshots)
The Power BI dashboard consists of three analytical pages.

Page 1: Overview and Profit
Page 1: Overview and Profit

Page 1 contents: Total Sales, Total Profit, Profit Margin, Avg Discount %, Total Orders, Late Delivery % cards; Monthly Sales Trend; Profit by Market; Profit by Category; Profit by Customer Segment; Top 10 Products by Sales; 10 Lowest-Profit Products; Market and Customer Segment slicers.

Page 2: Discounts and Delivery
Page 2: Discounts and Delivery

Page 2 contents: Avg Discount %, Late Delivery %, Late Orders, On-time Orders, Total Orders cards; Discount vs Profit scatter; Late Delivery % by Shipping Mode; Orders by Delivery Status; Orders by Shipping Mode.

Page 3: Where the Leakage Is
Page 3: Where the Leakage Is

Page 3 contents: Total Profit, Loss Order %, Profit Margin cards; loss-making products table (displaying products with negative total profit, which currently returns 3 products); Profit Margin by Discount Band; Profit by Market; Profit by Category.

How to Open the Dashboard
Open powerbi/DataCo_Supply_Chain_Analysis.pbix in Power BI Desktop (current version). All slicers should be cleared to see company-wide totals.

Key Insights
Sales of 36.78 million produced 3.97 million profit, a 10.78 percent margin on gross sales.
Europe and LATAM together contribute about 58 percent of profit; Africa contributes the least, at about 6 percent.
The Consumer segment contributes about 52 percent of profit.
More than half of orders (54.82 percent) are flagged as late deliveries, which is the largest operational concern in the data.
Only 3 of 118 products lose money overall, and the combined loss is small (1,390.63). The more significant leakage is the 37.49 percent of orders that contain at least one loss-making line.
Discount-band findings: profit margin falls from 11.7% (Low, below 10%) to 10.2% (Medium, 10% to below 20%) to 9.0% (High, 20% and above).
Shipping-mode late rates: First Class 95.3%, Second Class 76.7%, Same Day 46.1%, Standard Class 38.1%.
Business Recommendations
Review discount policy where profit margin falls below the overall average, using the Discount Band chart.
Reprice or review costs for the three loss-making products, starting with SOLE E35 Elliptical.
Investigate the causes of the 54.82 percent late-delivery rate by shipping mode before adjusting shipping promises.
Investigate why more than a third of orders include a loss-making line, and whether specific discount levels or categories drive it.
Limitations
Profit margin uses gross sales as the denominator; a net-sales margin is 12.00 percent.
On_Time_Orders includes cancelled shipments.
Loss Order % flags an order if any single line is negative, so it overstates order-level losses compared with a net-order definition.
The dataset is a public sample; results describe this dataset only.
Repository Structure
DataCo-Supply-Chain-Analytics/
|-- README.md
|-- datasets/
|   `-- raw/
|       |-- DataCoSupplyChainDataset.csv
|       `-- DescriptionDataCoSupplyChain.csv
|-- excel/
|   |-- DataCo_Scenario_Analysis.xlsx
|   |-- DataCo_cleaned.xlsx
|   `-- Pivot_Analysis.xlsx
|-- powerbi/
|   |-- 01_overview_profit.png
|   |-- 02_discounts_delivery.png
|   |-- 03_leakage.png
|   `-- DataCo_Supply_Chain_Analysis.pbix
`-- sql/
    `-- DataCo_Profit_Leakage_Analysis.sql
Skills Demonstrated
SQL data validation, aggregation, and date-time standardization
Relational data auditing and baseline verification
ETL and data cleaning in Power Query
DAX measure and calculated column implementation
Interactive three-page dashboard design in Microsoft Power BI
Supply chain profit leakage identification and discount margin analysis
Fulfillment reliability analysis and operational performance auditing
Author and Contact
Author: Spoorti
GitHub: github.com/spoortibiradar8
Repository: DataCo-Supply-Chain-Analytics
Category: Data Analytics, Business Intelligence, Supply Chain Analytics
