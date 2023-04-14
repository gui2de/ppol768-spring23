**** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" 

// Change working directory 

clear
	set seed 3005					// Use set seed to maintain the observations 

	set obs 10000					// Create a dataset that generates 10000 observations 
	gen x = runiform()				// Generate dataset

	save tiida.dta, replace 		// Save dataset 
	

*	DGP
	
* Sampling noise in a fixed population 						

capture program drop wkeight						// Establish program 
program define wkeight,rclass						// Define the program 
	syntax, samplesize(integer)
	clear 
	use tiida, clear								// Load dataset with observations
	
	sample `samplesize', count 						// Randomly generate a subset of the data 
	
	gen error=runiform()
	
	gen y = 3 + 4*x + 5*error						// Generate y variable 
	
	
	reg y x
	matrix results = r(table)
	
	return scalar beta = results[1,1]
	return scalar pval = results[4,1]
	return scalar ul = results[6,1]
	return scalar ll = results[5,1]
	return scalar std = results[2,1]
end

clear
tempfile combined										// Establish local file
save `combined', replace emptyok						// Empty local file

forvalues i = 1/4 {										// Define loop
	local ss = 10^`i'									// Establish local file to run simulations N number of times

	simulate beta=r(beta) pvalues=r(pval), reps(500) : wkeight, samplesize(`ss')	// Run simulation
	gen sampleesize=`ss'									// Generate local file to save N number of simulations
	
	append using `combined'								// Append local file everytime the simulation is run N number of times 
	save `combined', replace							// Save local file
	
	}

use `combined', clear									// Run local file

tempfile sims
simulate column_beta=r(beta) column_pvalues=r(pval) column_std=r(std) column_ll=r(ll) column_ul=r(ul), reps(500) saving(`sims'): wkeight, samplesize(10000)

use `sims'

hist column_beta 
display column_beta, column_std, column_ll, column_ul
graph export part1sample10000.png, replace 

exit 

	
													