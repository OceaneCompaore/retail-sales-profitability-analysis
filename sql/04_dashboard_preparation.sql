-- ============================================================
-- 04_dashboard_preparation.sql
-- Retail Sales & Profitability Analysis
--
-- Purpose:
-- Create aggregated BigQuery tables used by Looker Studio
-- to simplify dashboard construction and ensure consistent KPIs.
-- ============================================================

-- Prepare yearly performance using a valid date representing
-- the beginning of each year for Looker Studio time-series charts.

CREATE OR REPLACE TABLE
`braided-rush-482613-i6.retail_sales_profitability.dashboard_yearly_performance` AS

SELECT
  DATE(EXTRACT(YEAR FROM `Order Date`), 1, 1) AS Year_Date,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Year_Date
ORDER BY Year_Date;

-- Prepare regional profitability metrics for the dashboard.

CREATE OR REPLACE TABLE
`braided-rush-482613-i6.retail_sales_profitability.dashboard_region` AS

SELECT
  Region,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Region
ORDER BY Total_Profit DESC; 

-- Prepare customer segment performance metrics for the dashboard.

CREATE OR REPLACE TABLE
`braided-rush-482613-i6.retail_sales_profitability.dashboard_segment` AS

SELECT
  Segment,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Segment
ORDER BY Total_Sales DESC; 

-- Prepare sub-category profitability metrics to identify the strongest
-- and weakest product groups.

CREATE OR REPLACE TABLE
`braided-rush-482613-i6.retail_sales_profitability.dashboard_subcategory` AS

SELECT
  `Sub-Category` AS Sub_Category,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Sub_Category
ORDER BY Total_Profit DESC; 

-- Prepare discount-level profitability metrics to analyze the relationship
-- between discounting and business profitability.

CREATE OR REPLACE TABLE
`braided-rush-482613-i6.retail_sales_profitability.dashboard_discount` AS

SELECT
  Discount,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Discount
ORDER BY Discount; 

-- Prepare return-status metrics for the dashboard by comparing
-- returned and non-returned orders.

CREATE OR REPLACE TABLE
  `braided-rush-482613-i6.retail_sales_profitability.dashboard_returns` AS

SELECT
  CASE
    WHEN r.`Order ID` IS NOT NULL THEN 'Returned'
    ELSE 'Not Returned'
  END AS Return_Status,

  COUNT(DISTINCT o.`Order ID`) AS Total_Orders,
  ROUND(SUM(o.Sales), 2) AS Total_Sales,
  ROUND(SUM(o.Profit), 2) AS Total_Profit,

  ROUND(
    SAFE_DIVIDE(SUM(o.Profit), SUM(o.Sales)) * 100,
    2
  ) AS Profit_Margin_Percent

FROM
  `braided-rush-482613-i6.retail_sales_profitability.orders_clean` AS o

LEFT JOIN
  `braided-rush-482613-i6.retail_sales_profitability.returns_raw` AS r
ON
  o.`Order ID` = r.`Order ID`

GROUP BY
  Return_Status

ORDER BY
  Total_Orders DESC;