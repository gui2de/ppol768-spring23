

clear 
capture program drop par

* Week 8 Assignment
* Emma Nyhof

* Super busy with work this week so ran out of time, will come back to it onece things slow down


cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation"

*** PART 1 ***

*Part 1: Sampling noise in a fixed population
	* 1. Develop some data generating process for data X's and for outcome Y.
	
	* 2. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's 	for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.
	
	clear
	set obs 10000
	set seed 9999
	gen x1 = rnormal(50, 10) 
	

	
	save "week-08-part1-data.dta", replace
	clear
	
	* 3. Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().
	
capture program drop part1
program define part1, rclass
	syntax, samplesize(integer)
	clear
	use "week-08-part1-data.dta"
	sample `samplesize', count
	gen y = x1*7 + rnormal(10,5)
	
	reg y x1 
	mat results = r(table)
	return scalar N = `samplesize'
	return scalar beta = results[1,1]
	return scalar SEM = results[2,1]
	return scalar pval = results[4,1]
	* figured out confidence intervlas - upper and lower bounds below
	return scalar ll = results[5,1]
	return scalar ul = results[6,1]
	

end
	

	local ss 10 100 1000 10000
	
	foreach x in `ss' {
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval) ll = r(ll) ul = r(ul), reps(500) seed(9999) saving(`sims`x''): part1, samplesize(`x') 
	save `sims`x'', replace
	}
	
	local ss 100 1000 10000
	use `sims10'
	
	foreach x in `ss' {
	append using `sims`x''
	}


	* 5. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
	
	*Extreme variation in beta when sample size is small (10), very little variation when large. SEM and CIs very large with small sample size, much smaller as it increases.
	
	twoway (histogram beta if N == 10, color(blue%30)) ///
		   (histogram beta if N == 10000, color(yellow%30)), ///
		   legend(order(1 "N = 10" 2 "N = 10000"))
	
	graph save "Graph" "week8_part1.gph", replace
	
	table () (N), stat(sd beta) stat(mean beta pval SEM ll ul) stat(range beta pval SEM) nototal
	
	* 6. Fully describe your results in your README.md file, including figures and tables as appropriate.
	
	
********* Part 2: Sampling noise in an infitie superpopulation

* 1. Write a do-file defining a program that 

clear
capture program drop week8part2
program define week8part2, rclass

	syntax, samplesize(integer)
	clear
	set obs `samplesize'
	*set seed 9999
	gen x1 = rnormal(50, 10)
	
	gen y = x1*7 + rnormal(10,5)
	reg y x1
	
	mat results = r(table)
	return scalar N = `samplesize'
	return scalar beta = results[1,1]
	return scalar SEM = results[2,1]
	return scalar pval = results[4,1]

end
	
	local samples 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 524288 1048576 2097152 10 100 1000 10000 100000 1000000

foreach x in `samples' {
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(500) seed(9999) saving(`sims`x''): week8part2, samplesize(`x')
}

local samples 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 524288 1048576 2097152 10 100 1000 10000 100000 1000000

use `sims4'
foreach x in `samples' {
	append using `sims`x''
}
 
 	table (N) (), stat(sd beta) stat(mean beta pval SEM) stat(range beta pval SEM) nototal
	
	twoway (histogram beta if N == 256, color(blue%30)) ///
		(histogram beta if N == 4096, color(yellow%30)) ///
		(histogram beta if N == 2097152, color(red%30)), ///
		legend(order(1 "N = 256" 2 "N = 4,096" 3 "N = 2,097,152"))
	
	graph save "Graph" "week8_part2.gph", replace
	
	
	 table () (N) if N == 10 | N == 100 | N == 1000 | N == 10000, stat(sd beta) stat(mean beta pval SEM) stat(range beta pval SEM) nototal
	 
	 
* Experimenting with increasing/decreasing repetitions (limiting number of sample size options to save time)

	local samples 4 128 2048 32768 524288 2097152 

foreach x in `samples' {
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(100) seed(9999) saving(`sims`x''): week8part2, samplesize(`x')
}

local samples 128 2048 32768 524288 2097152 

use `sims4'
foreach x in `samples' {
	append using `sims`x''
}
 
	table (N) (), stat(sd beta) stat(mean beta pval SEM) stat(range beta pval SEM) nototal
	
	
		local samples 4 128 2048 32768 524288 2097152 

foreach x in `samples' {
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(1000) seed(9999) saving(`sims`x''): week8part2, samplesize(`x')
}

local samples 128 2048 32768 524288 2097152 

use `sims4'
foreach x in `samples' {
	append using `sims`x''
}
 
	table (N) (), stat(sd beta) stat(mean beta pval SEM) stat(range beta pval SEM) nototal

