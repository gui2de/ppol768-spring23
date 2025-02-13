
capture program drop wk10_demo
program define wk10_demo, rclass
syntax, samplesize(integer)
	clear
	set obs `samplesize'  //total sample size
	local treat = `samplesize'/2 //divide control-treatment 
	gen treatment = 0
	replace treatment=1 if _n>`treat'
	gen math_score= rnormal()  //generate math_score
	replace math_score = math_score + 0.1 if treatment==1 //score in treatment is 0.1 sd higher 

	*run the regression
	reg math_score treatment 
	*store results
	matrix results =r(table)
	return scalar beta = results[1,1]
	return scalar pvalue = results[4,1]

end


 
clear
tempfile combined sims
save `combined', replace emptyok

forvalues i=500(1000)5000 {
simulate beta=r(beta) pval = r(pvalue), rep(500) saving(`sims', replace): ///
	wk10_demo, samplesize(`i')

	use `sims', clear
	gen N = `i'
	append using `combined'
	save `combined', replace


}


use `combined', clear 
gen sig = 0
replace sig =1 if pval<0.05
*power for each sample size level
mean sig, over(N)
