********************************************************************************
* PPOL 768: Week 4
* Individual Assignment
* Scott Brown
* February 11, 2023
********************************************************************************

cd "D:/2021-2023, Georgetown University/2023 - Spring/Research Design & Implementation/ScottsRepo/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

********************************************************************************
* Q1: Crop Insurance in Kenya
* You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.
********************************************************************************
use q1_village_pixel.dta, clear

/* a) Payout variable should be consistent within a pixel, confirm if that is the case. 
Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)
*/

bysort pixel:egen pixel_consistent = mean(payout)
replace pixel_consistent = 0 if pixel_consistent==1
sum pixel_consistent // no deviations from 0, i.e. payout variable is consistent within the pixel groups

/* b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). 
Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.
*/

*Create numeric pixel variable
gen pixel_number = substr(pixel,3,4)
destring pixel_number, replace
order pixel_number, after(pixel)

*Verify is villages have the same pixel number
bysort village: egen pixel_village = mean(pixel_number) // villages within ONE pixel group should have no difference between the village's avg pixel and the individual households's pixel.
replace pixel_village = pixel_village - pixel_number
replace pixel_village = 1 if pixel_village !=0

/* c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. 
For this purpose, divide the households in the following three categories:
I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.
*/

* Village Category I
gen village_category = 0
replace village_category = 1 if pixel_village ==0
count if village_category == 1

* Village Category II
bysort village: egen payout_village = mean(payout)
replace payout_village = payout_village - payout
replace payout_village = 1 if payout_village !=0

replace village_category = 2 if pixel_village ==1 & payout_village ==0
count if village_category == 2
list hhid village if village_category ==2

* Village Category III
replace village_category = 3 if pixel_village ==1 & payout_village ==1
count if village_category == 3

* Check if categories are mutually exclusive and exhaustive; totals should equal
tab village_category 
count 

********************************************************************************
* Q2: National IDs in Pakistan
********************************************************************************
/* We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. 
This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.
*/
clear
global excel_t21 "q2_Pakistan_district_table21.xlsx"

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
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

/* 
Here's my thinking – you can run a loop with some conditional statement(s) to replace blank columns with the closest populated cell, but you'd have to ensure that the loop does not result in overwriting of correct cells. You should be able to create a local for the alphabet (B-Z). (or we can create a local for allvars, or should we rename B-Z with actual numbers so that we can do i+1?)Then use foreach `alphabet' or varlist with a replace and if-and-else. If the first cell is blank, replace with the following column value if that column is population; if not, replace with the next column if population; and so on.
*/
preserve

foreach _n {
	
}
if C =="" replace C = D

restore 

if D=="" replace D = E


********************************************************************************
* Q3: Faculty Funding Proposals
********************************************************************************
/* Faculty members submitted 128 proposals for funding opportunities. 
Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)
*/

use "q3_grant_prop_review_2022", clear

// Correct typos and inconsistent naming
rename Rewiewer1 Reviewer1
rename Review1Score Score1
rename Reviewer2Score Score2
rename Reviewer3Score Score3

// Reshape the data to get the unique reviews in each rows
reshape long Reviewer Score, i(proposal_id) j(number)

// Generate variables needed to normalize each reviewer's score
bysort Reviewer : egen Reviewers_min = min(Score)
bysort Reviewer : egen Reviewers_max = max(Score)

// Generate normalized scores for each review and an avg for the proposal
gen Normalized_reviewer_score = (Score-Reviewers_min)/(Reviewers_max-Reviewers_min) 
bysort proposal_id : egen Norm_avg_score = mean(Normalized_reviewer_score)

// Drop the no-longer-needed variables (min, max) to prepare data for reshaping
drop Reviewers_min Reviewers_max Normalized_reviewer_score
reshape wide Reviewer Score, i(proposal_id) j(number)

// Sort by normalized avg score and create a rank variable 
gsort -Norm_avg_score
egen rank = rank(-Norm_avg_score)

// List of the top 50 proposals
list rank proposal_id in 1/50

********************************************************************************
* Q4: Student Data from Tanzania
********************************************************************************
/* This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website (https://onlinesys.necta.go.tz/results/2021/psle/results/shl_ps0101114.htm). Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.
*/

gen subject_position = strpos(s, "SUBJECT")
replace s = substr(s, 3852, .)
split s, parse("</TD></TR>") // </TD></TR> separates each row in the original table
gen serial = _n
drop s
reshape long s, i(serial) j(j)


schoolcode, 

cand_id, 

gender, 

prem_number, 

name, 

"<FONT FACE="Arial" SIZE=1><P>*<TD WIDTH="55%" VALIGN="MIDDLE">"

Kiswahili, 

English, 

maarifa, 

hisabati, 

science, 

uraia, 

average




