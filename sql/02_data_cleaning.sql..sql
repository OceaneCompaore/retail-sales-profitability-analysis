-- DATA CLEANING
-- Retail Sales and Profitability Analysis
-- =====================================================

-- This script prepares the raw datasets for analysis while
-- preserving the original raw tables.


-- =====================================================
-- 1. CLEAN ORDERS DATA
-- =====================================================

-- Create an analysis-ready copy of the Orders table.
-- Convert Order Date and Ship Date from Excel serial numbers
-- into proper SQL DATE values.
-- Rename Country_Region to Country and State_Province to State
-- for clearer and more consistent field names.

CREATE OR REPLACE TABLE
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean` AS

SELECT
  `Row ID`,
  `Order ID`,

  DATE_ADD(DATE '1899-12-30', INTERVAL CAST(`Order Date` AS INT64) DAY)
    AS `Order Date`,

  DATE_ADD(DATE '1899-12-30', INTERVAL CAST(`Ship Date` AS INT64) DAY)
    AS `Ship Date`,

  `Ship Mode`,
  `Customer ID`,
  `Customer Name`,
  Segment,
  Country_Region AS Country,
  City,
  State_Province AS State,
  `Postal Code`,
  Region,
  `Product ID`,
  Category,
  `Sub-Category`,
  `Product Name`,
  Sales,
  Quantity,
  Discount,
  Profit

FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_raw`;

  -- =====================================================
-- 2. VALIDATE CLEAN ORDERS DATA
-- =====================================================
-- Confirm that all 10,194 original rows were preserved
-- and verify the date range after converting the date fields.

  SELECT
  COUNT(*) AS total_rows,
  MIN(`Order Date`) AS earliest_order,
  MAX(`Order Date`) AS latest_order,
  MIN(`Ship Date`) AS earliest_shipping,
  MAX(`Ship Date`) AS latest_shipping
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_clean`; 

-- Check for invalid shipping dates.
-- A shipping date should never occur before its corresponding order date.

SELECT COUNT(*) AS ship_before_order
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
WHERE `Ship Date` < `Order Date`; 

-- Perform a final sample check to confirm that the renamed geographic
-- fields, converted dates, and numerical values display correctly.

SELECT
  Country,
  State,
  `Order Date`,
  `Ship Date`,
  Sales,
  Profit
FROM `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
LIMIT 10; 

-- =====================================================
-- 3. CLEAN REGIONAL MANAGER DATA
-- =====================================================
-- Create a clean People table.
-- The original CSV import treated the header as a data row and assigned
-- generic field names (string_field_0 and string_field_1).
-- Rename the fields to Regional_Manager and Region and remove the
-- incorrectly imported header row.

CREATE OR REPLACE TABLE
  `braided-rush-482613-i6.retail_sales_profitability.people_clean` AS

SELECT
  string_field_0 AS Regional_Manager,
  string_field_1 AS Region
FROM
  `braided-rush-482613-i6.retail_sales_profitability.people_raw`
WHERE string_field_1 != 'Region'; 

-- =====================================================
-- 4. VALIDATE CLEAN REGIONAL MANAGER DATA
-- =====================================================
-- Review the cleaned People table to confirm that the incorrect header
-- was removed and that the expected four regional manager records remain.

SELECT *
FROM `braided-rush-482613-i6.retail_sales_profitability.people_clean`;

