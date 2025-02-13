/*High Frequency Checks for Capital bikeshare ride data */

//setting directory

if "`c(hostname)'" == "DESKTOP-TA8GE06" {
	global user "C:/Users/Maeve/OneDrive - Georgetown University/Documents/Spring 2023/Research Design and Implementation/HFC"

	}
else if {
	display as error "update the global to your machine specs"
}

cd "$user"
	
//loading data
use "cabi_2017_q1.dta",clear


//defining values
global date `c(current_date)' ///setting current date
global ride_flags "$user/rideflags_$date.xls" // denoting output location



//HFCs

	//HFC #1 checking for missing information

	foreach var of varlist startdate enddate startstationnumber endstationnumber bikenumber membertype {
		mdesc `var'
		cap assert `r(miss)' == 0 
		if _rc != 0 {
			di `r(miss_vars)' " has `r(miss)' missing values" 

		}
		
	}


	//HFC #2 checking for unusual ride durations - lost/stolen/improperly docked bikes 
		/// making reformatting the date/times 
		gen start_date = clock(startdate, "YMDhms")
		gen end_date = clock(enddate, "YMDhms")

		format %tcMonth_DD,_CCYY_HH:MM:SS start_date
		format %tcMonth_DD,_CCYY_HH:MM:SS end_date

	
		//gen duration in minutes

		gen ridetime = round(((end_date - start_date)/1000)/60)
		
		//running the check
		
		preserve 

		di "Unusually long ride:"
		list `bikeid' ridetime if ridetime > 75 & membertype == "Casual"
		gen longride = 0
		replace longride = 1 if ridetime > 75 & membertype == "Casual"
			
		di "Unusually long ride:"
		list `bikeid' ridetime if ridetime > 90 & membertype == "Member"	
		replace longride = 1 if ridetime > 90 & membertype == "Member"	
		
		di "Unusually short ride:"
		list `bikeid' ridetime if ridetime < 2
		gen shortride = 0
		replace shortride = 1 if ridetime < 2
		
		
		//exporting unusually short and long rides 
		keep if long == 1 | short == 1
		export excel using "$ride_flags", sheetreplace firstrow(variables)
		
		
		restore
		

		//saving 

		
	
	import delimited "cabi_2017_q4.csv", clear

	