/* Week 4 Assignment - cmg340 */

/* Setup */


cd "C:\Users\Maeve\GitHub\ppol768-spring23\Individual Assignments\Grady Maeve\week-04\03_assignment\01_data"

use "q1_village_pixel.dta", clear
br 

/* ## Q1 Crop Insurance in Kenya */

	/*A*/
	bysort pixel: summ payout
	gen pixel_consistent = 0
	bysort pixel: gen min_payout = r(min) 
	bysort pixel: gen max_payout= r(max) 
	bysort pixel: replace pixel_consistent = 1 if min_payout < max_payout  

	
	/*B*/
	/*first checking tab to see examples of edge cases */ 
	bysort village: tab pixel
	

	
	/*now generating new indicator for when housholds from a village are in more than one pixel*/
	
	/*first generating two columns to compare the first hh in a village and last hh in a village*/
	bysort village (pixel): gen serial = _n
	bysort village (pixel): gen hh_max = _N
	
	/*creating columns that are the pixel value for the first and last hh in each village*/
	gen pixel_first = "."
	replace pixel_first = pixel if serial == 1
	
	gen pixel_last = "."
	replace pixel_last = pixel if serial == hh_max
	
	/*replacing all values in Pixel_first with the pixel value of the first hh in a village, by village */
	replace pixel_first = pixel_first[_n-1] if pixel_first == "."
	
	/*generating the indicator column requested in question*/
	gen pixel_village  = 0 
	bysort village: replace pixel_village  = 1 if serial == hh_max & pixel_first != pixel_last
	
		
	/*C*/
	/* creating mutually exclusive hh categories*/
	gen hh_cat = 0
	replace hh_cat = 1 if pixel_village == 0 
	replace hh_cat = 2 if pixel_village == 1 & pixel_consistent == 0
	replace hh_cat = 3 if pixel_village == 1 & pixel_consistent == 1 
		
	sum hh_cat 
	/*checking if consistent with crosstab*/
	tab pixel_village pixel_consistent
	
/* ## Q2 National IDs in Pakistan */

/* need to extract columns 2-13 from each table*/
global excel_t21 "C:\Users\Maeve\GitHub\ppol768-spring23\Individual Assignments\Grady Maeve\week-04\03_assignment\01_data\q2_Pakistan_district_table21.xlsx"


clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok


forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number /// full value is 135

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	/*dropping empty columns*/
	missings dropvars, force  
	/*adding sequential numbers to var names*/
	rename * v#, addnumber
			
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear

/*renaming vars with actual variable names*/
	rename v# (AGEGROUP TOTPOP_allsexes CNIOBTAINED_allsexes CNINOTOBTAINED_allsexes TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans)
*fix column width issue so that it's easy to eyeball the data
format %40s AGEGROUP TOTPOP_allsexes CNIOBTAINED_allsexes CNINOTOBTAINED_allsexes TOTPOP_male CNIOBTAINED_male CNINOTOBTAINED_male TOTPOP_female CNIOBTAINED_female CNINOTOBTAINED_female TOTPOP_trans CNIOBTAINED_trans CNINOTOBTAINED_trans

sort table
br

/* ## Q3 Faculty Funding Proposals */
use "q3_grant_prop_review_2022.dta", clear

br 
** have to lengthen to include multiple rounds then use egen commands to figure out mean and standard deviation. then we can merge back to original dataset using the proposal id 

/*renaming vars so that reshape works*/
rename (Rewiewer1 Review1Score Reviewer2Score Reviewer3Score ) (Reviewer1 Score1 Score2 Score3 )

/*reshaping to long so that we can account for the reviews from all rounds when grouping by reviewer*/
reshape long  Reviewer Score, i(proposal_id) j(num) 

/*grouping by reviewer and creating standardized scores (z-score) creating list in summarize step is helpful to check that the correct calculation has been made*/
sort Reviewer
bysort Reviewer: summarize Score  
bysort Reviewer: egen stand_score = std(Score)

/*dropping Score*/
drop Score

/*reshaping to wide to have proposal_id be unit of observation*/
reshape wide  stand_score Reviewer, i(proposal_id) j(num)

/*renaming columns*/
rename (stand_score#) (stand_r#_score)

/*average stand score calculation*/
gen average_stand_score = .
replace average_stand_score = ((stand_r1_score + stand_r2_score +stand_r3_score)/3)

/*generating rankings*/
gsort -average_stand_score
gen rankings = _n



/* ## Q4 Student Data from Tanzania */

use "q4_Tz_student_roster_html.dta", clear


/* dropping everything before "subject" since that's what we're interested in  and parsing using the line breaks TD /TR */
gen str_pos = strpos(s, "SUBJECT")
replace s = substr(s, strpos(s, "SUBJECT"), . )
split s, parse("</TD></TR>")

/*reshaping so that each row is a different observation*/
gen i = _n
drop s
reshape long s, i(i) j(j)

/*parsing to get variables into unique columns*/
split s, parse("</FONT></TD>")
drop s
drop str_pos


/*getting rid of non-observation rows*/
keep if j >= 2
keep if j <= 17

/*getting rid of the html formatting one var at a time*/

	/*cand_no*/
	split s1 , p("CENTER")
	drop s11
	split s12 , p(>)
	drop s1
	drop s12
	drop s121
	rename s122 cand_no

	/*prem_no*/
	split s2 , p("CENTER")
	drop s21
	split s22 , p(>)
	drop s2
	drop s22
	drop s221
	rename s222 prem_no
	
	/*Sex*/
	split s3 , p("CENTER")
	drop s31
	split s32 , p(>)
	drop s3
	drop s32
	drop s321
	rename s322 sex
	
	/*name*/
	split s4 , p("<P>")
	drop s41
	rename s42 cand_name
	drop s4

	/*grades*/
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

/*parsing grades into columns by subject, renaming columns and making contents just the grad as opposed to subject and grade*/

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
	
	drop grades
	drop i
	drop j

	/*i'm sure there was a more elegant way to do this, but this does work!*/

	br