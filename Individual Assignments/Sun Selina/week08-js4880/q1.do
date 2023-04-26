global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week08-js4880/"

global q1 "$wd/week08.dta"

capture program drop noise
*allow returning values to memory 
program define noise, rclass //Allow returning values 

*syntax to define samplesize 
syntax, samplesize(integer)
use "$q1", clear
sample `samplesize',count

*create y from x and an error source 
gen y= 7*x + rnormal(27,8)

*regression y on x 
reg y x 

*store return results n, beta, SEM, p-value and confidence interval 
mat a = r(table)
return scalar n = e(N)
return scalar beta = a[1,1]
return scalar SEM = a[2,1]
return scalar pvalue = a[4,1]
return scalar ll = a[5,1]
return scalar ul = a[6,1]
end 
*simulate the program 500 times at different sample size and load the results
clear 
tempfile sim_results 
save `sim_results', replace emptyok

forvalues i=1/4{
	local samplesize = 10^`i'
	tempfile sims
	simulate beta =r(beta) SEM=r(SEM) ///
	pval=r(pvalue) ll=r(ll) ul=r(ul), ///
	reps(500) seed(20230407) saving(`sims'): ///
	noise, samplesize(`samplesize')
	
	
	use `sims', clear
	gen samplesize = `samplesize'
	append using `sim_results'
	save `sim_results', replace 
	
}

use `sim_results', clear

*table beta, sem, confidence interval
tabstat beta pval SEM ul ll, by(samplesize)
*export beta estimates 
twoway (histogram beta, frequency by(samplesize)), ///
xtitle("Beta Estimates")
graph export q1_beta.png, replace
*change of sem, different sample size
graph hbox SEM, over(samplesize)
graph export q1_SEM.png, replace 


