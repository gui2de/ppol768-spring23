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
	display as error `i' //display the loop number
	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
 
 *I know a loop that check missing value could solve the problem. I tried but I failed. Tried "" and >=. and destring then drop missing. Finally, I took a shortcut by install a package called 'missings'
    missings dropvars, force
*compress and align rows that have droped missing values for future append. help rename no.18 change alphabetic variable names into numbers 
	rename (*) (var#), addnumber 
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
format %10s var1-var13 
rename var1 age 
rename var2 total_pop 
rename var3 CNI_obtained 
rename var4 CNI_NOT_obtained 
rename var5 total_pop_male 
rename var6 CNI_obtained_male 
rename var7 CNI_NOT_obtained_male 
rename var8 total_pop_female 
rename var9 CNI_obtained_female 
rename var10 CNI_NOT_obtained_female 
rename var11 total_pop_trans 
rename var12 CNI_obtained_trans 
rename var13 CNI_NOT_obtained_trans

order table, first
format %10.0g table
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
*split each line 
split s, parse("</TD></TR>") 
gen serial = _n
drop s 
reshape long s, i(serial) j(observation)
*break strings 
split s, parse("><P")
drop s 
*substract string to get variable we want 
gen cand_No = substr(s2,17,14)
gen prem_No = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
*remove the tail of name, split again
split s5, parse("</FONT>")
drop s52
gen name = substr(s51,2,.)
*remove the tail of subject, split again. now I think I should do the spilt///
*in the parse ("</TD></TR>")but I think this conclusion could only be drawn///
*after I parse the long string
split s6, parse("</FONT>")
gen grade = substr(s61, 15,.)
*sort table 
drop s*
drop observation 
keep in 2/17
gen schoolcode = substr(cand_No, 1, 9)
order schoolcode, first
