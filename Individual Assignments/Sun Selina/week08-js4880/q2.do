global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week08-js4880/"

*program generate sample
capture program drop infinite
program define infinite, rclass 
*samplesize as syntax
syntax, samplesize(integer)
clear
set obs `samplesize'
gen x = rnormal(100,5)
gen y= 7*x + rnormal(27,8)
reg y x 
mat a=r(table)
return scalar beta = a[1,1]
return scalar SEM = a[2,1]
return scalar pvalue = a[4,1]
return scalar ll = a[5,1]
return scalar ul = a[6,1]
end 

clear 

tempfile sim_2results 
save `sim_2results', replace emptyok

*first twenty powers of two
forvalues i=1/20{
	local samplesize = 2^`i'
	tempfile sims2
	simulate beta =r(beta) SEM=r(SEM) ///
	pval=r(pvalue) ll=r(ll) ul=r(ul), ///
	reps(500) seed(2023048) saving(`sims2', replace): ///
	infinite, samplesize(`samplesize')
	
	
	use `sims2', clear
	gen samplesize = `samplesize'
	append using `sim_2results'
	save `sim_2results', replace 

}

save "$wd/q2_results.dta", replace


tempfile sim_3results 
save `sim_3results', replace emptyok

*first twenty powers of two
forvalues i=1/6{
	local samplesize = 10^`i'
	tempfile sims3
	simulate beta =r(beta) SEM=r(SEM) ///
	pval=r(pvalue) ll=r(ll) ul=r(ul), ///
	reps(500) seed(2023048) saving(`sims3', replace): ///
	infinite, samplesize(`samplesize')
	
	
	use `sims3', clear
	gen samplesize = `samplesize'
	append using `sim_3results'
	save `sim_3results', replace 

}

save "$wd/q2_2results.dta", replace

use "$wd/q2_2results", clear

gen part = 2 
replace part = 1 if samplesize==10|samplesize==100 ///
|samplesize==1000|samplesize==10000|samplesize==100000

tabstat beta pval SEM ul ll, by(samplesize)

twoway (histogram beta if part == 1, frequency by(samplesize)), ///
xtitle("Beta Estimates")
graph export q2_beta.png, replace
twoway (histogram beta if part == 2, frequency by(samplesize)), ///
xtitle("Beta Estimates")
graph export q2_power2.png, replace
graph hbox SEM, over(samplesize)
graph export q2_SEM.png, replace 

****************************************************************
*repeat 100 times 
clear 
tempfile sim_100_results
save `sim_100_results', replace emptyok

forvalues i=1/4{
	local samplesize = 10^`i'
	tempfile sims
	simulate beta =r(beta) SEM=r(SEM) ///
	pval=r(pvalue) ll=r(ll) ul=r(ul), ///
	reps(100) seed(20230410) saving(`sims'): ///
	infinite, samplesize(`samplesize')
	
	
	use `sims', clear
	gen samplesize = `samplesize'
	append using `sim_100_results'
	save `sim_100_results', replace 
	
}
save "$wd/q2_100results.dta", replace

tabstat beta pval SEM ul ll, by(samplesize)
