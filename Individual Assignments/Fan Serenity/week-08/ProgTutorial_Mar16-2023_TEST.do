clear 

set seed 1000 
set obs 10000

gen x1 = rnormal() 
save Q1_fixed_population, replace 


capture program drop normal_reg
program define normal_reg, rclass 
	syntax, samplesize(integer)
	clear 
	*set obs `samplesize'
	*gen x1 = rnormal() 
     
	use Q1_fixed_population
	sample `samplesize', count 
	
	set obs `samplesize'
	
	gen random_num = rnormal()
	egen rank = rank(random_num)

	gen treatment=0
	replace treatment=1 if rank>50 

*DGP = Data-Generating Process 
	gen y = x1 + treatment*runiform() 
	reg y treatment 
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar pval = results[4,1]
	return scalar SEM = results[2,1] 
	return scalar ci_lower = results[5,1]
	return scalar ci_upper = results[6,1]

end

*normal_reg, samplesize(100)  
*display r(beta)

*mat list results




*Simulate_____________
clear
tempfile combined 
save `combined', replace emptyok

forvalues i=1/4 { 
	local samplesize = 10^`i'
	tempfile sims
	simulate beta_coeff=r(beta) N=r(subsample_size) pvalues=r(pval) beta=r(beta) SEM=r(SEM) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(50) seed(2023) 	saving(`sims'): normal_reg, samplesize(`samplesize')

	use `sims', clear 
	append using `combined'
	save `combined', replace
}

use `combined', clear


*local style "start(-0.5) barwidth(0.99) width(0.1) fc(gray) freq" 
*tw /// 
*	(histogram beta, `style' lc(red) ) ///
*	(histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ), xtit("") legend(on ring(0) pos(1F) order(2 "p<0.05") region(lc(none)))