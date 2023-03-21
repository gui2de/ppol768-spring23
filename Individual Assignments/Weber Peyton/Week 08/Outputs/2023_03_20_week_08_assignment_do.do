*SS 2023 PPOL 768-01 Week 8 Assignment 
*Author: Peyton Weber
*March 20, 2023 

*Part 1: Sampling noise in a fixed population

*Clearing the dataset. 
clear
*Setting the number of observations in a new, empty dataset. 
set obs 10000
*Setting a unique seed number so that the results are replicable. 
set seed 27138870
*Generating an x variable. 
gen x1 = rnormal()
*Saving the newly-created dataset and using the replace function to run the .do file over many times. 
save part_one, replace

*Step 1: Define the program
capture program drop dgp
program define dgp, rclass
*Creating code that will allow us to define the sample size each time you recall the program. 
syntax, samplesize(integer) 
*Loading in the dataset. 
use "part_one", clear
*Generating a random variable. 
gen random_num = rnormal()
*Sorting the random variable. 
egen rank = rank(random_num)
sort random_num
*Creating a treatment to study using a regression model. Splitting the sample in half, where only half of the sample receives the treatment. 
gen treatment = 0 
replace treatment = 1 if rank > 50
*Creating the outcome variable. 
gen y = x1 + treatment
*Regressing the outcome variable on the key, dependent variable. 
reg y x1 
*Saving the results in a matrix. 
mat results = r(table)
*Create way to recall the beta coefficient. 
return scalar beta = results[1,1]
*Create way to recall the p-value. 
return scalar pval = results[4,1]
*Create way to recall the standard error.
return scalar se = results[2,1]
*Create way to recall the lower limit of the confidence interval. 
return scalar ll = results[5,1]
*Create way to recall the upper limit of the confidence interval. 
return scalar ul = results[6,1] 
*Create way to recall the sample size number. 
return scalar N = results[7,1]+2 
end 

clear 
tempfile partone
*Saving a tempfile. Telling Stata it's okay if the dataset is empty, and that it's okay to replace the dataset each time the .do file is run. 
save `partone', replace emptyok

*Creating a loop so that I can adjust the sample sizes! 
forvalues i=1/4{
	*Creating a local variable that dictates the sample size. 
	local samplesize= 10^`i'
	*Following code from 3/16/2023 class notes.
	tempfile sims 
	*Using simulate command per 3/16/2023 in-class exercise. 
	simulate betacoef=r(beta), reps(500) seed(27138870) saving(`sims') : dgp, samplesize(`samplesize')
	*Asking stata to provide the return list.
	return list
	use `sims', clear 
	*Creating the various sample sizes required for this assignment. 
	gen samplesize=`samplesize'
	append using `partone'
	save `partone', replace
}

*Creating a histogram that illustrates the beta coefficients by sample size. 
histogram betacoef, by(samplesize) xtitle("Estimated Beta Coefficient") ytitle("Density") 
*Creating a table that illustrates the variance by sample size. 
table samplesize, stat(variance betacoef) 

*Part 2:

*Still needs to be completed! 



