/*******************************************************************************

Week 08 Problem Set

********************************************************************************/
wd "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-08"


set obs 10000

set seed 12785

gen x= runiform(0,10)

save "week8_data", replace 


capture program drop trial1
program define trial1, rclass

syntax, samplesize(integer)
*(a) loads this data
use "week8_data" , clear

*(b) randomly samples a subset whose sample size is an argument to the program
sample `samplesize', count 

*(c) create the Y's from the X's with a true relationship an an error source;

gen y=  x + x*runiform()

*(d) performs a regression of Y on one X;

reg x y
*(e) returns the N, beta, SEM, p-value, and confidence intervals into r().*/

mat a = r(table)


 return scalar samp = _N
 return scalar beta = a[1,1]
 return scalar sem = a[2,1]
 return scalar pval = a[2,1]
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
 mat list results 
 

exit

*Creating figure using class code
histogram beta, by(samplesize)
histogram se, by(samplesize)
exit 


*generating a histogram of betas for samplesize=100
keep if samplesize==100
local style "start(-0.5)  barwidth(0.09) width(.1) fc(gray) freq"
tw ///
  (histogram beta , `style' lc(red) ) ///
  (histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ) ///
, xtit("") legend(on ring(0) pos(1) order(2 "p < 0.05") region(lc(none)))

*Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

	*what I have attempted for this: getting the min and max values of the variables 
	
	/*clear
tempfile tabletry
save `tabletry', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile table
	
egen beta_min= min(beta) 
egen beta_max= max(beta) 
egen se_min= min(se) 
egen se_max= max(se) 
egen pval_min= min(pval) 
egen pval_max= max(pval) 
egen ci_l_min= min(lower) 
egen ci_l_max= max(lower) 
egen ci_u_min= min(upper) 
egen ci_u_max= max(upper) 

gen sample_size= samplesize

 drop beta pval se lower upper samplesize
 
 duplicates drop 
 
}// but this does not differentiate min and max by samplesize, it does it overall

	* I tried converting the summary results into tables 
	by samplesize: summ 
	
	outsheet using "mydata.xlsx", excel replace // tells me excel is not allowed
	
	*/
	
 *******************************************************************************
