clear
tempfile clean_stu
save `clean_stu', emptyok replace

forvalues i=1/13{
use "C:\Users\Alexandra\Documents\GitHub\ppol768-spring23\Class Materials\week-05\03_assignment\01_data\q1_psle_student_raw.dta" , clear

keep in `i'
clean 

append using `clean_stu'
save `clean_stu', replace 

}


use `clean_stu'