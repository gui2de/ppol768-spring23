
cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data"

***** Question 1 *****

tempfile students // Create a tempfile 


clear // Load dataset

forvalues i=1/1 {
	
	use "q1_psle_student_raw.dta", clear
	
	keep in `i'

		do "week4" // Using the previous dofile from assignment 4 

	save `students'	
}
		
		
/*

For the loop 

For each school the following steps would apply 


Step1: load the dataset
Step2: keep one observation
Step3: run the code from week4 
Result: end up with student level dataset for that 1 school	


generate a temporary file
run the loop for one school
save the data to the temp file 
result: student level dataset for the one school saved to the temp file 


append using 

	

*/
