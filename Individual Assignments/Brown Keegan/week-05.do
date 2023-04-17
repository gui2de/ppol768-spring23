*--------------------------------------------------------------------------*
* Keegan Brown
* Research Design
* Assignment - wk5
*--------------------------------------------------------------------------*

*** Setting Global Environment 


global wd "/Users/keeganbrown/Desktop/Georgetown/RD/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_populationdensity.xlsx"
global q3 "$wd/q3_GPS Data.dta"
global q4 "$wd/q4_Tz_election_2010_raw.xls"
// q5 loaded in within question line 

clear 



*-------------------------------------------------------------------------*
*Q1 
/*This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of
138 schools in Arusha District in Tanzania (previously had data of only 1 school)  
You can build on your code from week 4 assignment to create a student level 
dataset for these 138 schools.*/
*-------------------------------------------------------------------------*



tempfile psle
save `psle', emptyok

br

use "$q1", clear

sort schoolcode
gen school_val = _n 


foreach i of numlist 1/138 {

    split s, parse(">PS")
 
}

// for some reason the code doesnt work unless these are split run this in a 
// different line than the top
drop s s1 
drop schoolcode 


gen schoolcode = substr(s2, 1,7)

order schoolcode, before(s2)

reshape long s, i(schoolcode) j(student)

gen real_s_ct = student - 1 

order real_s_ct, before(s)

drop student

drop if s == ""
drop school_val

gen prem_num = substr(s, 105, 11) // prem number pull
gen gender = substr(s, 207, 1) // gender pull 
   
order gender prem_num, before(s)


split s, parse("<P>") // pull for the students names 
drop s1 // removing unneeded data 

// extracting name 
split s2, parse("</FONT>")
rename s21 name 
drop s s1 s2 s23 

// extracting grades 
split s22, parse("<P ALIGN=")
drop s22 s221 
gen grades = substr(s222, 8, 103)
drop s222

// pulling grade information
gen Kiswahili =  substr(grades, 13, 1)
gen English = substr(grades, 26, 1)
gen Maarifa = substr(grades, 39, 1)
gen Hisabati = substr(grades, 53, 1)
gen Science = substr(grades, 66, 1)
gen Uraia = substr(grades, 77, 1)
gen Average = substr(grades, 96, 1)
drop grades school_val real_s_ct




*-------------------------------------------------------------------------*
*Q2
*-------------------------------------------------------------------------*
clear
tempfile q2 
save `q2'
clear 

import excel using "$wd/q2_CIV_populationdensity.xlsx", clear firstrow


keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")

//renaming department variable to single name 
gen department = NOMCIRCONSCRIPTION
drop NOMCIRCONSCRIPTION
split department, parse("DEPARTEMENT")
drop department department1 
rename department2 department 

levelsof department

replace department = subinstr(department, "arrha","arrah",.)

save "CIV_populationdensity.dta", replace


// trying to recreate what i had previously, but there isnt a file to merge to 
// as of PM 3/31. cant really reproduce without the file 



*-------------------------------------------------------------------------*
*Q3 
/*We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 
enumerators (~6 surveys per enumerator per day) in such a way that each 
enumerator is assigned 6 households that are close to each other. Manually 
assigning them for each village will take you a lot of time. Your job is to 
write an algorithm that would auto assign each household (i.e. add a column 
and assign it a value 1-19 which can be used as enumerator ID). 
Note: Your code should still work if I run it on data from another village.*/ 
*-------------------------------------------------------------------------*

use "$q3", clear
br

tempfile data
save `data'
br 

sort latitude longitude

// above sorts the lat long together as close as possible with others 
// absent a eucledian distance measure formula this is best approx 

gen enumerator = ""

* splits thegrouping into 6 even groups based on the grouping. 
gen group = ceil(6 * _n/_N)

*alternatively, a geographic distance caluculation would allow for an evaluation
* a progrma where we are minimizing the means of any of the cuts. but 

 
	


*-------------------------------------------------------------------------*
*Q4 
/* 2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable 
in its current form. You have to create a dataset in the wide form, where each 
row is a unique ward and votes received by each party are given in separate 
columns. You can check the following dta file as a template for your output: 
Tz_elec_template. Your objective is to clean the dataset in such a way that 
it resembles the format of the template dataset.*/
*-------------------------------------------------------------------------*

import excel using "$q4", clear

drop in 1/4

// filling in blanks 
gen gender = ""
replace gender = "male" if F == "M"
replace gender = "female" if F == ""

//elected y/n 
gen elected = ""
replace elected = "yes" if J == "ELECTED"
replace elected = "no" if J == ""

// dropping cleaned variables 
drop J F G K 

rename (A B C D) (region district constituency ward)
 

* fill the blanks
foreach v of varlist region district constituency ward {
	replace `v' = `v'[_n-1] if missing(`v')
}

rename (E H I) (candidate party votes)

drop in 1/2 

* calculate the number of candidates for cross reference 
levelsof candidate, local(unique_candidates)
local n_unique_candidates : word count `unique_candidates'
display "Number of unique candidates: " `n_unique_candidates'

egen ward_var = group(region district constituency ward)



** find dupes 
duplicates tag ward_var party, gen(duplicates)

br if duplicates != 0


** dropping duplicate and conflicting values 

drop if duplicates == 1 

*resetting the values for the candidates who ran unopposed to not account in ttl







*-------------------------------------------------------------------------*
*Q5
/*Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944.
 This happened by dividing existing ward into 2 (or in some cases more) new wards.
 You have to create a dataset where each row is a 2015 ward matched with the 
 corresponding parent ward from 2010. It's a trivial task to match wards that 
 weren't divided, but it's impossible to match wards that were divided without 
 additional information. Thankfully, we had access to shapefiles from 2012 and
 2017. We used ArcGIS to create a new dataset that tells us the percentage area
 of 2015 ward that overlaps a 2010 ward. You can use information from this 
 dataset to match wards that were division */ 
*-------------------------------------------------------------------------*


use "q5_Tz_elec_10_clean.dta" , clear



