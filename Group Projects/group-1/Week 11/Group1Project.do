*Group 1 Project, PPOL 768-01
*Figures and Tables, .do file 
*Brown, Hill, Weber 
*Last edited: April 11, 2023 at 1:03PM EDT

// Generate simulated data for job openings and job applications
clear
set seed 20230410
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
merge 1:1 jobseeker_id using "/Users/peytonweber/Downloads/jobs_data.dta"
keep if distance_to_station < 1
drop _merge
merge 1:1 jobseeker_id using "/Users/peytonweber/Downloads/applications_data.dta" 

// Generate simulated data for commuting behavior
clear
set obs 1500
gen jobseeker_id = _n
gen distance_to_station_home = rnormal(1, 0.5)
gen distance_to_station_work = rnormal(1, 0.5)
gen commute_time = distance_to_station_home + distance_to_station_work + rnormal(30, 10)
gen commute_method = cond(distance_to_station_home < 0.5, "Walking", cond(distance_to_station_home < 1, "Biking", cond(distance_to_station_work < 1, "Transit", "Driving")))

// Simulate commuting behavior data
keep jobseeker_id distance_to_station_home distance_to_station_work commute_time commute_method
save commuting_data, replace

// Merge jobseekers and commuting behavior data
merge 1:1 jobseeker_id using jobseekers_data
drop _merge 
keep if distance_to_station_home < 1 | distance_to_station_work < 1
merge m:1 jobseeker_id using jobs_data

// Creating a numeric variable for race
gen nonwhite = 0 
replace nonwhite = 1 if race != "White"

gen white = 0
replace white = 1 if race == "White" 

*Our group still needs to create figures and tables, and we need to put them into a README.md file. 

