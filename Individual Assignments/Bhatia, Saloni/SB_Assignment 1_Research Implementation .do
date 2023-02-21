**Q1.a

cd "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data"

use "q1_village_pixel.dta", clear 

sort pixel

bysort pixel: egen pixelmin = min(payout)
bysort pixel: egen pixelmax = max(payout)

gen pixel_consistent = 1 

replace pixel_consistent= 0 if pixelmin==pixelmax

count if pixel_consistent==0

**Q1.b

order pixel village hhid

bysort village(pixel) : gen serial = _n

bysort village(pixel) : gen hh_max = _N

gen pixel_first = ""
replace pixel_first = pixel if serial == 1 

gen pixel_last = ""
replace pixel_last = 1 if serial == 1

**Q1.c

**Q2

cd "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data"

use "q2_Pakistan_district_table21.xlsx"

import excel "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data/q2_Pakistan_district_table21.xlsx", sheet("Table 1") firstrow clear
 
 forvalues i=1/135{
	import excel "q2_Pakistan_district_table21.xlsx", sheet("Table 1") firstrow case(lower) clear
	if `i'>1 append using "mainfile"
	save "mainfile", replace
	}
	
*Q3

cd "/Users/salonibhatia/Desktop/Semester 2 - Coursework /Research Design and Implementation (PPOL-768)/Week 4/01_data"

use "q3_grant_prop_review_2022.dta", clear

rename Rewiewer1 Reviewer1
rename Review1Score Reviewscore1
rename Reviewer2Score Reviewscore2
rename Reviewer3Score Reviewscore3

reshape long Reviewer Reviewscore, i(proposal_id) j(Reviewer_number)

sort Reviewer

bysort Reviewer: egen normalizedscore = std(Reviewscore)

reshape wide Reviewer Reviewscore normalizedscore, i(proposal_id) j(Reviewer_number)

bysort Reviewer: egen avergae = std(Reviewscore)


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





