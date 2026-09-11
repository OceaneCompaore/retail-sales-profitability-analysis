# Data Analysis Process

## Project Workflow

This document summarizes the end-to-end data preparation and analysis process used for the **Retail Sales & Profitability Analysis** project.

The workflow followed six main stages:

**Excel Preparation → BigQuery Import → Data Audit → Data Cleaning → SQL Analysis → Looker Studio Visualization**

---

## 1. Initial Data Preparation

The project started with the Tableau Sample Superstore Excel workbook.

The workbook contained three worksheets:

- **Orders**
- **Returns**
- **People**

Before importing the data into BigQuery, the worksheets were separated into individual files.

Some column names containing special characters were also adjusted for compatibility with BigQuery:

- `Country/Region` → `Country_Region`
- `State/Province` → `State_Province`

The three datasets were then imported into BigQuery as:

- `orders_raw`
- `returns_raw`
- `people_raw`

The original raw tables were preserved throughout the project.

---

## 2. Data Audit

Before cleaning the data, I performed an initial SQL audit to understand the datasets and identify potential data-quality issues.

The Orders audit included:

- Dataset preview
- Total row count
- Unique Row ID validation
- Unique Order ID count
- Duplicate Row ID detection
- Missing-value checks
- Date-range inspection
- Shipping-date validation
- Numeric-range validation
- Invalid sales, quantity, and discount checks
- Categorical-value inspection

The Orders dataset contained **10,194 transaction rows representing 5,111 unique orders**.

The Returns dataset was separately checked for:

- Total records
- Unique returned Order IDs
- Missing Order IDs
- Duplicate Order IDs
- Returned-field values

Relational integrity was also tested by checking whether all returned Order IDs existed in the Orders dataset.

The People dataset required additional attention because its header row had been imported as data and BigQuery assigned generic column names.

---

## 3. Data Cleaning

Cleaning was performed in BigQuery while preserving the original raw tables.

### Orders

A new `orders_clean` table was created.

The main transformations included:

- Converting Excel serial numbers into SQL `DATE` values for Order Date and Ship Date
- Renaming `Country_Region` to `Country`
- Renaming `State_Province` to `State`
- Preserving the remaining analytical fields

After transformation, validation queries confirmed that all **10,194 rows** were preserved.

Shipping dates were also checked to ensure that no shipment occurred before its corresponding order date.

### People

A `people_clean` table was created to correct the original import issue.

The generic fields were renamed:

- `string_field_0` → `Regional_Manager`
- `string_field_1` → `Region`

The incorrectly imported header row was removed.

The resulting table contained the expected regional manager records.

### Returns

A separate cleaned Returns table was not required.

The audit found no duplicate returned Order IDs or unmatched return records requiring correction, so `returns_raw` was retained for subsequent analysis.

---

## 4. Business Analysis

After cleaning and validation, SQL was used to analyze business performance.

The analysis covered:

### Overall Performance

Key performance indicators included:

- Total sales
- Total profit
- Total quantity sold
- Total orders
- Total customers
- Overall profit margin

### Performance Over Time

Annual and monthly sales, profit, and profit margins were analyzed to evaluate changes in business performance over time.

### Product Performance

Category and sub-category performance was analyzed using:

- Sales
- Profit
- Profit margin

Loss-making sub-categories were identified separately.

### Discount Analysis

Profitability was compared across discount levels to investigate the relationship between discounting and business performance.

Average discount levels were also compared across product sub-categories.

### Regional Performance

Sales, profit, and profit margins were compared across regions.

The cleaned People dataset was joined with Orders to associate regional managers with regional business performance.

### Customer Segments

Customer segments were compared based on:

- Number of customers
- Number of orders
- Sales
- Profit
- Profit margin

### Returns

Orders were classified as either:

- Returned
- Not Returned

The two groups were compared using order counts, sales, profit, and profit margin.

Because the dataset does not provide refund costs, restocking expenses, or other return-related costs, the analysis does not attempt to estimate the true financial impact of returns.

---

## 5. Dashboard Preparation

Rather than connecting every dashboard visual directly to transaction-level calculations, dedicated aggregate tables were created in BigQuery.

The dashboard tables included:

- `dashboard_yearly_performance`
- `dashboard_region`
- `dashboard_segment`
- `dashboard_subcategory`
- `dashboard_discount`
- `dashboard_returns`

This approach simplified the Looker Studio data model and helped maintain consistent calculations between the SQL analysis and dashboard.

---

## 6. Data Visualization

The final dashboard was developed in **Looker Studio**.

It contains two pages.

### Executive Overview

The first page summarizes overall business performance through:

- Total Sales
- Total Profit
- Profit Margin
- Total Orders
- Sales & Profit by Year
- Profit by Region
- Sales by Customer Segment

### Profitability Analysis

The second page provides deeper profitability analysis through:

- Profit by Sub-Category
- Profit Margin by Discount Level
- Orders by Return Status

The final dashboard was reviewed against the SQL analysis to ensure that the visualized results were consistent with the calculated business metrics.

---

## Project Files

The complete SQL workflow is available in the repository:

- `01_data_audit.sql` — initial data-quality assessment
- `02_data_cleaning.sql` — data transformation and validation
- `03_business_analysis.sql` — business analysis
- `04_dashboard_preparation.sql` — aggregated tables used for visualization
