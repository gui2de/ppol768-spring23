* Part 1-(1~2): Save the equation with regard to the X!!!

clear

set seed 1234
 * Set a seed to create same data
set obs 10000
 * Fix population as 10000

gen e1 = rnormal()
 * Generate one error-term as normal distribution values 
gen random_num = rnormal()

gen x=random_num+e1
drop e1 random_num

save Part1_data, replace 

* Part 1-(3): Run the regression and see the results!!!

clear 

capture program drop normal_reg 
program define normal_reg, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\Week_08\Part1_data.dta"
	sample `samplesize', count
	
	gen e2 = runiform()
	gen y=5+3*x +e2
	* create the Y's from the X's
	reg y x
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

normal_reg, samplesize(100)
  * Randomly sampled 100

* Part 1-(4): Simulate program by running 500 times with different N and see the results!!!

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local ss = 10^`i'
	tempfile sims
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed(2023) saving(`sims'): normal_reg, samplesize(`ss')

use `sims', clear
append using `combined'
save `combined',replace
	
}

* Part 1-(5): Show it as a figure and a table!!!
use `combined', clear

histogram beta, by(N)
histogram sem, by(N)

gen range = ci_u- ci_l
histogram range, by(N)

* Part 2-(1): Write a program with 'randomly created data set'!!!

clear

capture program drop normal_reg2 
program define normal_reg2, rclass 
	syntax, samplesize(integer)
	clear
	set obs `samplesize'
	
	gen e1 = rnormal()
	 * Generate one error-term as normal distribution values 
	gen random_num = rnormal()

	gen x=random_num+e1
	drop e1 random_num
	
	gen e2 = runiform()
	gen y=5+3*x +e2
	reg y x
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

normal_reg2, samplesize(100)

* Part 2-(2): Simulate 500 times with sample first 20 powers of two; as well as first 6 powers of 10!!!

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/6{
	local ss = 10^`i'
	tempfile sims
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed(2023) saving(`sims'): normal_reg2, samplesize(`ss')

use `sims', clear
append using `combined'
save `combined',replace
	
}

* Part 2-(3): Create on figure and one table showing the variation in beta estimates, characterize the size of SEM and CI!!!

histogram beta, by(N)
histogram sem, by(N)

gen range = ci_u- ci_l
histogram range, by(N)

clear
tempfile combined
save `combined', replace emptyok

forvalues i=2/21{
	local ss = 2^`i'
	tempfile sims
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), reps(500) seed(2023) saving(`sims'): normal_reg2, samplesize(`ss')
use `sims', clear
append using `combined'
save `combined',replace
		
}

histogram beta, by(N)
histogram sem, by(N)

gen range = ci_u- ci_l
histogram range, by(N)