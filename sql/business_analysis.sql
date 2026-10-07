-- ==============================================================================
-- Amazon Sales Intelligence - Business Analysis SQL Script
-- ==============================================================================
-- Description: This file contains 15 professional business queries answering 
-- critical questions using the cleaned Amazon Sales Dataset.
-- Concepts demonstrated: Joins, CTEs, Window Functions, Aggregate Functions, 
-- Case Statements, Date/Time Functions.
-- ==============================================================================

-- =========================================================
-- 1. OVERALL BUSINESS PERFORMANCE
-- =========================================================

-- Q1. What are the high-level business KPIs (Total Revenue, Total Orders, AOV)?
SELECT 
    COUNT(DISTINCT OrderID) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,
    ROUND(SUM(TotalAmount), 2) AS Gross_Revenue,
    ROUND(SUM(TotalAmount) / COUNT(DISTINCT OrderID), 2) AS Average_Order_Value,
    ROUND(SUM(Discount), 2) AS Total_Discount_Given
FROM Amazon_Sales;


-- Q2. How is the Month-over-Month (MoM) revenue trend performing?
WITH MonthlyRevenue AS (
    SELECT 
        OrderYearMonth,
        SUM(TotalAmount) AS Revenue
    FROM Amazon_Sales
    WHERE OrderStatus = 'Delivered'
    GROUP BY OrderYearMonth
)
SELECT 
    OrderYearMonth,
    ROUND(Revenue, 2) AS Current_Month_Revenue,
    ROUND(LAG(Revenue) OVER (ORDER BY OrderYearMonth), 2) AS Prev_Month_Revenue,
    ROUND(((Revenue - LAG(Revenue) OVER (ORDER BY OrderYearMonth)) / 
          LAG(Revenue) OVER (ORDER BY OrderYearMonth)) * 100, 2) AS MoM_Growth_Pct
FROM MonthlyRevenue;


-- =========================================================
-- 2. PRODUCT & CATEGORY INSIGHTS
-- =========================================================

-- Q3. Which product categories drive the highest revenue and volume?
SELECT 
    Category,
    COUNT(DISTINCT OrderID) AS Order_Count,
    SUM(Quantity) AS Units_Sold,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue,
    ROUND(SUM(TotalAmount) / SUM(Quantity), 2) AS Avg_Price_Per_Unit
FROM Amazon_Sales
GROUP BY Category
ORDER BY Total_Revenue DESC;


-- Q4. What are the Top 5 most profitable brands overall?
SELECT TOP 5
    Brand,
    SUM(Quantity) AS Units_Sold,
    ROUND(SUM(NetRevenue), 2) AS Total_Net_Revenue
FROM Amazon_Sales
WHERE OrderStatus = 'Delivered'
GROUP BY Brand
ORDER BY Total_Net_Revenue DESC;


-- Q5. What is the cancellation and return rate by category?
SELECT 
    Category,
    COUNT(OrderID) AS Total_Orders,
    SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
    SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END) AS Returned_Orders,
    ROUND((SUM(CASE WHEN OrderStatus IN ('Cancelled', 'Returned') THEN 1 ELSE 0 END) * 100.0) / COUNT(OrderID), 2) AS Defect_Rate_Pct
FROM Amazon_Sales
GROUP BY Category
ORDER BY Defect_Rate_Pct DESC;


-- =========================================================
-- 3. CUSTOMER ANALYSIS
-- =========================================================

-- Q6. Who are the Top 10 most valuable customers by Lifetime Value (LTV)?
SELECT TOP 10
    CustomerID,
    CustomerName,
    COUNT(DISTINCT OrderID) AS Total_Purchases,
    ROUND(SUM(TotalAmount), 2) AS Lifetime_Value,
    ROUND(AVG(TotalAmount), 2) AS Avg_Order_Value
FROM Amazon_Sales
WHERE OrderStatus = 'Delivered'
GROUP BY CustomerID, CustomerName
ORDER BY Lifetime_Value DESC;


-- Q7. What is the customer purchasing frequency (One-time vs. Repeat buyers)?
WITH CustomerPurchaseCount AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT OrderID) AS Purchase_Count
    FROM Amazon_Sales
    GROUP BY CustomerID
)
SELECT 
    CASE 
        WHEN Purchase_Count = 1 THEN 'One-time Buyer'
        WHEN Purchase_Count BETWEEN 2 AND 5 THEN 'Occasional Buyer (2-5)'
        ELSE 'Frequent Buyer (6+)' 
    END AS Buyer_Segment,
    COUNT(CustomerID) AS Customer_Count,
    ROUND((COUNT(CustomerID) * 100.0) / (SELECT COUNT(DISTINCT CustomerID) FROM Amazon_Sales), 2) AS Pct_of_Total
FROM CustomerPurchaseCount
GROUP BY 
    CASE 
        WHEN Purchase_Count = 1 THEN 'One-time Buyer'
        WHEN Purchase_Count BETWEEN 2 AND 5 THEN 'Occasional Buyer (2-5)'
        ELSE 'Frequent Buyer (6+)' 
    END;


-- Q8. Does offering a higher discount lead to larger order quantities?
SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10 THEN 'Low (1-10%)'
        WHEN Discount > 0.10 AND Discount <= 0.25 THEN 'Medium (11-25%)'
        ELSE 'High (>25%)'
    END AS Discount_Tier,
    COUNT(OrderID) AS Order_Volume,
    ROUND(AVG(Quantity), 2) AS Avg_Units_Per_Order,
    ROUND(AVG(TotalAmount), 2) AS Avg_Revenue_Per_Order
FROM Amazon_Sales
GROUP BY 
    CASE 
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10 THEN 'Low (1-10%)'
        WHEN Discount > 0.10 AND Discount <= 0.25 THEN 'Medium (11-25%)'
        ELSE 'High (>25%)'
    END
ORDER BY Avg_Units_Per_Order DESC;


-- =========================================================
-- 4. GEOGRAPHICAL PERFORMANCE
-- =========================================================

-- Q9. Which States generate the highest revenue?
SELECT TOP 10
    State,
    COUNT(DISTINCT OrderID) AS Total_Orders,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue,
    ROUND(AVG(ShippingCost), 2) AS Avg_Shipping_Cost
FROM Amazon_Sales
WHERE Country = 'United States'
GROUP BY State
ORDER BY Total_Revenue DESC;


-- Q10. What is the most popular payment method in each State?
WITH PaymentRanks AS (
    SELECT 
        State,
        PaymentMethod,
        COUNT(OrderID) AS Usage_Count,
        ROW_NUMBER() OVER(PARTITION BY State ORDER BY COUNT(OrderID) DESC) AS Rnk
    FROM Amazon_Sales
    GROUP BY State, PaymentMethod
)
SELECT 
    State,
    PaymentMethod AS Top_Payment_Method,
    Usage_Count
FROM PaymentRanks
WHERE Rnk = 1;


-- =========================================================
-- 5. SELLER & OPERATIONS METRICS
-- =========================================================

-- Q11. Who are the Top 5 performing Sellers by Revenue?
SELECT TOP 5
    SellerID,
    COUNT(DISTINCT OrderID) AS Orders_Fulfilled,
    SUM(Quantity) AS Total_Items_Sold,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue
FROM Amazon_Sales
WHERE OrderStatus = 'Delivered'
GROUP BY SellerID
ORDER BY Total_Revenue DESC;


-- Q12. How does shipping cost impact the likelihood of cancellation?
SELECT 
    CASE 
        WHEN ShippingCost = 0 THEN 'Free Shipping'
        WHEN ShippingCost > 0 AND ShippingCost <= 5 THEN 'Low Cost ($1-$5)'
        WHEN ShippingCost > 5 AND ShippingCost <= 15 THEN 'Medium Cost ($6-$15)'
        ELSE 'High Cost (>$15)' 
    END AS Shipping_Cost_Tier,
    COUNT(OrderID) AS Total_Orders,
    SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
    ROUND((SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(OrderID), 2) AS Cancellation_Rate_Pct
FROM Amazon_Sales
GROUP BY 
    CASE 
        WHEN ShippingCost = 0 THEN 'Free Shipping'
        WHEN ShippingCost > 0 AND ShippingCost <= 5 THEN 'Low Cost ($1-$5)'
        WHEN ShippingCost > 5 AND ShippingCost <= 15 THEN 'Medium Cost ($6-$15)'
        ELSE 'High Cost (>$15)' 
    END
ORDER BY Cancellation_Rate_Pct DESC;


-- Q13. Are there any seasonal sales trends based on the Day of the Week?
SELECT 
    OrderDayOfWeek,
    COUNT(OrderID) AS Order_Volume,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue,
    ROUND(AVG(TotalAmount), 2) AS Avg_Order_Value
FROM Amazon_Sales
GROUP BY OrderDayOfWeek
ORDER BY Total_Revenue DESC;


-- =========================================================
-- 6. ADVANCED ANALYTICS (WINDOW FUNCTIONS)
-- =========================================================

-- Q14. What is the cumulative running total of revenue over the year 2023?
WITH DailyRevenue AS (
    SELECT 
        OrderDate,
        SUM(TotalAmount) AS Daily_Total
    FROM Amazon_Sales
    WHERE OrderYear = 2023
    GROUP BY OrderDate
)
SELECT 
    OrderDate,
    Daily_Total,
    SUM(Daily_Total) OVER (ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_Total_Revenue
FROM DailyRevenue
ORDER BY OrderDate;


-- Q15. Identify the top selling product within each category (by Revenue).
WITH RankedProducts AS (
    SELECT 
        Category,
        ProductName,
        ROUND(SUM(TotalAmount), 2) AS Product_Revenue,
        RANK() OVER(PARTITION BY Category ORDER BY SUM(TotalAmount) DESC) AS Rnk
    FROM Amazon_Sales
    GROUP BY Category, ProductName
)
SELECT 
    Category,
    ProductName AS Top_Product,
    Product_Revenue
FROM RankedProducts
WHERE Rnk = 1;
