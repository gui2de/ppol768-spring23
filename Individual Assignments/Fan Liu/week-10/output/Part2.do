capture program drop CI
program define CI, rclass
syntax, samplesize(integer)
clear
set obs `samplesize'
set seed 1234
gen school = _n
generate urban = runiform()<0.50 
expand 10 
bysort school: generate cluster_id = _n 
generate u_i = rnormal(0,2)
expand 16+int((25-16+1)*runiform()) 
generate u_ij = rnormal(0,3)
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
reg score1 treat urban, vce(cluster cluster_id)
mat a = r(table)
return scalar CI_vce1 = a[6,1] - a[5,1]
reg score2 treat urban
mat a = r(table)
return scalar Beta_DGP2 = a[1,1]
return scalar CI_DGP2 = a[6,1] - a[5,1]
bootstrap, reps(1000) seed(1234): reg score2 treat urban i.cluster_id
mat a = r(table)
return scalar CI_exact2 = a[6,1] - a[5,1]
reg score2 treat urban, vce(cluster cluster_id)
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

