cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-10"

* Part 1
clear

tempfile part1_result
save `part1_result', emptyok replace

* DGP

set seed 20230326

cap program drop dgp
program define dgp, rclass
	clear

	syntax, samplesize(integer) r(integer)

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
	expand `samplesize' // Different number of facility in each state and sector strata
	bysort state sector: gen facility = _n

	* covariates: affects the outcome but not the treatment
	gen production = rnormal(40, 8) // the randomlized production scale

	* generate emission data
	gen emission = 50 ///
		- 30*mul_cat ///
		- 10*liberal ///
		+ 40*production ///
		+ rnormal(1000, 80)

	if `r' == 1 {
		reg emission mul_cat liberal production // base model (1): true relationship
	}
	else if `r' == 2 {
	    reg emission mul_cat liberal // omit covariate production
	}
	else if `r' == 3 {
	    reg emission mul_cat liberal production economy_complexity // add covariate economy_complexity
	}

	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar pval = results[4, 1]
end

* simulate
tempfile simulation
    foreach size in 2 3 4 5 6 7 8 9 10 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp, samplesize(`size') r(1)
		gen reg = 1
		append using `part1_result'
		save `part1_result', replace
	}
	
foreach size in 103 104 105 106 107 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp, samplesize(`size') r(2)
		gen reg = 2
		append using `part1_result'
		save `part1_result', replace
	}

foreach size in 10 11 12 13 14 15 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp, samplesize(`size') r(3)
		gen reg = 3
		append using `part1_result'
		save `part1_result', replace
	}


gen sig = 0
replace sig = 1 if pval < 0.05

bysort reg n: egen sig_pct = mean(sig) 

collapse (mean) sig_pct, by(reg n)
* Reg1: the overall sample size is 693 or the sample size is 7 in each strata
* Reg2: the overall sample size is 10296 or the sample size is 104 in each strata
* Reg3: the overall sample size is 1188 or the sample size is 12 in each strata

********************************************************************************
* back to DGP to find the minimum detectable effect size

clear

tempfile part1_result2
save `part1_result2', emptyok replace

cap program drop dgp2
program define dgp2, rclass
	clear

	syntax, samplesize(integer) r(integer) treatment(integer)

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
	expand `samplesize' // Different number of facility in each state and sector strata
	bysort state sector: gen facility = _n

	* covariates: affects the outcome but not the treatment
	gen production = rnormal(40, 8) // the randomlized production scale

	* generate emission data
	gen emission = 50 ///
		- `treatment'*mul_cat ///
		- 10*liberal ///
		+ 40*production ///
		+ rnormal(1000, 80)

	if `r' == 1 {
		reg emission mul_cat liberal production // base model (1): true relationship
	}
	else if `r' == 2 {
	    reg emission mul_cat liberal // omit covariate production
	}
	else if `r' == 3 {
	    reg emission mul_cat liberal production economy_complexity // add covariate economy_complexity
	}

	mat results = r(table) // save the results of regression results in the matrix
	return scalar pval = results[4, 1]
end

* simulate
tempfile simulation
    foreach treatment in 25 26 27 28 29 30 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp2, samplesize(7) r(1) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 1
		append using `part1_result2'
		save `part1_result2', replace
	}
	
* simulate
tempfile simulation
    foreach treatment in 28 29 30 31 32 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp2, samplesize(104) r(2) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 2
		append using `part1_result2'
		save `part1_result2', replace
	}	
	
* simulate
tempfile simulation
    foreach treatment in 28 29 30 31 32 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			dgp2, samplesize(12) r(3) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 3
		append using `part1_result2'
		save `part1_result2', replace
	}

gen sig = 0
replace sig = 1 if pval < 0.05

bysort reg treatment: egen sig_pct = mean(sig) 

collapse (mean) sig_pct, by(reg treatment)