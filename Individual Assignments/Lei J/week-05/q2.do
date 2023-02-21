*q2 
cd "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-05\03_assignment\01_data"

import excel "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-05\03_assignment\01_data\q2_CIV_populationdensity.xlsx"

keep if strpos(A, "DEPARTEMENT")
*get rid of other data as department level data is the only ones we care 
gen department=subinstr(A, "DEPARTEMENT D'","",.)
replace department=lower(department)
*generate a variable to match with the variable in the other dta and make it lowercase as they are lowercases in the other file.

rename B SUPERFICIE_KM2
rename C POPULATON
rename D DENSITE_AU_KM2
drop A
order department, before(SUPERFICIE_KM2)
save q2_department_popden.dta
*cleaning up 
use "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-05\03_assignment\01_data\q2_CIV_Section_0.dta", clear
decode b06_departemen, gen(department)
*department in the using file is string, hence generata a string value to match
merge m:m department  using q2_department_popden.dta
drop department _merge
*cleaning up