// Week 08
// Hannah Hill

*******************************************************************************
*  Question 1                                                                 *
*******************************************************************************
clear
set scheme s1color
set obs 10000
set seed 4142023
gen random_x = rnormal() 
save "wk08_data", replace 
use "wk08_data.dta"

capture program drop trial 
program define trial, rclass
syntax, samplesize(integer) 
	clear
	use "wk08_data.dta" 
	sample `samplesize', count
	local treat_num = `samplesize'/2 
	gen e = rnormal() // error term
	gen n_random = rnormal() 
    egen rank = rank(n_random) 
    gen treatment = 0 
	replace treatment = 1 if rank >= `treat_num'
	gen y = 7 + 2*treatment*runiform() + e
	reg y treatment
	mat results = r(table)
    return scalar n = `samplesize'
	return scalar beta = results[1,1]
	return scalar sem = results[2,1] 
    return scalar pval = results[4,1]
	return scalar lowerCI = results[5,1]
	return scalar upperCI = results[6,1]

end

 
//Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the 2,000 regression results into Stata.

tempfile merge
save `merge', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(2023414) saving(`sims') ///
	  : trial, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `merge'
	save `merge', replace

}
use `merge', clear
exit

// histogram by samplesize
histogram beta_coef, by(samplesize)
// table of beta coefficients
tabstat beta_coef se lowerbound upperbound, by(samplesize) stats(iqr mean)


*******************************************************************************
*  Question 2                                                                 *
*******************************************************************************

capture program drop trial2 
program define trial2, rclass 
syntax, samplesize(integer) 

	clear
	set obs `samplesize'
	local treat_num = `samplesize'/2 
	gen e = rnormal()
	gen n_random = rnormal() 
    egen rank = rank(n_random)
    gen treatment = 0 
	replace treatment = 1 if rank >= `treat_num'
	gen y = 7 + 2*treatment*runiform() + e 
	reg y treatment
	mat results = r(table) 
    return scalar n = `samplesize' 
	return scalar beta = results[1,1]
	return scalar sem = results[2,1] 
    return scalar pval = results[4,1]
	return scalar lowerCI = results[5,1]
	return scalar upperCI = results[6,1]
	
end

// load the 13,000 regressions

clear
tempfile sim_merge
save `sim_merge', replace emptyok

forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sim
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(247192) saving(`sim') ///
	  : trial2, samplesize(`samplesize') 

	use `sim' , clear
	gen samplesize=`samplesize'
	append using `sim_merge'
	save `sim_merge', replace
}

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sim1
	simulate beta_coef=r(beta) pvalue=r(pval) se = r(sem) lowerbound = r(lowerCI) upperbound = r(upperCI) n = r(n) ///
	  , reps(500) seed(2023414) saving(`sim1') /// 
	  : trial2, samplesize(`samplesize') 

	use `sim1' , clear
	gen samplesize=`samplesize'
	append using `sim_merge'
	save `sim_merge', replace
}
 
use `sim_merge', clear
exit 

// histogram by sample size for betas
histogram beta_coef, by(samplesize)
// export table betas
tabstat beta_coef se lowerbound upperbound, by(samplesize) stats(iqr mean)
