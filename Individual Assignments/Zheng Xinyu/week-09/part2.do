cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-09"

* Part 2
clear

tempfile part2_result
save `part2_result', emptyok replace

* DGP

tempfile part2_dgp

set seed 20230326

* State level
set obs 11  // one multi-sector CAT state and 10 RGGI states
gen state = _n

*treatment
gen mul_cat = round(runiform(0, 1), 1)

* Sector level
expand 9 // 9 main sectors
bysort state: gen sector = _n

* Facility level
expand 400 + int((500-400)*runiform()) // Different number of facility in each state and sector strata
bysort state sector: gen facility = _n

* channel: determine Y in the true DGP, not the treatment variable itself
gen production = 200*mul_cat + rnormal(500, 100) 

* generate emission data
gen emission = 50 ///
	+ 40*production ///
	+ rnormal()
	
* collider: a function of both Y and the treatment variable.
gen public_grievance = 30*emission - 15*mul_cat + rnormal()

*save "part2_result.dta", replace

* Regression

cap program drop regression
program define regression, rclass
	syntax, samplesize(integer) r(integer)
	use "part2_result.dta", clear
	sample `samplesize', count by(state sector)
	if `r' == 1 {
		reg emission production // base model (1): true relationship
	}
	else if `r' == 2 {
		reg emission mul_cat // include treatment but omit production 
	} 
	else if `r' == 3 {
		reg emission mul_cat production // add mul_cat (the treatment) to model (1) 
	}
	else if `r' == 4 {
		reg emission mul_cat public_grievance // include both treatment and collider
	}
	else {
		reg emission mul_cat production public_grievance // include both channel and collider 
	}
	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar beta = results[1, 1] // extract values from the matrix
	return scalar se = results[2, 1]
end

forvalues r = 1/5 {
	tempfile simulation_`r'
	foreach size in 100 200 300 400 {
		simulate n = r(n) beta = r(beta) se = r(se), ///
			reps(100) saving(`simulation_`r'', replace): ///
			regression, samplesize(`size') r(`r')
	    gen regression = `r'
	    append using `part2_result'
	    save `part2_result', replace
	}
}

save "part2_result_simulation.dta", replace

forvalues r = 1/5 {
	hist beta if regression == `r', ///
		by(n, title("Distribution of coefficient estimates by sample sizes") note("")) ///
		fcolor(none) lcolor(black) ///
		xtitle("coefficient estimates of treatment")
		
	graph export "outputs/part2_hist_`r'.png", replace
}

bysort regression n: outreg2 using outputs/summary2.doc, replace sum(log) keep(beta se) eqkeep(N mean)

