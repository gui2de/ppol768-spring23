global wd "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

*********************************Question 1*************************************
*This answer is complete


use  "$wd/q1_psle_student_raw", clear

replace schoolcode=substr(schoolcode,5,9)
 gen serial = _n
	 split s, parse(">PS")
 drop s 
 reshape long s, i(serial) j(student) 
 
 split s, parse("<")
 
 keep s1 s6 s11 s16 s21 schoolcode
 drop in 1 
 
 ren (s1 s6 s11 s16 s21) (candm prem sex name subjects)
 
 compress
 
 replace candm= "PS" + candm
 
 replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
 
 replace sex = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
 
 replace name = subinstr(name,`"P>"',"",.)  
 
 replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"',"",.)
 
 compress
 
 split subjects , parse (",")
 

 drop if prem==""
 drop if candm=="PS﻿"

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



**********************************Question 2************************************
*incomplete

import excel "$wd/q2_civ_density", sheet ("Population density") firstrow 



clear 
use "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2_CIV_Section_0.dta"

decode b06_departemen, gen(department)

tempfile density
save `density', emptyok

import excel "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2_CIV_populationdensity.xlsx", sheet(Population density)

keep D A
rename D density 
rename A department

generate dep = regexm(department, "^DEP")
keep if dep==1


merge 1:m density using `"/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2_CIV_Section_0.dta"'


*********************************Question 3*************************************
*incomplete


use  "$wd/q3_GPS Data", clear
sort latitude   
keep in 1
rename * one_* 
cross using  "$wd/q3_GPS Data" 
geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km
list one_id id distance_km
drop if _n>6
keep id 
gen enumerator = 1
merge 1:1 id using  "$wd/q3_GPS Data"


sort latitude  
drop _merge
keep in 1 if enumerator==.
rename * two_* 
cross using  "$wd/q3_GPS Data" 
geodist two_latitude two_longitude latitude longitude, generate (distance_km)
sort distance_km
drop if _n>6 
keep id 
gen enumerator = 2
merge 1:1 id using  "$wd/q3_GPS Data"






