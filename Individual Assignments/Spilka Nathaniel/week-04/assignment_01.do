*******************************************************************************
** clean workspace, set dir, load data, quick view of data
*******************************************************************************
* nate spilka
* 2023-03-22

* clean workspace 
cls
clear all

* set dir
cd "/Users/nathanielhugospilka/Documents/research_methods_2023/research_design/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/"

*******************************************************************************
** Q1 : Crop Insurance in Kenya
*******************************************************************************

* load data
use q1_village_pixel.dta, clear

* quick data overview
browse
describe
summarize

* a) The payout variable is consistent within pixels
tab pixel payout

* finding the sd of payout by pixel - 0's everywhere since it's all consistent
egen ind_pixel = sd(payout), by(pixel)
generate pixel_consistent = 0 
replace pixel_consistent = 1 if ind_pixel == 1

* to confirm
tab pixel pixel_consistent

*******************************************************************************

* b)
tab village pixel

* turning pixel into a numeric so we can treat it similar to the process above
encode pixel, gen(pixel_num)
egen ind_2 = sd(pixel_num), by(village)
generate pixel_village = 1 
replace pixel_village = 0 if ind_2 == 0 | ind_2 == .

*******************************************************************************

* c) 
generate indicator_1c = 1 if pixel_village == 0
replace indicator_1c = 2 if pixel_village == 1 & pixel_consistent == 0
replace indicator_1c = 3 if pixel_village == 1 & pixel_consistent == 1

*******************************************************************************
** Q2 : National IDs in Pakistan
*******************************************************************************

cls
clear all

* load data
global excel_t21 "q2_Pakistan_district_table21.xlsx"

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i = 1/135 {
	
	qui import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	qui display as error `i' //display the loop number

	qui keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND" ) == 1 //keep only those rows that have "18 AND"
	
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	qui keep in 1 //there are 3 of them, but we want the first one
	qui rename TABLE21PAKISTANICITIZEN1 table21

	* remove empty cells (an attempt)
	qui missings dropvars, force
	
	qui gen table = `i' //to keep track of the sheet we imported the data from
	qui append using `table21' 
	qui save `table21', replace //saving the tempfile so that we don't lose any data
}

*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB

*******************************************************************************
** Q3 : Faculty Funding Proposals
*******************************************************************************

cls
use q3_grant_prop_review_2022.dta, clear

* change the column names to lowercase
rename *, lower

* get the column means and stds
egen mean1 = mean(review1score)
egen sd1 = sd(review1score)

egen mean2 = mean(reviewer2score)
egen sd2 = sd(reviewer2score)
 
egen mean3 = mean(reviewer3score)
egen sd3 = sd(reviewer3score)

* standardize the scores 
generate stand_r1_score = (review1score - mean1)/sd1
generate stand_r2_score = (reviewer2score - mean2)/sd2
generate stand_r3_score = (reviewer3score - mean3)/sd3

* get the overall average (across the three reviews)
egen double average_stand_score = rowmean(stand_r1_score stand_r2_score stand_r3_score)

* rank the overall average values
egen rank = rank(-average_stand_score) 

*******************************************************************************
** Q4 : Student Data from Tanzania
*******************************************************************************

* clear workspace and load in data
cls
use q4_Tz_student_roster_html.dta, clear

* parse out students columnwise
split s, parse(">PS")

* generate another value to reshape by
generate val = 1 

* drop before reshaping
drop s 

* flip the participant columns to become rows
reshape long s, i(val) j(student)

* Disaggregate cells further
split s, parse("<")

* remove the first row/header
drop in 1 

* rename variables 
rename s1 cand_id
rename s6 prem_number
rename s11 gender
rename s16 name
rename s21 grade

* only keep relevant variables
keep cand_id prem_number gender name grade 

* more cleaning
replace prem_number = subinstr(prem_number, `"P ALIGN="CENTER">"', "", .)
replace gender = subinstr(gender, `"P ALIGN="CENTER">"', "", .)
replace name = subinstr(name, "P>", "", .)
replace grade = subinstr(grade, `"P ALIGN="LEFT">"', "", .)

* parsing out the different classes
split grade, parse(",")

* taking the last string value (-1) of the cells (i.e., the grade)
foreach var of varlist grade* {
	replace `var' = substr(`var', -1, 1)
}

* renmae the subjects
rename (grade1 grade2 grade3 grade4 grade5 grade6 grade7) ///
(kiswahili english maarifa hisabati science uraia average)

* this is no longer needed
drop grade 



