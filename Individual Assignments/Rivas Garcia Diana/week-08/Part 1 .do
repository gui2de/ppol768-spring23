/*******************************************************************************

Week 08 Problem Set

********************************************************************************/

clear
set seed 12785


cd "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-08"



set obs 10000


gen x =rnormal() 

save "week8_data", replace 


capture program drop trial1
program define trial1, rclass

syntax, samplesize(integer)
*(a) loads this data
use "week8_data" , clear

*(b) randomly samples a subset whose sample size is an argument to the program
sample `samplesize', count 

*(c) create the Y's from the X's with a true relationship an an error source;
gen y= 2 + 1.5*x + 2*rnormal() 

*(d) performs a regression of Y on one X;

reg y x 
*(e) returns the N, beta, SEM, p-value, and confidence intervals into r().*/

mat a = r(table)


 return scalar samp = _N
 return scalar beta = a[1,1]
 return scalar sem = a[2,1]
 return scalar pval = a[4,1]
 return scalar ci_l= a[5,1] 
 return scalar ci_u= a[6,1] 

end

*trial1 100 // trying it out with this value 

*Trying different sample sizes 

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval) se=r(sem) lower=r(ci_l) upper=r(ci_u) ///
	  , reps(500) seed(725485) saving(`sims') ///
	  : trial1, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace

}
use `combined', clear 
 mat list a
 

*Betas by samplesize graph
tw (lpolyci beta samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(1.5) 

*Betas by samplesize histogram
histogram beta, by(samplesize)

*Creating table 
collapse (mean) beta se , by(samplesize)

