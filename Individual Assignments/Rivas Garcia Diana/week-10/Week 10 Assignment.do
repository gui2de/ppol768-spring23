/*******************************************************************************

Week 10 Assignment 
Diana Rivas 
Part 1

*******************************************************************************/


*Power is the probability that a test correctly rejects a false null hypothesis

power twomeans 0 .5 , power(0.8) sd(2)  


*I was able to make the following program work and obtain power close to .8. I am struggling in adding a `samplesize' so that the regressings are done in different samplesizes 


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

