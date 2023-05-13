*Group 1 Project, PPOL 768-01
*Figures and Tables, .do file 
*Brown, Hill, Weber 
*Last edited: April 17, 2023 at 1:40PM EDT

*********************************
*WEEK 11 ASSIGNMENT STARTS HERE*
*********************************

cd "D:\2021-2023, Georgetown University\2023 - Spring\Research Design & Implementation\ScottsRepo\ppol768-spring23\Group Projects\group-1\Week 11"

// Generate simulated data for job openings and job applications
clear
set seed 20230411
set obs 2000
gen jobseeker_id = _n
gen distance_to_station = rnormal(1, 0.5)
gen salary = rnormal(60000, 10000)
gen job_open_date = ym(2024, 1) + int(24*runiform())
gen job_close_date = job_open_date + int(12*runiform())
gen job_open = job_open_date <= _n < job_close_date

// Simulate job openings data
keep jobseeker_id distance_to_station salary job_open
save jobs_data, replace 

// Simulate job applications data
clear
set obs 4000
gen job_id = ceil(_n/2)
gen jobseeker_id = _n
gen job_application_date = ym(2025, 1) + int(12*runiform())
gen application_status = cond(runiform() < 0.8, "Pending", "Rejected")

keep job_id jobseeker_id job_application_date application_status
save applications_data, replace 

// Simulate demographic data for job seekers
clear
set obs 2000
gen jobseeker_id = _n
gen age = int(18 + 40*runiform())
gen education_level = cond(runiform() < 0.3, "High School", cond(runiform() < 0.6, "College", "Advanced Degree"))
gen race = cond(runiform() < 0.5, "White", cond(runiform() < 0.8, "Black", "Other"))
gen income = rnormal(50000, 10000)

// Simulate jobseekers data
keep jobseeker_id age education_level race income
save jobseekers_data, replace 

// Merge job openings and job applications data
merge 1:1 jobseeker_id using jobs_data.dta
drop if distance_to_station <= 0
*keep if distance_to_station < 1
drop _merge
merge 1:1 jobseeker_id using applications_data.dta

save jobseeker_application_job_merged, replace


// Generate simulated data for commuting behavior
clear
set obs 1500
gen jobseeker_id = _n
gen distance_to_station_home = rnormal(1, 0.5)
gen distance_to_station_work = rnormal(1, 0.5)
gen commute_time = distance_to_station_home + distance_to_station_work + rnormal(30, 10)
gen commute_method = cond(distance_to_station_home < 0.5, "Walking", cond(distance_to_station_home < 1, "Biking", cond(distance_to_station_work < 1, "Transit", "Driving")))

drop if distance_to_station_home <0
drop if distance_to_station_work < 0
drop if commute_time < 0

// Simulate commuting behavior data
keep jobseeker_id distance_to_station_home distance_to_station_work commute_time commute_method
save commuting_data, replace

// Merge jobseekers and commuting behavior data
merge 1:1 jobseeker_id using jobseekers_data
drop _merge 
keep if distance_to_station_home < 1 | distance_to_station_work < 1
merge m:1 jobseeker_id using jobs_data

// Creating a dummy variable for white
gen white = 0
replace white = 1 if race == "White" 


// Scatterplot of distance to station by race
twoway (scatter distance_to_station white, msymbol(circle) msize(tiny)) ///
    (lfit distance_to_station white if white == 1, lpattern(dash)) ///
	(lfit distance_to_station white if white == 0, lpattern(dash)) ///
    ytitle(Distance to Station) xtitle(Race) legend(off)
graph export distance_by_race.png, replace

// Create a histogram of jobseeker age
histogram age, bin(10) ///
    xtitle("Age") ytitle("Count") title("Distribution of Jobseeker Age")
graph export age_histogram.png, replace

// Create a bar chart of jobseeker education level
graph bar (count) education_level, ///
    over(race) blabel(bar) stack asyvars ytitle("Count") xtitle("Education Level") ///
    legend(off) title("Distribution of Jobseeker Education Level by Race")
graph export education_by_race.png, replace

// Create a scatterplot of commute time by distance to station
twoway (scatter commute_time distance_to_station, msymbol(circle) msize(tiny)) ///
    (lfit commute_time distance_to_station, lpattern(dash)) ///
    ytitle("Commute Time") xtitle("Distance to Station") title("Relationship Between Commute Time and Distance to Station")
graph export commute_by_distance.png, replace

// Create a histogram of commute time by commute method
histogram commute_time, ///
    by(commute_method) ///
    ytitle("Frequency") xtitle("Commute Time") ///
    name(commute_hist, replace)
graph export commute_by_means.png, replace


**********
// Create a bar chart of education level by race
graph bar (count) education_level, over(race) ///
    ytitle("Count") xtitle("Race") ///
    legend(off) name(edu_race, replace)

// Create a scatterplot of distance to station by race
twoway (scatter distance_to_station white, msymbol(circle) msize(tiny)) ///
    (lfit distance_to_station white if white == 1, lpattern(dash)) ///
    (lfit distance_to_station white if white == 0, lpattern(dash)) ///
    ytitle(Distance to Station) xtitle(Race) legend(off) name(dist_race, replace)

// Create a scatterplot of salary by age with regression line
graph twoway (scatter salary age, msymbol(circle) msize(tiny)) ///
    (lfit salary age) ///
    ytitle("Salary") xtitle("Age") legend(off) name(salary_age, replace)
	
*********************************
*WEEK 12 ASSIGNMENT STARTS HERE*
*********************************

**Data quality checks**
// Simulate data for start and end time
gen start_time = runiformint(1, 100)
gen end_time = start_time + runiformint(10, 30)

// Calculate the duration of the survey
gen duration = end_time - start_time

// Simulate completion rates
gen completion_rate = runiform()

// Calculate the number of completed surveys
gen completed = rbinomial(_N, completion_rate)

// Calculate the number of incomplete surveys
gen incomplete = _N - completed

// Print summary statistics and examine for outlyers
summarize start_time end_time duration completion_rate completed incomplete

// Check for missing values
summarize if missing(), detail // This simulated dataset does not have missing values, but real data will

// Check for extreme values
summarize distance_to_station distance_to_station_home distance_to_station_work commute_time salary, detail

// Check for negative and outlying income values NOTE: there's a syntax error, not sure why
if min(income) < 0 {
    di "Negative values detected!"
}

// check for outlying values
qui sum income
local min = r(min)
local p1 = r(p1)
local p99 = r(p99)
local max = r(max)

//Again, more syntax errors here, but the spirit of the code is that it will display a message that there are some outliers that deserve examination
if min < p1 {
    di "Outlying values detected below 1st percentile! Total outlying values: " _Noutlying(income, `p1')
    drop if income < `p1'
}

if max > p99 {
    di "Outlying values detected above 99th percentile! Total outlying values: " _Noutlying(income, `p99')
    drop if income > `p99'
}
