***** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 
**** Part 2: Sampling noise in an infinite superpopulation

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" // Change working directory 

clear
	set seed 3005					// Use set seed to maintain the observations 

	set obs 10000					// Create a dataset that generates 10000 observations 
	gen x = runiform()				// Generate dataset

	save tiida.dta, replace 		// Save dataset 
	

clear
capture program drop nissan					// Establish program 
program define nissan 						// Define the program 
syntax, samplesize(integer)					// Randomly create a dataset; Sample size is an argument in the program
	clear
	sample `samplesize', count 				// Randomly generate a subset of the data 

	gen num_num =runiform()					// Generate a new variable to store random sample
	
	
	gen y = 5 +7* x+ 6*num_num				// Generate new variable using x's
	
	reg y x					     		// Regression of y on one x observation

	matrix a = r(table)

	return scalar beta = results[1,1]
	return scalar pval = results[1,4]
	return scalar stderr = results[1,2]
	return scalar upl = results[1,5]
	return scalar lowl = results[1,6]

end 


clear
tempfile primary										// Establish local file
save `primary', replace emptyok							// Empty local file

forvalues i = 1/4 {										// Define loop
	local sm = 10^`i'									// Establish local file to run simulations N number of times
	
	tempfile siims
	simulate col_beta=r(beta) col_pvalues=r(pval) reps(500) seed(3005) saving(`siims'): nissan, samplesize(`sm')	// Run simulation
	gen samplesize=`sm'									// Generate local file to save N number of simulations

	append using `primary'								// Append local file everytime the simulation is run N number of times 
	save `primary', replace								// Save local file
	}
	
	
forvalues i = 1/20
	local sp = 2^`i'

	simulate col_beta=r(beta) col_pvalues=r(pval) reps(500) seed(3005): nissan, samplesize(`sp')

	gen samplesize =`sp'
	
	append using `primary'								// Append local file everytime the simulation is run N number of times 
	save `primary', replace								// Save local file
	
	}

exit 


	
					