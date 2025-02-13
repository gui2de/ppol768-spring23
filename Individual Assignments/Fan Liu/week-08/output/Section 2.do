//1
program define regress_Y_X_2, rclass
syntax, samplesize(integer) 
clear
set obs `samplesize'
gen X = rnormal()
gen Y = X + rnormal()
reg Y X
mat a = r(table)
return scalar Beta = a[1,1]
return scalar SEM = a[2,1]
return scalar Pval = a[4,1]
return scalar CI_left = a[5,1]
return scalar CI_right = a[6,1]
end

//2
clear
tempfile combined2
save `combined2', replace emptyok
forvalues i=1/6 {
	local samplesize= 10^`i'
	tempfile sims
	simulate beta = r(Beta) pval=r(Pval) SEM = r(SEM) CI_L = r(CI_left) CI_R = r(CI_right) ///
	, reps(500) seed(1234) saving(`sims') ///
	: regress_Y_X_2, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined2'
	save `combined2', replace
}
save "/Users/liufan/Desktop/ppol768-spring23/Individual Assignments/Fan Liu/week-08/data2.dta", replace
clear
tempfile combined3
save `combined3', replace emptyok
forvalues i=1/20 {
	local samplesize= 2^`i'
	tempfile sims
	simulate beta = r(Beta) pval=r(Pval) SEM = r(SEM) CI_L = r(CI_left) CI_R = r(CI_right) ///
	, reps(500) seed(1234) saving(`sims') ///
	: regress_Y_X_2, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined3'
	save `combined3', replace
}
append using "/Users/liufan/Desktop/ppol768-spring23/Individual Assignments/Fan Liu/week-08/data2.dta"

//3
gr hbox beta, o(samplesize) 
tabstat beta CI_L CI_R SEM, by(samplesize)
