# Week 12 Assignment

Author: Yuqing Daniel Fang, Fan Liu

## HTC Description
In this Stata code, we perform a high frequency check (HFC) to the data quality of the administrative data we pulled from our sources, containing information regarding past performance metrics of our targeted State-owned enterprises. Our code exports the results back to an Excel file named "Dashboard.xlsx". The code performs the following tasks:

Checks for missing data in the variables lag_revenue, SalesGrowth, LossIndicator, Change_in_EPS, Debt_to_Assets, Book_to_Market, and Treatment. 

Checks for duplicated IDs and time (year) in the dataset. 

Checks for outliers in the variable lag_revenue. The code calculates the average, standard deviation, and standard deviation boundaries and creates a dummy variable indicating if a data point is an outlier. If there are any outliers, the information is exported to an Excel sheet named "Outlier_lag revenue".

Checks for outliers in the variable SalesGrowth. The code calculates the average, standard deviation, and standard deviation boundaries and creates a dummy variable indicating if a data point is an outlier. If there are any outliers, the information is exported to an Excel sheet named "Outlier_SalesGrowth".

Checks for outliers in the variable Change_in_EPS. The code calculates the average, standard deviation, and standard deviation boundaries and creates a dummy variable indicating if a data point is an outlier. If there are any outliers, the information is exported to an Excel sheet named "Outlier_Change in EPS".

Checks for outliers in the variable Debt_to_Assets. The code calculates the average, standard deviation, and standard deviation boundaries and creates a dummy variable indicating if a data point is an outlier. If there are any outliers, the information is exported to an Excel sheet named "Outlier_Debt to Assets".

Checks for outliers in the variable Book_to_Market. The code calculates the average, standard deviation, and standard deviation boundaries and creates a dummy variable indicating if a data point is an outlier. If there are any outliers, the information is exported to an Excel sheet named "Outlier_Book to Market".

## To execute the code:
The user may need to change the file path or file name if the file is located in a different directory or has a different name. 