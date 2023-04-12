clear all 


capture program drop wk9
program define wk9, rclass
syntax, strata(integer) samplesize(integer) 


clear 
set obs 5
gen region=_n

expand 50

gen cov_xy = rnormal()
gen cov_x = rnormal()
gen cov_y = rnormal()

gen treatment = (region/5 + cov_x + 0.1*cov_xy + 2*rnormal())>0.45

gen y = region + cov_xy + cov_y + rnormal() + 0.5*treatment 

matrix a=r(table) 

reg y treatment 
return scalar m1=_b[treatment]
reg y treatment i.region 
return scalar m2=_b[treatment]
reg y treatment i.region cov_xy 
return scalar m3=_b[treatment]
reg y treatment i.region cov_xy cov_x
return scalar m4=_b[treatment]
reg y treatment i.region cov_xy cov_x cov_y
return scalar m5=_b[treatment]
end 

clear
tempfile table
save `table', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate m1=r(m1) m2=r(m2) ///
           m3=r(m3) m4=r(m4) ///
           m5=r(m5), reps(500) saving(`sims') ///
  : wk9, strata(5) samplesize(`samplesize')
  
  use `sims' , clear
	gen samplesize=`samplesize'
	append using `table'
	save `table', replace

}
use `table', clear 
 mat list a
 
histogram m1, by(samplesize)

collapse (mean) m1 m2 m3 m4 m5, by(samplesize)

*new problem I need help with: Now I am getting the same results for all of the simulations no matter the samplesize 
