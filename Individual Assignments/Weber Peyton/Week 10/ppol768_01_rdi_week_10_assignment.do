*PPOL 768-01: Research, Design, and Implementation
*Week 10 Assignment Do File
*Author: Peyton Weber
*Last edited: April 4, 2023, April 14, 2023 

cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 10"
*Reviewer to adjust working directory appropriately. 

********************************Part One:***************************************
*Step 1: Determine the required sample size for 80% power. 

clear 

set seed 04142023 // *Generate unique seed for replicability. 

set obs 50 // *Simulate data in Stata. 
 
gen state = _n // *Create a state variable using the 100 observations.

gen u_i = rnormal(1,3) // *Create state effects. 

gen unemploy = rnormal(0.032, 0.0085) // *Generate unemployment "noise." 

bysort state: gen temprand_state = rnormal(0.5, 0.1) // *Sort observations and create random variable. 

expand int(runiform(10000,100000))
 
gen u_ij = rnormal(1,2) // *Create individual person effects.

bysort state: gen person = _n

gen temprand_person = runiform()

gen unemployed = runiform()<unemploy // *Create variable that affects the treatment & not the outcome. 

gen hoursworked = rnormal(25,5) if unemployed != 0 // *Create the confounder. 

keep if hoursworked < 20 | unemployed == 1 

egen temprand = rowmean(temprand_state temprand_person) 

gen treatment = temprand<0.5 

gen age = runiform(18,64) // *Create age variable that affects the outcome, but not the treatment. 

gen weekly_income = rnormal(800,250) + (100 * treatment) + (8 * hoursworked) + (4.5 * age) + u_i + u_ij

save "week-10-part-one.dta", replace  

capture program drop ppol768 // drop program if already defined 

program define ppol768, rclass // define program and use rclass to create results matrix 

	syntax, samplesize(integer) // sample size is the program argument 
	
		clear
		
		use "week-10-part-one.dta" // loading in the simulated dataset
		
		sample `samplesize', count // setting varying observation levels
		
		return scalar N = `samplesize' 
		
		reg weekly_income treatment i.state hoursworked age // regress y on x (1st regression)
		
			mat results  = r(table) // create a matrix to recall the scalars 
			
			return scalar beta = results[1,1] // recall the beta coefficient 
			
			return scalar pval = results[4,1] // recall the p-value 
			
			return scalar SEM = results[2,1] // recall the standard errors 

end

local samples 225 250 255 275

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval), reps(100) seed(2713) saving(`sims`x''): ppol768, samplesize(`x') 
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

mean sig, over(N) // *The minimum sample size to get 80% power is 255.

clear

set seed 2222

set obs 50 // *Simulate data in Stata. 
 
gen state = _n // *Create a state variable using the 100 observations.

gen u_i = rnormal(1,3) // *Create state effects. 

gen unemploy = rnormal(0.032, 0.0085) // *Generate unemployment "noise." 

bysort state: gen temprand_state = rnormal(0.5, 0.1) // *Sort observations and create random variable. 

expand int(runiform(10000,100000))
 
gen u_ij = rnormal(1,2) // *Create individual person effects.

bysort state: gen person = _n

gen temprand_person = runiform()

gen unemployed = runiform()<unemploy // *Create variable that affects the treatment & not the outcome. 

gen hoursworked = rnormal(25,5) if unemployed != 0 // *Create the confounder. 

keep if hoursworked < 20 | unemployed == 1 

egen temprand = rowmean(temprand_state temprand_person) 

gen treatment = temprand<0.5 

gen age = runiform(18,64) // *Create age variable that affects the outcome, but not the treatment. 


save "week-10-part-two.dta", replace

capture program drop ppol768_2 

program define ppol768_2, rclass

    syntax, treatment_effect(integer)
	
	clear
	
	use "week-10-part-two.dta"

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
	simulate N = r(N) beta1 = r(beta1) SEM1 = r(SEM1) pval1 = r(pval1) beta2 = r(beta2) SEM2 = r(SEM2) pval2 = r(pval2) treatment_effect = treatment_effect, reps(100) seed(1693) saving(`sims`x''): ppol768_2, treatment_effect(`x') 
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

mean sig1, over(treatment_effect) // *The minimum detectable effect size for regression with controls is 93.

gen sig2 = 0
replace sig2 = 1 if pval2 < 0.05
sum sig2

mean sig2, over(treatment_effect) // *The minimum detectable effect size for regression without controls is 91. 

clear

set seed 0418202

set obs 50

gen state = _n

gen u_i = rnormal(3,5) // *Create larger state effects 

expand int(runiform(10000,100000))

gen u_ij = rnormal(1,2)

bysort state: gen person = _n

gen temprand_person = runiform()

gen unemployed = runiform()<0.032 // *Create var that affects treatment but not the outcome. 

gen hoursworked = rnormal(25,5) if unemployed != 0 // *Create the confounder. 

keep if hoursworked < 20 | unemployed == 1

gen treatment = temprand_person<0.5

gen age = runiform(18,64)

gen wkly_inc = rnormal(800,250) ///
			+ (100 * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij

save "week-10-part-three.dta", replace

capture program drop ppol768_3
program define ppol768_3, rclass
    syntax, samplesize(integer)
	clear
	use "week-10-part-three.dta"
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
	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval) ll = r(ll) ul = r(ul), reps(100) seed(89770) saving(`sims`x''): ppol768_3, samplesize(`x') 
	save `sims`x'', replace
}

local samples 1000 5000 10000
use `sims500'

foreach x in `samples' {
    append using `sims`x''
}

mean beta, over(N)// *The standard errors became increasingly smaller as the sample size grew! 

