***** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 
**** Part 2: Sampling noise in an infinite superpopulation

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" // Change working directory

capture program drop nissan					// Establish program 
program define nissan, rclass					// Define the program 
syntax, samplesize(integer)					// Randomly create a dataset; Sample size is an argument in the program
	clear
	set obs `samplesize'
	gen x = runiform()				// Generate dataset

	gen num_num =runiform()					// Generate a new variable to store random sample
	
	
	gen y = 5 +7* x+ 6*num_num				// Generate new variable using x's
	
	reg y x					     		// Regression of y on one x observation

	matrix a = r(table)

	return scalar sample_size = e(N)
	return scalar beta = a[1,1]
	return scalar pval = a[4,1]
	return scalar stderr = a[2,1]
	return scalar upl = a[5,1]
	return scalar lowl = a[6,1]

end 


clear
tempfile primary										// Establish local file
save `primary', replace emptyok							// Empty local file

forvalues i = 1/6 {										// Define loop
	local sm = 10^`i'									// Establish local file to run simulations N number of times
	tempfile sems
	simulate N=r(sample_size) col_beta=r(beta) col_pvalues=r(pval), reps(500) saving (`sems'): nissan, samplesize(`sm')	// Run simulation
	gen samplesize=`sm'									// Generate local file to save N number of simulations

	use`sems',clear
	append using `primary'								// Append local file everytime the simulation is run N number of times 
	save `primary', replace								// Save local file
	}
	
	
forvalues i = 2/20 {
	local sm = 2^`i'
	
	tempfile sems
	simulate N=r(sample_size) col_beta=r(beta) col_st= r(stderr), reps(500) saving(`sems'): nissan, samplesize(`sm')
	gen samplesize =`sm'
	
	use `sems',clear 
	append using `primary'								// Append local file everytime the simulation is run N number of times 
	save `primary', replace								// Save local file
	
}

use `primary', clear 
	

hist col_beta, by(N)
graph export part_two_five.png,replace








