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
	+ rnormal(2000, 200)
	
* collider: a function of both Y and the treatment variable.
gen public_grievance = 30*emission - 15*mul_cat + rnormal(10000, 5000)

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

*save "part2_result_simulation.dta", replace

forvalues r = 1/5 {
	levelsof n, local(size)
	foreach s in `size'{
		sum beta if regression == `r' & n == `s'
		local beta_mean = round(`r(mean)', 0.001)
		local beta_high_2sd = round(`r(mean)'+2*`r(sd)', 0.01)
		local beta_low_2sd = round(`r(mean)'-2*`r(sd)', 0.01)
		hist beta if regression == `r' & n == `s', ///
			fcolor(none) lcolor(black) bstyle(outline) ///
			xline(`r(mean)', lcolor(blue)) ///
			xlab(`beta_low_2sd' "`beta_low_2sd'" `r(mean)' "`beta_mean'" `beta_high_2sd' "`beta_high_2sd'") ///
			xtitle("coefficient estimates of treatment") ///
			title("n = `s'") ///
			ytitle(, margin(1)) ///
			saving("dis_`r'_`s'", replace)
	}
}

* reg 1
graph combine "dis_1_9900" "dis_1_19800" "dis_1_29700" "dis_1_39600", ///
	note("Blue line label the mean of estimated betas in regressions.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on production", size(2))
graph export "outputs/part2_hist_1.png", replace

*reg 2
graph combine "dis_2_9900" "dis_2_19800" "dis_2_29700" "dis_2_39600", ///
	note("Blue line label the mean of estimated betas in regressions.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment", size(2))
graph export "outputs/part2_hist_2.png", replace

* reg 3
graph combine "dis_3_9900" "dis_3_19800" "dis_3_29700" "dis_3_39600", ///
	note("Blue line label the mean of estimated betas in regressions.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment and production", size(2))
graph export "outputs/part2_hist_3.png", replace

* reg 4
graph combine "dis_4_9900" "dis_4_19800" "dis_4_29700" "dis_4_39600", ///
	note("Blue line label the mean of estimated betas in regressions.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment and public grievance", size(2))
graph export "outputs/part2_hist_4.png", replace

* reg 5
graph combine "dis_5_9900" "dis_5_19800" "dis_5_29700" "dis_5_39600", ///
	note("Blue line label the mean of estimated betas in regressions.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment, production, and public grievance", size(2))
graph export "outputs/part2_hist_5.png", replace

bysort regression n: outreg2 using outputs/summary2.doc, replace sum(log) keep(beta se) eqkeep(N mean)

