cd "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\"

/* Q1 : Crop Insurance in Kenya */
/* a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel) */

use "q1_village_pixel.dta", clear

by pixel(payout), sort: gen pixel_consistent = payout[1] != payout[_N]
list pixel payout if pixel_consistent

/* b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level. */

by village(pixel), sort: gen pixel_village = pixel[1] != pixel[_N]
list village pixel if pixel_village

/* c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories. */

gen village_type = 0
replace village_type = 1 if pixel_village == 0 & pixel_consistent == 0
replace village_type = 2 if pixel_village == 1 & pixel_consistent == 0
replace village_type = 3 if pixel_village == 1 & pixel_consistent == 1
tab village_type

clear

/* Q2 : National IDs in Pakistan
We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly. */


global excel_t21 "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\q2_Pakistan_district_table21.xlsx"

clear

tempfile table21
save `table21', replace emptyok

forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring
	display as error `i' 
	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 
	keep in 1
	rename TABLE21PAKISTANICITIZEN1 table21

	gen table=`i' 
	append using `table21' 
	save `table21', replace 
}

use `table21', clear

* This is all I got. I've tried to what I learned from Ali's Q&A session, but I counln't get it right.

/* Q3 : Faculty Funding Proposals
Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128) */

use "q3_grant_prop_review_2022.dta", clear

egen stand_r1_score = std(Review1Score)
egen stand_r2_score = std(Reviewer2Score)
egen stand_r3_score = std(Reviewer1Score)
egen average_stand_score = (stand_1_score + stand_2_score + stand_3_score)/3)

gsort - average_stand_score
gen rank = _n

br

clear

/* Q4 : Student Data from Tanzania
Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average. */


use "q4_Tz_student_roster_html.dta", clear

* I couldn't get it, even though I spent more than 12 hours on it. It was a mental crushing work.