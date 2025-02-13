//1,2
set seed 1234
set obs 10000
gen X = rnormal()
save "/Users/liufan/Desktop/ppol768-spring23/Individual Assignments/Fan Liu/week-08/data.dta", replace

//3
program define regress_Y_X, rclass
syntax, samplesize(integer) 
clear
use "/Users/liufan/Desktop/ppol768-spring23/Individual Assignments/Fan Liu/week-08/data.dta"
sample `samplesize', count
gen Y = X + rnormal()
reg Y X
mat a = r(table)
return scalar Beta = a[1,1]
return scalar SEM = a[2,1]
return scalar Pval = a[4,1]
return scalar CI_left = a[5,1]
return scalar CI_right = a[6,1]
end

//4
clear
tempfile combined
save `combined', replace emptyok
forvalues i=1/4 {
	local samplesize= 10^`i'
	tempfile sims
	simulate beta = r(Beta) pval=r(Pval) SEM = r(SEM) CI_L = r(CI_left) CI_R = r(CI_right) ///
	, reps(500) seed(1234) saving(`sims') ///
	: regress_Y_X, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
}

//5
gr hbox beta, o(samplesize)
tabstat beta CI_L CI_R SEM, by(samplesize)
