cd "D:\2021-2023, Georgetown University\2023 - Spring\Research Design & Implementation\ScottsRepo\ppol768-spring23\Individual Assignments\Brown Scott\week-08"
clear

*Part 1: Sampling noise in a fixed population
*Develop some data generating process for data X's and for outcome Y.
*Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.
clear
set seed 20230320
set obs 10000
gen x=rnormal()
save "week08data", replace

*Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().

capture program drop week08program
	prog def week08program, rclass 
	syntax, samplesize(integer)
	use "week08data.dta", clear
	sample `samplesize', count
	
	// Create treatment group (random assignment)
	local treatmentcount = `samplesize'/2
	gen x1 = rnormal() // control var x1
	gen random = rnormal()  // random assignment into treatment
    egen rank = rank(random)
    gen treat = rank <= `treatmentcount'

	// Create output var y as a function of x with random noise
	gen y= 50 + 10*x + 5*rnormal()
	
	// Regression
	reg y treat
		mat returns = r(table)
		return scalar beta = returns[1,1]
		return scalar pval = returns[4,1]
		return scalar lowci = returns[5,1]
		return scalar highci = returns[6,1]
		return scalar SEM = returns[2,1]
		return scalar N = returns[2,1]
	
end


*Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	display as error "iteration = `i'"
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(20230320) saving(`sims') ///
	  : week08program, samplesize(`samplesize') 
		display as error "after simulate command"
		
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
}
 

*Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
use `combined', clear

histogram beta, by(samplesize)
graph export beta_histogram.png, replace
	
histogram se, by(samplesize)
graph export se_histogram.png, replace
	
gen ci = upperbound - lowerbound
histogram ci, by(samplesize)
graph export ci_histogram.png, replace


*Part 2: Sampling noise in an infinite superpopulation.
*Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().
clear
capture program drop week08program_2
	prog def week08program_2, rclass 
	syntax, samplesize(integer)
	use "week08data.dta", clear
	sample `samplesize', count
	
	// Create treatment group (random assignment)
	local treatmentcount = `samplesize'/2
	gen x1 = rnormal() // control var x1
	gen random = rnormal()  // random assignment into treatment
    egen rank = rank(random)
    gen treat = rank <= `treatmentcount'

	// Create output var y as a function of x with random noise
	gen y= 50 + 10*x + 5*rnormal()
	
	// Regression
	reg y treat
		mat returns = r(table)
		return scalar beta = returns[1,1]
		return scalar pval = returns[4,1]
		return scalar lowci = returns[5,1]
		return scalar highci = returns[6,1]
		return scalar SEM = returns[2,1]
		return scalar N = returns[2,1]
	
end

*Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.
clear
tempfile combined_2
save `combined_2', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(20230320) saving(`sims') ///
	  : week08program_2, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_2'
	save `combined_2', replace
}
 
forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(20230320) saving(`sims') ///
	  : week08program_2, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_2'
	save `combined_2', replace
}
 
*Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
use `combined_2', clear

histogram beta, by(samplesize)
graph export beta_histogram2.png, replace
	
histogram se, by(samplesize)
graph export se_histogram2.png, replace
	
gen ci = upperbound - lowerbound
histogram ci, by(samplesize)
graph export ci_histogram2.png, replace

*Fully describe your results in your README.md file, including figures and tables as appropriate.


*In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?


*Do these results change if you increase or decrease the number of repetitions (from 500)?