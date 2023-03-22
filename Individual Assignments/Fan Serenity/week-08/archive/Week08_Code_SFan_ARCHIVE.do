*Part 1: Sampling noise in a fixed population

*Develop some data generating process for data X's and for outcome Y.

*Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.

*Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().

*Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.

*Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

*Fully describe your results in your README.md file, including figures and tables as appropriate.

*_______________________________
*Part 2: Sampling noise in an infinite superpopulation.

*Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().

*Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.

*Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

*Fully describe your results in your README.md file, including figures and tables as appropriate.

*In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?

*Do these results change if you increase or decrease the number of repetitions (from 500)?

*Resources
*1) www.stata.com/manuals/u18.pdf 
*         /manuals13/psyntax.pdf 

*Create fixed population of 10,000 observations and generate random X's 
clear

set seed 1000

set obs 10000

*Move this to inside the program, for PART II
gen x1 = rnormal() 

save Q1_fixed_population, replace


capture program drop normal_reg
program define normal_reg, rclass 
	syntax, samplesize(integer)
	
	clear
	use Q1_fixed_population 
	*Create Sub-Sample  
	sample `samplesize', count 

	set obs `samplesize'
	*gen x1 = rnormal() 
	gen random_num = rnormal()
	egen rank = rank(random_num)

	gen treatment=0
	replace treatment=1 if rank>5000 

*DGP = Data-Generating Process 
*Add data which includes random noise ranging from [0,100]
	gen y = x1 + treatment*100*runiform() 
*Ryun regression on this 
	reg y treatment 
	mat results = r(table) 
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar pval = results[4,1]
	return scalar SEM = results[2,1] 
	return scalar ci_lower = results[5,1]
	return scalar ci_upper = results[6,1]
	
end

*Write simulated subsampled data to tempfiles 
clear
tempfile combined
save `combined', replace emptyok

*Simulate: Run program 500 times at each sub-sample size 10, 100, 1000, and 10,000 forvalues i=1(2)10
forvalues i = 1/4 {
	local samplesize = 10^`i' 
	tempfile sim_results 
	simulate beta_coeff=r(beta) N = r(subsample_size) pvalues=r(pval) beta=r(beta) SEM=r(SEM) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(50) seed(2023) saving(`sim_results'): normal_reg, samplesize(`samplesize')
		
		use `sim_results', clear 
		append using `combined'
		save `combined', replace
} 
*sample() 
*count()

use `combined', clear
*exit

*use `sims', clear 











*Create histogram 
*local style "start(-0.5) barwidth(0.99) width(0.1) fc(gray) freq" 
*tw /// 
*	(histogram beta, `style' lc(red) ) ///
*	(histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ), xtit("") legend(on ring(0) pos(1F) order(2 "p<0.05") region(lc(none)))