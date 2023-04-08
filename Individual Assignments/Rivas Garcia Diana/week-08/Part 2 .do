********************************************************************************

*Question 2

********************************************************************************

clear all

capture program drop week8_p2
program define week8_p2, rclass 
syntax, samplesize(integer) 


clear 
set obs `samplesize'



gen x =rnormal() 
gen y= 2 + 1.5*x + 2*rnormal() 
reg y x 

matrix a=r(table) 
matrix list a

return scalar samp = _N
 return scalar beta = a[1,1]
 return scalar sem = a[2,1]
 return scalar pval = a[4,1]
 return scalar ci_l= a[5,1] 
 return scalar ci_u= a[6,1] 

end



clear
tempfile combined2
save `combined2', replace emptyok

forvalues i=1/6{
	 local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval) se=r(sem) lower=r(ci_l) upper=r(ci_u) ///
	  , reps(500) seed(5678) saving(`sims') ///
	  : week8_p2, samplesize(`samplesize') 
	  
	use `sims', clear
	gen samplesize=`samplesize'
	append using `combined2'
	save `combined2', replace

}
use `combined2', clear 

*Betas by samplesize histogram
histogram beta, by(samplesize)


*Betas against real value
 tw (lpolyci beta samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(1.5) 

*Creating table
 collapse (mean) beta se , by(samplesize)
 

 