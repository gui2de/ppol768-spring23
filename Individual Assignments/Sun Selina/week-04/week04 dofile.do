global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-04"

global q1 "$wd/q1_village_pixel.dta"
global q3 "$wd/q3_grant_prop_review_2022.dta"
global q4 "$wd/q4_Tz_student_roster_html.dta"


*Questin 1
use "$q1", clear

*1a.payout variable be consistent within a pixel
encode pixel, gen (pixel_str)
sort pixel_str payout
bysort pixel_str: egen pixel_payout_min=min(payout)
bysort pixel_str: egen pixel_payout_max=max(payout)
gen pixel_consistent = 1
replace pixel_consistent = 0 if pixel_payout_max == pixel_payout_min

*1b.village and pixel consistency
sort village pixel 
bysort village: egen village_pixel_min=min(pixel_str)
bysort village: egen village_pixel_max=max(pixel_str)
gen pixel_village = 1 
replace pixel_village = 0 if village_pixel_max == village_pixel_min

*1c.village's pixel and payout consistency 
sort village payout
bysort village: egen village_payout_min = min(payout)
bysort village: egen village_payout_max = max(payout)
gen village_payout = 1
replace village_payout = 0 if village_payout_min == village_payout_max 

gen household = 0 
replace household = 1 if pixel_village == 0
replace household = 2 if pixel_village == 1 & village_payout == 0
replace household = 3 if pixel_village == 1 & village_payout == 1 
tab household 

gen hhid_village = hhid if household == 2

clear

*Question 2
ssc install missings
global excel_t21 "$wd/q2_Pakistan_district_table21.xlsx"
*update the global

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number /// full value is 135

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21 
    *tried to write loop to discard missing values, after googling, chose the shortcut by installing 'missings' package to remove missing values...but still it showed 29 variable...
	missings dropvars, force 
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear

sort table


*Question 3
use "$q3", clear
*sort variable names for reshape and pivot 
rename (Rewiewer1 Review1Score Reviewer2Score Reviewer3Score ) (Reviewer1 Score1 Score2 Score3 )
*pivot the table, sorted by reviewer to calculate standardized score 
reshape long Reviewer Score, i(proposal_id) j(order)

bysort Reviewer: egen std_score = std(Score)

drop Score

*reshape into original table to recalculate the average score 
reshape wide std_score Reviewer, i(proposal_id) j(order)

*rename standarized reviewer scores 
rename (std_score1 std_score2 std_score3) (stand_r1_score stand_r2_score stand_r3_score)

*calculate average standardized score for each proposal 
bysort proposal_id: egen average_stand_score = mean(stand_r1_score+stand_r2_score+stand_r3_score)

*generate proposal ranking based on average standarized score in descending order
egen rank = rank(-average_stand_score)

*Question 4
use "$q4", clear

replace s = substr(s, strpos(s, "SUBJECT"), .)

split s, parse("</TD></TR>") 

gen serial = _n

drop s 

reshape long s, i(serial) j(string)


*tried my best...
