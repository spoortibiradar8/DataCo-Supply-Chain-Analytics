# DataCo Supply Chain & Profitability Analysis

## Project Overview

An end-to-end data analytics project focused on analyzing sales performance, profitability, discount patterns, and delivery operations using the DataCo Supply Chain dataset.

The project uses SQL for data validation and business analysis, and Microsoft Power BI to build an interactive dashboard that helps identify profitability issues and support data-driven business decisions.

## Business Problem

Businesses operating in supply chains need to understand not only how much revenue they generate, but also how much profit they retain.

High discounts, loss-making products, and delivery inefficiencies can affect profitability even when overall sales appear strong.

This project investigates the DataCo dataset to answer key business questions:

- How much revenue and profit does the business generate?
- What is the overall profit margin?
- How do discounts relate to profitability?
- Which product categories and markets generate lower profits?
- Which products generate negative profit?
- How does sales performance change over time?
- What delivery patterns should management investigate?

## Project Objectives

1. Analyze overall sales, profit, order volume, and profitability.
2. Evaluate discount patterns and their relationship with profit.
3. Identify loss-making products and categories.
4. Compare profitability across different markets.
5. Analyze monthly sales trends.
6. Examine delivery performance and potential operational inefficiencies.
7. Build an interactive Power BI dashboard with business recommendations.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL | Data validation, cleaning, aggregation, and analysis |
| Microsoft Power BI | Interactive dashboards and visualizations |
| Power Query | Data transformation and date correction |
| DAX | Measures and calculated columns |
| Excel | Initial data inspection and preparation |

## Dataset Overview

- Dataset: DataCo Supply Chain Dataset
- Source table: `dataco_orders`
- Database: `hidden_cost_growth`
- Total records: 180,519
- Distinct orders: 65,752

The dataset contains order, product, customer, sales, discount, profit, market, and delivery-related information.

## Data Cleaning & Preparation

The following preparation activities were performed:

1. Inspected the dataset and reviewed its columns and data types.
2. Validated the total record count and distinct order count.
3. Identified inconsistent date formats in the order date column.
4. Converted the order date into a consistent Date/Time format in Power Query.
5. Validated the parsed dates and confirmed zero invalid date rows in the monthly SQL validation.
6. Prepared the data for monthly sales analysis and dashboard reporting.

### Date Standardization in MySQL

The source contained two date formats:

- `MM/DD/YYYY HH:MM`
- `DD-MM-YYYY HH:MM`

The following SQL expression handles both formats:

```sql
COALESCE(
    STR_TO_DATE(
        `order date (DateOrders)`,
        '%m/%d/%Y %H:%i'
    ),
    STR_TO_DATE(
        `order date (DateOrders)`,
        '%d-%m-%Y %H:%i'
    )
)
```

This expression converts both formats into a standard MySQL date/time value.

## SQL Analysis

SQL was used to validate the dataset, calculate business metrics, and prepare monthly sales analysis.

### 1. Total Records

```sql
SELECT COUNT(*) AS total_records
FROM dataco_orders;
```

### 2. Distinct Orders

```sql
SELECT COUNT(DISTINCT `Order Id`) AS total_orders
FROM dataco_orders;
```

### 3. Total Sales

```sql
SELECT SUM(Sales) AS total_sales
FROM dataco_orders;
```

### 4. Total Profit

```sql
SELECT SUM(`Order Profit Per Order`) AS total_profit
FROM dataco_orders;
```

### 5. Monthly Sales Analysis

```sql
SELECT
    DATE_FORMAT(
        COALESCE(
            STR_TO_DATE(
                `order date (DateOrders)`,
                '%m/%d/%Y %H:%i'
            ),
            STR_TO_DATE(
                `order date (DateOrders)`,
                '%d-%m-%Y %H:%i'
            )
        ),
        '%Y-%m'
    ) AS month,
    SUM(Sales) AS monthly_sales,
    SUM(`Order Profit Per Order`) AS monthly_profit
FROM dataco_orders
WHERE COALESCE(
    STR_TO_DATE(
        `order date (DateOrders)`,
        '%m/%d/%Y %H:%i'
    ),
    STR_TO_DATE(
        `order date (DateOrders)`,
        '%d-%m-%Y %H:%i'
    )
) IS NOT NULL
GROUP BY month
ORDER BY month;
```

## Key Business Metrics

| Metric | Result |
|---|---:|
| Total Records | 180,519 |
| Distinct Orders | 65,752 |
| Total Sales | 36,784,735.01 |
| Total Profit | 3,966,902.97 |
| Profit Margin | 10.78% |
| Average Discount | 10.17% |

*Figures are based on the project's current validation results.*

## Power BI Dashboard

The Power BI report is organized into three analytical pages.

### Page 1 – Business Overview

Focuses on the overall business performance.

Key metrics and visuals:
- Total Sales
- Total Profit
- Profit Margin
- Average Discount
- Order performance
- Monthly Sales Trend (2015–2018)

### Page 2 – Delivery & Operational Performance

Focuses on order fulfillment and delivery performance.

The analysis examines:
- Delivery status
- Late delivery patterns
- On-time delivery performance
- Operational trends and potential areas for improvement

### Page 3 – Where the Leakage Is

Focuses on identifying potential profitability issues.

Key visuals:
- Profitability KPIs
- Profit Margin by Discount Band
- Profit by Category
- Profit by Market
- Top 10 Loss-Making Products
- Market and Customer Segment slicers
- Business recommendations

## Key Insights

The following baseline findings have been established:

1. **Revenue and profitability:** The dataset contains approximately 36.78 million in sales and 3.97 million in profit.
2. **Profit margin:** The overall profit margin is approximately 10.78%.
3. **Discount patterns:** The average discount is approximately 10.17%.
4. **Loss-making products:** Product-level profit analysis can help identify items requiring pricing and cost review.
5. **Time-based performance:** Monthly sales analysis covers January 2015 through December 2018.

Category, market, discount-band, and delivery findings should be finalized using the validated dashboard results rather than assumed in advance.

## Business Recommendations

1. **Review discount strategies:** Investigate products receiving high discounts, particularly where profitability is low or negative.
2. **Evaluate loss-making products:** Review pricing, shipping expenses, and promotional costs for products generating negative profit.
3. **Improve delivery operations:** Investigate late deliveries and identify operational causes that may affect customer experience and business costs.

## Project Workflow

```text
DataCo Dataset
      |
      v
Data Inspection & Cleaning
      |
      v
MySQL Data Validation
      |
      v
SQL Business Analysis
      |
      v
Power Query Transformation
      |
      v
DAX Measures & Calculated Columns
      |
      v
Power BI Dashboard
      |
      v
Business Insights & Recommendations
```

## Conclusion

This project demonstrates an end-to-end data analytics workflow, combining SQL-based data validation and analysis with Power BI dashboard development.

It transforms raw supply chain data into business-focused insights about sales, profitability, discount patterns, product performance, and delivery operations.

The objective is to help decision-makers understand where revenue is generated, where profitability may be affected, and which areas deserve further investigation.

## Skills Demonstrated

- SQL querying and aggregation
- Data cleaning and validation
- Date/time standardization
- Business KPI development
- Power Query transformations
- DAX measures and calculated columns
- Interactive Power BI dashboards
- Data visualization
- Business analysis and recommendations

---

**Project Category:** Data Analytics | Business Intelligence | Supply Chain Analytics

**Tools:** MySQL | Microsoft Power BI | Power Query | DAX
