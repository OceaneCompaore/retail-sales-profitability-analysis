-- ============================================================
-- 01_data_audit.sql
-- Retail Sales & Profitability Analysis
--
-- Purpose:
-- Perform an initial quality assessment of the raw Orders,
-- Returns, and People datasets before cleaning and analysis.
-- ============================================================


-- ============================================================
-- 1. ORDERS DATASET OVERVIEW
-- ============================================================

-- Preview the first 20 rows of the Orders dataset to inspect
-- the structure, column names, and imported values.
SELECT *
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
LIMIT 20;


-- Count the total number of rows in the Orders dataset.
SELECT
    COUNT(*) AS total_rows
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- Compare total rows with unique Row IDs and unique Order IDs.
-- Row ID should uniquely identify each transaction line.
-- Order ID may appear multiple times when one order contains
-- several products.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Row ID`) AS unique_row_ids,
    COUNT(DISTINCT `Order ID`) AS unique_orders
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- Check for duplicate Row IDs.
-- No returned rows means that Row ID values are unique.
SELECT
    `Row ID`,
    COUNT(*) AS occurrences
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
GROUP BY `Row ID`
HAVING COUNT(*) > 1;


-- ============================================================
-- 2. MISSING VALUES
-- ============================================================

-- Check important fields in the Orders dataset for missing values.
SELECT
    COUNTIF(`Order ID` IS NULL) AS missing_order_id,
    COUNTIF(`Order Date` IS NULL) AS missing_order_date,
    COUNTIF(`Customer ID` IS NULL) AS missing_customer_id,
    COUNTIF(Segment IS NULL) AS missing_segment,
    COUNTIF(Region IS NULL) AS missing_region,
    COUNTIF(Category IS NULL) AS missing_category,
    COUNTIF(`Sub-Category` IS NULL) AS missing_subcategory,
    COUNTIF(Sales IS NULL) AS missing_sales,
    COUNTIF(Quantity IS NULL) AS missing_quantity,
    COUNTIF(Discount IS NULL) AS missing_discount,
    COUNTIF(Profit IS NULL) AS missing_profit
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- ============================================================
-- 3. DATE VALIDATION
-- ============================================================

-- Inspect the minimum and maximum Order Date and Ship Date values
-- to understand the time range and identify unusual imported dates.
SELECT
    MIN(`Order Date`) AS earliest_order,
    MAX(`Order Date`) AS latest_order,
    MIN(`Ship Date`) AS earliest_ship_date,
    MAX(`Ship Date`) AS latest_ship_date
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- Check whether any Ship Date occurs before its corresponding Order Date.
SELECT
    COUNT(*) AS invalid_shipping_dates
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
WHERE `Ship Date` < `Order Date`;


-- ============================================================
-- 4. NUMERIC FIELD VALIDATION
-- ============================================================

-- Review the range and average of key numeric fields to identify
-- unusual values and better understand the raw data.
SELECT
    MIN(Sales) AS min_sales,
    MAX(Sales) AS max_sales,
    AVG(Sales) AS avg_sales,

    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,

    MIN(Discount) AS min_discount,
    MAX(Discount) AS max_discount,

    MIN(Profit) AS min_profit,
    MAX(Profit) AS max_profit,
    AVG(Profit) AS avg_profit
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- Check for invalid numeric values.
-- Sales should not be negative.
-- Quantity should be greater than zero.
-- Discount should remain between 0 and 1.
SELECT
    COUNTIF(Sales < 0) AS negative_sales,
    COUNTIF(Quantity <= 0) AS invalid_quantity,
    COUNTIF(Discount < 0 OR Discount > 1) AS invalid_discount
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;


-- ============================================================
-- 5. CATEGORICAL FIELD VALIDATION
-- ============================================================

-- Review distinct customer segments.
SELECT DISTINCT Segment
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
ORDER BY Segment;


-- Review distinct regions.
SELECT DISTINCT Region
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
ORDER BY Region;


-- Review distinct product categories.
SELECT DISTINCT Category
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
ORDER BY Category;


-- Review distinct product sub-categories.
SELECT DISTINCT `Sub-Category`
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw`
ORDER BY `Sub-Category`;


-- ============================================================
-- 6. RETURNS DATASET AUDIT
-- ============================================================

-- Preview the first 20 rows of the Returns dataset.
SELECT *
FROM `braided-rush-482613-i6.retail_sales_profitability.returns_raw`
LIMIT 20;


-- Validate the Returns dataset by comparing total rows with
-- unique returned Order IDs and checking for missing Order IDs.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Order ID`) AS unique_returned_orders,
    COUNTIF(`Order ID` IS NULL) AS missing_order_ids
FROM `braided-rush-482613-i6.retail_sales_profitability.returns_raw`;


-- Check for duplicate Order IDs in the Returns dataset.
-- No returned rows means each returned order appears only once.
SELECT
    `Order ID`,
    COUNT(*) AS occurrences
FROM `braided-rush-482613-i6.retail_sales_profitability.returns_raw`
GROUP BY `Order ID`
HAVING COUNT(*) > 1;


-- Review the values stored in the Returned field.
SELECT
    Returned,
    COUNT(*) AS records
FROM `braided-rush-482613-i6.retail_sales_profitability.returns_raw`
GROUP BY Returned;


-- ============================================================
-- 7. PEOPLE DATASET AUDIT
-- ============================================================

-- Preview the full People dataset.
-- This table contains only a small number of records.
SELECT *
FROM `braided-rush-482613-i6.retail_sales_profitability.people_raw`;


-- The People file was imported without recognizing its header row.
-- BigQuery therefore created generic field names:
-- string_field_0 = Regional Manager
-- string_field_1 = Region
--
-- This audit checks the total number of rows, distinct region values,
-- and missing values before cleaning.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT string_field_1) AS unique_regions,
    COUNTIF(string_field_1 IS NULL) AS missing_regions,
    COUNTIF(string_field_0 IS NULL) AS missing_people
FROM `braided-rush-482613-i6.retail_sales_profitability.people_raw`;


-- ============================================================
-- 8. RELATIONAL INTEGRITY CHECKS
-- ============================================================

-- Check whether any returned Order IDs do not exist in Orders.
-- A result of 0 confirms that every returned order matches an
-- order in the main Orders dataset.
SELECT
    COUNT(*) AS unmatched_returns
FROM `braided-rush-482613-i6.retail_sales_profitability.returns_raw` r
LEFT JOIN `braided-rush-482613-i6.retail_sales_profitability.orders_raw` o
    ON r.`Order ID` = o.`Order ID`
WHERE o.`Order ID` IS NULL;


-- Check whether any regions in Orders do not match the People dataset.
-- string_field_1 is used because Region was not recognized as a header
-- when the People file was imported.
--
-- No returned rows confirms that all regions in Orders are represented
-- in the People dataset.
SELECT DISTINCT
    o.Region
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_raw` o
LEFT JOIN `braided-rush-482613-i6.retail_sales_profitability.people_raw` p
    ON o.Region = p.string_field_1
WHERE p.string_field_1 IS NULL;