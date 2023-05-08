
********************************************************************************
* PPOL 768
* Week 8
* Keegan Brown
********************************************************************************


/*## Part 1: Sampling noise in a fixed population

1. Develop some data generating process for data X's and for outcome Y.*/
clear all

cd "/Users/keeganbrown/Desktop/Georgetown/RD/Assignments (Non-Repository) /week-08"

/*2. Write a do-file that creates a fixed population of 10,000 individual 
observations and generate random X's for them (use `set seed` to make sure it 
will always create the same data set). Save this data set in your `week-08` 
folder.*/ 
set obs 10000
set seed 13609
generate x = rnormal()
gen y = x + runiform() // gen y from x 


save "output.dta", replace 
clear 

/*3. Write a do-file defining a `program` that: (a) loads this data; (b) 
randomly samples a subset whose sample size is an argument to the program; 
(c) create the Y's from the X's with a true relationship an an error source; 
(d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, 
p-value, and confidence intervals into `r()`.*/ 


set seed 13609

capture program drop listargs
program define listargs, rclass
	syntax, samplesize(integer)
	clear 
	use "output.dta" // loading data 
	sample `samplesize', count 
	reg y x // performs regression 
	mat results = r(table)
	return scalar n = e(N) // provides n for later pull 
	return scalar beta = results[1, 1]
	return scalar ser = results[2, 1]
	return scalar pval = results[4, 1]
	return scalar cilow = results[5, 1]
	return scalar cihigh = results[6, 1]
end

tempfile first
tempfile all
save `all', replace emptyok 


	

/*4. Using the `simulate` command, run your program 500 times each at sample 
sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 
regression results into Stata.*/ 

forvalues i = 1/4 {
	local samplesize = 10^`i'
	display `samplesize'
	simulate n = r(n) betas = r(beta) ses = r(ser) pval = r(pval) lower = r(cilow) upper = r(cihigh), ///
	reps(500) seed(13609) saving(`first', replace): listargs, samplesize(`samplesize')
	use `all'
	append using `first'
	save `all', replace
}



/*5. Create at least one figure and at least one table showing the variation in 
your beta estimates depending on the sample size, and characterize the size of 
the SEM and confidence intervals as N gets larger.*/ 

// graph
graph bar betas, over(n) blabel(total) /// graph for the first part 

collapse betas ses lower upper, by(n)

graph export "outputs/part1_bar.png", replace


// table 

gen interval = upper - lower 


export excel using "outputs/part1_table.xls", firstrow(variables) replace 


/*6. Fully describe your results in your `README.md` file, including figures 
and tables as appropriate.*/


/*## Part 2: Sampling noise in an infinite superpopulation.
1. Write a do-file defining a `program` that: (a) randomly creates a data set 
whose sample size is an argument to the program following your DGP from Part 1 
including a true relationship an an error source; (b) performs a regression of 
Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals
 into `r()`.*/
 
 
 capture program drop second_prog
 program define second_prog, rclass 
 syntax, samplesize(integer)
 
	clear 
	set obs `samplesize'
	gen x = rnormal()
	gen y = x + 3*rnormal()
	regress y x
	mat results = r(table)
	return scalar n = e(N) // provides n for later pull 
	return scalar beta = results[1, 1]
	return scalar ser = results[2, 1]
	return scalar pval = results[4, 1]
	return scalar cilow = results[5, 1]
	return scalar cihigh = results[6, 1]
end

tempfile part_2
save part_2, replace emptyok 
	
	
 
/*2. Using the `simulate` command, run your program 500 times each at sample 
sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as 
well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the 
resulting data set of 13,000 regression results into Stata.*/

clear 

tempfile all 
save `all', replace emptyok 

tempfile reg1
forvalues i = 2/21 {
	local samplesize = 2^`i'
	display `samplesize'
	simulate betas =r(beta) pvalue=r(pval) se = r(ser) lower= r(cilow) upper = r(cihigh) n = r(n) ///
	  , reps(500) seed(13609) saving(`reg1', replace) ///
	  : second_prog, samplesize(`samplesize') 
	use `reg1'
	append using `all'
	save `all', replace 
}



tempfile reg2 
forvalues i = 1/6 {
	local samplesize = 10^`i'
	simulate betas =r(beta) pvalue=r(pval) se = r(ser) lower= r(cilow) upper = r(cihigh) n = r(n) ///
	 , reps(500) seed(13609) saving(`reg2', replace) ///
	  : second_prog, samplesize(`samplesize') 
	use `reg2'
	append using `all'
	save `all', replace
}


/*3. Create at least one figure and at least one table showing the variation in
 your beta estimates depending on the sample size, and characterize the size of 
 the SEM and confidence intervals as N gets larger.*/
 

graph bar betas, over(n) blabel(total) // mean of betas
twoway lpolyci betas n if n>100, xscale(log) // confidence intervals 


collapse betas se lower upper, by(n)

graph export "outputs/part2_graph.png", replace

rename n samplesize 

export excel using "outputs/part2_table.xls", firstrow(variables) replace 



/*4. Fully describe your results in your `README.md` file, including figures 
and tables as appropriate.*/



/*5. In particular, take care to discuss the reasons why you are able to draw a 
larger sample size than in Part 1, and why the sizes of the SEM and confidence 
intervals might be different at the powers of ten than in Part 1. Can you 
visualize Part 1 and Part 2 together meaningfully, and create a comparison table?
*/



/*6. Do these results change if you increase or decrease the number of 
repetitions (from 500)?*/

// does not change - but the confidence average of the betas do not change the results
// 

