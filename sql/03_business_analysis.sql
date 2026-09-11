-- =====================================================
-- 1. OVERALL BUSINESS PERFORMANCE
-- =====================================================

-- Calculate the company's overall sales, profit, quantity sold,
-- number of orders, number of customers, and overall profit margin.

SELECT
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity_Sold,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers,
    ROUND(SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100, 2)
        AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`; 

-- =====================================================
-- 2. SALES AND PROFIT PERFORMANCE OVER TIME
-- =====================================================

-- Analyze annual sales, profit, and profit margin to evaluate
-- how the company's financial performance changed over time. 

SELECT
    EXTRACT(YEAR FROM `Order Date`) AS Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Year
ORDER BY Year;

-- Analyze monthly sales and profit to identify trends, seasonal patterns,
-- and periods where strong sales did not translate into strong profitability.

SELECT
    DATE_TRUNC(`Order Date`, MONTH) AS Month,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Month
ORDER BY Month; 

-- =====================================================
-- 3. CATEGORY AND SUB-CATEGORY PERFORMANCE
-- =====================================================

-- Compare sales, profit, and profit margin across product categories
-- to identify which categories contribute most to business performance. 

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Category
ORDER BY Total_Sales DESC; 

-- Analyze performance at the sub-category level to identify
-- the strongest and weakest product groups by sales and profitability. 

SELECT
    Category,
    `Sub-Category` AS Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Category, Sub_Category
ORDER BY Total_Profit DESC; 

-- Identify sub-categories that generated an overall loss
-- despite contributing sales to the business. 

SELECT
    Category,
    `Sub-Category` AS Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC; 

-- =====================================================
-- 4. DISCOUNT IMPACT ON PROFITABILITY
-- =====================================================

-- Analyze profitability across discount levels to determine whether
-- higher discounts are associated with lower profits and profit margins.

SELECT
    Discount,
    COUNT(*) AS Transaction_Lines,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Discount
ORDER BY Discount; 

-- Compare average discount levels across sub-categories to investigate
-- whether poorly performing product groups are exposed to heavier discounting. 

SELECT
    Category,
    `Sub-Category` AS Sub_Category,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Category, Sub_Category
ORDER BY Profit_Margin_Percent ASC; 

-- =====================================================
-- 5. REGIONAL PERFORMANCE
-- =====================================================

-- Compare sales, profit, and profit margin across regions to identify
-- geographic differences in business performance. 

SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Region
ORDER BY Total_Profit DESC; 

-- Link regional performance with the People dataset to identify the
-- regional manager associated with each region's business results. 

SELECT
    o.Region,
    p.Regional_Manager,
    ROUND(SUM(o.Sales), 2) AS Total_Sales,
    ROUND(SUM(o.Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(o.Profit), SUM(o.Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean` o
LEFT JOIN
    `braided-rush-482613-i6.retail_sales_profitability.people_clean` p
ON o.Region = p.Region
GROUP BY o.Region, p.Regional_Manager
ORDER BY Total_Profit DESC; 

-- =====================================================
-- 6. CUSTOMER SEGMENT PERFORMANCE
-- =====================================================

-- Compare sales, profit, and profitability across customer segments
-- to identify which customer groups contribute most to business performance. 

SELECT
    Segment,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SAFE_DIVIDE(SUM(Profit), SUM(Sales)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean`
GROUP BY Segment
ORDER BY Total_Profit DESC; 

-- =====================================================
-- 7. RETURNS AND PROFITABILITY
-- =====================================================

-- Compare returned and non-returned orders to evaluate whether
-- returns are associated with differences in sales and profitability.

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
    `braided-rush-482613-i6.retail_sales_profitability.orders_clean` o
LEFT JOIN
    `braided-rush-482613-i6.retail_sales_profitability.returns_raw` r
ON o.`Order ID` = r.`Order ID`
GROUP BY Return_Status
ORDER BY Return_Status; 





