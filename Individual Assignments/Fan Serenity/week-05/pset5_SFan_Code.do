*C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05

*Q3 
use "q3_GPS Data"
scatter latitude longitude



*Q1 
clear 
tempfile student_clean 
save `student_clean', replace emptyok


forvalues i=1/10 {
	
	use "q1_student", clear 	
	keep in `i'  ///  Compresses the data 
	
	do "$wk4_q4_cleaning"
	
	append using `student_clean'
	save `student_clean', replace 
	
	
}

use student_clean 