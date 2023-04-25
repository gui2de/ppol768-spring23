cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-10"

* Part 2
clear

tempfile part2_result1
save `part2_result1', emptyok replace

* DGP

set seed 20230326

cap program drop dgp1
program define dgp1, rclass
	syntax, samplesize(integer)
	
	clear

	* State level
	set obs 11  // one multi-sector CAT state and 10 RGGI states
	gen state = _n
	gen ui = rnormal(30, 6)

	*treatment
	gen mul_cat = round(runiform(0, 1), 1)

	* Sector level
	expand 9 // 9 main sectors
	bysort state: gen sector = _n
	gen uij = rnormal(20, 5)

	* Facility level
	expand `samplesize' // Different number of facility in each state and sector strata
	bysort state sector: gen facility = _n
	gen uijk = rnormal(15, 2)

	* covariate
	gen production = rnormal(25, 5) 

	* generate emission data
	gen emission = 50 ///
		+ 20*mul_cat ///
		+ 30*production ///
		+ ui + uij + uijk

	reg emission mul_cat production
	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar beta = results[1, 1] // extract values from the matrix
	return scalar ll = results[5, 1]
	return scalar ul = results[6, 1]
end

tempfile simulation
foreach size in 20 40 60 80 100 {
	simulate n = r(n) beta = r(beta) ll = r(ll) ul = r(ul), ///
		reps(100) saving(`simulation', replace): ///
		dgp1, samplesize(`size')
	append using `part2_result1'
	save `part2_result1', replace
}

*save "part2_result_simulation.dta", replace

* calculate exact CI
collapse (mean) mean = beta (sd) sd = beta, by(n)
gen ll = mean-1.96*sd
gen ul = mean+1.96*sd
gen exact = 1

append using `part2_result1'
save `part2_result1', replace

* plot analytical CI against exact CI
sort n exact
bysort n: gen repeat = _n

foreach s in 1980 5940 7920 9900 {
	graph twoway rcap ul ll repeat if n == `s' ///
	|| rcap ul ll repeat if n == `s' & exact == 1, ///
	ytitle("95% condifence interval") ///
	xtitle("Simulation repeat") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("Sample size = `s'")
	
	graph export "outputs/part2_ci1_`s'.png", replace
}

********************************************************************************
* Another round of DGP

clear

tempfile part2_result2
save `part2_result2', emptyok replace

cap program drop dgp2
program define dgp2, rclass
	syntax, samplesize(integer)
	
	clear

	* State level
	set obs 11  // one multi-sector CAT state and 10 RGGI states
	gen state = _n
	gen ui = rnormal(30, 6)

	*treatment
	gen mul_cat = round(runiform(0, 1), 1)

	* Sector level
	expand 9 // 9 main sectors
	bysort state: gen sector = _n
	gen uij = rnormal(20, 5)

	* Facility level
	expand `samplesize' // Different number of facility in each state and sector strata
	bysort state sector: gen facility = _n

	* covariate
	gen production = rnormal(25, 5) 

	* generate emission data
	gen emission = 50 ///
		+ 20*mul_cat ///
		+ 30*production ///
		+ ui + uij

	reg emission mul_cat production, vce(cluster state sector)
	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar beta = results[1, 1] // extract values from the matrix
	return scalar ll = results[5, 1]
	return scalar ul = results[6, 1]
end

tempfile simulation
foreach size in 20 40 60 80 100 {
	simulate n = r(n) beta = r(beta) ll = r(ll) ul = r(ul), ///
		reps(100) saving(`simulation', replace): ///
		dgp2, samplesize(`size')
	append using `part2_result2'
	save `part2_result2', replace
}

*save "part2_result_simulation.dta", replace

* calculate exact CI
collapse (mean) mean = beta (sd) sd = beta, by(n)
gen ll = mean-1.96*sd
gen ul = mean+1.96*sd
gen exact = 1

append using `part2_result2'
save `part2_result2', replace

* plot analytical CI against exact CI
sort n exact
bysort n: gen repeat = _n

foreach s in 1980 5940 7920 9900 {
	graph twoway rcap ul ll repeat if n == `s' ///
	|| rcap ul ll repeat if n == `s' & exact == 1, ///
	ytitle("95% condifence interval") ///
	xtitle("Simulation repeat") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("Sample size = `s'")
	
	graph export "outputs/part2_ci2_`s'.png", replace
}
