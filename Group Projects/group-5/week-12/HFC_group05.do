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
 
global user "C:\Users\kevin\Github\ppol768-spring23\Group Projects\group-5\week-12"


*******************************************************************************
*C. GLOBALS
*******************************************************************************

global midline "$user\Project_DiFi.dta"
global dashboard "$user\dashboard.xls"


********************************************************************************
*Load Dataset
*******************************************************************************
use "$midline", clear 

*Drop Un-needed Variables 
drop c1 c2 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 e1_sources f1 f2 f3 f3_other f4 f4_other f5 f6 hhmencouraged j3 df_working df_notworking 
drop surveystatus1 surveystatus2 surveystatus3 surveystatus4 surveystatus5 surveystatus6 surveystatus7 surveystatus8 surveystatus9 surveystatus10 surveystatus11 surveystatus12 surveystatus13

	
	
***** 
*CHECK 1: CHECK THE MOST SUCCESSFUL TIMES FOR ENUMERATORS TO DO SURVEYS 
sort starttime_manual
*keep starttime_manual if regex(starttime_manual, "Mar-12", .)



foreach j in 2 5 6 7 8 9 12 13 14 15 16 {

preserve 

keep if strpos(starttime_manual, "Mar-`j'")

gen starttime_new = starttime_manual 
order starttime_new, after(starttime_manual)

replace starttime_new = subinstr(starttime_new, "2018-Mar-`j'", "",.)
split starttime_new, parse(:) 
*replace starttime_new = substr(starttime_new, 1, strpos(starttime_new, ".") - 5) 
drop starttime_new2 starttime_new3
order starttime_new1, after(starttime_new)
drop starttime_new 
destring starttime_new1, replace

*Generate indicator variable 
gen surveysuccess = 0 
replace surveysuccess = 1 if hh_found==1 & members_present==1 & consentyesno==1 
order surveysuccess, after(consentyesno)
bysort starttime_new1: egen sum_surveysuccess = sum(surveysuccess)
order sum_surveysuccess, after(surveysuccess)

bysort starttime_new1: egen count_time = count(starttime_new1)
order starttime_new1, after(sum_surveysuccess)

gen rate = sum_surveysuccess / count_time * 100
order rate, after(starttime_new1)
order count_time, after(sum_surveysuccess)

 

keep starttime_new1 rate
duplicates drop

graph twoway bar rate starttime_new1, xla(9(1)17) xtitle("Start Time Hour in Day [24 h clock]") ytitle("Success Rate (%)") title("Mar `j' 2018 Survey Time Success Rates")
graph export times_surveys_Mar_`j'_2018.png, replace 

*export excel using "$dashboard", sheet("Mar_`j'_2018 Summ") sheetreplace firstrow(variables)

restore 



}





*CHECK 2 
gen commute_times_past = runiform(0,120)
gen commute_times_pres = commute_times_past + rnormal(3,3)
gen commute_times_diff = (commute_times_pres - commute_times_past) / commute_times_past * 100 

gen newjob = 0 
	replace newjob = 1 if rnormal()>0 

gen check1 = 0 
	replace check1=1 if (newjob==0) & (commute_times_diff>10) 

	






/* 

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




*/ 




* exit 