# Amazon Sales Intelligence Dashboard

This directory is the designated location for the Power BI (`.pbix`) file.

## Dashboard Architecture & Pages

If you are building the Power BI dashboard, here is the recommended structure to impress freelance clients:

### 1. Executive Summary (Page 1)
- **Target Audience:** C-Suite / Business Owners
- **Key Visuals:** 
  - KPI Cards: Total Revenue, Total Orders, Average Order Value, Total Items Sold.
  - Line Chart: Revenue & Order trend over time (Month & Year hierarchy).
  - Map Visual: Revenue by State (use the cleaned `Country` and `State` fields).

### 2. Product & Category Performance (Page 2)
- **Target Audience:** Product Managers / Inventory Team
- **Key Visuals:**
  - Bar Chart: Revenue and Volume by Category.
  - Matrix/Table: Top 10 Products by Net Revenue and Margin Proxy.
  - Scatter Plot: Discount % vs. Units Sold (to analyze elasticity).

### 3. Customer & Fulfillment (Page 3)
- **Target Audience:** Operations & Customer Success
- **Key Visuals:**
  - Donut Chart: Order Status breakdown (Delivered vs. Cancelled vs. Returned).
  - Column Chart: Cancellation rate by Shipping Cost tier.
  - Treemap: Top Brands by Customer repeat purchases.

## Data Source Configuration
When connecting Power BI to the dataset:
1. Connect to **Text/CSV**.
2. Select the file: `../data/processed/Amazon_Cleaned.csv`.
3. Ensure `OrderDate` is parsed as a Date hierarchy.
4. Set geographic data categories for `State` and `Country` to enable the map visuals.
