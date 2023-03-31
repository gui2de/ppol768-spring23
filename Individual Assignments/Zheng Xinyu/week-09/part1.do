cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-09"

* Part 1
clear

tempfile part1_result
save `part1_result', emptyok replace

* DGP

tempfile part1_dgp

set seed 20230326

* State level
set obs 11  // one multi-sector CAT state and 10 RGGI states
gen state = _n

* confounder: affects both the outcome and the likelihood of receiving treatment
gen liberal = round(runiform(0, 1), 1) //high public acceptance of transition to low-carbon economy

* covariates: affects the treatment but not the outcome
gen economy_complexity = round((runiform(0, 1)), 1) // high economic complexity or not

* treatment
gen mul_cat = 0 // 10 RGGI states, single-sector CAT
replace mul_cat = 1 if liberal == 1 & economy_complexity == 1 // multi-sector CAT

* Sector level
expand 9 // 9 main sectors
bysort state: gen sector = _n

* Facility level
expand 400 + int((500-400)*runiform()) // Different number of facility in each state and sector strata
bysort state sector: gen facility = _n

* covariates: affects the outcome but not the treatment
gen production = rnormal(500, 100) // the randomlized production scale

* generate emission data
gen emission = 50 ///
	- 30*mul_cat ///
	- 10*liberal ///
	+ 40*production ///
	+ rnormal()

save "part1_result.dta", replace
	
cap program drop regression
program define regression, rclass
	syntax, samplesize(integer) r(integer)
	use "part1_result.dta", clear
	sample `samplesize', count by(state sector)
	if `r' == 1 {
		reg emission mul_cat liberal production // base model (1): true relationship
	}
	else if `r' == 2 {
		reg emission mul_cat liberal production economy_complexity // add economy_complexity to model (1)
	} 
	else if `r' == 3 {
		reg emission mul_cat liberal // omit production from model (1) 
	}
	else if `r' == 4 {
		reg emission mul_cat production // omit liberal from model (1)
	}
	else {
		reg emission mul_cat // omit production and liberal from model (1)
	}
	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar beta = results[1, 1] // extract values from the matrix
	return scalar se = results[2, 1]
end

* simulate

forvalues r = 1/5 {
	tempfile simulation
	foreach size in 100 200 300 400 {
		simulate n = r(n) beta = r(beta) se = r(se), ///
			reps(100) saving(`simulation', replace): ///
			regression, samplesize(`size') r(`r')
	    gen regression = `r'
	    append using `part1_result'
	    save `part1_result', replace
	}
}

*save "part1_result_simulation.dta", replace

use "part1_result_simulation.dta", clear

* plot histogram of betas

forvalues r = 1/5 {
	sum beta if regression == `r'
	hist beta if regression == `r', ///
		by(n, title("Distribution of coefficient estimates by sample sizes") note("")) ///
		fcolor(none) lcolor(black) ///
		xline(-30, lcolor(red)) xline(`r(mean)', lcolor(blue)) ///
		xtitle("coefficient estimates of treatment")
		
	graph export "outputs/part1_hist_`r'.png", replace
}

* export the summary table of betas and their ses

bysort regression n: outreg2 using outputs/summary1.doc, replace sum(log) keep(beta se) eqkeep(N mean)

