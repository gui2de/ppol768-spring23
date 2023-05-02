* Chance Hope
* Do-file: Week 08
cd "C:\Users\maxis\Desktop\ppol768-spring23\Individual Assignments\Hope Chance\week-08"
global wd "C:\Users\maxis\Desktop\ppol768-spring23\Individual Assignments\Hope Chance\week-08"
global p1results "$wd\p1results"
// Part 1: Sampling noise in a fixed population
/*
1.Develop some data generating process for data X's and for outcome Y.
2.Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.
3.Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().
4.Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.
5.Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
6.Fully describe your results in your README.md file, including figures and tables as appropriate.
*/

* Part 1: Question 1
// Define the program
cap prog drop normaldistro
prog def normaldistro, rclass 	// Allow returning values to memory

syntax, samplesize(integer)

  clear
  set obs `samplesize'
  local treat_num = `samplesize'/2
  gen x1 = rnormal() 			// Arbitrary covariate
  gen rand = rnormal()  	 	// 50-50 treatment
  egen rank = rank(rand)
  gen treatment = rank <= `treat_num'

 // DGP
  gen y = x1 + treatment*runiform() // Heterogeneous, positive effect

  reg y treatment
  mat a = r(table)
  return scalar beta = a[1,1]
  return scalar pval = a[4,1]
end
*-----------------------------------------

*Part 1: Question 2
* Set seed for reproducibility
clear
set seed 12345

* Generate fixed population of 10,000 observations
set obs 10000

* Generate random X's
gen x = rnormal(0, 1)

* Save the dataset
save "$wd\population.dta", replace
*-----------------------------------------

* Part 1: Question 3
* Define the program
cap prog drop reg1
prog def reg1, rclass
  args samplesize

  * Load the fixed population data
  use "$wd\population.dta", clear

  * Randomly sample a subset
  sample `samplesize', count

  * Define X and Y
  gen y = 2 * x + rnormal(0, 1)

  * Perform a regression of Y on X
  reg y x

  * Store regression results in matrix
  mat a = r(table)
 
  * Return the N, beta, SEM, p-value, and confidence intervals into r()
  return scalar N = `samplesize'
  return scalar beta = a[1,1]
  return scalar SEM = a[2,1]
  return scalar pvalue = a[4,1]
  return scalar CI_lower = a[5,1]
  return scalar CI_upper = a[6,1]
end
*-----------------------------------------

* Part 1: Question 4 
* Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000
clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate N = r(N) beta=r(beta) SEM = r(SEM) pval=r(pvalue) ///
	CI_lower = r(CI_lower) CI_upper = r(CI_upper), ///
	reps(500) seed(12345) saving(`sims'): reg1 `samplesize'
	use `sims', clear
	append using `combined'
	save `combined', replace
	}
use `combined'
*-----------------------------------------
//Part 1: Question 5
*histogram to show distribution of betas by samplesize
histogram beta, by(N) freq

*tables showing variation in beta estimates by sample size
gen cidif = CI_upper-CI_lower
tab N, sum(cidif) nost nofreq 
tab N, sum(SEM) nost nofreq 
save "$wd\p1results", replace

// Part 2: Sampling noise in an infinite superpopulation.
/*1.Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().
2. Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. 3. Load the resulting data set of 13,000 regression results into Stata.
3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
5. Fully describe your results in your README.md file, including figures and tables as appropriate.
6. In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?
Do these results change if you increase or decrease the number of repetitions (from 500)?*Part 1: Sampling noise in a fixed population
*/

* Part 2: Question 1
cap prog drop reg2
prog def reg2, rclass
  args samplesize

  * Randomly create a dataset
  clear
  set obs `samplesize'
  gen x = rnormal(0, 1)
  gen y = 2 * x + rnormal(0, 1)

  * Perform a regression of Y on X
  reg y x

  * Return the N, beta, SEM, p-value, and confidence intervals into r()
  mat a = r(table)
  return scalar N = `samplesize'
  return scalar beta = a[1,1]
  return scalar SEM = a[2,1]
  return scalar pvalue = a[4,1]
  return scalar CI_lower = a[5,1]
  return scalar CI_upper = a[6,1]
end
*-----------------------------------------

* Part 2: Question 2
clear

tempfile combined2

save `combined2', replace emptyok

// For powers of two
forvalues i = 2(1)21 {
    local samplesize2 = 2^`i'
    
    tempfile sims2
    
    simulate beta=r(beta) pval=r(pvalue) CI_lower=r(CI_lower) CI_upper=r(CI_upper) N=r(N) SEM=r(SEM), ///
      reps(500) seed(725485) saving(`sims2'): reg2 `samplesize2'
    
    use `sims2', clear
    gen samplesize = `samplesize2'
    
    append using `combined2'
    save `combined2', replace
}

// For powers of ten
forvalues i = 1/6 {
  local samplesize10 = 10^`i'
  
  tempfile sims10
  
  simulate beta=r(beta) pval=r(pvalue) CI_lower=r(CI_lower) CI_upper=r(CI_upper) N=r(N) SEM=r(SEM), ///
    reps(500) seed(725485) saving(`sims10') : reg2 `samplesize10'
  
  use `sims10', clear
  gen samplesize =`samplesize10'
  
  append using `combined2'
  save `combined2', replace
}

use `combined2', clear
save "C:\Users\maxis\Desktop\ppol768-spring23\Individual Assignments\Hope Chance\week-08\pt2.dta", replace
*-----------------------------------------
* Part 2, Question 3
*histogram to show distribution of betas by samplesize
histogram beta, by(N) freq

*tables showing variation in beta estimates by sample size
gen cidif = CI_upper-CI_lower
tab N, sum(cidif) nost nofreq 
tab N, sum(SEM) nost nofreq 

*compare datasets
gen pt2=1
append using "$wd\p1results"
replace pt2=0 if pt2==.
tab N pt2 if inlist(N, 10, 100, 1000, 10000), sum(cidif) nost nofreq 
tab N pt2 if inlist(N, 10, 100, 1000, 10000), sum(SEM) nost nofreq 

histogram SEM if N==10 | N==100 | N==1000 | N==10000, freq by(N pt2)
histogram SEM if N==10 | N==100, freq by(N pt2)
histogram cidif if N==10 | N==100 | N==1000 | N==10000, freq by(N pt2)
histogram cidif if N==10 | N==100, freq by(N pt2)
