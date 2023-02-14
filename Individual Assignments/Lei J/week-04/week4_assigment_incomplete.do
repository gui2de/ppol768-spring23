
*Question 1 


*a)
use "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\q1_village_pixel.dta", clear
gen pixel_consistent=0
bysort pixel: egen payout_min=min(payout)
bysort pixel: egen payout_max=max(payout)
replace pixel_consistent=1 if payout_min==payout_max
* If the maximum payout and the minimum payout are the same within a pixel, the payout numbers must be consistent. Since there all have same minimum payout and maximum payout,t it is the case that they are consistent.*

*b
encode pixel, gen(pixel_id)
by village pixel_id, sort:gen nvals=_n==1
by village: replace nvals=sum(nvals)
by village: replace nvals = nvals[_N] 
gen pixel_village=0
replace pixel_village=1 if nvals>1

*c
gen catogory=0
replace catogory=1 if pixel_village==0
gen village_consistent=0
bysort village: egen vpayout_min=min(payout)
bysort village: egen vpayout_max=max(payout)
replace village_consistent=1 if vpayout_max==vpayout_min
replace catogory=2 if pixel_village==1&village_consistent==1
replace catogory=3 if pixel_village==1&village_consistent==0
tab catogory, missing

Question 2

global excel_t21 "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\q2_Pakistan_district_table21.xlsx"
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
	foreach var in varlist*{
		if var=.,drop
	}
	foreach var in varlist*{
	rename
	}
	drop 
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

Question 3
cd "/Users/al/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use q3_grant_prop_review_2022.dta, clear
rename Rewiewer1 Reviewer1
rename Review1Score ReviewerScore1

rename Reviewer2Score ReviewerScore2
rename Reviewer3Score ReviewerScore3
*rename to make it possible to reshape 
reshape long Reviewer ReviewerScore, i(proposal_id)
bysort Reviewer: egen meanscore=mean(ReviewerScore)
bysort Reviewer: egen sd_score=sd(ReviewerScore)
gen norm_score=(ReviewerScore -meanscore )/sd_score
drop meanscore sd_score 
*find the normalized score with z-score method
reshape wide Reviewer ReviewerScore norm_score, i(proposal_id)
gen average_standard_score=(norm_score1+norm_score2+norm_score3)/3
rename norm_score1 standard_r1_score
rename norm_score2 standard_r2_score
rename norm_score3 standard_r3_score
*reshape it back and change the name to required names.
egen rank= rank(-average_standard_score)
sort rank
*make the rank 


Question 4 

use "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\q4_Tz_student_roster_html.dta", clear

gen subject_position = strpos(s, "SUBJECT")

replace s =substr(s, strpos(s, "SUBJECT"),.)

split s, parse("</TD></TR>")

gen serial = _n
drop s
reshape long s, i(serial) j(j)

exit 
substr("abcdef", 2,3)="bcd"