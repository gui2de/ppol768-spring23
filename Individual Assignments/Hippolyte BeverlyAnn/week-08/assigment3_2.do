***** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 
**** Part 2: Sampling noise in an infinite superpopulation

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" // Change working directory 

clear
capture program drop nissan					// Establish program 
program define nissan 						// Define the program 
syntax, samplesize(integer)					// Randomly create a dataset; Sample size is an argument in the program
	gen num_num =runiform()						// Generate a new variable to store random sample
	egen rank = rank(num_num)					// Generate another variable to rank the new random sample
	gen belt =0 							// Generate new variable to store condition for regression
	
	replace belt =1 if rank-5000 <50		 // Set variable equal to one if the random minus one thousand is less than 50 
	
end	
	
	gen y = x + belt						// Generate new variable using x's
	
	reg y x						     		// Regression of y on one x observations


tempfile twenty
	   forvalue i=1/20{
		`twenty'= 2 ^`i'					// In the local file twenty, for each value in the list, multiply 10 by itself (raise 10 to that power)
	   }				
	simulate new_list, reps(500): nissan  	// Using simulate, run the program wkeight 500 times

	
					

					