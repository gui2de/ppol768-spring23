clear all
cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use q1_village_pixel.dta


*Q1. You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

/*a)	Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (`pixel_consistent`), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel) */
*by mpg, sort: egen mean_w = mean(weight)//code to augment
by pixel, sort: egen meanpayout = mean (payout) 
gen pixel_consistent=0
replace pixel_consistent=1 if meanpayout==1
*list village if pixel_consistent==1 


//attempted code:
*gen pixelmin=0 if payout==0 //attempted code
*replace pixelmin=1 if payout==1
*gen pixelmax=0 if payout==0
*replace pixelmax=1 if payout==1
*I don't know why this is only generating missing values
*gen pixelmax=0 if payout==1 //part of the attempt made earlier//
*display pixel_consistent

/*b)	Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (`pixel_village`), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level. */

codebook village 
codebook pixel
by village(pixel), sort: gen pixel_village=pixel[1]!=pixel[_N]
	/*I do not fully understand why the addition of !=pixel changes the 	variable to 0 or 1*/
browse pixel_village village
list village if pixel_village==1
	//unsure how to make it print only one time
	
*by village, sort: tab (pixel), row
	//using to physically check if the list seems to be consistent
	
	
//Attempted code below: 
*bysort village
*encode pixel, generate(pixel_2)
*list village pixel_2
*gen pixel_village=if !=pixel[_N]
*replace pixel_village=1 if pixel==[_N] 
*list pixel_village!=1
/*sum pixel(_N)
*sum pixel_2 by village
*gen number_pixel=pixel(_N)
*count pixels per village
*reshape long a b, if, i(pixel) 
*display rowtotal(pixel)
replace pixel_village=1 if percent!=100 */ 


/*c)	For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:  
I.	Villages that are entirely in a particular pixel. (==1)  
II.	Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)  
III.	Villages that are in different pixels AND have different payout status (==3)  
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories. */


gen hhid_village=0
replace hhid_village=1 if pixel_village==0
//in q1b a 0 means that the village is only in one pixel, so to make the hhid_village consistent 
list village if hhid_village==1

replace hhid_village=2 if pixel_village==1 & pixel_consistent==0
replace hhid_village=3 if pixel_village==1 & pixel_consistent==1
list village if hhid_village==2
list village if hhid_village==3
list village if hhid_village!=1 &hhid_village!=2 & hhid_village!=3



clear all
/* Q2 : National IDs in Pakistan
We have the information of adults that have computerized national ID card in the following pdf: [Pakistan_district_table21.pdf](01_data/q2_Pakistan_district_table21.pdf). This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.*/


clear all
global excel_t21 "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
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

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
	
	*edit table21
egen everything=concat(*), p(|) //notes from office hours on reordering
replace everything=subinstr(everything, " ", "", .)
replace everything=subinstr(everything, "-", "", .)
forvalues i=1/20{
	replace everything=subinstr(everything, "||", "|", .)
} 
keep everything
split everything, parse(|) generate(newv) limit(13)

}
save `table21', replace//*load the tempfile
*use table21.dta, clear
*browse table21
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s `table21' B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC
drop everything
rename newv1 age
rename newv2 total_pop 
rename newv3 CNI_obt 
rename newv4 CNI_no 
rename newv5 male_pop
rename newv6 mCNI_obt 
rename newv7 mCNI_no 
rename newv8 female_pop
rename newv9 fCNI_obt 
rename newv10 fCNI_no 
rename newv11 transg_pop 
rename newv12 tCNI_obt 
rename newv13 tCNI_n

/*attempted code
*split everything //generates variable everything1
/*does not work when I run the code top to bottom, have to run everything starting from egen everything one line at a time...unsure why*/
*destring everything1, force replace 
*global cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23"
*use "Class Materials/week-04/03_assignment/hint_q2.do",clear 
*do hint_q2.do 
*do "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/hint_q2.do" //trying to call and run the hint do file 
*labels to replace the columns with: age total_pop CNI_obt CNI_no male_pop mCNI_obt mCNI_no female_pop fCNI_obt fCNI_no transg_pop tCNI_obt tCNI_no
*append using `table21', force 
*save `table21' 
*drop `table21'
*ignore("18ANDABOVE","OVERALL18ANDABOVE")//tried to use in place of force and didn't work
*generate `table21'
*drop `table21' 
*replace everything1
*replace `table21'
*destring everything, replace
*save table21,replace
*edit table21
*/


*Q3.
/*Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)*/
clear all

cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use q3_grant_prop_review_2022.dta

compress
browse //to look at the current set up of the data
//unclear what it means to normalize with respect to a reviewer...
//I am assuming that the way to standardize each review score we subtract the average review score from the review score present and divide it by the standard deviation of each respective review 
//128*3=# of reviews, divided by 24 proposals per student=16 students
rename Rewiewer1 Reviewer1
*rename Review1Score Reviewer1Score
rename Review1Score ReviewScore1
rename Reviewer2Score ReviewScore2
rename Reviewer3Score ReviewScore3
sort Reviewer1 Reviewer2 Reviewer3
*sort Reviewer1Score Reviewer2Score Reviewer3Score
drop PIName Department
*gen Reviewers=0
*replace Reviewers
*stack Reviewer1 Reviewer2 Reviewer3, into (Reviewers) 
*keep Reviewers Reviewer1Score Reviewer2Score Reviewer3Score //does not work
*stack Reviewer1Score Reviewer2Score Reviewer3Score, into (Scores)
//maybe should use reshape instead but had very little luck...

reshape long Reviewer ReviewScore, i(proposal_id) j(rev_iteration) //j representing which of the 3 ReviewScores correspond, couldn't find out how to make only the correct reviewscore show up
*reshape long ReviewScore Reviewer, i(proposal_id)
*replace ReviewScore=mean(Reviewer1Score,Reviewer2Score,Reviewer3Score)
*reshape long Reviewer ReviewScore, i(proposal_id) //trying to make ReviewScore one variable instead of 3
*j(ReviewScore)
*reshape wide Reviewer1 Reviewer2 Reviewer3, i(Reviewer1Score Reviewer2Score Reviewer3Score)
*order Reviewer1 Reviewer1Score Reviewer2 Reviewer2Score Reviewer3 Reviewer3Score   //organize the score and the reviewer
//need a variable to put all the Reviewers in the same column with their scores beside them so that I could then sort them more effectively 
by Reviewer, sort: summarize ReviewScore // Review2Score Review3Score //tried to put the reviewerscores together so that only the corresponding number would come up in the table, would love some help figuring out how to do that

*by Reviewer2, sort: summarize Reviewer2Score //thought you wanted standard deviation, but according to google that's not what normalizing means, so I'm trying the formula that I'm seeing
*by Reviewer3, sort: summarize Reviewer3Score
gen review_min=r(min)
gen review_max=r(max)
gen stand_r1_score=(ReviewScore-review_min)/(review_min-review_max) if rev_iteration==1//only displays missing as missing values and I don't know why???
gen stand_r2_score=(ReviewScore-review_min)/(review_min-review_max) if rev_iteration==2
gen stand_r3_score=(ReviewScore-review_min)/(review_min-review_max) if rev_iteration==3

*gen stand_r1_score=r(sd ReviewScore) if rev_iteration==1
*gen stand_r2_score=r(sd ReviewScore) if rev_iteration==2
*gen stand_r3_score=r(sd ReviewScore) if rev_iteration==3
gen average_stand_score=(ReviewScore-AverageScore)/(StandardDeviation) //I have no clue if this is correct, i am using the values that are within a specific proposal_id, not the full dataset's averages
gen rank=group(average_stand_score) //also doesn't work and I don't know why


*Q4. 
/*Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from [Tanzania's government website](https://onlinesys.necta.go.tz/results/2021/psle/results/shl_ps0101114.htm). Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.*/

clear all

cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use q4_Tz_student_roster_html.dta 
//notes from office hours
split s, parse(">PS")
gen serial = 26544
drop s
reshape long s, i(serial) j (student)
split s, parse("<")
keep s1 s6 s11 s16 s21
drop in 1
ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)
compress
replace cand = "PS"+cand //is the 0101114 supposed to be included? I can eliminate that
replace prem = subinstr(prem, `"P ALIGN="CENTER">"', "",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"', "",.)
replace name = subinstr(name, `"P>"', "",.)
replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"', "",.)
compress
split subject, parse(",")
foreach var of varlist subject* {
	replace `var' = substr(`var',-1,.)
}
drop subjects
rename subjects1 Kiswahili
rename subjects2 English
rename subjects3 maarifa
rename subjects4 hisabati
rename subjects5 science
rename subjects6 uraia
rename subjects7 average

compress
