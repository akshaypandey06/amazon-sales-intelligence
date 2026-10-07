import pandas as pd
import numpy as np
import os

def clean_data(input_path, output_path):
    print(f"Reading raw data from {input_path}...")
    df = pd.read_csv(input_path)

    print("Cleaning data...")
    
    # 1. Convert OrderDate to datetime
    df['OrderDate'] = pd.to_datetime(df['OrderDate'])

    # 2. Fix Geographical Mismatches
    # Map all US states to 'United States'
    us_states = ['TX', 'DC', 'NC', 'WA', 'NY', 'CA', 'FL', 'IL', 'PA', 'OH', 'GA', 'MI', 'VA']
    
    # Identify non-US rows based on country (if there are other countries, we'll give them fake states or just clean the country)
    # Actually, let's just make the Country 'United States' if the State is in the US list.
    df.loc[df['State'].isin(us_states), 'Country'] = 'United States'
    
    # If there are still mismatches (e.g. India, Canada with US states), we'll overwrite the country to United States.
    # To keep it global, let's randomly assign some non-US countries to specific states/provinces if needed, 
    # but the simplest fix for a portfolio project is consistent mappings.
    # Let's map any remaining 'India' to state 'MH', 'Canada' to 'ON', 'UK' to 'ENG', 'Australia' to 'NSW'
    # Wait, we only have US states in the 'State' column based on earlier describe (13 unique states).
    # So we will just set all Country = 'United States' for simplicity and consistency.
    df['Country'] = 'United States'

    # 3. Fix Product Category Mismatches
    # We will use keyword matching on ProductName to assign the correct Category
    def assign_category(name):
        name_lower = str(name).lower()
        if any(kw in name_lower for kw in ['drone', 'camera', 'webcam', 'microphone', 'speaker', 'headphone', 'earbuds', 'tv', 'monitor', 'laptop', 'tablet', 'phone', 'power bank']):
            return 'Electronics'
        elif any(kw in name_lower for kw in ['shirt', 't-shirt', 'jeans', 'jacket', 'shoes', 'sneakers', 'dress', 'hat', 'socks']):
            return 'Clothing'
        elif any(kw in name_lower for kw in ['book', 'novel', 'guide', 'fiction', 'dictionary']):
            return 'Books'
        elif any(kw in name_lower for kw in ['toy', 'game', 'puzzle', 'lego', 'board', 'doll', 'action figure']):
            return 'Toys & Games'
        elif any(kw in name_lower for kw in ['kitchen', 'blender', 'mug', 'pan', 'cookware', 'vacuum', 'pillow', 'towel', 'desk', 'chair']):
            return 'Home & Kitchen'
        elif any(kw in name_lower for kw in ['ball', 'bat', 'racket', 'tent', 'dumbbells', 'yoga', 'bike', 'helmet']):
            return 'Sports & Outdoors'
        else:
            return 'Other'

    df['Category_Cleaned'] = df['ProductName'].apply(assign_category)
    # Where 'Other', keep original category just in case
    df['Category'] = np.where(df['Category_Cleaned'] == 'Other', df['Category'], df['Category_Cleaned'])
    df.drop(columns=['Category_Cleaned'], inplace=True)

    # 4. Feature Engineering
    # Calculate Profit Margin Proxy (Revenue - Shipping - Tax) 
    # (Since we don't have COGS, this is Net Revenue before COGS)
    df['NetRevenue'] = df['TotalAmount'] - df['Tax'] - df['ShippingCost']
    
    # 5. Extract Date features
    df['OrderYear'] = df['OrderDate'].dt.year
    df['OrderMonth'] = df['OrderDate'].dt.month
    df['OrderDayOfWeek'] = df['OrderDate'].dt.day_name()
    df['OrderYearMonth'] = df['OrderDate'].dt.to_period('M').astype(str)

    print(f"Saving cleaned data to {output_path}...")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_csv(output_path, index=False)
    print("Data pipeline completed successfully!")

if __name__ == "__main__":
    input_csv = "data/raw/Amazon.csv"
    output_csv = "data/processed/Amazon_Cleaned.csv"
    clean_data(input_csv, output_csv)
