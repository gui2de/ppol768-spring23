/*-----------------------------------------//

********************************************************************************/
set more off
clear
drop _all

********************************************************************************
*A. CHANGE DATE BELOW EVERYDAY
********************************************************************************
global date 20180319			

********************************************************************************
*B. INTEROPERABILITY
********************************************************************************
 

if c(username)=="ah1152" {
	global user "C:/Users/ah1152/Desktop/week_12"
	}

else if {
	display as error "Update the global according to your machine before running this do file"
	exit 
	}
	
cd "$user"


*******************************************************************************
*C. GLOBALS
*******************************************************************************
*input
global midline "$user/02_data/$date/Project_DiFi.dta"


*output
global dashboard "$user/03_output/dashboard_$date.xls"


********************************************************************************
*Load Dataset
*******************************************************************************
use "$midline", clear 
 


*Duplicates
*****************************************

preserve
	keep if surveystatus==1  //keep only completed survets

	isid hhid 

	if _rc==9 {
		duplicates tag hhid, gen(d)
		keep if d>0
		keep  enumerator submissiondate hhid surveystatus respname 
		*write code to export it
	}

restore


************************************************************************
*summary stats
*************************************************************************

*Cumulative surveys by survey status

preserve
		*generate dummy variables for different statuses
		gen count_comp = 1 if surveystatus==1
		gen count_incomp =  1 if surveystatus==2 | surveystatus==4 | surveystatus==5 | ///
								surveystatus==6 | surveystatus==9
		gen count_ref = 1 if surveystatus==3
		gen count_issues = 1 if surveystatus==8 | surveystatus==10 | surveystatus==11 
		gen count_other = 1 if surveystatus==13 | surveystatus==12 | surveystatus==7 
	*keep only the relevant variables
	keep count_comp count_incomp count_ref count_issues count_other
	*use collapse command to generate the required output
	collapse (sum) count_comp count_incomp count_ref count_issues count_other
*export the results
export excel using "$dashboard", sheet("overall_summ") firstrow(variables) replace

restore

*Survey Status by date
preserve
	
		gen count_comp = 1 if surveystatus==1
		gen count_incomp =  1 if surveystatus==2 | surveystatus==4 | surveystatus==5 | ///
								surveystatus==6 | surveystatus==9
		gen count_ref = 1 if surveystatus==3
		gen count_issues = 1 if surveystatus==8 | surveystatus==10 | surveystatus==11 
		gen count_other = 1 if surveystatus==13 | surveystatus==12 | surveystatus==7 

	keep count_comp count_incomp count_ref count_issues count_other date

	collapse (sum) count_comp count_incomp count_ref count_issues count_other, by(date)

export excel using "$dashboard", sheet("bydate_summ") sheetreplace firstrow(variables)

restore

**Identify/export short duration surveys
preserve 
	gen duration = (endtime -starttime)/(1000*60) //gen duration in mins variable from start and end time 
	keep if surveystatus==1  //short survey is only an issue if it's a completed survey
	keep if duration<25  //lower bound is 25 mins
	*keep relevant variables
	keep date enumerator hhid treatment starttime endtime duration enumerator
	
	*export the records to the excel sheet
	export excel using "$dashboard", sheet("short_duration") sheetreplace firstrow(variables)
restore



exit 

*bydate









exit 