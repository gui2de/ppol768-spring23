global wd "/Users/liufan/Desktop/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"
global q1 "$wd/q1_village_pixel.dta"
global q2 "$wd/q2_Pakistan_district_table21.xlsx"
global q3 "$wd/q3_grant_prop_review_2022.dta"
global q4 "$wd/q4_Tz_student_roster_html.dta"

//Q1 : Crop Insurance in Kenya
use "$q1", clear 

//a)
bysort pixel: egen min_payout = min(payout)
bysort pixel: egen max_payout = max(payout) 
gen pixel_consistent = cond(min_payout == max_payout, 0, 1)
drop min_payout max_payout

//b)
gen last_pixel = substr(pixel,-1,1)
destring last_pixel, replace force
bysort village: egen mean_last_pixel = mean(last_pixel)
gen pixel_village = cond(mean_last_pixel == last_pixel, 0, 1)
drop last_pixel mean_last_pixel

//c)
gen category = 0
replace category  = 1 if pixel_village == 0  
replace category  = 2 if pixel_village == 1 & pixel_consistent == 0 
replace category  = 3 if pixel_village == 1 & pixel_consistent == 1 
 
//Q2 : National IDs in Pakistan
clear
tempfile table21
save `table21', replace emptyok
forvalues i=1/135 {
	import excel "$q2", sheet("Table `i'") firstrow clear allstring //import
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
rename v# (Age Total_pop CNI_obtained CNI_not_obtained Total_pop_male CNI_obtained_male CNI_not_obtained_male Total_pop_female CNI_obtained_female CNI_not_obtained_female Total_pop_trans  CNI_obtained_trans CNI_not_obtained_trans)
format %10s Age Total_pop CNI_obtained CNI_not_obtained Total_pop_male CNI_obtained_male CNI_not_obtained_male Total_pop_female CNI_obtained_female CNI_not_obtained_female Total_pop_trans  CNI_obtained_trans CNI_not_obtained_trans 
order table, first
sort table
drop table


//Q3 : Faculty Funding Proposals
use "$q3", clear 
rename (Rewiewer1 Review1Score Reviewer2Score Reviewer3Score) (Reviewer1 S1 S2 S3) 
reshape long Reviewer S, i(proposal_id) j(number) 
bysort Reviewer: egen stand_score = std(S) 
drop S
reshape wide stand_score Reviewer, i(proposal_id) j(number) 
rename (stand_score#) (stand_r#_score) 
gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3
gsort -average_stand_score 
gen rank = _n 

//Q4 : Student Data from Tanzania
use "$q4", clear
split s, parse(<TABLE) 
keep s3
split s3, parse(<TR>)
drop s31 s32 s3
gen i = _n
reshape long s, i(i) j(string) 
drop i
split s, parse(<P)
split s5, p("</FONT>")
gen t_schoolcode = substr(s2, 17, 9)
gen cand_id = substr(s2, 27, 4)
gen prem_number = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
gen name = subinstr(s51,">","", 1)
split s6, p("- ", ",")
gen average = substr(s614, 1, 1)
rename s62 Kiswahili
rename s64 English
rename s66 Maarifa
rename s68 Hisabati
rename s610 Science
rename s612 Uraia
drop s*
rename t_schoolcode schoolcode
