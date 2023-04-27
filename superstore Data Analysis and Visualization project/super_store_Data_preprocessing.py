import pandas as pd
import math
import seaborn as sns
from datetime import datetime


ds= pd.read_csv(r"C:\Users\Dell\Downloads\superstore_final_dataset.csv")
ds
ds.info
ds.head

## step 1 checking if duplicate rows exists 

duplicate_rows = ds[ds.duplicated()]
print("Duplicate Rows:")
print(duplicate_rows)
ds.Postal_Code.isnull()

## There are no duplicate rows



## step 2 Removing rows for which few values are missing.

ds.isnull().sum()
[features for features in ds.columns if  ds[features].isnull().sum()>0]

ds=ds.dropna()
print(ds)

 
## Step 3: Remove irrelevant values from each column if any.
##Validation of all values for a column( order date and ship date value must be in correct date format ). 
##For each entry in dataset ship date >= order date


ds['Order_Date'] = pd.to_datetime(ds['Order_Date'])


ds['Ship_Date'] = pd.to_datetime(ds['Ship_Date'])


ds['Ship_Date > Order_Date'] = ds['Ship_Date'] > ds['Order_Date']



print(ds)


ds= ds.drop(ds[ds['Ship_Date > Order_Date'] == False].index)
ds


## converting the cleaned data into csv file in UTF-8 Encoding.


cleaned_data = pd.DataFrame(ds)






cleaned_data.to_csv('cleaned_data_utf8.csv', index=False, encoding='utf-8-sig')


