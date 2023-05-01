*******************************************************************************
*** PPOL 768-01
*** Student: Gustavo Murillo Velazquez
*** Week 08 Assignment
*******************************************************************************

cd "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-08"


// Step 1: Develop some data generating process for data X's and for outcome Y.

/*

y= sales are normally distrubuted with mean 10000 sd 1500
x= access to the treatment

*/

// Step 2: creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). 

clear
set seed 2000
set obs 10000
gen shoparea=runiform(500,1000)

save NEWDATA, replace


// Step 3 Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().


capture program drop normal_treat
program define normal_treat, rclass
syntax, samplesize(integer)


clear
use NEWDATA, clear
gen sales = 4000 + 4*shoparea + runiform(4000,10000)

sample `samplesize', count 



reg sales shoparea

mat results = r(table)


 
return scalar N = e(N)
return scalar beta = results[1,1]
return scalar SEM = results[2,1]
return scalar pval = results[4,1]
return scalar ci_upper = results[6,1]
return scalar ci_lower = results[5,1]

end

normal_treat, samplesize(1000)

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4 {
	local samplesize = 10^`i'
tempfile sims
simulate beta=r(beta) se=r(SEM) pvalue=r(pval) ci_u=r(ci_upper) ci_l=r(ci_lower) N=r(N), reps(500) seed(2023) saving(`sims'): normal_treat, samplesize(`samplesize')

use `sims', clear 
append using `combined'
save `combined', replace 	
	
	
	
}

use `combined', clear


*Graph and tables

histogram beta, by (N) xtitle("Beta Coefficient Estimations") ytitle("Density")
graph save "Graph" "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-08/outputs/Graph.gph", replace

tabstat beta se ci_l ci_u, by(N) stats(iqr mean) 


/////////////////////////// PART 2 /////////////////////////////////////////////

// Step 1: Creating a random dataset

clear

capture program drop normal_treat2
program define normal_treat2, rclass
	syntax, samplesize(integer)
	clear
	
	gen sales = 4000 + 4*shoparea + runiform(4000,10000)

	set obs `samplesize'


	reg sales shoparea

	mat results = r(table)


	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar SEM = results[2,1]
	return scalar pval = results[4,1]
	return scalar ci_upper = results[6,1]
	return scalar ci_lower = results[5,1]

end

normal_treat, samplesize(1000)

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4 {
	local samplesize = 10^`i'
tempfile sims
simulate beta=r(beta) se=r(SEM) pvalue=r(pval) ci_u=r(ci_upper) ci_l=r(ci_lower) N=r(N), reps(500) seed(2023) saving(`sims'): normal_treat, samplesize(`samplesize')

use `sims', clear 
append using `combined'
save `combined', replace 	
	
	
	
}

use `combined', clear


*Graph and tables

histogram beta, by (N) xtitle("Beta Coefficient Estimations") ytitle("Density")
graph save "Graph2" "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-08/outputs/Graph.gph", replace

tabstat beta se ci_l ci_u, by(N) stats(iqr mean) 
