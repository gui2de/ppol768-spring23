global wd"/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-05"

global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_Section_0.dta"

*Q1
{
use "$q1", clear
replace s = substr(s, strpos(s, "SUBJECT"), .)
*split each line 
split s, parse("</TD></TR>") 
drop s s1
*serial indicate different schools 
gen serial = _n
reshape long s, i(serial) j(stud_obs)
split s, parse("><P")
drop s 

gen cand_No = substr(s2,17,14)
gen prem_No = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
replace schoolcode = substr(schoolcode, 5, 9)

split s5, parse("</FONT>")
drop s52
gen name = substr(s51,2,.)

split s6, parse("-" ",")
rename s62 Kiswahili
rename s64 English 
rename s66 Maarifica 
rename s68 Hisabati 
rename s610 Science 
rename s612 Uraia 
gen average =substr(s614, -8, 1)

order s*
drop s1-s614

drop if missing(cand_No)
}

*Q2
global pop "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-05/q2_CIV_populationdensity.xlsx"
*update the global
clear

import excel "$density", sheet("Population density") firstrow case(lower) clear

rename nomcirconscription departement 
keep if strpos(departement, "DEPARTEMENT") == 1 

split departement, parse(" ")
drop departement departement1 departement2

use "$q2", clear
br
