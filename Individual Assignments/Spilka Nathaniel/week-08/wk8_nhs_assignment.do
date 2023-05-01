*******************************************************************************
** clean workspace, set dir, load data, quick view of data
*******************************************************************************
* nate spilka
* 2023-04-26

* clean workspace 
cls
clear all

* set dir
cd "/Users/nathanielhugospilka/Documents/research_methods_2023/research_design/ppol768-spring23/Individual Assignments/Spilka Nathaniel/week-08"

*******************************************************************************
** Part 1: Sampling noise in a fixed population
*******************************************************************************

* 2
cls
clear all
set seed 950703
* creating 10,000 random x values from a normal distribution - then save the data
set obs 10000
generate x_val_rand = rnormal()
save "x_rand", replace 

* 3
clear

* drop the program before defining it
capture program drop p1program 

* define the program
program define p1program, rclass

* creating the sample size arguement
syntax, sample_size(integer)
	
	clear	
	* (a) load data
	use "x_rand.dta"
	
	* (b) randomly sample a subset whose sample size is an argument to the program
	sample `sample_size', count 
	
	* (c) create the Y's from the X's with a true relationship and an error source
	generate y_val_rand = x_val_rand + runiform()
	
	* (d) performs a regression of Y on X
	regress y_val_rand x_val_rand
	
// 	mat list results 
	* (e) returns the N, beta, SEM, p-value, and confidence intervals into r()	
	mat results = r(table)
	return scalar N = `sample_size'
	return scalar beta = results[1, 1]
	return scalar SEM = results[2, 1]
	return scalar pvalue = results[4, 1]
	return scalar ci_ll = results[5, 1]
	return scalar ci_ul = results[6, 1]

end

* checking output
// p1program, sample_size(10)

* 4
tempfile temp1
tempfile temp2
save `temp2', replace emptyok 

* N = 10, 100, 1,000, and 10,000
local vals 10 100 1000 10000

foreach val of local vals {
	
	* run your program 500 times
	simulate ///
	beta_coef = r(beta) ///
	se = r(SEM) ///
	pvalue = r(pvalue) ///
	n = r(N) ///
	lowerbound = r(ci_ll) upperbound = r(ci_ul), ///
	reps(500) seed(950703) saving(`temp1', replace): ///
	p1program, sample_size(`val') 
	
	use `temp1'
	append using `temp2'
	save `temp2', replace

}

* 5

* creating a ci for the figures below
generate conf_int = upperbound - lowerbound

* Histograms showing the variation in betas, ses, and cis, by sample size
histogram beta_coef, by(n)
histogram se, by(n)
histogram conf_int, by(n)

* Table showing the variation in beta, se, lowerbound, upperbound, and conf_int, by sample size
collapse (iqr) beta_coef se lowerbound upperbound conf_int, by(n)


*******************************************************************************
** Part 2: Sampling noise in an infinite superpopulation
*******************************************************************************

cls
clear all
set seed 950703

* 1
* drop the program before defining it
capture program drop p2program 

* define the program
program define p2program, rclass

* creating the sample size arguement
syntax, sample_size(integer)
	
	clear
	* (a) the program argument sets the sample size
	set obs `sample_size'
	
	generate x_val_rand = rnormal()
	generate y_val_rand = x_val_rand + 3 * rnormal()
	
	* (b) performs a regression of Y on X
	regress y_val_rand x_val_rand
// 	mat list results
 
	* (c) returns the N, beta, SEM, p-value, and confidence intervals into r()	
	mat results = r(table)
	return scalar N = `sample_size'
	return scalar beta = results[1, 1]
	return scalar SEM = results[2, 1]
	return scalar pvalue = results[4, 1]
	return scalar ci_ll = results[5, 1]
	return scalar ci_ul = results[6, 1]
	
end

* 2
tempfile temp3
tempfile temp4
tempfile temp5
save `temp5', replace emptyok 

forvalues i = 2/21 {
	
	* sample sizes corresponding to the first twenty powers of two
	local val = 2 ^ `i'
	
	* run your program 500 times
	simulate ///
	beta_coef = r(beta) ///
	se = r(SEM) ///
	pvalue = r(pvalue) ///
	n = r(N) ///
	lowerbound = r(ci_ll) upperbound = r(ci_ul), ///
	reps(50) seed(950703) saving(`temp3', replace): ///
	p2program, sample_size(`val') 
	
	use `temp3'
	append using `temp5'
	save `temp5', replace

}

* N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000
local vals 10 100 1000 10000 100000 1000000

foreach var of local vals {
	
	* run your program 500 times
	simulate ///
	beta_coef = r(beta) ///
	se = r(SEM) ///
	pvalue = r(pvalue) ///
	n = r(N) ///
	lowerbound = r(ci_ll) upperbound = r(ci_ul), ///
	reps(50) seed(950703) saving(`temp4', replace): ///
	p2program, sample_size(`var') 
	
	use `temp4'
	append using `temp5'
	save `temp5', replace

}

* 3

* creating a ci for the figures below
generate conf_int = upperbound - lowerbound

* Histograms showing the variation in betas, ses, and cis, by sample size
histogram beta_coef, by(n)
histogram se, by(n)
histogram conf_int, by(n)

* Table showing the variation in beta, se, lowerbound, upperbound, and conf_int, by sample size
collapse (iqr) beta_coef se lowerbound upperbound conf_int, by(n)




