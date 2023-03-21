**** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" // Change working directory 

clear
tempfile tiida
	set seed 3005					// Use set seed to maintain the observations 

	set obs 10000					// Create a dataset that generates 10000 observations 
	gen x = runiform()				
	
	save tiida.dta, replace
	

*	DGP
	
* Sampling noise in a fixed population 						

capture program drop wkeight					// Establish program 
program define wkeight,rclass						// Define the program 
	clear 
	use `tiida', clear								// Load dataset with observations
	gen sch_hll =runiform()						// Generate a new variable to store random sample
	egen rank = rank(sch_hll)					// Generate another variable to rank the new random sample
	gen car_barn =0 							// Generate new variable to store condition for regression
	
	replace car_barn =1 if rank-1000 <50		 // Set variable equal to one if the random number minus one thousand is less than 50 
	
	gen y = x + car_barn						// Generate new variable using x's
	
	reg y x 						     		// Regression of y on one x observations
					
	
	reg y treatment
	mat results =r(table)
	
	
end
	
													// Return N, beta, SEM, pvalue and confidence intervals into r()

tempfile ten
	   forvalue i=1/4{
		`ten'= 10^`i'							// In the local file ten, for each value in the list, multiply 10 by itself (raise 10 to that power)
	   }							
	   
	   simulate new_var_list , reps(500) : wkeight // Using simulate, run the program wkeight 500 times

