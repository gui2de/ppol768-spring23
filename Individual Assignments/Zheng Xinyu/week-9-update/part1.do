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
	+ rnormal(2000, 200)

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
	levelsof n, local(size)
	foreach s in `size'{
		sum beta if regression == `r' & n == `s'
		local beta_mean = int(`r(mean)')
		local beta_high_2sd = int(`r(mean)'+2*`r(sd)')
		local beta_low_2sd = int(`r(mean)'-2*`r(sd)')
		hist beta if regression == `r' & n == `s', ///
			fcolor(none) lcolor(black) bstyle(outline) ///
			xline(-30, lcolor(red)) xline(`r(mean)', lcolor(blue)) ///
			xlab(`beta_low_2sd' "`beta_low_2sd'" `r(mean)' "`beta_mean'" -30 "-30" `beta_high_2sd' "`beta_high_2sd'") ///
			xtitle("coefficient estimates of treatment") ///
			title("n = `s'") ///
			ytitle(, margin(1)) ///
			saving("dis_`r'_`s'", replace)
	}
}

* reg 1
graph combine "dis_1_9900" "dis_1_19800" "dis_1_29700" "dis_1_39600", ///
	note("Red and blue lines label the true beta in the DGP and the mean of estimated betas in regressions, respectively.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment, liberal, and production", size(2))
graph export "outputs/part1_hist_1.png", replace

*reg 2
graph combine "dis_2_9900" "dis_2_19800" "dis_2_29700" "dis_2_39600", ///
	note("Red and blue lines label the true beta in the DGP and the mean of estimated betas in regressions, respectively.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment, liberal, production, and economy complexity", size(2))
graph export "outputs/part1_hist_2.png", replace

* reg 3
graph combine "dis_3_9900" "dis_3_19800" "dis_3_29700" "dis_3_39600", ///
	note("Red and blue lines label the true beta in the DGP and the mean of estimated betas in regressions, respectively.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment and liberal", size(2))
graph export "outputs/part1_hist_3.png", replace

* reg 4
graph combine "dis_4_9900" "dis_4_19800" "dis_4_29700" "dis_4_39600", ///
	note("Red and blue lines label the true beta in the DGP and the mean of estimated betas in regressions, respectively.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment and production", size(2))
graph export "outputs/part1_hist_4.png", replace

* reg 5
graph combine "dis_5_9900" "dis_5_19800" "dis_5_29700" "dis_5_39600", ///
	note("Red and blue lines label the true beta in the DGP and the mean of estimated betas in regressions, respectively.", size(2)) ///
	title("The distribution of betas by sample size", size(3)) ///
	subtitle("in regression of emission on treatment", size(2))
graph export "outputs/part1_hist_5.png", replace

* export the summary table of betas and their ses

bysort regression n: outreg2 using outputs/summary1.doc, replace sum(log) keep(beta se) eqkeep(N mean)

