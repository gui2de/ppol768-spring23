/*******************************************************************************

Week 9 Assignment 
Diana Rivas 
Part 1

*******************************************************************************/


clear all 


capture program drop wk9
program define wk9, rclass
syntax, strata(integer) samplesize(integer) 


clear 
set obs 5
gen region=_n

expand 50

gen cov_xy = rnormal() // affects treatment and y , Confounder 
gen cov_x = rnormal()  // affects the treatment 
gen cov_y = rnormal() // only affects y 

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
reg y treatment i.region cov_y cov_xy
return scalar m6=_b[treatment]
end 

clear
tempfile table
save `table', replace emptyok

*I am unsure if I should put a seed anywhere here because I have tried putting it in different places and it makes me get the same predictions for all samplesizes so this shows up in the graph as a flat line

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate m1=r(m1) m2=r(m2) ///
           m3=r(m3) m4=r(m4) ///
           m5=r(m5) m6=r(m6), reps(500) saving(`sims') /// 
  : wk9, strata(5) samplesize(`samplesize')
  
  use `sims' , clear
	gen samplesize=`samplesize'
	append using `table'
	save `table', replace

}
use `table', clear 
 mat list a

histogram m1, by(samplesize)
histogram m4, by(samplesize)
histogram m6, by(samplesize) //includes all variable except colliding 


tw (lpolyci m6 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) 
tw (lpolyci m5 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5)
tw (lpolyci m4 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5)
tw (lpolyci m3 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) //only chose certain models for sake of space. 


collapse (mean) m1 m2 m3 m4 m5 m6, by(samplesize)

rename (m1 m2 m3 m4 m5 m6) (treat treat_reg treat_reg_conf treat_reg_conf_cov treat_reg_conf_cov_cov treat_reg_cov_conf)



