import streamlit as st
import pandas as pd
import plotly.express as px
import os

# --- PAGE SETUP ---
st.set_page_config(page_title="Amazon Sales Dashboard", page_icon="🛒", layout="wide")
st.title("🛒 Amazon Sales Intelligence Dashboard")
st.markdown("An interactive business intelligence dashboard built for executive overview and product performance analysis.")

# --- LOAD DATA ---
@st.cache_data
def load_data():
    # Dynamically locate the processed data file
    file_path = os.path.join(os.path.dirname(__file__), '../data/processed/Amazon_Cleaned.csv')
    df = pd.read_csv(file_path)
    df['OrderDate'] = pd.to_datetime(df['OrderDate'])
    # Sort by date for chronological charts
    df = df.sort_values('OrderDate')
    return df

try:
    df = load_data()
except FileNotFoundError:
    st.error("Data file not found. Please run `python src/data_pipeline.py` first to generate the cleaned dataset.")
    st.stop()

# --- SIDEBAR FILTERS ---
st.sidebar.header("🔍 Filter Data")

# Year Filter
years = ['All'] + sorted(df['OrderYear'].unique().tolist())
selected_year = st.sidebar.selectbox("Select Year", years)

# Category Filter
categories = ['All'] + sorted(df['Category'].unique().tolist())
selected_category = st.sidebar.selectbox("Select Category", categories)

# Apply Filters
filtered_df = df.copy()
if selected_year != 'All':
    filtered_df = filtered_df[filtered_df['OrderYear'] == selected_year]
if selected_category != 'All':
    filtered_df = filtered_df[filtered_df['Category'] == selected_category]

# --- KPIs ---
st.markdown("### 📈 Executive Summary")
col1, col2, col3, col4 = st.columns(4)

total_revenue = filtered_df['TotalAmount'].sum()
total_orders = filtered_df['OrderID'].nunique()
total_items = filtered_df['Quantity'].sum()
aov = total_revenue / total_orders if total_orders > 0 else 0

col1.metric("Gross Revenue", f"${total_revenue:,.2f}")
col2.metric("Total Orders", f"{total_orders:,}")
col3.metric("Average Order Value (AOV)", f"${aov:,.2f}")
col4.metric("Total Items Sold", f"{total_items:,}")

st.markdown("---")

# --- CHARTS ---
col_left, col_right = st.columns(2)

with col_left:
    st.markdown("#### Revenue Trend Over Time")
    # Group by YearMonth for trend
    trend_df = filtered_df.groupby('OrderYearMonth')['TotalAmount'].sum().reset_index()
    fig_trend = px.line(trend_df, x='OrderYearMonth', y='TotalAmount', markers=True, 
                        labels={'OrderYearMonth': 'Month', 'TotalAmount': 'Revenue ($)'})
    fig_trend.update_layout(xaxis_tickangle=-45)
    st.plotly_chart(fig_trend, use_container_width=True)

    st.markdown("#### Top 10 States by Revenue")
    state_df = filtered_df.groupby('State')['TotalAmount'].sum().reset_index().sort_values(by='TotalAmount', ascending=False).head(10)
    fig_state = px.bar(state_df, x='State', y='TotalAmount', color='TotalAmount', 
                       color_continuous_scale='Blues',
                       labels={'State': 'State', 'TotalAmount': 'Revenue ($)'})
    st.plotly_chart(fig_state, use_container_width=True)

with col_right:
    st.markdown("#### Revenue by Category")
    cat_df = filtered_df.groupby('Category')['TotalAmount'].sum().reset_index().sort_values(by='TotalAmount', ascending=False)
    fig_cat = px.bar(cat_df, x='Category', y='TotalAmount', color='Category',
                     labels={'Category': 'Product Category', 'TotalAmount': 'Revenue ($)'})
    st.plotly_chart(fig_cat, use_container_width=True)

    st.markdown("#### Order Status Breakdown")
    status_df = filtered_df['OrderStatus'].value_counts().reset_index()
    status_df.columns = ['OrderStatus', 'Count']
    fig_status = px.pie(status_df, names='OrderStatus', values='Count', hole=0.4, 
                        color_discrete_sequence=px.colors.qualitative.Pastel)
    st.plotly_chart(fig_status, use_container_width=True)

st.markdown("---")
st.markdown("#### 🏆 Top Products by Net Revenue")
top_products = filtered_df.groupby('ProductName')['NetRevenue'].sum().reset_index().sort_values(by='NetRevenue', ascending=False).head(10)
# Format currency
top_products['NetRevenue'] = top_products['NetRevenue'].apply(lambda x: f"${x:,.2f}")
st.table(top_products.set_index('ProductName'))

st.markdown("---")
st.markdown("### 📚 Data Dictionary & Metric Definitions")
st.markdown("""
* **Gross Revenue:** The total sales value before any deductions. Calculated as the sum of `TotalAmount`.
* **Net Revenue:** A proxy for profitability calculated as `TotalAmount - Tax - ShippingCost`. (Note: True net profit cannot be calculated without COGS).
* **Total Orders:** Count of unique `OrderID`s.
* **Average Order Value (AOV):** `Gross Revenue` divided by `Total Orders`.
* **Returns / Cancellations:** Orders marked with an `OrderStatus` of 'Returned' or 'Cancelled'.
""")

st.markdown("*Dashboard powered by Streamlit & Python.*")

