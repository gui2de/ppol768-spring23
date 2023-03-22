*____________________________
*PART 1: SAMPLING NOISE IN A FIXED POPULATION 

clear 

set seed 1000 
set obs 10000

gen x1 = rnormal() 
save Q1_fixed_population, replace 

*Create program 
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
	replace treatment=1 if rank>7 

*DGP = Data-Generating Process 
	gen y = x1 + treatment*runiform() 
	reg y treatment 
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar SEM = results[2,1] 
	return scalar pval = results[4,1]
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


*N = 10, 100, 1000, 10,000
forvalues i=1/4 { 
	local samplesize = 10^`i'
	tempfile sims
	simulate N=r(subsample_size) beta_coeff=r(beta) SEM=r(SEM) pvalues=r(pval) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) seed(2023) 	saving(`sims'): normal_reg, samplesize(`samplesize')

	use `sims', clear 
	append using `combined'
	save `combined', replace
}

use `combined', clear

*Graph 
histogram beta_coeff, by(N)
graph export "outputs/beta_graph_fixed.png", replace

*Figures for table 
bysort N: egen mean_beta = mean(beta)
bysort N: egen mean_SEM = mean(SEM)
bysort N: egen mean_pvalues = mean(pvalues)
bysort N: egen mean_ci_lower = mean(ci_lower)
bysort N: egen mean_ci_upper = mean(ci_upper)

save "outputs/stats_fixed.dta", replace





*____________________________
*PART 2: SAMPLING NOISE IN AN INFINITE SUPERPOPULATION 

clear 

*Create program 
capture program drop normal_reg_superpop
program define normal_reg_superpop, rclass 
	syntax, populationsize(integer)
	clear 
	set obs `populationsize'
	gen x1 = rnormal() 

	save Q2_fixed_population, replace      
	use Q2_fixed_population
	
	gen random_num = rnormal()
	egen rank = rank(random_num)

	gen treatment=0
	replace treatment=1 if rank>7 

*DGP = Data-Generating Process 
	gen y = x1 + treatment*runiform() 
	reg y treatment 
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar SEM = results[2,1] 
	return scalar pval = results[4,1]
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

*N = 2, 4, 8, 16, ..., 1,048,576
forvalues i=2/20 { 
	local populationsize = 2^`i'
	tempfile sims
	simulate N=r(subsample_size) beta_coeff=r(beta) SEM=r(SEM) pvalues=r(pval) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) 	saving(`sims'): normal_reg_superpop, populationsize(`populationsize')

	use `sims', clear 
	append using `combined'
	save `combined', replace
}

*N = 10, 100, 1000, 10,000, 100,000, and 1,000,000
forvalues i=1/6 { 
	local populationsize = 10^`i'
	tempfile sims
	simulate N=r(subsample_size) beta_coeff=r(beta) SEM=r(SEM) pvalues=r(pval) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) 	saving(`sims'): normal_reg_superpop, populationsize(`populationsize')

	use `sims', clear 
	append using `combined'
	save `combined', replace
}

use `combined', clear


*Graph 
histogram beta_coeff, by(N)
graph export "outputs/beta_graph_super.png", replace

*Figures for table 
bysort N: egen mean_beta = mean(beta)
bysort N: egen mean_SEM = mean(SEM)
bysort N: egen mean_pvalues = mean(pvalues)
bysort N: egen mean_ci_lower = mean(ci_lower)
bysort N: egen mean_ci_upper = mean(ci_upper)

save "outputs/stats_super.dta", replace

*Input graphs into markdown! Save, then make in markdown folder, then insert preliminary observations, for both parts. 