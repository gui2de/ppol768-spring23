***Lidia Guzman week 04 
clear

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

clear
***Question 1 -----------------------------------------------------------------

use "${wd}/q1_village_pixel.dta" , clear

**read the data and sort it 

***Q1.a

sort village pixel 

bysort pixel: egen pixel_min = min(payout)
bysort pixel: egen pixel_max = max(payout) 


**generate dummy to distinguish consistent from inconsistent 

gen pixel_consistent = 0 

replace pixel_consistent= 1 if pixel_min == pixel_max 

***Q.1.b

egen pixel_gp = group(pixel)
egen village_gp = group(village)

gsort village_gp

gen dummy = 0

by village_gp: replace dummy = 1 if pixel_gp[_n] != pixel_gp[_n-1]

bysort village_gp: egen dummy_mean = mean(dummy)

gen pixel_village = 0
replace pixel_village = 1 if dummy_mean <=.5

***Q1.c
***categorize the 3 groups

***Q1.C.1 Villages that are entirely in a particular pixel ==1 

gen category = 0

replace category = 1 if dummy_mean <=.5


***Q1.C.2 Villages that are in different pixels AND have same payout status(==2)

gen payoutstatus = 0

replace payoutstatus = 1 if village_gp & payout == 1

/// payoutstatus = 0 is same village and same payout

replace category = 2 if dummy_mean >.5 & payoutstatus == 0

***Q1.C.3.Villages different pixels AND have different payout status(==3)

replace category = 3 if dummy_mean >.5 & payoutstatus == 1

save "${wd}/q1_village_pixel_results.dta" , replace 

***Question 2 -----------------------------------------------------------------
clear

global excel_t21 "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
clear

*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok


*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND")==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21

	foreach var of varlist * {
    qui count if missing(`var')
    if r(N) > 0 {
        drop `var'
    }	
}

foreach var of varlist * {
    rename `var' column_1
	}
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}

///*\load the tempfile
///use `table21', clear
*fix column width issue so that it's easy to eyeball the data
///format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC


***Question 3 -----------------------------------------------------------------
clear 
use "${wd}/q3_grant_prop_review_2022.dta" , clear

summarize Review1Score
gen mean_r1_score = r(mean)
egen sd_r1_score = sd(Review1Score)

gen stand_r1_score = ((Review1Score - mean_r1_score)/sd_r1_score)

summarize Reviewer2Score
gen mean_r2_score = r(mean)
egen sd_r2_score = sd(Reviewer2Score)

gen stand_r2_score = ((Reviewer2Score - mean_r2_score)/sd_r2_score)

summarize Reviewer3Score
gen mean_r3_score = r(mean)
egen sd_r3_score = sd(Reviewer3Score)

gen stand_r3_score = ((Reviewer3Score - mean_r3_score)/sd_r3_score)


gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3

egen rank = rank(-average_stand_score) /// (highest score =>1, lowest => 128)


***Question 4 -----------------------------------------------------------------
clear
use "${wd}/q4_Tz_student_roster_html.dta" , clear 

split s, parse (">PS")

gen serial = 1 
/// because we have only one variable 

drop s

reshape long s, i(serial) j(student)

split s, parse ("<")

keep s1 s6 s16 s11 s21 

drop in 1

ren (s1 s6 s16 s11 s21) (cand prem sex name subjects)
	compress
	
replace cand = "PS" + cand
replace prem = subinstr(prem, `"P ALING = CENTER">"',"",.)
replace sex = subinstr(sex, `"P ALING = CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects = subinstr(subjects, `"P ALING = CENTER">"',"",.)

compress

split subjects , parse(",")

drop subjects 

foreach var of varlist subject* {
	replace `var' = substr(`var', -1,1)
}

compress

rename cand cand_id

rename prem schoolcode

replace schoolcode = subinstr(schoolcode,`"P ALIGN="CENTER">"',"",.)

rename name gender 

replace gender = subinstr(gender,`"P ALIGN="CENTER">"',"",.)
 
rename sex name

replace name = subinstr(name,`"P>"',"",.)

rename subjects1 Kiswahili 

rename subjects2 English

rename subjects3 maarifa

rename subjects4 hisabati 

rename subjects5 science 

rename subjects6 uraia 

rename subjects7 average



