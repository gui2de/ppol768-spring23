/* Marlyn Bruno
PPOL 768
Week 4 Assignment*/

**********************************************************************************

						*Question 1: Crop Insurance in Kenya*
						
***********************************************************************************

*Setting up working directory
global wd "/Users/marlyn/GitHub/ppol768-spring23/Individual Assignments/Bruno Marlyn/week-04"
use "/Users/marlyn/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q1_village_pixel.dta", clear

*a) Payout variable should be consistent within a pixel, confirm if that is the case. 
bysort pixel: tab payout //confirming it's the case and it is

*a) Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)
bysort pixel: egen pixel_mean = mean(payout)

gen pixel_inconsistent = 0
replace pixel_inconsistent = 1 if pixel_mean != 0 & pixel_mean != 1
count if pixel_inconsistent == 1

*b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.

sort village pixel
bysort village (pixel): gen serial = _n
bysort village (pixel): gen hh_max = _N

gen pixel_first = ""
replace pixel_first = pixel if serial == 1
gen pixel_last = ""
replace pixel_last = pixel if serial == hh_max

* Creating a check to see when boundary cases occur 
preserve //since I'll be dropping observations, I want to preserve my dataset first

drop if pixel_first == "" & pixel_last == ""

replace pixel_last = pixel_last[_n+1] if pixel_last == "" 
replace pixel_first = pixel_first[_n-1] if pixel_first == ""

gen pixel_village = 0
replace pixel_village = 1 if pixel_first != pixel_last // =1 if households from a village are in more than one pixel

* Seeing which villages are a boundary case
tab village if pixel_village == 1

*c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories: These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.

*First, I want to create a dummy to check if the pixels have the same payout status
bysort village: egen pixel_mean_payout = mean(payout)
	
gen village_category = 0
replace village_category = 1 if pixel_village == 0 //I. this will be the "baseline" category, which will end up being villages in the same pixel (==1) 
replace village_category = 2 if pixel_village == 1 & pixel_mean_payout != 0.5 //II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
replace village_category = 3 if pixel_village == 1 & pixel_mean_payout == 0.5 //III. Villages that are in different pixels AND have different payout status (==3)

tab village if village_category == 3 //to specifically see the villages that would pose an issue

restore //restoring my dataset 


/*********************************************************************************

						Question 2: National IDs in Pakistan
						
*********************************************************************************/

*We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

global excel_t21 "/Users/marlyn/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
*update the global

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/5 {
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

*Drop variables with all missing observations
foreach var of varlist _all {
     capture assert mi(`var')
     if !_rc {
        drop `var'
     }
 }
 
*Shifting data to the left
rename * column* //renaming each of my variables so that they have the same string prefix of "column", which will allow me to run later commands

egen column = concat(column*), p(" ") //literally "smushing" every column's numbers together into one string
replace column = subinstr(column, ".", "", .) // replacing the empty values (.) with empty spaces  
split column, destring //destringing across columns 

*Keep only the "destrung" variables we want for a tidy dataset
drop columntable21 columnB columnC columnD columnE columnF columnG columnH columnI columnJ columnK columnL columnM columnN columnO columnP columnQ columnR columnS columnT columnU columnV columnW columnX columnY columnZ columnAA columnAB column column1 column 2 column3 column16

*Sort by the Excel sheet number we sourced the observation from
sort columntable

*Rename columns to match excel sheet
rename (column*) (sheet total_pop_all cni_no_all cni_yes_all total_pop_m cni_no_m cni_yes_m total_pop_f cni_no_f cni_yes_f total_pop_t cni_no_t cni_yes_t)

*I noticed that the values for all columns related to transgender people were coded as strings. I'm going to change them to numeric values in case I want to run some calculations 
encode total_pop_t, generate(total_pop_trans)
encode cni_no_t, generate(cni_no_trans)
encode cni_yes_t, generate(cni_yes_trans)
drop total_pop_t cni_no_t cni_yes_t 

/*********************************************************************************

						Question 3: Faculty Funding Proposals
						
*********************************************************************************/

*Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)

use "/Users/marlyn/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q3_grant_prop_review_2022.dta", clear

*Fixing the names of variables so they're consistent
rename Rewiewer1 Reviewer1
rename Review1Score ReviewScore1
rename Reviewer2Score ReviewScore2
rename Reviewer3Score ReviewScore3

*Reshaping data to long format
reshape long Reviewer ReviewScore, i(proposal_id) j(ReviewerOrder)

*Creating variable for normalized scores
sort Reviewer
bysort Reviewer: egen ReviewerMean = mean(ReviewScore)
bysort Reviewer: egen ReviewerSD = sd(ReviewScore)

gen ReviewScoreNorm = ((ReviewScore - ReviewerMean) / ReviewerSD )

*Reshaping data back to wide format
reshape wide Reviewer ReviewScore ReviewerMean ReviewerSD ReviewScoreNorm, i(proposal_id) j(ReviewerOrder)

*Fixing the names to align with assignment 
rename ReviewScoreNorm1 stand_r1_score
rename ReviewScoreNorm2 stand_r2_score
rename ReviewScoreNorm3 stand_r3_score

*Generating average standardized scores
gen average_stand_score = ((stand_r1_score + stand_r2_score + stand_r3_score) / 3)

*Generating variable to rank proposals
gsort - average_stand_score, generate(rank) mfirst

*I don't like the order of the variables after I reshaped them to wide format so I'm going to reorder them so they make more intuitive sense
order proposal_id rank PIName Department Reviewer1 ReviewScore1 ReviewerMean1 ReviewerSD1 stand_r1_score Reviewer2 ReviewScore2 ReviewerMean2 ReviewerSD2 stand_r2_score Reviewer3 ReviewScore3 ReviewerMean3 ReviewerSD3 stand_r3_score AverageScore StandardDeviation average_stand_score 
sort proposal_id

/*********************************************************************************

						 Question 4: Student Data from Tanzania
						
*********************************************************************************/

*Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

use "/Users/marlyn/GitHub/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q4_Tz_student_roster_html.dta", clear

*Drop everything before the table starts and it starts at "SUBJECT"
replace s = substr(s, strpos(s, "SUBJECT"), .)

*Break data after each "row" or observation as seen in website 
split s, parse("</TD></TR>")

*Break into columns
gen observation = _n //label each observation with a number
drop s
reshape long s, i(observation) j(j)

*Drop last observation which has no data
drop if _n == _N | _n == 1 //dropping the first and last observations since they don't contain data we're interested in, they're just HTML text

*We can now split the data into neat text chunks
split s, parse(">") //this neatly splits the data and starts each of the columns where we want it (at the start of the word)

*I want to keep only the variables that have the data 
keep observation j s s5 s10 s15 s20 s25 //this keeps the variables we're interested in, which I saw were organized in increments of 5

*Cleaning up the variable strings
replace s5 = subinstr(s5,"</FONT","",.)
replace s10 = subinstr(s10,"</FONT","",.)
replace s15 = subinstr(s15,"</FONT","",.)
replace s20 = subinstr(s20,"</FONT","",.)
replace s25 = subinstr(s25,"</FONT","",.)

*Post peer-review Update: I could just run a loop for the above to have more efficient code
foreach var of varlist *{
	replace `var' = subinstr(`var', "</FONT","",.)
}


*Renaming variables to match their website names
rename (s5 s10 s15 s20 s25) (cand_number prem_number sex cand_name subjects) 


