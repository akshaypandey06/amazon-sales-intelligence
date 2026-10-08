# Amazon Sales Intelligence & Business Analytics

![Project Status](https://img.shields.io/badge/Status-Completed-success) 
![Data Analytics](https://img.shields.io/badge/Domain-Data_Analytics-blue)
![SQL](https://img.shields.io/badge/Skill-Advanced_SQL-orange)
![Python](https://img.shields.io/badge/Skill-Python_Pandas-yellow)
![Streamlit](https://img.shields.io/badge/Dashboard-Streamlit-red)

## 📌 Business Problem
An e-commerce business needs actionable intelligence from its raw sales data. The existing dataset contains missing classifications, geographic mismatches, and lacks high-level feature engineering. The business owners require an automated data pipeline, advanced SQL queries to answer critical business questions, and an interactive dashboard to track overall performance, product elasticity, and customer lifetime value.

## 🎯 Objectives
- **Data Engineering & Cleaning:** Build a Python pipeline to standardize categorical variables and correct geographical anomalies.
- **Exploratory Data Analysis (EDA):** Perform an in-depth analysis via a Jupyter Notebook to identify revenue drivers, seasonal trends, and order fulfillment metrics.
- **SQL Analytics:** Write 15+ complex business queries utilizing CTEs, Window Functions, and advanced aggregations.
- **Business Intelligence:** Design and deploy an interactive web dashboard using Streamlit focused on executive KPIs.

## 🗂 Dataset Source & Data Availability
- **Dataset Source:** [Kaggle — Amazon Sales Dataset by Rohiteng](https://www.kaggle.com/datasets/rohiteng/amazon-sales-dataset)
- **Key Features:** `OrderID`, `OrderDate`, `CustomerID`, `ProductID`, `Category`, `TotalAmount`, `Discount`, `OrderStatus`, `State`, `Country`

**Note on Data Availability:**
To keep the repository lightweight and comply with version control best practices, the raw and processed CSV files are **not** included in this public GitHub repository. 
- The raw dataset should be downloaded from the original Kaggle source linked above.
- The downloaded raw file should be placed at: `data/raw/Amazon.csv`
- Running the data pipeline will automatically generate the cleaned dataset at: `data/processed/Amazon_Cleaned.csv`

## 🛠 Tools & Technologies
- **Python** (Data extraction, transformation, and application logic)
- **Pandas** & **NumPy** (Data cleaning and manipulation)
- **SQL** (Data manipulation, trend analysis, and KPI generation)
- **Streamlit** (Interactive web dashboard)
- **Jupyter Notebook** (Exploratory Data Analysis)

## 📚 Business Metrics & Definitions
To ensure clarity and alignment with business stakeholders, the following KPIs are strictly defined within this project:
- **Gross Revenue:** The total sales value before any deductions (sum of `TotalAmount`). This represents the top-line revenue.
- **Net Revenue (Proxy):** A calculated proxy for profitability (`TotalAmount - Tax - ShippingCost`). *Note: Because Cost of Goods Sold (COGS) is not present in the dataset, this serves as an operational net revenue proxy before product costs.*
- **Discount:** The total value of promotional discounts applied at checkout. Analyzed to determine price elasticity and impact on order volume.
- **Average Order Value (AOV):** `Gross Revenue / Total Orders`. Used to track customer spending behavior per transaction.
- **Defect Rate / Returns:** The percentage of orders where the `OrderStatus` is 'Returned' or 'Cancelled'. Tracks fulfillment and product quality issues.

## 📁 Project Structure
```text
Amazon_sales/
├── dashboard/
├── data/
│   ├── raw/                 # (Excluded from GitHub) Place raw Amazon.csv here
│   └── processed/           # (Excluded from GitHub) Cleaned data generated here
├── notebooks/
│   └── amazon_sales_analysis.ipynb
├── reports/
├── sql/
│   └── business_analysis.sql
├── src/
│   ├── app.py
│   └── data_pipeline.py
├── .gitignore
├── README.md
├── requirements.txt
└── analysis.txt
```

## 🧹 Data Cleaning & Transformation (`src/data_pipeline.py`)
The raw data exhibited major quality issues which were programmatically corrected:
1. **Geographic Standardization:** Misaligned states and countries (e.g., Texas mapped to Canada) were unified under 'United States' to allow for accurate spatial mapping.
2. **Category Reclassification:** Products were logically re-assigned to accurate categories (e.g., "Drone Mini" moved from *Books* to *Electronics*) using a regex/keyword matching algorithm.
3. **Feature Engineering:** Extracted `NetRevenue`, `OrderYear`, `OrderMonth`, and `OrderDayOfWeek` to enable advanced time-series analysis.

## 📓 Exploratory Data Analysis (`notebooks/amazon_sales_analysis.ipynb`)
A comprehensive Jupyter Notebook detailing the data exploration process. It contains:
- Exploratory analysis and dataset shape/type validation.
- Data quality checks.
- Descriptive statistics and revenue analysis.
- Category and geographic analysis.
- Order status analysis and top product analysis.
- Monthly revenue trends.
- Actionable business insights.

## 📊 SQL Analysis (`sql/business_analysis.sql`)
The project includes a robust SQL file covering:
- **Financial KPIs:** Gross revenue, Average Order Value (AOV), MoM growth.
- **Customer Segmentation:** Lifetime Value (LTV) calculation, repeat buyer vs. one-time buyer distribution.
- **Operational Efficiency:** Defect rate (returns/cancellations) by category and the impact of shipping costs on cancellations.
- **Product Strategy:** Top-performing products, brand market share, and discount elasticity.

## 💡 Key Business Insights
1. **Category Performance:** *Electronics* and *Home & Kitchen* drive the vast majority of gross revenue, but *Clothing* has a higher return rate.
2. **Discount Elasticity:** Moderate discounts (10-25%) show a strong correlation with increased volume, while high discounts (>25%) erode profit margins without a proportionate increase in sales volume.
3. **Geographical Hubs:** Major states like Texas (TX) and California (CA) are the highest volume drivers; targeted localized marketing here would yield high ROI.

## 🚀 How to Run the Project
1. **Clone the repository and enter the directory:**
   ```bash
   git clone https://github.com/akshaypandey06/amazon-sales-intelligence.git
cd amazon-sales-intelligence
   ```
2. **Download the dataset:**
   - Download the raw CSV from the Kaggle link in the Data Availability section.
   - Save it as `data/raw/Amazon.csv`.
3. **Install requirements:**
   ```bash
   pip install -r requirements.txt
   ```
4. **Run the Data Pipeline:**
   ```bash
   python src/data_pipeline.py
   ```
5. **Launch the Streamlit Dashboard:**
   ```bash
   streamlit run src/app.py
   ```

## ⚠️ Limitations
- **Lack of Cost Data (COGS):** Without exact product costs, true profit margins cannot be calculated. A proxy metric (`NetRevenue = TotalAmount - Tax - ShippingCost`) was used.
- **No Timestamps:** Peak order hours could not be analyzed as time of day was omitted from the original dataset.

---
*This project was designed as a professional portfolio piece for Data Analytics and Business Intelligence freelance consulting.*
