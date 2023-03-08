global wd "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"


*********************************Question 1*************************************
*This answer is complete


use  "$wd/q1_psle_student_raw", clear

replace schoolcode = substr(schoolcode,5,9)
 gen serial = _n
	 split s, parse(">PS")
 drop s 
 reshape long s, i(serial) j(student) 
 
 split s, parse("<")
 
 keep s1 s6 s11 s16 s21 schoolcode
 drop in 1 
 
 ren (s1 s6 s11 s16 s21) (candm prem sex name subjects)
 
 compress
 
 replace candm = "PS" + candm
 
 replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
 
 replace sex = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
 
 replace name = subinstr(name,`"P>"',"",.)  
 
 replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"',"",.)
 
 compress
 
 split subjects , parse (",")
 

 drop if prem == ""
 drop if candm == "PS﻿"

compress
drop subjects

foreach var of varlist subjects* {
 	replace `var' = substr(`var', -1,.)
 }

 ren subjects1 Kiswahili 
 ren subjects2 English 
 ren subjects3 Maarifa 
 ren subjects4 Hisabati 
 ren subjects5 Science
 ren subjects6 Uraia
 ren subjects7 Average

 replace candm= substr(candm, 11,.)



**********************************Question 2************************************
*complete

global wd "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

use "$wd/q2_CIV_Section_0.dta", clear

decode b06_departemen, gen(department) 

tempfile density
save `density', replace

import excel "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2_CIV_populationdensity.xlsx", sheet(Population density) clear

keep D A
rename D density
rename A department

generate dep = regexm(department, "^DEP")
keep if dep==1
destring density, replace 

replace department = subinstr(department, "DEPARTEMENT DE","",.)
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DU","",.)
replace department = strtrim(department)
replace department = lower(department)
replace department = "arrha" if department=="arrah"

replace department= lower(department)

merge 1:m department using `density'

drop _merge
drop dep



*********************************Question 3*************************************
*complete

clear all
tempfile enumerator
save `enumerator', replace emptyok

use "$wd/q3_GPS Data", clear

tempfile remaining_hh
save `remaining_hh' , replace

forvalues i=1/19 {

use `remaining_hh', clear //loading dataset with 111 observations
 *but this one has 111 observations, you need to delete the observations that
 *have been assignment to enumerator 1
 *you can do that by merging this dataset with `enumerator' and drop all HH that match
 
*using your code
sort latitude
keep in 1
rename * one_*   //you don't have to call it two, you can just call it what you called it before
*cross using "$wd/q3_GPS Data"
cross using `remaining_hh'

geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km
drop if _n>6
keep id
gen enumerator = `i'

*now you can append these 6 observations to the enumerator tempfile
append using `enumerator'
save `enumerator', replace //then re-save the dataset
count

keep id
merge 1:1 id using `remaining_hh'
count if _merge==3

drop if _merge==3 | _merge==1
drop _merge
count

save `remaining_hh', replace

}
use `enumerator', clear
sort enumerator

merge 1:1 id using "$wd/q3_GPS Data"

keep enumerator id 
sort enumerator 
