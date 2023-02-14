// Hannah Hill //
// February 13, 2023 //
// Week 04 Assignment //


*******************************************************************************
** 1A): Generate Dummy Variable pixel_consistent                             **
*******************************************************************************
use "q1_village_pixel.dta", clear

// Confirm that payout is consistent within a pixel:
tab pixel payout
// All pixels have consistent payout.


// generate new dummy variable for when payout is not consistent across pixels
gen pixel_consistent = 0 if payout == 0 | payout == 1
replace pixel_consistent = 1 if payout == 0 & payout == 1
tab pixel_consistent
// All pixels indeed have consistent payout. This new dummy variable will indicate whether or not any future pixels have varying payouts.


*******************************************************************************
** 1B): Generate Dummy Variable pixel_village                                **
*******************************************************************************
// check to see if edge cases exist //
bysort village: tab pixel

// gen variables to compare //
bysort village (pixel): gen serial = _n
bysort village (pixel): gen hh_max = _N
gen pixel_first = "."
replace pixel_first = pixel if serial == 1
gen pixel_last = "."
replace pixel_last = pixel if serial == hh_max

// set up pixels of first hh by village //
replace pixel_first = pixel_first[_n-1] if pixel_first == "."
gen pixel_village = 0
bysort village: replace pixel_village = 1 if serial == hh_max & pixel_first != pixel_last


*******************************************************************************
** 1C): Village Categories                                                   **
*******************************************************************************
// create base indicator //
gen hh_category = 0

// generate mutually exclusive categories //
replace hh_cat = 1 if pixel_village == 0
replace hh_cat = 2 if pixel_village == 1 & pixel_consistent == 0
replace hh_cat = 3 if pixel_village == 1 & pixel_consistent == 1

// verify //
sum hh_category
tab pixel_village pixel_consistent

*******************************************************************************
** 2):  National IDs in Pakistan                                             **
*******************************************************************************
global excel_t21 "C:\week-04\03_assignment\01_data\q2_Pakistan_district_table21.xlsx"
clear
// set up tempfile //
tempfile table21
save `table21', replace emptyok

forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	// need to drop empty columns that were generated 
	missings dropvars, force  
	// need to add numbers to vars
	rename * v#, addnumber
			
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear

// rename numbers to corresponding variable names
	rename v# (AGEGROUP TOTPOP_allsexes CNIOBTAINED_allsexes CNINOTOBTAINED_allsexes TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans)
*fix column width issue so that it's easy to eyeball the data
format %40s AGEGROUP TOTPOP_allsexes CNIOBTAINED_allsexes CNINOTOBTAINED_allsexes TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans

// organize table
sort table


*******************************************************************************
** 3):  Faculty Funding Proposals                                            **
*******************************************************************************
use "q3_grant_prop_review_2022.dta", clear

// rename variables //
rename Rewiewer1 Reviewer1
rename Review1Score Score1
rename Reviewer2Score Score2
rename Reviewer3Score Score3

// Reshape the data to get the unique reviews in each rows //
reshape long Reviewer Score, i(proposal_id) j(number)

// Generate variable needed to normalize each reviewer's score //
bysort Reviewer: egen stand_score = std(Score)
drop Score

// want proposal_id as unit of obs, then rename//
reshape wide stand_score Reviewer, i(proposal_id) j(number)
rename (stand_score#) (stand_r#_score)

// calculate avg stand_score //
gen average_stand_score = .
replace average_stand_score = ((stand_r1_score + stand_r2_score +stand_r3_score)/3)

// calculate rank //
gsort -average_stand_score
gen rank = _n


*******************************************************************************
** 4):  Student Data from Tanzania                                           **
*******************************************************************************
use "q4_Tz_student_roster_html.dta", clear

gen str_pos = strpos(s, "SUBJECT")
replace s = substr(s, strpos(s, "SUBJECT"), . )
split s, parse("</TD></TR>")

//reshape data to expand unique observations into rows/
gen i = _n
drop s
reshape long s, i(i) j(j)

//parse variables to create columns//
split s, parse("</FONT></TD>")
drop s
drop str_pos


//delete rows without data//
keep if j >= 2
keep if j <= 17

//parse through html variable by variable//

	//cand_id//
	split s1 , p("CENTER")
	drop s11
	split s12 , p(>)
	drop s1
	drop s12
	drop s121
	rename s122 cand_id

	//prem_number//
	split s2 , p("CENTER")
	drop s21
	split s22 , p(>)
	drop s2
	drop s22
	drop s221
	rename s222 prem_number
	
	//gender//
	split s3 , p("CENTER")
	drop s31
	split s32 , p(>)
	drop s3
	drop s32
	drop s321
	rename s322 gender
	
	//name//
	split s4 , p("<P>")
	drop s41
	rename s42 name
	drop s4

	//grades//
	split s5 , p("LEFT")
	drop s51
	split s52 , p(>)
	drop s5
	drop s52
	drop s521
	split s522 , p("<")
	rename s5221 grades
	drop s5222
	drop s522

// split grades //

	split grades , p(,)
	
	split grades1 , p(-)
	rename grades12 Kiswahili
	drop grades1
	drop grades11
	
	split grades2 , p(-)
	rename grades22 English
	drop grades2
	drop grades21
	

	split grades3 , p(-)
	rename grades32 Maarifa
	drop grades3
	drop grades31
	
	split grades4 , p(-)
	rename grades42 Hisbati
	drop grades4
	drop grades41
	
	split grades5 , p(-)
	rename grades52 Science
	drop grades5
	drop grades51
	
	split grades6 , p(-)
	rename grades62 Uraia
	drop grades6
	drop grades61
	
	split grades7 , p(-)
	rename grades72 Average_Grade
	drop grades7
	drop grades71
	
// finish dropping unecessary columns //
	drop grades
	drop i
	drop j

// split cand_id into school code and actual cand_id //
	split cand_id , p(-)
	rename cand_id1 schoolcode
	drop cand_id
	rename cand_id2 cand_id