/*Marlyn Bruno
Assignment 08*/

/***************************************************************************

Part 1: Sampling noise in a fixed population

****************************************************************************/

*2. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder

cd "/Users/marlyn/GitHub/ppol768-spring23/Individual Assignments/Bruno Marlyn/week-08"

clear
set obs 10000
set seed 194861
gen random_x = rnormal() //sets random numbers based on random picks using a normal distribution 

save "mydata", replace 

*3. Write a do-file defining a program that a) loads this data; b) randomly samples a subset whose sample size is an argument to the program; c) create the Y's from the X's with a true relationship an error source; d) performs a regression of Y on one X and e) returns the N, beta, SEM, p-value, and confidence intervals into r()

use "mydata.dta"

/*

Code I would do for one run with fixed sample size 10000 - reviewers, can ignore this code as it was written to help me write the program below. 
	set obs 10000
	gen x1 = rnormal() // Arbitrary covariate
	gen rand = rnormal()  // 50-50 treatment
    egen rank = rank(rand) //rank the random numbers so that we can split upper into treatment group
    gen treatment = 0
	replace treatment = 1 if rank >= 50

 
  gen y = x1 + treatment*runiform() // Heterogeneous, positive effect

  reg y treatment
  mat a = r(table)
  mat list a
  
	return scalar beta = a[1,1]
	return scalar sem = a[2,1] 
    return scalar pval = a[4,1]
	return scalar lowerCI = a[5,1]
	return scalar upperCI = a[6,1] */
  

capture program drop myprogram //Before defining program, drop it
program define myprogram, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program

	clear
	display as error "1"
	use "mydata.dta" 
	display as error "2"
	sample `samplesize', count
	local treat_num = `samplesize'/2 //divide by two to split sample into control & treatment
	display as error "3"
	gen x1 = rnormal() // Arbitrary covariate
	gen rand = rnormal()  // 50-50 treatment based off normal distribution
    egen rank = rank(rand) //rank the random numbers so that we can split upper half into treatment group
    gen treatment = 0 
	replace treatment = 1 if rank >= `treat_num'

 display as error "4"
	gen y = x1 + treatment*runiform() // Heterogeneous, positive effect
	display as error "5"
	reg y treatment
	mat results = r(table) //save matrix of results as "results"
   display as error "6"
    return scalar n = `samplesize'
	return scalar beta = results[1,1]
	display as error "7"
	return scalar sem = results[2,1] 
    return scalar pval = results[4,1]
	display as error "8"
	return scalar lowerCI = results[5,1]
	return scalar upperCI = results[6,1]

end

 
*4. Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting daataset of 2,000 regression results into Stata

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	display as error "iteration = `i'"
	tempfile sims
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(864086) saving(`sims') ///
	  : myprogram, samplesize(`samplesize') 
	display as error "after simulate command"

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace

}
 
use `combined', clear
exit 

*5. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger. 


*histogram to show distribution of betas by samplesize
histogram beta_coef, by(samplesize)

*use collapse command to create a table 
collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize)

/*generating a histogram of betas for samplesize=100
keep if samplesize==100
local style "start(-0.5)  barwidth(0.09) width(.1) fc(gray) freq"
tw ///
  (histogram beta , `style' lc(red) ) ///
  (histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ) ///
, xtit("") legend(on ring(0) pos(1) order(2 "p < 0.05") region(lc(none)))*/


/***************************************************************************

Part 1: Sampling noise in a fixed population

****************************************************************************/

*Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r(). (We are generating a population here)

capture program drop myprogram2 //Before defining program, drop it
program define myprogram2, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program

	clear
	set obs `samplesize'
	local treat_num = `samplesize'/2 //divide by two to split sample into control & treatment
	gen x1 = rnormal() // Arbitrary covariate
	gen rand = rnormal()  // 50-50 treatment based off normal distribution
    egen rank = rank(rand) //rank the random numbers so that we can split upper half into treatment group
    gen treatment = 0 
	replace treatment = 1 if rank >= `treat_num'

	gen y = x1 + treatment*runiform() // Heterogeneous, positive effect
	reg y treatment
	mat results = r(table) //save matrix of results as "results"
    return scalar n = `samplesize' 
	return scalar beta = results[1,1]
	return scalar sem = results[2,1] 
    return scalar pval = results[4,1]
	return scalar lowerCI = results[5,1]
	return scalar upperCI = results[6,1]
	
end

*Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.

clear
tempfile combined_sims
save `combined_sims', replace emptyok

forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims2
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(247192) saving(`sims2') ///
	  : myprogram2, samplesize(`samplesize') 

	use `sims2' , clear
	gen samplesize=`samplesize'
	append using `combined_sims'
	save `combined_sims', replace
	
	display as error "This is iteration `i'"
}

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims3 //do i have to use another tempfile here than the one used in first loop?
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(247192) saving(`sims3') /// //do we have to use different seed here?
	  : myprogram2, samplesize(`samplesize') 

	use `sims3' , clear
	gen samplesize=`samplesize'
	append using `combined_sims'
	save `combined_sims', replace
	
	display as error "This is iteration `i'"
}
 
use `combined_sims', clear

exit 

*histogram to show distribution of betas by samplesize
histogram beta_coef, by(samplesize)

*use collapse command to create a table 
collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize)


*6. Do these results change if you increase or decrease the number of repetitions (from 500)?

clear
tempfile q6
save `q6', replace emptyok

forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims4
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(50) seed(247192) saving(`sims4') ///
	  : myprogram2, samplesize(`samplesize') 

	use `sims4' , clear
	gen samplesize=`samplesize'
	append using `q6'
	save `q6', replace
	
	display as error "This is iteration `i'"
}

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims5 //do i have to use another tempfile here than the one used in first loop?
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(50) seed(247192) saving(`sims5') /// //do we have to use different seed here?
	  : myprogram2, samplesize(`samplesize') 

	use `sims5' , clear
	gen samplesize=`samplesize'
	append using `q6'
	save `q6', replace
	
	display as error "This is iteration `i'"
}
 
use `q6', clear

collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize)
