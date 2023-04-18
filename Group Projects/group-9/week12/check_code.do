cd "/Users/liufan/Desktop/ppol768-spring23/Group Projects/group-9/week12"

global dashboard "Dashboard.xlsx"

clear

use "final dataset.dta"

*Check missing data
egen missing_data = rowmiss(lag_revenue SalesGrowth LossIndicator Change_in_EPS Debt_to_Assets Book_to_Market Treatment)
count if missing_data != 0
export excel using "Dashboard", sheet("Missing Data", modify) firstrow(variables)
// 16 missing data

*Check dupilicated ID and Time(year)
duplicates tag stkcd rptyr, gen(duplicate)
count if duplicate!= 0
preserve
drop missing_data
export excel using "Dashboard", sheet("Duplicate", modify) firstrow(variables)
restore
// No duplicate data

*Check Outlier of lag_revenue
egen average_lag_revenue = mean(lag_revenue)
egen sd_lag_revenue = sd(lag_revenue)
gen standard_right_lag_revenue = average_lag_revenue + 3*sd_lag_revenue
gen standard_left_lag_revenue = average_lag_revenue - 3*sd_lag_revenue
gen ourlier_lag_revenue = cond(lag_revenue > standard_left_lag_revenue & lag_revenue < standard_right_lag_revenue, 0, 1)
drop average_lag_revenue sd_lag_revenue standard_left_lag_revenue standard_right_lag_revenue
count if ourlier_lag_revenue == 1
preserve
drop missing_data duplicate
export excel using "Dashboard", sheet("Outlier_lag revenue", modify) firstrow(variables)
restore
// 60 outlier of lag_revenue

*Check Outlier of SalesGrowth
egen average_SalesGrowth = mean(SalesGrowth)
egen sd_SalesGrowth = sd(SalesGrowth)
gen standard_right_SalesGrowth = average_SalesGrowth + 3*sd_SalesGrowth
gen standard_left_SalesGrowth = average_SalesGrowth - 3*sd_SalesGrowth
gen ourlier_SalesGrowth = cond(SalesGrowth > standard_left_SalesGrowth & SalesGrowth < standard_right_SalesGrowth, 0, 1)
drop average_SalesGrowth sd_SalesGrowth standard_left_SalesGrowth standard_right_SalesGrowth
count if ourlier_SalesGrowth == 1
preserve
drop missing_data duplicate ourlier_lag_revenue
export excel using "Dashboard", sheet("Outlier_SalesGrouth", modify) firstrow(variables)
restore
// 22 outlier of SalesGrowth

*Check Outlier of Change_in_EPS
egen average_Change_in_EPS = mean(Change_in_EPS)
egen sd_Change_in_EPS = sd(Change_in_EPS)
gen standard_right_Change_in_EPS = average_Change_in_EPS + 3*sd_Change_in_EPS
gen standard_left_Change_in_EPS = average_Change_in_EPS - 3*sd_Change_in_EPS
gen ourlier_Change_in_EPS = cond(Change_in_EPS > standard_left_Change_in_EPS & Change_in_EPS < standard_right_Change_in_EPS, 0, 1)
drop average_Change_in_EPS sd_Change_in_EPS standard_left_Change_in_EPS standard_right_Change_in_EPS
count if ourlier_Change_in_EPS == 1
preserve
drop missing_data duplicate ourlier_lag_revenue ourlier_SalesGrowth
export excel using "Dashboard", sheet("Outlier_Change in EPS", modify) firstrow(variables)
restore
//12 outlier of Change_in_EPS

*Check Outlier of Debt_to_Assets
egen average_Debt_to_Assets = mean(Debt_to_Assets)
egen sd_Debt_to_Assets = sd(Debt_to_Assets)
gen standard_right_Debt_to_Assets = average_Debt_to_Assets + 3*sd_Debt_to_Assets
gen standard_left_Debt_to_Assets = average_Debt_to_Assets - 3*sd_Debt_to_Assets
gen ourlier_Debt_to_Assets = cond(Debt_to_Assets > standard_left_Debt_to_Assets & Debt_to_Assets < standard_right_Debt_to_Assets, 0, 1)
drop average_Debt_to_Assets sd_Debt_to_Assets standard_left_Debt_to_Assets standard_right_Debt_to_Assets
count if ourlier_Debt_to_Assets == 1
preserve
drop missing_data duplicate ourlier_lag_revenue ourlier_SalesGrowth ourlier_Change_in_EPS
export excel using "Dashboard", sheet("Outlier_Debt to Assets", modify) firstrow(variables)
restore
//25 outlier of Debt_to_Assets

*Check Outlier of Book_to_Market
egen average_Book_to_Market = mean(Book_to_Market)
egen sd_Book_to_Market = sd(Book_to_Market)
gen standard_right_Book_to_Market = average_Book_to_Market + 3*sd_Book_to_Market
gen standard_left_Book_to_Market = average_Book_to_Market - 3*sd_Book_to_Market
gen ourlier_Book_to_Market = cond(Book_to_Market > standard_left_Book_to_Market & Book_to_Market < standard_right_Book_to_Market, 0, 1)
drop average_Book_to_Market sd_Book_to_Market standard_left_Book_to_Market standard_right_Book_to_Market
count if ourlier_Book_to_Market == 1
preserve
drop missing_data duplicate ourlier_lag_revenue ourlier_SalesGrowth ourlier_Change_in_EPS ourlier_Debt_to_Assets
export excel using "Dashboard", sheet("Outlier_Book to Market", modify) firstrow(variables)
restore
//18 outlier of Book_to_Market

*Final dataset
drop if missing_data != 0 | duplicate!= 0 | ourlier_lag_revenue == 1 | ourlier_SalesGrowth == 1 | ourlier_Change_in_EPS == 1 | ourlier_Debt_to_Assets == 1 | ourlier_Book_to_Market == 1
drop missing_data duplicate ourlier_lag_revenue ourlier_SalesGrowth ourlier_Change_in_EPS ourlier_Debt_to_Assets ourlier_Book_to_Market
export excel using "Dashboard", sheet("Final Dataset", modify) firstrow(variables)
