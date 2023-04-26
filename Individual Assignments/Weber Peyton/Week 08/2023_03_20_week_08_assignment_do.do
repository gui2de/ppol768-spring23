*SS 2023 PPOL 768-01 Week 8 Assignment 
*Author: Peyton Weber
*Last edited March 20, 2023 ; March 28, 2023 ; March 31, 2023 ; April 1, 2023

*Part 1: Sampling noise in a fixed population

cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 08/Outputs" 

*Reviewer should change the working directory accordingly. 

*First task : "Write a .do file that creates a fixed population of 10,000 individual observations and generate random Xs for them...Save this dataset in your week-08 folder."

*Clearing the dataset. 
clear
*Setting the number of observations in a new, empty dataset. 
set obs 10000
*Setting a unique seed number so that the results are replicable. 
set seed 27138870
*Generating an x variable that generates random numbers using a normal distribution. 
gen random_x = rnormal()
*Saving the newly-created dataset and using the replace function to run the .do file over many times. 
save "part_one", replace

*Second task: "Write a .do file defining a program that a) loads this data; b) randomly samples a subset whose sample sizee is an argument to the program; c) create the Ys from the Xs with a true relationship and an error source; d) performs a regression of Y on one X; and e) returns the N, beta, SEM, p-value, and confidence intervals into r()." 

*Loading in the dataset saved.
use "part_one.dta"
*Defining the program. Before Stata defines the program, it should drop it. Allows for us to re-run the .do file.
capture program drop dgp
program define dgp, rclass
*Creating code that will allow us to define the sample size each time you recall the program. In this case, sample size is the argument. 
syntax, samplesize(integer) 
*Loading in the dataset. 
clear
display as error "1"
*Displaying as error the steps will allow me to better track where code breaks. 
use "part_one.dta" 
display as error "2" 
sample `samplesize', count
local treat_num = `samplesize'/2 
display as error "3" 
gen x1 = rnormal() 
*Create an arbitrary regressor. 
gen random_num = rnormal()
*Sorting the random variable. 
egen rank = rank(random_num)
*Creating a treatment to study using a regression model. Splitting the sample in half, where only half of the sample receives the treatment. 
gen treatment = 0 
replace treatment = 1 if rank >= `treat_num'
display as error "4" 
*Creating the outcome variable from the X variable. 
gen y = x1 + treatment*runiform()
display as error "5" 
*Regressing the outcome variable on the treated population. 
reg y treatment  
*Saving the results in a matrix. 
mat results = r(table)
display as error "6" 
*Create a way to recall the beta coefficient. 
return scalar beta = results[1,1]
display as error "7" 
*Create a way to recall the p-value. 
return scalar pval = results[4,1]
display as error "8"
*Create a way to recall the standard error.
return scalar sem = results[2,1]
display as error "9" 
*Create a way to recall the lower limit of the confidence interval. 
return scalar lower = results[5,1]
*Create a way to recall the upper limit of the confidence interval. 
return scalar upper = results[6,1] 
display as error "10" 
*Create a way to recall the sample size number. 
return scalar n = `samplesize'
display as error "11" 
end 

*Third task : "Using the simulate command, run your program 500 times at each sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting dataset of 2,000 regression results into Stata."

clear 
tempfile partone
*Saving a tempfile. Telling Stata it's okay if the dataset is empty, and that it's okay to replace the dataset each time the .do file is run. 
save `partone', replace emptyok

*Creating a loop so that I can adjust the sample sizes! 
forvalues i=1/4{
	*Creating a local variable that dictates the sample size. 
	local samplesize= 10^`i'
	display as error "iteration = `i'" 
	*Following code from 3/16/2023 class notes.
	tempfile sims 
	*Using simulate command per 3/16/2023 in-class exercise. 
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lower) upperbound = r(upper) n = r(n), reps(500) seed(27138870) saving(`sims') : dgp, samplesize(`samplesize')
	display as error "Post-Simulate Code"
	
	use `sims', clear 
	gen samplesize=`samplesize'
	append using `partone'
	save `partone', replace
}

use `partone', clear

*Fourth task : "Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size and characterize the size of the SEM and confidence intervals as N gets larger." 

*Creating a histogram that illustrates the distribution of beta coefficients by sample size. 
histogram beta_coef, by(samplesize) xtitle("Estimated Beta Coefficient") ytitle("Density") 
*Creating a table that illustrates the distribution of the beta coefs, standard errors, and confidence intervals by sample size. 
collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize) 

*Part 2:

*First task : "Write a .do file defining a program that: a) randomly creates a dataset whose sample size is an argument to the program following your DGP from Part 1, including a true relationship and an error source; b) performs a regression of Y on one X; and c) returns the N, beta, SEM, p-value, and confidence intervals into r()." 

*Generate and define a new program:
capture program drop dgp2
program define dgp2, rclass 
*Generating an "arg" for sample size. 
syntax, samplesize(integer)
clear
set obs `samplesize'
local treat_num = `samplesize'/2
*Create an arbitrary regressor. 
gen x1 = rnormal()
*Generating a random variable to be an arbitrary covariate. 
gen random_num = rnormal()
*Sorting the random variable. 
egen rank = rank(random_num)
*Creating a treatment to study using a regression model. Splitting the sample in half, where only half of the sample receives the treatment. 
gen treatment = 0 
replace treatment = 1 if rank >= `treat_num'
*Creating the outcome variable. 
gen y = x1 + treatment*runiform()
*Regressing the outcome variable on the treatment. 
reg y treatment 
*Doing a lot of the same thing we did in the first program from part one. 
mat results = r(table)
*Create a way to recall the beta coefficient. 
return scalar beta = results[1,1]
*Create a way to recall the p-value. 
return scalar pval = results[4,1]
*Create way to recall the standard error.
return scalar sem = results[2,1]
*Create way to recall the lower limit of the confidence interval. 
return scalar lower = results[5,1]
*Create way to recall the upper limit of the confidence interval. 
return scalar upper = results[6,1] 
*Create way to recall the sample size number. 
return scalar n = `samplesize'
end

*Second task : "Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata." 

clear
tempfile combined2
save `combined2', replace emptyok


forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims2
	simulate beta_coef=r(beta) pval=r(pval)  se = r(sem) lowerbound = r(lower) upperbound = r(upper) n = r(n) ///
	  , reps(500) seed(31723) saving(`sims2') ///
	  : dgp2, samplesize(`samplesize') 

	use `sims2' , clear
	gen samplesize=`samplesize'
	append using `combined2'
	save `combined2', replace
	display as error "iteration = `i'"
}
 
forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims3
	simulate beta_coef=r(beta) pval=r(pval)  se = r(sem) lowerbound = r(lower) upperbound = r(upper) n = r(n) ///
	  , reps(500) seed(31723) saving(`sims3') ///
	  : dgp2, samplesize(`samplesize') 

	use `sims3' , clear
	gen samplesize=`samplesize'
	append using `combined2'
	save `combined2', replace
	display as error "iteration = `i'"
}
 

use `combined2', clear

*Third task : "Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger."

histogram beta_coef, by(samplesize) 
collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize)  

*Fourth task : "Do these results change if you increase or decrease the number of repetitions (from 500)?" 

clear
tempfile final_q
save `final_q', replace emptyok


forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims4
	simulate beta_coef=r(beta) pval=r(pval)  se = r(sem) lowerbound = r(lower) upperbound = r(upper) n = r(n) ///
	  , reps(50) seed(31723) saving(`sims4') ///
	  : dgp2, samplesize(`samplesize') 

	use `sims4' , clear
	gen samplesize=`samplesize'
	append using `final_q'
	save `final_q', replace
	display as error "iteration = `i'"
}
 
forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims5
	simulate beta_coef=r(beta) pval=r(pval)  se = r(sem) lowerbound = r(lower) upperbound = r(upper) n = r(n) ///
	  , reps(50) seed(31723) saving(`sims5') ///
	  : dgp2, samplesize(`samplesize') 

	use `sims5' , clear
	gen samplesize=`samplesize'
	append using `final_q'
	save `final_q', replace
	display as error "iteration = `i'"
}
 

use `final_q', clear

*Fifth task : "Create histogram of beta distribution by sample size..." 

histogram beta, by(samplesize)
collapse (iqr) beta_coef se lowerbound upperbound, by(samplesize) 

