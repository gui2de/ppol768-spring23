/*-----------------------------------------//

********************************************************************************/
set more off
clear
drop _all

********************************************************************************
*A. CHANGE DATE BELOW EVERYDAY
********************************************************************************
			

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

global midline "$user\02_data\20180716\Project_DiFi.dta"
global dashboard "$user\03_output\dashboard.xls"


********************************************************************************
*Load Dataset
*******************************************************************************
use "$midline", clear 



*Duplicates
*****************************************

preserve
	keep if surveystatus==1


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

*Cumulative

preserve
	
		gen count_comp = 1 if surveystatus==1
		gen count_incomp =  1 if surveystatus==2 | surveystatus==4 | surveystatus==5 | ///
								surveystatus==6 | surveystatus==9
		gen count_ref = 1 if surveystatus==3
		gen count_issues = 1 if surveystatus==8 | surveystatus==10 | surveystatus==11 
		gen count_other = 1 if surveystatus==13 | surveystatus==12 | surveystatus==7 

	keep count_comp count_incomp count_ref count_issues count_other

	collapse (sum) count_comp count_incomp count_ref count_issues count_other

export excel using "$dashboard", sheet("overall_summ") firstrow(variables) replace

restore


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


preserve 
	gen duration = (endtime -starttime)/(1000*60) 
	keep if surveystatus==1
	keep if duration<25

	keep date enumerator hhid treatment starttime endtime duration enumerator
	export excel using "$dashboard", sheet("short_duration") sheetreplace firstrow(variables)
restore



exit 

*bydate









exit 