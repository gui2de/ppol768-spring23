**** BeverlyAnn Hippolyte 
**** PPOL 768 : Week 8 Assignment 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-08" 

// Change working directory 

clear
	set seed 3005					// Use set seed to maintain the observations 

	set obs 10000					// Create a dataset that generates 10000 observations 
	gen x = runiform()				

	save tiida.dta, replace
	

*	DGP
	
* Sampling noise in a fixed population 						

capture program drop wkeight						// Establish program 
program define wkeight,rclass						// Define the program 
	syntax, samplesize(integer)
	clear 
	use tiida, clear								// Load dataset with observations
	
	sample `samplesize', count 						// Randomly generate a subset of the data 
	
	gen error=runiform()
	
	gen y = 3 + 4*x + 5*error
	
	
	reg y x
	matrix results = r(table)
	
	return scalar beta = results[1,1]
	return scalar pval = results[4,1]
	return scalar serrorm = results[2,1]
	return scalar conint = results[5,1]		 // Return N, beta, SEM, pvalue and confidence intervals into r()
	return scalar confint = results [6,1]								
	
	
end


clear
tempfile combined
save `combined', replace emptyok

forvalues i = 1/4 {
	local ss = 10^`i'

	simulate column_beta=r(beta) column_pvalues=r(pval), reps(500) : wkeight, samplesize(`ss')	
	gen samplesize=`ss'
	
	append using `combined'
	save `combined', replace
	
	}

use `combined', clear

exit 
tempfile sims
simulate column_beta=r(beta) column_pvalues=r(pval), reps(500) saving(`sims'): wkeight, samplesize(1000)

use `sims', clear

exit 
	
													