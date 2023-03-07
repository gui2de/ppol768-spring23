**Q1.a. Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)

cd "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use "q1_village_pixel.dta", clear 

**We start with sorting pixels in order to check if payout within each pixel is consistent 
sort pixel

**For each pixel, we check for min and max values to compare the two and check for discrepencies
bysort pixel: egen pixelmin = min(payout)
bysort pixel: egen pixelmax = max(payout)

**We create a dummy variabble (pixel_consistent) = 1 if payouts are consistent 
gen pixel_consistent = 1 

**By comparing pixelmin with pixelmax and assigning a value of 0 if payout within each pixel is consistent
replace pixel_consistent= 0 if pixelmin==pixelmax

**Since all values for pixel_consistent = 0, we confirm that payout variable is consistent within a pixel 
count if pixel_consistent==0

**Q1.b. b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.

**Our goal in this question is to check if some villages are falling under more than one pixels. By eyeballing the data, I found that village MUDHIERO is falling under pixel KE362 and KE3558. In this case my dummy variable pixel_village = 1. In cases where there is no overlap of villages across pixels, pixel_village = 0 

cd "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

use "q1_village_pixel.dta", clear 

**For my understanding, we order the columns pixel --> village --> household
order pixel village hhid

**We start with sorting villages by pixel and general a variable to assign serial numbers to pixels under each village. For instance, under village BARUNGA, there are 4 KE632 pixels 
bysort village(pixel) : gen serial = _n
order pixel village serial

**Once again, we sort villages by pixel and generate a variable that gives us the maximum number of pixels in each village 
bysort village(pixel) : gen pixel_max = _N
order pixel village serial pixel_max

gen pixel_first = ""
replace pixel_first = pixel if serial == 1 

gen pixel_last = ""
replace pixel_last = pixel if pixel_max == serial 

**bysort village(pixel) : gen overlap = 1 if pixel_first != pixel_last

carryforward pixel_first, gen(pixel_first_check)

gen pixel_village = 0 if pixel_last == pixel_first_check
gen pixel_village_check = 1 if pixel_last != pixel_first_check & pixel_last != "" 
count if pixel_village_check == 1
**This generates 30 values. 

**Q1.c. For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
*I. Villages that are entirely in a particular pixel. (==1)
*II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
*III. Villages that are in different pixels AND have different payout status (==3)
*These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.

**Q2. We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

global excel_t21 "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
*update the global

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets (0 sheets at a time), one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
foreach var of varlist * {
		if missing(`var') {
			drop `var'
		}
	}
	
local i=1 
	foreach var of varlist * {
		rename `var' column_`i' 
		local i = `i' + 1
} 

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21', force //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

gen district_id = _n

order district_id column_2

rename column_2 total_pop_all
rename column_3 cni_obt_all
rename column_4 cni_notobt_all
rename column_5 total_pop_male
rename column_6 cni_obt_male
rename column_7 cni_notobt_male
rename column_8 total_pop_female
rename column_9 cni_obt_female
rename column_10 cni_notobt_female
rename column_11 total_pop_trans
rename column_12 cni_obt_trans
rename column_13 cni_notobt_trans

compress

drop column_1 
		
**Q3. Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)

cd "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data"

use "q3_grant_prop_review_2022.dta", clear

**We begin with consistently renaming the reviewer and reviewerscore variables. the consistency helps in reshaping long to wide later in the question 
rename Rewiewer1 Reviewer1
rename Review1Score Reviewscore1
rename Reviewer2Score Reviewscore2
rename Reviewer3Score Reviewscore3

**since we want to normalize 
reshape long Reviewer Reviewscore, i(proposal_id) j(Reviewer_number)

compress

sort Reviewer

bysort Reviewer: egen normalizedscore = std(Reviewscore)

reshape wide Reviewer Reviewscore normalizedscore, i(proposal_id) j(Reviewer_number)

drop Reviewscore1 Reviewscore2 Reviewscore3

rename normalizedscore1 stand_r1_score
rename normalizedscore2 stand_r2_score
rename normalizedscore3 stand_r3_score

egen average_stand_score = rmean(stand_r1_score stand_r2_score stand_r3_score)

egen rank = rank(-average_stand_score)

sort rank 

keep in 1/50 

**Q4
**This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

cd "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data"

use "q4_Tz_student_roster_html.dta", clear

split s, parse(">PS")

gen serial = _n 

drop s 

reshape long s, i(serial) j(student)

split s, parse("<")

keep s1 s6 s11 s16 s21
drop in 1 

ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)

compress 

replace cand = "PS" + cand 
replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)


split subjects, parse(",")
compress 

drop subjects
foreach var of varlist subjects* {
	replace `var' = substr(`var',-1,.)
	}

compress 





