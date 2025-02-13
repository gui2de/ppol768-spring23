*PPOL 768-01: Research, Design, and Implementation
*Week 10 Assignment Do File
*Author: Peyton Weber
*Last edited: April 4, 2023, April 14, 2023,  April 30, 2023

*PLEASE NOTE: Coding below was heavily relied upon the code previously submitted by my peers!  

cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 10"
*Reviewer to adjust working directory appropriately. 

********************************Part One:***************************************
clear 

set obs 51 // *Simulate data in Stata. 
 
gen state = _n // *Create a state variable using the observations.

gen polparty = 1 // *Create political party variable, where 1 is for Dems and 0 is for Repubs

replace polparty = 0 if state > 25

*gen u_i = rnormal(1,3) // *Create state effects. 
*gen unemploy = rnormal(0.032, 0.0085) // *Generate unemployment "noise." 
*bysort state: gen temprand_state = rnormal(0.5, 0.1) // *Sort observations and create random variable. 

expand 30+int(50-30+1)*runiform() // *Each state will have 30-50 factories. 
 
*gen u_ij = rnormal(1,2) // *Create individual person effects.
*bysort state: gen person = _n
*gen temprand_person = runiform()
*gen unemployed = runiform()<unemploy // *Create variable that affects the treatment & not the outcome. 
*gen hoursworked = rnormal(25,5) if unemployed != 0 // *Create the confounder. 
*keep if hoursworked < 20 | unemployed == 1 
*egen temprand = rowmean(temprand_state temprand_person) 
*gen treatment = temprand<0.5 
*gen age = runiform(18,64) // *Create age variable that affects the outcome, but not the treatment. 
*gen weekly_income = rnormal(800,250) + (100 * treatment) + (8 * hoursworked) + (4.5 * age) + u_i + u_ij

local N = _N
	
local N_2 = `N'/2

bysort state: gen factory = _n // *Generate factory level ID

gen industry = int(1 + 10 * uniform()) // *The factory industry with the larger number will be more likely to generate GHGs. 

gen activity = rnormal(100,8) // *The average number of GHG activities per factory in the past decade

gen rand = polparty + 10*industry + rnormal() // *The treatment liklihood depends on the state. 

egen rank = rank(rand)

sort rank

gen treatment = rank > `N_2'

gen emission = 500 - 50*treatment + 10*state - 40*polparty  + 50*activity + rnormal(100, 10) // Generate outcome variable of interest

save "week-10-part-one.dta", replace  

global data_1 "week-10-part-one.dta"

capture program drop ppol768rdi1 // *Tell Stata to drop program if it is already defined 

*Create a program that includes a regression that creates the unbiased, "true" model: 

program define ppol768rdi1, rclass // define program and use rclass to create results matrix 

	syntax, samplesize(integer) // sample size is the program argument 
	
		clear
		
		use "$data_1", clear  // loading in the simulated dataset
		
		sample `samplesize', count // setting varying observation levels
		
		reg emission treatment i.polparty industry activity // regress y on x with proper covariates (1st regression)
		
			mat a  = r(table) // create a matrix to recall the scalars 
			
			*return scalar beta = a[1,1] // recall the beta coefficient 
			
			return scalar pval = a[4,1] // recall the p-value 
			
			*return scalar SEM = a[2,1] // recall the standard errors 
			
			return scalar n = e(N) // recall the sample size

end

capture program drop ppol768rdi2

*Create a program that includes a regression that creates a biased model, subject to OMV bias: 

program define ppol768rdi2, rclass // define program and use rclass to create results matrix 

	syntax, samplesize(integer) // sample size is the program argument 
	
		clear
		
		use "$data_1", clear  // loading in the simulated dataset
		
		sample `samplesize', count // setting varying observation levels
		
		reg emission treatment // regress y on x (2nd regression)
		
			mat a  = r(table) // create a matrix to recall the scalars  
			
			return scalar pval = a[4,1] // recall the p-value 
			
			return scalar n = e(N) // recall the sample size 

end
*local samples 225 250 255 275

clear

tempfile combined

save `combined', replace emptyok 

foreach i in 100 234 235 1957 1958{
	forvalues j=1(1)2{
	tempfile sims
	simulate p=r(pval), reps(300) seed(1234) saving(`sims'): ppol768rdi`j', samplesize(`i') 
	gen samplesize=`i' 
	gen model=`j' 
	append using `combined'
	save `combined', replace	
	}
} 

*local samples 250 255 275
*use `sims225'

*foreach x in `samples' {
    *append using `sims`x''
*}

gen sig = 0 // *Generate variable if the result is stat significant at 5% level 
replace sig = 1 if p<=0.05 // *Generate variable if the result is stat significant at 5% level
bysort model samplesize: egen sig_pob = mean(sig)  
collapse (mean) sig_pob, by(model samplesize)
table samplesize model, stat(mean sig) 

sum sig
mean sig, over(samplesize) // *The minimum sample size to get 80% power is 235?

********************ALLOWING TREATMENT SIZE TO VARY***************************** 

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

	gen weekly_inc = rnormal(800,250) ///
			+ (`treatment_effect' * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij

	sample 255, count

	return scalar N = 255
	gen treatment_effect = `treatment_effect'
	reg weekly_inc treatment i.state hoursworked age 
		mat results1 = r(table)
		return scalar beta1 = results1[1,1]
		return scalar SEM1 = results1[2,1]
		return scalar pval1 = results1[4,1]

	reg weekly_inc treatment 
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
replace sig1 = 1 if pval1 <= 0.05
sum sig1

mean sig1, over(treatment_effect) // *The minimum detectable effect size for regression with controls is 92.

gen sig2 = 0
replace sig2 = 1 if pval2 <= 0.05
sum sig2

mean sig2, over(treatment_effect) // *The minimum detectable effect size for regression without controls is 92. 

********************************Part Two:***************************************
clear
*set seed 0418202
set obs 51

gen state = _n

gen u_i = rnormal(60,4) // *Create larger state effects 

gen rand = runiform(1,10)

xtile cluster = rand, nq(10) 

gen uc_i = rnormal(5,1)

expand 30+int(50-30+1)*runiform() // *Ensuring each state has approximately 30-50 factories. 

gen factory = _n

gen ucf_i = rnormal(50,3) 

gen activity = rnormal(100,5)

gen treatment = cluster > 5 

gen emission = 1000 /// 
	+ (-100)*treatment ///    
	+ 80*activity ///  
	+ u_i + uc_i + ucf_i

gen emission1 = 1-00 /// 
	+ (-100)*treatment ///    
	+ 80*activity ///    
	+ uc_i + ucf_i ///

*bysort state: gen person = _n
*gen temprand_person = runiform()
*gen unemployed = runiform()<0.032 // *Create var that affects treatment but not the outcome. 
*gen hoursworked = rnormal(25,5) if unemployed != 0 // *Create the confounder. 
*keep if hoursworked < 20 | unemployed == 1
*gen treatment = temprand_person<0.5
*gen age = runiform(18,64)

*gen weekly_inc = rnormal(800,250) ///
			*+ (100 * treatment) ///
			*+ (8 * hoursworked) /// 
			*+ (4.5 * age) ///
			*+ u_i + u_ij

save "week-10-part-three.dta", replace 

capture program drop ppol768_parttwo1
program define ppol768_parttwo1, rclass
    syntax, samplesize(integer)
	use "week-10-part-three.dta", clear
	sample `samplesize', count

	*return scalar N = `samplesize' 

	reg emission treatment activity
		mat a = r(table)
		return scalar beta = a[1,1]
		*return scalar SEM = results[2,1]
		*return scalar pval = results[4,1]
		return scalar c_lower = a[5,1]
		return scalar c_upper = a[6,1] 


end

capture program drop ppol768_parttwo2
program define ppol768_parttwo2, rclass
	syntax, samplesize(integer)
	use "week-10-part-three.dta", clear
	sample `samplesize', count
	reg emission1 treatment activity 
	mat a = r(table)
		return scalar beta = a[1,1]
		return scalar c_lower = a[5,1]
		return scalar c_upper = a[6,1] 
		
end 

clear
tempfile combined
save `combined', replace emptyok

forvalues i=100(500)2000{
	forvalues j=1(1)2{
	tempfile sims
	simulate beta=r(beta) c_upper=r(c_upper) c_lower=r(c_lower), reps(300) seed(1234) saving(`sims') : ppol768_parttwo`j', samplesize(`i')
	use `sims' , clear 
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace
	}
}

gen ci_wide = c_upper - c_lower

table samplesize model, stat(mean beta) // Beta means 
table samplesize model, stat(mean ci_wide) //mean of ci width  

*local samples 500 1000 5000 10000

*foreach x in `samples'{
*	tempfile sims`x'
*	simulate N = r(N) beta = r(beta) SEM = r(SEM) pval = r(pval) ll = r(ll) ul = r(ul), reps(100) seed(89770) saving(`sims`x''): ppol768_3, samplesize(`x') 
*	save `sims`x'', replace
*}

*local samples 1000 5000 10000
*use `sims500'

*foreach x in `samples' {
*    append using `sims`x''
*}

*mean beta, over(N)// *The standard errors became increasingly smaller as the sample size grew! 

