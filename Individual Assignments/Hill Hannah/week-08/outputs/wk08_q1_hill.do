// Week 08
// Hannah Hill

*******************************************************************************
*   Question 1                                                                *
*******************************************************************************
clear
set scheme s1color

// set seed for reproducibility
set seed 32023
set obs 10000

// generate epsilon
gen e = rnormal()
gen n_random = rnormal()
gen x = n_random + e

save week08_data_hh803, replace

clear

capture program drop trial
program define trial, rclass
	syntax, samplesize(integer)

// A - load the data
use "week08_data_hh803.dta", clear

// B - randomly sample a subset whose sample size is an argument to the program
sample `samplesize', count

// C - create the Y's from the X's with a true relationship and an error source
gen ep = runiform()
gen y = 7 + 2*x + ep


// D - performs a regression of Y on one X
reg y x

// E - returns the N, beta, SEM, p-value, and confidence intervals into r()
matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[3,1]
	return scalar ci_l = results[4,1]
	return scalar ci_u = results[5,1]
	
end

// use 'simulate' command, run your program 500 times each at sample sizes N = 10, 100, 1000, and 10000.
clear
tempfile merge
save `merge', replace emptyok

forvalues i=1/4{
	local ss = 10^`i'
	tempfile simulations
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed(32023) saving(`simulations'): trial, samplesize(`ss')


use `simulations', clear
append using `merge'
save `merge', replace

}

// create one figure and one table showing variation in beta estimates depending on sample size and characterize the size of the SEM and confidence intervals as N gets larger
use `merge', clear

histogram sem, by(N)
histogram beta, by(N)
gen range = ci_u - ci_l
histogram range, by(N)




*******************************************************************************
** QUESTION 2                                                                **
*******************************************************************************
clear

// A - randomly creates a dataset whose sample size is an argument to the program following your DGP from Part 1 including a true relationship and an error source

capture program drop trial2
program define trial2, rclass
	syntax, samplesize(integer)
	clear
	set obs `samplesize'
	
	gen e = rnormal()
	gen n_random = rnormal()
	gen x = n_random + e

	gen ep = runiform()
	gen y = 7 + 2*x + ep

// B - performs a regression of Y on one X

reg y x

// C - returns the N, beta, SEM, p-value, and confidence intervals into r()
matrix results = r(table)
	matrix list results

	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[3,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]

end

trial2, samplesize(100)

// using 'simulate' command, run program 500 times each at sample sizes corresponding to the first 20 powers of two (ie 4,8,16, etc) as well as N = 10, 100, 1000, 10000, 100000, and 1000000.
clear
tempfile `merge'
save `merge', replace emptyok

forvalues i=1/6{
	local ss = 10^`i'
	tempfile simulations
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed (3202023) saving(`simulations'): trial2, samplesize(`ss')
	
// load resulting dataset of 13,000 regression results into stata
use `simulations', clear
append using `merge'
save `merge', replace

}

// create one figure and one table showing variation in beta estimates depending on sample size and characterize the size of the SEM and confidence intervals as N gets larger

histogram sem, by(N)
histogram beta, by(N)
gen range = ci_u - ci_l
histogram range, by(N)
clear

tempfile `merge'
save`merge', replace emptyok

forvalues i=2/20{
	local ss = 2^`i'
	tempfile simulations
	imulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed (3202023) saving(`simulations'): trial2, samplesize(`ss')
	
use `simulations', clear
append using `merge'
save `merge', replace
}

histogram sem, by(N)
histogram beta, by(N)
gen range = ci_u - ci_l
histogram range, by(N)