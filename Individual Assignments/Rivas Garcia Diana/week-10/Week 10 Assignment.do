/*******************************************************************************

Week 10 Assignment 
Diana Rivas 
Part 1

*******************************************************************************/


*Power is the probability that a test correctly rejects a false null hypothesis

power twomeans 0 .5 , power(0.8) sd(2)  


*Creating process for a fixed samplesize: 

capture program drop wk10_prog
program  define wk10_prog, rclass
clear 
set obs 5
gen region=_n

expand 40

gen cov_xy = rnormal() // affects treatment and y , Confounder 
gen cov_x = rnormal()  // affects the treatment 
gen cov_y = rnormal() // only affects y 

gen treatment = (region/5 + cov_x + 0.1*cov_xy + 2*rnormal())>0.45

gen y = region + cov_xy + cov_y + rnormal() + 0.5*treatment 

reg y treatment  
	matrix results =r(table)  //store results
	return scalar beta = _b[treat]
	return scalar pval = results[4,1]
end

simulate beta=r(beta) pvalue=r(pval), seed(5689) rep(1000): wk10_prog
gen sig1 = pvalue < 0.05  
summ sig 

*******************************************************************************
*simulating different populations sizes

capture program drop wk10_prog
program  define wk10_prog, rclass
syntax, strata(integer) samplesize(integer)
clear 
set obs 5
gen region=_n

expand 40

gen cov_xy = rnormal() // affects treatment and y , Confounder 
gen cov_x = rnormal()  // affects the treatment 
gen cov_y = rnormal() // only affects y 

gen treatment = (region/5 + cov_x + 0.1*cov_xy + 2*rnormal())>0.45

gen y = region + cov_xy + cov_y + rnormal() + 0.5*treatment 

reg y treatment  
	matrix results =r(table)  //store results
	return scalar beta = _b[treat]
	return scalar pval = results[4,1]
end

clear
tempfile table
save `table', replace emptyok


forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pvalue=r(pval), seed(5689) rep(1000) saving(`sims') ///
		: wk10_prog, strata(5) samplesize(`samplesize')
  
  use `sims' , clear
	gen samplesize=`samplesize'
	append using `table'
	save `table', replace

}
use `table', clear 
gen sig1 = pvalue < 0.05  
summ sig 



reg y treeatment 
power twomeans .89 .87 , power(0.8) sd(.31)  //The minimum population is 7,546 



