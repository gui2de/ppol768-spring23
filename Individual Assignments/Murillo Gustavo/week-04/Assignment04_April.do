*******************************************************************************
*** PPOL 768-01
*** Student: Gustavo Murillo Velazquez
*** Week 04 Assignment
*******************************************************************************


** Setting A Global Working Directory
clear
global wd "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-04/"

** Setting Global Datasets

global Villages "$wd/q1_village_pixel"
global Grant "$wd/q3_grant_prop_review_2022"
global Tanzania "$wd/q4_Tz_student_roster_html"

************************** Question 1 ****************************************

use "$Villages", clear
describe
codebook

** Q1a

bysort pixel: egen pixel_pay_min = min(payout)
bysort pixel: egen pixel_pay_max = max(payout)

gen pixel_consistent = 0 if pixel_pay_min == pixel_pay_max
replace pixel_consistent = 1 if pixel_pay_min != pixel_pay_max
tab pixel_consistent

** We can confirm that all payouts are consistent with the pixel


*** Failed attempt at another approach using mean that I was trying

* bysort pixel: egen payoutmean = mean(payout)
* gen pixel_consistent = 1
* replace pixel_consistent = 0 if payoutmean != 0 | payoutmean != 1

*** What I was trying to do is: Mean has to be either 0, or 1, if it's different (probably a decimal), it should be labeled as inconsistent. 


**Q1b

order village pixel
encode pixel, gen(pixelfreq)
bysort village: egen pixelfreq_min = min(pixelfreq)
bysort village: egen pixelfreq_max = max(pixelfreq)

gen pixel_unique = 0 if pixelfreq_min == pixelfreq_max
replace pixel_unique = 1 if pixelfreq_min != pixelfreq_max
tab pixel_unique


**Q1c 

gen partpixel= 1 if pixel_unique == 0
replace partpixel = 2 if pixel_unique == 1 & pixel_consistent == 0
replace partpixel = 3 if pixel_unique == 1 & pixel_consistent == 1

 
************************** Question 2 ****************************************


import excel "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-04/q2_Pakistan_district_table21.xlsx", sheet("Table 1") firstrow

use "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q1_village_pixel.dta", clear



** Question 2

global excel_t21"/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
	foreach var of varlist * {
    qui count if missing(`var')
    if r(N) > 0 {
        drop `var'
    }
}
	foreach var of varlist * {
    rename `var' to column_1
}

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data

*load the tempfile
use `table21', clear

*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

drop table21
drop table21

*Here I got stuck

************************** Question 3 ****************************************

use "$Grant", clear

*3.1, 3.2, 3.3

*Renaming the Review1Score variable to match the three needed variables
rename Review1Score Reviewer1Score

*Generating the mean score for each Reviewer
forvalues i=1/3 {
		egen meanR`i' = mean(Reviewer`i'Score)
			}
*Generating the standarized scores
forvalues i=1/3 {
		gen stand_r`i'_score = (Reviewer`i'Score-meanR`i')/StandardDeviation
			}

*3.4
egen average_stand_score = rowmean(stand_r`i'_score)

*3.5
egen rank = rank(average_stand_score)


************************** Question 4 ****************************************

use "$Tanzania", clear

** Following Ben's Example

split s , parse(">PS")

* Reshaping the data to make sure that all rows corresponds to unique observations

gen serial = _n
drop s
reshape long s, i(serial) j(student)  

*Determining how to break the data into rows/ observations

split s , parse("<")


keep s1 s6 s11 s16 s21
drop in 1

ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)
compress

replace cand = "PS" + cand
replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
replace sex  = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name,`"P>"',"",.)
replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

compress

split subjects , parse(",")

  foreach var of varlist subjects* {
    replace `var' = substr(`var',-1,.)
  }
  
compress


////////////////////////
// Failed own attempt
////////////////////////

use "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q4_Tz_student_roster_html.dta", clear

*Cleaning the data to keep only relevant information (deleting everything that is before SUBJECTS=
gen subject_position = strpos(s, "SUBJECTS")
gen new_string = substr(s, 3852, .)
replace s = substr(s, strpos(s,"SUBJECT"), .)

*Breaking the data into rows/ observations
split s, parse("</TD></TR>")

* Reshaping the data to make sure that all rows corresponds to unique observations
gen serial = _n
drop s
reshape long s, i(serial) j(j)

*Dropping observations with no data
drop if _n == _N | _n == | 

*Splitting the data in a more clean version
split s, parse("<")


