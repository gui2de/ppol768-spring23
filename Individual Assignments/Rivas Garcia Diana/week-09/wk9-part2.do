/*******************************************************************************

Week 9 Assignment 
Diana Rivas 
Part 2

*******************************************************************************/


clear all 


capture program drop wk9_2
program define wk9_2, rclass
syntax, strata(integer) samplesize(integer) 


clear 
set obs 5
gen region=_n

expand 50

gen cov_xy = rnormal() // affects treatment and y , Confounder 
gen cov_x = rnormal()  // affects the treatment 
gen cov_y = rnormal() // only affects y 

gen treatment = (region/5 + cov_x + 0.1*cov_xy + 2*rnormal())>0.45

gen channel= treatment*rnormal() // channel is a function of treatment 


*DGP

gen y = region + cov_xy + cov_y + rnormal() + 0.5*channel

gen collider= rnormal() + .2*y // creating the collider variable

matrix a=r(table) 

reg y channel // MODEL 1
	return scalar model1=_b[channel]

reg y channel i.region // MODEL 2
	return scalar model2=_b[channel]

reg y channel i.region collider // MODEL 3
	return scalar model3=_b[channel]

reg y channel i.region cov_xy cov_x // MODEL 4
	return scalar model4=_b[channel]

reg y channel i.region cov_xy cov_x cov_y collider // MODEL 5
	return scalar model5=_b[channel]

reg y channel i.region cov_y cov_xy // MODEL6
	return scalar model6=_b[channel]

end 

clear
tempfile table
save `table', replace emptyok



forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate model1=r(model1) model2=r(model2) ///
           model3=r(model3) model4=r(model4) ///
           model5=r(model5) model6=r(model6), reps(500) saving(`sims') /// 
  : wk9_2, strata(5) samplesize(`samplesize')
  
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


tw (lpolyci model6 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) 
tw (lpolyci model5 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) // has collider
tw (lpolyci model4 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5)
tw (lpolyci model3 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) //has collider
tw (lpolyci model2 samplesize,fc(gray%30)) , xscale(log) xlab(10 100 1000 10000) yline(.5) //no colider, same as 2

collapse (mean) model1 model2 model3 model4 model5 model6, by(samplesize)





