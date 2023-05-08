// Hannah Hill
// Week 10

******************************************************************************
* Part One                                                                   *
******************************************************************************
clear
set scheme s1color
tempfile q1_r1
save `q1_r1', emptyok replace
set seed 512023

capture program drop ccc
program define ccc, rclass
	syntax, samplesize(integer) 
	clear
	set obs `samplesize'
	gen college = _n
	gen u_i = rnormal(0,2)
	gen urban = runiform()<0.50
	expand 5 // 5 years of data for each college
	bysort college: generate year = 2000 + _n -1
	bysort college year: generate course = _n
	gen u_ij = rnormal(0,3)
	// generate % of remedial courses at each college
	bysort college year: generate remedial = .3+int((.85-.3+1)*runiform())
	*Creating a variable for years of teaching experience. 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	*Generate student-level dataset where each school-class will have 16-25 students.
	expand 16+int(10*runiform())
	*Create student IDs
	bysort college course: generate child = _n 
	*Create student-level effects
	generate e_ijk = rnormal(0,5)
	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	// generate treatment 
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)


// DGP
	bysort college year: generate transfer_rate = runiform() * 0.04 + 0.005 ///
			+ .05*treat ///
			+ (-2)*urban ///
			+ .3*diversity  ///
			+ 1.4*teach_exp ///
			+ .02*remedial ///
			+ 0.2*mother_educ ///
			+ u_i + u_ij + e_ijk
	format transfer_rate %4.2f

	if `r' == 1 {
		reg transfer_rate treat mother_educ
	}
	else if `r' == 2 {
	    reg transfer_rate treat mother_educ urban diversity
	}
	else if `r' == 3 {
	    reg transfer_rate treat mother_educ urban diversity remedial 
	}

	return scalar n = e(N)
	mat results = r(table)
	return scalar pval = results[4, 1]
end

* simulate
tempfile simulation
    foreach size in 2 3 4 5 6 7 8 9 10 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc, samplesize(`size') r(1)
		gen reg = 1
		append using `q1_r1'
		save `q1_r1', replace
	}
	
foreach size in 103 104 105 106 107 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc, samplesize(`size') r(2)
		gen reg = 2
		append using `q1_r1'
		save `q1_r1', replace
	}

foreach size in 10 11 12 13 14 15 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc, samplesize(`size') r(3)
		gen reg = 3
		append using `q1_r1'
		save `q1_r1', replace
	}


gen stat_sig = 0
replace stat_sig = 1 if pval < 0.05

bysort reg n: egen sig_pct = mean(stat_ig) 

collapse (mean) stat_sig_pct, by(reg n)

********************************************************************************

clear
tempfile q1_r2
save `q1_r2', emptyok replace

capture program drop ccc
program define ccc, rclass
	syntax, samplesize(integer) 
	clear
	set obs `samplesize'
	gen college = _n
	gen u_i = rnormal(0,2)
	gen urban = runiform()<0.50
	expand 5 // 5 years of data for each college
	bysort college: generate year = 2000 + _n -1
	bysort college year: generate course = _n
	gen u_ij = rnormal(0,3)
	// generate % of remedial courses at each college
	bysort college year: generate remedial = .3+int((.85-.3+1)*runiform())
	*Creating a variable for years of teaching experience. 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	*Generate student-level dataset where each school-class will have 16-25 students.
	expand 16+int(10*runiform())
	*Create student IDs
	bysort college course: generate child = _n 
	*Create student-level effects
	generate e_ijk = rnormal(0,5)
	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	// generate treatment 
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)


// DGP
	bysort college year: generate transfer_rate = runiform() * 0.04 + 0.005 ///
			+ .05*treat ///
			+ (-2)*urban ///
			+ .3*diversity  ///
			+ 1.4*teach_exp ///
			+ .02*remedial ///
			+ 0.2*mother_educ ///
			+ u_i + u_ij + e_ijk
	format transfer_rate %4.2f

	if `r' == 1 {
		reg transfer_rate treat mother_educ
	}
	else if `r' == 2 {
	    reg transfer_rate treat mother_educ urban diversity
	}
	else if `r' == 3 {
	    reg transfer_rate treat mother_educ urban diversity remedial 
	}

	return scalar n = e(N)
	mat results = r(table) // save the results of regression results in the matrix
	return scalar pval = results[4, 1]
end

// simulations
tempfile simulation
    foreach treatment in 25 26 27 28 29 30 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc2, samplesize(7) r(1) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 1
		append using `q1_r2'
		save `q1_r2', replace
	}
	
// simulations
tempfile simulation
    foreach treatment in 28 29 30 31 32 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc2, samplesize(104) r(2) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 2
		append using `q1_r2'
		save `q1_r2', replace
	}	
	
* simulate
tempfile simulation
    foreach treatment in 28 29 30 31 32 {
		simulate pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			ccc2, samplesize(12) r(3) treatment(`treatment')
		gen treatment = `treatment'
		gen reg = 3
		append using `q1_r2'
		save `q1_r2', replace
	}

gen stat_sig = 0
replace stat_sig = 1 if pval < 0.05
bysort reg treatment: egen stat_sig_pct = mean(stat_sig) 
collapse (mean) stat_sig_pct, by(reg treatment)


******************************************************************************
* Part Two                                                                   *
******************************************************************************
clear
set scheme s1color
tempfile p2_r1
save `p2_r1', emptyok replace
set seed 512023

capture program drop ccc
program define ccc, rclass
	syntax, samplesize(integer) 
	clear
	// set state level
	set obs 51 // 50 states plus DC
	gen state = _n
	gen u_i = rnormal(0,2)
	
	// treatment setup
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	
	// college level
	expand 5 // 5 imaginary colleges in each state
	bysort state: generate college = _n
	gen u_ij = rnormal(0,3)
	// generate treatment 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
	
	// student level
	expand `samplesize' // students per college 
	bysort state college: generate student = _n
	gen u_ijk = rnormal(0,5)

	// COVARIATES
	// generate % of remedial courses at each college
	bysort college: generate remedial = .3+int((.85-.3+1)*runiform())

	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	// main covariate
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())



// DGP
	generate success_rate = 100 * runiform() * 0.04 + 0.005 ///
			+ 2*treat ///
			+ .5*diversity  ///
			+ u_i + u_ij + u_ijk
	//format transfer_rate %4.2f

	reg success_rate treat diversity
	return scalar n = e(N)
	mat results = r(table)
	return scalar beta = results[1, 1]
	return scalar ll = results[5, 1]
	return scalar ul = results[6, 1]
end

tempfile simulation
foreach size in 20 40 60 80 100 {
	simulate n = r(n) beta = r(beta) ll = r(ll) ul = r(ul), ///
		reps(100) saving(`simulation', replace): ///
		ccc, samplesize(`size')
	append using `p2_r1'
	save `p2_r1', replace
}

save "p2_r1_sim.dta", replace

// exact ci
collapse (mean) mean = beta (sd) sd = beta, by(n)
gen ll = mean-1.96*sd
gen ul = mean+1.96*sd
gen exact = 1

append using `p2_r1'
save `p2_r1', replace

// compare analytical to exact
sort n exact
bysort n: gen repeat = _n

//5100 10200 15300 20400

foreach s in 5100 10200 15300 20400 {
	graph twoway rcap ul ll repeat if n == `s' ///
	|| rcap ul ll repeat if n == `s' & exact == 1, ///
	ytitle("95% Confidence Interval") ///
	xtitle("Simulations") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("Sample size = `s'")
	
	graph export "q2p1_ci_`s'.png", replace
}

// ITS WORKING NOW!!!!!!!!!!

********************************************************************************
clear
tempfile p2_r2
save `p2_r2', emptyok replace

set seed 512023
capture program drop ccc2
program define ccc2, rclass
	syntax, samplesize(integer) 
	clear
	// set state level
	set obs 51 // 50 states plus DC
	gen state = _n
	gen u_i = rnormal(0,2)
	
	// treatment setup
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	
	// college level
	expand 5 // 5 imaginary colleges in each state
	bysort state: generate college = _n
	gen u_ij = rnormal(0,3)
	// generate treatment 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
	
	// student level
	expand `samplesize' // students per college 
	bysort state college: generate student = _n
	gen u_ijk = rnormal(0,5)

	// COVARIATES
	// generate % of remedial courses at each college
	bysort college: generate remedial = .3+int((.85-.3+1)*runiform())

	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	// main covariate
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())



// DGP
	generate success_rate = 100 * runiform() * 0.04 + 0.005 ///
			+ 2*treat ///
			+ .5*diversity  ///
			+ u_i + u_ij + u_ijk
	//format transfer_rate %4.2f


	reg success_rate treat diversity, vce(cluster college)
	return scalar n = e(N)
	mat results = r(table) 
	return scalar beta = results[1, 1] 
	return scalar ll = results[5, 1]
	return scalar ul = results[6, 1]
end

tempfile simulation
foreach size in 20 40 60 80 100 {
	simulate n = r(n) beta = r(beta) ll = r(ll) ul = r(ul), ///
		reps(100) saving(`simulation', replace): ///
		ccc2, samplesize(`size')
	append using `p2_r2'
	save `p2_r2', replace
}

// exact CI
collapse (mean) mean = beta (sd) sd = beta, by(n)
gen ll = mean-1.96*sd
gen ul = mean+1.96*sd
gen exact = 1

append using `p2_r2'
save `p2_r2', replace

// compare analytical to exact
sort n exact
bysort n: gen repeat = _n

// 5100 10200 15300 20400
foreach s in 20400 {
	graph twoway rcap ul ll repeat if n == `s' ///
	|| rcap ul ll repeat if n == `s' & exact == 1, ///
	ytitle("95% Confidence Interval") ///
	xtitle("Simulations") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("n = `s'")
	
	graph export "q2p2_ci2_`s'.png", replace
}