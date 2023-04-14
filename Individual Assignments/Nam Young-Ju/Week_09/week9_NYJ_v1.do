* Part 1-(1~2): Develop some data generating process for data X's and for outcome Y

set seed 1234 
clear
set obs 8 
gen district = _n

* Part 1-(3): Make cov_xy(Confounder), cov_X, cov_y, treatment, and y

expand 100

	* Generate cov_xy: Business size
	gen bsize = rnormal()
	* Generate cov_x: Turist influx
	gen tourist_influx = rnormal()
	* Generate cov_y: Export 
	gen export = rnormal()
	* Generate treatment
	gen treat = (bsize + tourist_influx + district/4 + rnormal()) > 0.6
	* Generate Y: Sales
	gen sales = (1.2)*bsize + export - district/20 + 1.5*treat + rnormal()

save part1_model, replace 


* Part 1-(4): Run the 5 different regression with different sample sizes!!!

* 1st regression: reg sales treat 
capture program drop normal_reg_1 
program define normal_reg_1, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\part1_model.dta"
	sample `samplesize', count
	
	reg sales treat
	
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

* 2nd regression: reg sales treat bsize

capture program drop normal_reg_2
program define normal_reg_2, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\part1_model.dta"
	sample `samplesize', count
	
	reg sales treat bsize
	
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

* 3rd regression: reg sales treat bsize i.district

capture program drop normal_reg_3
program define normal_reg_3, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\part1_model.dta"
	sample `samplesize', count
	
	reg sales treat bsize i.district
	
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

* 4th regression: reg sales treat tourist_influx export  

capture program drop normal_reg_4
program define normal_reg_4, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\part1_model.dta"
	sample `samplesize', count
	
	reg sales treat tourist_influx export 
	
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

* 5th regression: reg sales treat bsize i.district tourist_influx export  

capture program drop normal_reg_5
program define normal_reg_5, rclass 
	syntax, samplesize(integer)
	clear
	use "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\part1_model.dta"
	sample `samplesize', count
	
	reg sales treat bsize i.district tourist_influx export  
	
    matrix results = r(table)
	matrix list results
	
	return scalar N = e(N)
	return scalar beta = results[1,1]
	return scalar sem = results[2,1]
	return scalar pvalue = results[4,1]
	return scalar ci_l = results[5,1]
	return scalar ci_u = results[6,1]
 
end

* Part 1-(4): Simulate program by running 500 times with different N

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
    forvalues j=1/5{
	local ss = 10^`i'
	tempfile sims
	simulate N=r(N) beta_coef=r(beta) sem=r(sem) pvalues=r(pvalue) ci_l=r(ci_l) ci_u=r(ci_u), 	reps(500) seed(2023) saving(`sims'): normal_reg_`j', samplesize(`ss')

	use `sims', clear
	append using `combined'
	save `combined',replace
	}
}

table `ss' `sims', stat(variance beta)
table `ss' `sims', stat(mean beta)

* Visualize

use `combined', clear

histogram beta, by(N)
