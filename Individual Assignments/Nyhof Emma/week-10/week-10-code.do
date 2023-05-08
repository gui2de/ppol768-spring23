cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-10\"

********************************* PART 1 **************************************

* FINDING SAMPLE SIZE NEEDED FOR 80% POWER *
clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(1,3) // state effects
gen unemp = rnormal(0.032,0.0085)
bysort state: gen temprand_state = rnormal(0.5,0.1)
expand int(runiform(10000,100000))
gen u_ij = rnormal(1,2) // person effects
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<unemp // affects treatment but not outcome
gen hoursworked = rnormal(25,5) if unemployed != 0 // confounder
keep if hoursworked < 20 | unemployed == 1
egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand<0.5
gen age = runiform(18,64) // affects outcome but not treatment

gen wkly_inc = rnormal(800,250) ///
			+ (100 * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij

save "week-10-part1.dta", replace

capture program drop week10part1 
program define week10part1, rclass
    syntax, samplesize(integer)
	clear
	use "week-10-part1.dta"
	sample `samplesize', count
	
	return scalar N = `samplesize' 
	
	reg wkly_inc treatment i.state hoursworked age
		mat results = r(table)
		return scalar beta = results[1,1]
		return scalar SEM = results[2,1]
		return scalar pval = results[4,1]
	
end

local samples 225 250 255 275

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(100) seed(89743) saving(`sims`x''): week10part1, samplesize(`x') 
	save `sims`x'', replace
}

local samples 250 255 275
use `sims225'

foreach x in `samples' {
    append using `sims`x''
}
gen sig = 0
replace sig = 1 if pval < 0.05
sum sig

mean sig, over(N) // minimum sample size to get 80% power is 255

* ALLOW TREATMENT SIZE TO VARY, FIND MINIMUM DETECTABLE EFFECT SIZE

clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(1,3) // state effects
gen unemp = rnormal(0.032,0.0085)
bysort state: gen temprand_state = rnormal(0.5,0.1)
expand int(runiform(10000,100000))
gen u_ij = rnormal(1,2) // person effects
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<unemp // affects treatment but not outcome
gen hoursworked = rnormal(25,5) if unemployed != 0 // confounder
keep if hoursworked < 20 | unemployed == 1
egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand<0.5
gen age = runiform(18,64) // affects outcome but not treatment


save "week-10-part1_2.dta", replace

capture program drop week10part1_2 
program define week10part1_2, rclass
    syntax, treatment_effect(integer)
	*syntax, treatment_effect(integer)
	clear
	use "week-10-part1_2.dta"
	
	gen wkly_inc = rnormal(800,250) ///
			+ (`treatment_effect' * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij
	
	sample 255, count
	
	return scalar N = 255
	gen treatment_effect = `treatment_effect'
	reg wkly_inc treatment i.state hoursworked age 
		mat results1 = r(table)
		return scalar beta1 = results1[1,1]
		return scalar SEM1 = results1[2,1]
		return scalar pval1 = results1[4,1]
		
	reg wkly_inc treatment 
		mat results2 = r(table)
		return scalar beta2 = results2[1,1]
		return scalar SEM2 = results2[2,1]
		return scalar pval2 = results2[4,1]
	
end


local te 90 91 92 93 94 95

foreach x in `te' {
	tempfile sims`x'
	simulate N = r(N) beta1 = r(beta1) SEM1 = r(SEM1) pval1 = r(pval1) beta2 = r(beta2) SEM2 = r(SEM2) pval2 = r(pval2) treatment_effect = treatment_effect, reps(100) seed(89743) saving(`sims`x''): week10part1_2, treatment_effect(`x') 
	save `sims`x'', replace
}

local te 91 92 93 94 95
use `sims90'

foreach x in `te' {
    append using `sims`x''
}
gen sig1 = 0
replace sig1 = 1 if pval1 < 0.05
sum sig1

mean sig1, over(treatment_effect) // minimum detectable effect size for regression with controls is 93

gen sig2 = 0
replace sig2 = 1 if pval2 < 0.05
sum sig2

mean sig2, over(treatment_effect)  // minimum detectable effect size for regression without controls is 91


********************************* PART 2 **************************************

* ALLOW TREATMENT SIZE TO VARY, FIND MINIMUM DETECTABLE EFFECT SIZE

* 1. DGP where some portion of the random error term is at the strata level
clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(3,5) // state effects - making bigger
* gen unemp = rnormal(0.032,0.0085) // no longer calculating unemployment rate at state level, only keeping random effects
*bysort state: gen temprand_state = rnormal(0.5,0.1) // excluding portion where state level might contribute to main effect
expand int(runiform(10000,100000))
gen u_ij = rnormal(1,2) // person effects - excluding person effects, random error ony comes from state (strata) level
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<0.032 // affects treatment but not outcome
gen hoursworked = rnormal(25,5) if unemployed != 0 // confounder
keep if hoursworked < 20 | unemployed == 1
*egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand_person<0.5
gen age = runiform(18,64) //

gen wkly_inc = rnormal(800,250) ///
			+ (100 * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij

save "week-10-part2_1.dta", replace

capture program drop week10part2_1 
program define week10part2_1, rclass
    syntax, samplesize(integer)
	clear
	use "week-10-part2_1.dta"
	sample `samplesize', count
	
	return scalar N = `samplesize' 
	
	reg wkly_inc treatment i.state hoursworked age
		mat results = r(table)
		return scalar beta = results[1,1]
		return scalar SEM = results[2,1]
		return scalar pval = results[4,1]
		return scalar ll = results[5,1]
		return scalar ul = results[6,1] 
	
	
end

local samples 500 1000 5000 10000

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval) ll = r(ll) ul = r(ul), reps(100) seed(89743) saving(`sims`x''): week10part2_1, samplesize(`x') 
	save `sims`x'', replace
}

local samples 1000 5000 10000
use `sims500'

foreach x in `samples' {
    append using `sims`x''
}

mean beta, over(N)



* 5. DGP where random error terms are ONLY determined at the cluster level

clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(3,5) // state effects - making bigger
* gen unemp = rnormal(0.032,0.0085) // no longer calculating unemployment rate at state level, only keeping random effects
*bysort state: gen temprand_state = rnormal(0.5,0.1)
expand int(runiform(10000,100000))
* gen u_ij = rnormal(1,2) // person effects - excluding person effects, random error ony comes from state (strata) level
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<0.032 // affects treatment but not outcome
gen hoursworked = rnormal(25,5) if unemployed != 0 // confounder
keep if hoursworked < 20 | unemployed == 1
*egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand_person<0.5
gen age = runiform(18,64) //

