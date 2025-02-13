*Week 10 Assignment
*Daniel Fang

// Part 2: Calculating power for DGPs with clustered random errors

** DGP with varying samplesizes and fixed treatment effects 
capture program drop CI
program define CI, rclass
syntax, samplesize(integer)
clear


*** School level
set obs `samplesize'
gen school = _n

*** Set up confounding variables
generate urban = runiform() < 0.50

*** Set up covariates

// NUMBER OF CLASSROOMS
expand 10
bysort school: generate cluster_id = _n 
gen u_i = rnormal(0,2)

expand 16+int((25-16+1)*runiform()) 
generate u_ij = rnormal(0,3)

// treatment
gen treat = cond(school <= 1, 1, 0)
generate score1 = 70 + 5*treat + 3* urban + u_i + u_ij
generate score2 = 70 + 5*treat + 3* urban + u_i
reg score1 treat urban 
mat a = r(table)
return scalar Beta_DGP1 = a[1,1]
return scalar CI_DGP1 = a[6,1] - a[5,1]
bootstrap, reps(1000) seed(1234): reg score1 treat urban
mat a = r(table)
return scalar CI_exact1 = a[6,1] - a[5,1]
reg score1 treat urban, vce(robust)
mat a = r(table)
return scalar CI_vce1 = a[6,1] - a[5,1]
reg score2 treat urban
mat a = r(table)
return scalar Beta_DGP2 = a[1,1]
return scalar CI_DGP2 = a[6,1] - a[5,1]
bootstrap, reps(1000) seed(1234): reg score2 treat urban
mat a = r(table)
return scalar CI_exact2 = a[6,1] - a[5,1]
reg score2 treat urban, vce(robust)
mat a = r(table)
return scalar CI_vce2 = a[6,1] - a[5,1]
end


clear
tempfile combined3
save `combined3', replace emptyok
forvalues i=1/8 {
	local samplesize= 2^`i'
	tempfile sims
	simulate Beta1 = r(Beta_DGP1) CI_len_estimate1 = r(CI_DGP1) CI_len_exact1 = r(CI_exact1) CI_vce1 = r(CI_vce1) ///
	Beta2 = r(Beta_DGP2) CI_len_estimate2 = r(CI_DGP2) CI_len_exact2 = r(CI_exact2) CI_vce2 = r(CI_vce2) ///
	, reps(1) seed(1234) saving(`sims') ///
	: CI, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined3'
	save `combined3', replace
}

tabstat Beta1 CI_len_estimate1 CI_len_exact1 CI_vce1 Beta2 CI_len_estimate2 CI_len_exact2 CI_vce2, by(samplesize)

	   
* Results and evaluations

twoway (line CI_len_exact1 samplesize, color(red)) ///
       (line CI_len_estimate1 samplesize, color(blue)) ///
       (line CI_vce1 samplesize, color(green)) ///
       , ytitle("CI length") xtitle("Sample size") ///
       legend(order(1 "Exact CI Length" 2 "Estimate CI Length" 3 "Robust Ci length")) ///
       title("Line Graph of CI length")

twoway (line CI_len_exact2 samplesize, color(red)) ///
       (line CI_len_estimate2 samplesize, color(blue)) ///
       (line CI_vce2 samplesize, color(green)) ///
       , ytitle("CI length") xtitle("Sample size") ///
       legend(order(1 "Exact CI Length" 2 "Estimate CI Length" 3 "Robust Ci length")) ///
       title("Line Graph of CI length")