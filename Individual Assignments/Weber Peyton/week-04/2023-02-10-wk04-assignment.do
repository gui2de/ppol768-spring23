*SS 2023 PPOL 768-01; Week 4 Stata Basics Assignment; 
*Author: Peyton Weber
*Revised February 10, 11, 12, 13 2023
*Problem Set Partner: Maeve Grady

clear all
set more off
cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"
*Change working directory 
use "q1_village_pixel.dta", clear

*Question 1, part (a): 
bysort pixel: summarize payout
*Looking at the minimum and maximum of each pixel to see whether or not they are the same. 
gen pixel_inconsistent = 0 
*Generating pixel_inconsistent variable as requested. 
bysort pixel: gen min_payout = r(min)
bysort pixel: gen max_payout = r(max) 
replace pixel_inconsistent = 1 if min_payout != max_payout 
*When this variable is equal to one, the payout is inconsistent within the pixel. 
count if pixel_inconsistent == 1 
*The payouts are all consistent. 


*Question 1, part (b): 
sort village pixel
*Villages are now listed together alongside their corrresponding pixels. 
bysort village (pixel): gen serial = _n
*Creating a new variable that counts the number of times a village is represented by an individual household.  
bysort village (pixel): gen hh_max = _N
*Creating a new variable that keeps track of the largest number of households for each village. 
gen pixel_first = ""
replace pixel_first = pixel if serial==1
*Creating a new variable that's the first pixel if the serial designation is 1. 
gen pixel_last = ""
replace pixel_last = pixel if serial==hh_max
*Creating a new variable representing the last pixel if the serial designation is the same number as the maximum number of households per village. 

replace pixel_first = pixel_first[_n-1] if pixel_first == "" 
*The above command replaces all values in pixel_first with the pixel number of the first HH in a village. 

gen pixel_village = 0
*Generating the pixel_village variable, as requested. 
bysort village: replace pixel_village = 1 if serial == hh_max & pixel_first != pixel_last
*These conditions allow the pixel_village variable to be equal to one if there exists a boundary case. 
 

*Question 1, part (c): 

gen HH_categorical = 0 
*Generating thte categorical variable, as requested. 
replace HH_categorical = 1 if pixel_village == 0
*The above command sets the value equal to one if all village households are in the same pixel.
replace HH_categorical = 2 if pixel_village == 1 & pixel_inconsistent == 0 
*The above command sets the value equal to two if there exist boundary cases in the village BUT have consistent payouts. 
replace HH_categorical = 3 if pixel_village == 1 & pixel_inconsistent == 1
*The above command sets the value equal to three if there exist boundary cases in the village AND there are inconsistent payouts. 


*Question 2: 

ssc install missings
*You can skip this step if you believe you've already installed the missings command in Stata! 

global excel_t21"/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx" 
*update the global

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
	missings dropvars, force // Dropping any columns with completely missing data.  
	rename * v#, addnumber // Adding consecutive numbers to variable names. 
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
rename v# (AGE TOTPOP_ALL CNIOBTAINED_ALL CNINOTOBTAINED_ALL TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans)
*Above command seeks to rename the columns that were not dropped. 
*fix column width issue so that it's easy to eyeball the data
format %40s AGE TOTPOP_ALL CNIOBTAINED_ALL CNINOTOBTAINED_ALL TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans 

sort table
*Sorting the table so that we may see the data in order of each page of the original pdf file that was OCR'd. 
br
*Confirming that the columns have been cleaned up. 

*Question 3

use "q3_grant_prop_review_2022.dta", clear 

rename Rewiewer1 Reviewer1
*Fixing a typo in the variable name. 

*During office hours with Ali on 2/10/2023, we discussed how this assignment would require reshaping the data to calculate the mean and standard deviation values. 

rename Review1Score Score1
rename Reviewer2Score Score2
rename Reviewer3Score Score3
*Preparing variables to reshape data. 

reshape long Reviewer Score, i(proposal_id) j(number)
*The above command reshapes the data and groups together the reviewer scores and reviewers. 

bysort Reviewer: egen stand_score = std(Score) 
*The above command groups the three reviewers and then standardizes the values to create z-scores. 

drop Score

reshape wide stand_score Reviewer, i(proposal_id) j(number) 
*Returning data to original set-up. 

rename stand_score1 stand_1_score
rename stand_score2 stand_2_score
rename stand_score3 stand_3_score
*Renaming the z-scores according to the assignment rules. 

gen avg_stand_score = .
*Generating the average z-scores, as requested. 
replace avg_stand_score = ((stand_1_score + stand_2_score + stand_3_score)/3)

gsort -avg_stand_score
*Sorting the newly created variable from largest to smallest values. 
gen rank = _n
*Creating the rank variable, as requested.
br

*Question 4:

use "q4_Tz_student_roster_html.dta", clear
codebook s 

*Checking out the data 

*Please note: The following code for question four is heavily relied upon office hours notes with Ali on 2/10/2023, as well as collaboration with PS partner, Maeve.

gen str_pos = strpos(s, "SUBJECTS")
replace s = substr(s,strpos(s,"SUBJECTS"),.)
split s, parse("</TD></TR>")
*The above commands are dropping anything that came before "SUBJECTS." 

gen i = _n 
drop s
reshape long s, i(i) j(j)
*The above commands are used to reshape the data to ensure each row is a unique observation. 

split s, parse("</FONT></TD>")
drop s str_pos

*The above split and parse commands serve to create unique columns for the observations to be sorted into. 

keep if j >=2
keep if j <=17
*Keep is the opposite command to drop. This command is asking Stata to keep everything, with the exceptions of the rows without observations. 

split s1 , p("CENTER")
drop s11
split s12 , p(>)
drop s1 s12 s121
rename s122 candidate_num
*Creating candidate number column. 

split s2 , p("CENTER")
drop s21
split s22 , p(>)
drop s2 s22 s221
rename s222 prem_num
*Creating prem_num column. 

split s3 , p("CENTER")
drop s31
split s32 , p(>)
drop s3 s32 s321
rename s322 gender
*Creating gender column. 

split s4 , p("<P>")
drop s41
rename s42 candidate_name
drop s4
*Creating candidate name column. 

split s5 , p("LEFT")
drop s51
split s52 , p(>)
drop s5 s52 s521
split s522 , p("<")
rename s5221 grades
drop s5222 s522
*Creating grades column. 

split grades , p(,)
	
split grades1 , p(-)
rename grades12 Kiswahili
drop grades1 grades11
*Creating Kiswahili grades column. 
	
split grades2 , p(-)
rename grades22 English
drop grades2 grades21
*Creating English grades column. 
	
split grades3 , p(-)
rename grades32 Maarifa
drop grades3 grades31
*Creating Maarifa grades column. 
	
split grades4 , p(-)
rename grades42 Hisbati
drop grades4 grades41
*Creating Hisbati grades column. 
	
split grades5 , p(-)
rename grades52 Science
drop grades5 grades51
*Creating Science grades column. 
	
split grades6 , p(-)
rename grades62 Uraia
drop grades6 grades61
*Creating Uraia grades column. 
	
split grades7 , p(-)
rename grades72 Avg_Grade
drop grades7 grades71
*Creating average grades column. 
	
drop grades i j
*Cleaning up variables that are no longer needed that were created when reshaping the data.  




