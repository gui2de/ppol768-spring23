*q2 
clear
cd "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
import excel "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2_CIV_populationdensity.xlsx"

keep if strpos(A, "DEPARTEMENT")
*get rid of other data as department level data is the only ones we care 
gen department=subinstr(A, "DEPARTEMENT ","",.)
replace department=subinstr(department,"D'","",.)
replace department=subinstr(department,"DE","",.)
replace department=subinstr(department,"DU","",.)
replace department=strtrim(department)
replace department=lower(department)
*generate a variable to match with the variable in the other dta and make it lowercase as they are lowercases in the other file.

rename B SUPERFICIE_KM2
rename C POPULATON
rename D DENSITE_AU_KM2
drop A
order department, before(SUPERFICIE_KM2)
save q2, replace
*cleaning up 
use q2_CIV_Section_0, clear
decode b06_departemen, gen(department)
*department in the using file is string, hence generata a string value to match
merge m:1 department  using q2
drop department _merge
erase "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q2.dta

*cleaning up
