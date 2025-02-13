
tempfile students // Create a tempfile 
clear
save `students', replace emptyok

clear // Load dataset

forvalues i=1/5 {
	
	use "q1_psle_student_raw.dta", clear
	
	keep in `i'

		do "week4" // Using the previous dofile from assignment 4 
 *save the data so that we don't lose it.
 
	append using `students'
 
	save `students', replace
	
}


use `students', clear
