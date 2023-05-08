
*

clear 
capture program drop par

* Week 8 Assignment
* Emma Nyhof

* Super busy with work this week so ran out of time, will come back to it onece things slow down


cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-08\"

*** PART 1 ***

*Part 1: Sampling noise in a fixed population
	* 1. Develop some data generating process for data X's and for outcome Y.
	
	* 2. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's 	for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.
	
	clear
	set obs 10000
	set seed 9999
	gen x1 = rnormal(50, 10)
	gen x2 = rnormal()
	gen x3 = 0
	replace x3 = 1 if x1*x2 > 0
	
	save "week-08-part1-data.dta", replace
	clear
	
	* 3. Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().
	
capture program drop part1
program define part1, rclass
	syntax, samplesize(integer)
	clear
	use "week-08-part1-data.dta"
	sample `samplesize', count
	gen y = x1 + x3*runiform()
	
	reg y x3 
	mat results = r(table)
	return scalar N = `samplesize'
	return scalar beta = results[1,1]
	return scalar SEM = results[2,1]
	return scalar pval = results[4,1]
	* return scalar ci = // not sure about this one?

end
	
	* 4. Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.
	
	tempfile sims10
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims10'): part1, samplesize(10) 
	
	tempfile sims100
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims100'): part1, samplesize(100) 

	tempfile sims1000
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims1000'): part1, samplesize(1000) 

	tempfile sims10000
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims10000'): part1, samplesize(10000) 
	
	use `sims10'
	append using `sims100' `sims1000' `sims10000'
	
/*	Was trying to come up with a more efficient way to do the above here
	
	local ss 10 100 1000 10000
	
	foreach x in `ss' {
	tempfile sims`ss'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims`ss''): part1, samplesize("`ss'") 
	}
	
	use sims10
	append using sims100
	append using sims1000
	append using sims10000
*/

	* 5. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
	
	*Extreme variation in beta when sample size is small (10), very little variation when large. SEM and CIs very large with small sample size, much smaller as it increases.
	
	* 6. Fully describe your results in your README.md file, including figures and tables as appropriate.
	
	
********* Part 2: Sampling noise in an infitie superpopulation

* 1. Write a do-file defining a program that 

clear
capture program drop week8part2
program define week8part2, rclass

	syntax, samplesize(integer)
	clear
	set obs `samplesize'
	set seed 9999
	gen x1 = rnormal(50, 10)
	gen x2 = rnormal()
	gen x3 = 0
	replace x3 = 1 if x1*x2 > 0
	gen y = x1 + x3*3
	
	reg y x3
	
	mat results = r(table)
	return scalar N = `samplesize'
	return scalar beta = results[1,1]
	return scalar SEM = results[2,1]
	return scalar pval = results[4,1]

end
	
	local samples 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 524288 1048576 2097152 10 100 1000 10000 100000 1000000

foreach x in `samples' {
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pbal = r(pval), reps(500) seed(9999) saving(`sims`x''): week8part2, samplesize(`x')
}

local samples 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 524288 1048576 2097152 10 100 1000 10000 100000 1000000

use `sims4'
foreach x in `samples' {
	append using `sims`x''
}
 
