*week04 Xinyu Zheng

* set up： PLEASE CHANGE THE WORKING DIRECTORY HERE
global wd "C:/Users/zheng/Desktop/research design/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

global q1 "$wd/q1_village_pixel.dta"
global q2 "$wd/q2_Pakistan_district_table21.xlsx"
global q3 "$wd/q3_grant_prop_review_2022.dta"
global q4 "$wd/q4_Tz_student_roster_html.dta"

********************************************************************************
* Q1
********************************************************************************

use "$q1", clear

* a)
bysort pixel (payout): gen pixel_consistent = payout[1] != payout[_N]

* b)
bysort village (pixel): gen pixel_village = pixel[1] != pixel[_N] 

* c)
gen village_category = .
replace village_category = 1 if pixel_village == 0
replace village_category = 2 if pixel_village == 1 & pixel_consistent == 0
replace village_category = 3 if pixel_village == 1 & pixel_consistent == 1

list hhid if village_category == 2

********************************************************************************
* Q2
********************************************************************************
clear

* METHOD 1: fix the problem inside the loop
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i = 1/135 {
	import excel "$q2", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number
	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
	* drop missing columns
	ds
	foreach var in `r(varlist)' {
	  if missing(`var') {
	  	drop `var'
	  }
	}
	
	* "-" indiscates a blank cell
	ds
	foreach var in `r(varlist)' {
	 if regex(`var', "-") {
	 	split `var', p("-")
		drop `var'
	 }
	}
	
	* generate columns when the missing columns are at the tail of the table
	creturn list
	if c(k) < 13 {
	  gen blank_col = ""
	} 
	
	* create matchable column names
	ds
	forvalue x = 2/13 {
	    local column: word `x' of `r(varlist)'
		rename `column' column_`x'
	}
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
*use `table21', clear
*fix column width issue so that it's easy to eyeball the data
ds, has(type string)
format %40s table21 `r(varlist)'

* rename columns properly
rename column_2 total_pop
rename column_3 total_obtained
rename column_4 total_not_obtained
rename column_5 male_pop
rename column_6 male_obtained
rename column_7 male_not_obtained
rename column_8 female_pop
rename column_9 female_obtained
rename column_10 female_not_obtained
rename column_11 trans_pop
rename column_12 trans_obtained
rename column_13 trans_not_obtained

/* METHOD 2: I'm able to fix the problem outside of the loop, but it's complicated, so I won't pursue method two here.
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$q2", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number
	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
*use `table21', clear

local varlist B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC
*fix column width issue so that it's easy to eyeball the data
format %40s table21 `varlist'

* clean data
drop table21 // do not need table21 anymore
order table, last // put table in the last to avoid mismanipulate by following steps
destring `varlist', force replace // convert all variables from string to numeric
* move values mistakenly put in the next few columns to the place they should be
foreach var in `varlist' {
	gen new_`var' = `var'
}
forvalues i = 1/12 {
	local column_main: word `i' of `varlist'
		forvalues x = 1/16 {
			local j = `i' + `x'
			local column_next: word `j' of `varlist'
			replace `column_main' = `column_next' if `column_main' == .
			replace `column_next' = . if `column_main' == `column_next' & new_`column_main' == .
			
			* if a cell contains a negative value, there should be a blank cell ahead of this cell
			replace `column_next' = abs(`column_main') if `column_main' < 0
			replace `column_main' = . if `column_main' < 0
			
			* update the copies to correctly set the if condition for the next loop
			replace new_`column_main' = `column_main'
			replace new_`column_next' = `column_next'
			}
}
missings dropvars, force // drop columns of all missing; need to install package missings
drop new_* // drop copies of variables

* rename varibles
rename B total_pop
rename C total_obtained
rename D total_not_obtained
rename E male_pop
rename F male_obtained
rename G male_not_obtained
rename H female_pop
rename I female_obtained
rename J female_not_obtained
rename K trans_pop
rename L trans_obtained
rename M trans_not_obtained
*/

********************************************************************************
* Q3
*******************************************************************************
use "$q3", clear

* the name of Review1Score is not alighed with the name of other score columns
rename Review1Score Reviewer1Score

* standardize each score
forvalues i = 1/3 {
	egen stand_r`i'_score = std(Reviewer`i'Score)
}

* average standardized scores
egen average_stand_score = rowmean(stand_*)

* rank the averaged scores
egen rank = rank(average_stand_score)

********************************************************************************
* Q4
*******************************************************************************
use "$q4", clear

* find the table
split s, p("<TABLE")
keep s3

* find each row of table
split s3, p("<TR>")
drop s3 s31 s32
gen number = 1 // generate to be able to reshape
reshape long s, i(number) j(string)
drop number string

* find each cell in each row
split s, p("<P")
drop s s1

* find information in each cell
gen t_schoolcode = substr(s2, 17, 9)
gen cand_id = substr(s2, 27, 4)
gen prem_number = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
split s5, p("</FONT>")
gen name = subinstr(s51,">","", 1)
split s6, p("- ", ",")
gen average = substr(s614, 1, 1)

* rename columns properly
rename s62 kiswahili
rename s64 english
rename s66 maarifa
rename s68 hisabati
rename s610 science
rename s612 uraia
drop s*
rename t_schoolcode schoolcode

