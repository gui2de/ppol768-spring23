/// Keegan Brown
/// Assignment 4

// setting global wd and assignments



global wd "/Users/keeganbrown/Desktop/Georgetown/RD/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"
global q1 "$wd/q1_village_pixel.dta"
global q2 "$wd/q2_Pakistan_district_table21.xlsx"
global q3 "$wd/q3_grant_prop_review_2022.dta"
global q4 "$wd/q4_Tz_student_roster_html.dta"


/*Q1 : Crop Insurance in Kenya
You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)*/

use "$q1", clear 

tab pixel 
sort pixel 

bysort pixel: egen min_payout = min(payout)
bysort pixel: egen max_payout = max(payout)
// compare the min and max to determine consistency 

gen pixel_consistent = 0
replace pixel_consistent = 1 if min_payout==max_payout

count if pixel_consistent == 1

br 

/// all pixel_consistent = 1, confirmed payouts are the same by pixel 


/*b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.*/

sort village pixel 

bysort village (pixel): gen serial = _n
bysort village (pixel): gen hh_max = _N
// above creates two sorted variables by village, then pixel, then creates observation number and total number of observations using _n/_N e.g. https://stats.oarc.ucla.edu/stata/seminars/notes/counting-from-_n-to-_n/

gen pixel_first = ""
replace pixel_first = pixel if serial == 1

gen pixel_last = ""
replace pixel_last = pixel if serial == hh_max

gen pixel_village = 0
replace pixel_village = 1 if pixel_first==pixel_last

// above matches the pixel to village count, replacing the pixel_village var to 0 if they do not match 

bysort village: tab pixel_village

count if pixel_village == 0
count if pixel_village == 1


br



/*c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.*/ 



egen pixel_e = group(pixel_village pixel_consistent)

// not sure why the above isnt working or why the below is doubling. I am getting all observations in them, and some double counts. 
replace pixel_e = 1 if pixel_village == 1
replace pixel_e = 2 if pixel_village == 0 & pixel_consistent == 1
replace pixel_e = 3 if pixel_village == 0 & pixel_consistent == 0

tab pixel_e

br

list hhid if pixel_e == 2




/// Q2  National IDs in Pakistan

/*We have the information of adults that have computerized national ID card in the following pdf: [Pakistan_district_table21.pdf](01_data/q2_Pakistan_district_table21.pdf). This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.*/

clear 

*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$q2", sheet("Table `i'") firstrow clear allstring //import
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

*Renaming the numbers to connect with variable names

format %40s table21 `var'

**created a function taht assigns the data to specific row with name and to align, 
** but keep getting a error for insufficent variables, moved on. 



/* Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)*/ 

use "$q3", clear 

br 

rename Review1Score Reviewer1Score

//normalize the score for each reviewer 
forvalues i = 1/3 {
	egen stand_r`i'_score = std(Reviewer`i'Score)
}

//creating average score variable calc using the column name specified 
gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3


//ranking scores
egen rank = rank(-average_stand_score)

sort rank

/*Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.*/ 


use "$q4", clear 

br 

*pulling out only the table 



		
split s, parse("<TABLE")
drop s1 s2 s 

* find each row of table
split s3, parse("<TR>")
drop s3 s31 s32

gen value = .
*reshaping data into wide format 
//reshape wide s, i(value) j(string)
//drop number string
* used the above and it did not work because data already wide? 

reshape long s, i(value) j(string)


*cand_id, splitting
split s, p("<P>")
split s2, p("</FONT>")
rename s21 name
drop s23

*grade variable pull 
split s22, p("LEFT")
drop s221 s2

gen grade_var = substr(s222, 3, .)
drop s222 s22

*schoolcode and prem_number 
split s1, p("CENTER")
gen cand_id = substr(s12, 3, 14)
gen schoolcode = substr(s13, 3, 11)

*pulling information out of the split sells

drop s s1 s11 s12 s13 s14 

gen Kiswahili =  substr(grade_var, 13, 1)
gen English = substr(grade_var, 26, 1)
gen Maarifa = substr(grade_var, 39, 1)
gen Hisabati = substr(grade_var, 53, 1)
gen Science = substr(grade_var, 66, 1)
gen Uraia = substr(grade_var, 77, 1)
gen Average = substr(grade_var, 96, 1)

drop value string grade_var










