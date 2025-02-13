/*Marlyn Bruno
Assignment 08

*****************************************************
Part 1: De-biasing a parameter estimate using controls 
******************************************************/

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

global wd "/Users/marlyn/GitHub/ppol768-spring23/Individual Assignments/Bruno Marlyn/week-10"

capture program drop week10 //Before defining program, drop it
program define week10, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program
	
	*Setting parameters
	clear
	set obs 50
	
	*DGP
		*Create STRATA and entity effects
		gen state = _n //setting a state ID
		gen state_effects = rnormal(0, 5) //State effects
		expand 1+int((`samplesize'-1+1) *runiform()) //generate individual-level dataset. Range of 1,000 to "infinite" individuals in each state with approved DACA cases
		sort state
		bysort state: generate individual = _n
		gen individual_effects = rnormal(0, 2) //individual effects

		*Create continuous variates
		gen conf_school = rnormal() //affects treatment and outcome
		gen corr_y_healthcare = rnormal() //affects only outcome
		gen corr_x_noenglish = rnormal() //affects only treatment

		*Generate treatment (DACA)
		gen daca = (state/10) ///make the probability that an individual unit receives treatment vary across strata groups
			+ conf_school ///confounder
			+ corr_x_noenglish ///variable affecting treatment but not outcome
			+ rnormal() > 0
			
		*Generate outcome Y (employment variable)
		gen salary = 13 + (0.25)*state ///make sure that the strata groups affect the outcome 
			+ conf_school ///counfounder
			+ corr_y_healthcare ///variable affecting outcome but not treatment
			+ (0.3)*daca ///true treatment effect is 2
			+ state_effects + individual_effects ///entity effects
			+ 0.5*rnormal() //random noise
	
	*Construct unbiased regression models to estimate the treatment parameter + save Betas & p-values
	
	reg salary daca
	mat results1 = r(table)
	return scalar Beta1 = _b[daca]
	return scalar pvalue1 = results1[4,1]

	reg salary daca conf_school corr_y_healthcare i.state
	mat results2 = r(table)
	return scalar Beta2 = _b[daca]
	return scalar pvalue2 = results2[4,1]
	
end

*Run these regressions at various sample sizes.
clear
tempfile combined_sims
save `combined_sims', replace emptyok

forvalues i=20(40)220 {
	local samplesize=`i'
	tempfile sims
	simulate Beta_nc=r(Beta1) Pvalue_nc=r(pvalue1) Beta_c=r(Beta2) Pvalue_c=r(pvalue2), reps(500) seed(473731) saving(`sims'): week10, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_sims'
	save `combined_sims', replace
	
	display as error "This is sample size `i'"
}

use `combined_sims', clear
save "$wd/output/p1.dta", replace

gen sig_nc = 0
replace sig_nc =1 if Pvalue_nc<0.05

gen sig_c = 0
replace sig_c =1 if Pvalue_c<0.05

*Power for each sample size level
mean sig_nc, over(samplesize)
mean sig_c, over(samplesize)

*Find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.
*Without controls, the sample size has to smaller than 20k. ~180K with controls

*Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

*I'll choose sample size 180 

capture program drop week10MDP //Before defining program, drop it
program define week10MDP, rclass //define program that will allow us to return values to memory
syntax, effectsize(real) ////treatment effect size is an argument to the program
	
	*Setting parameters
	clear
	set obs 50
	
	*DGP
		*Create STRATA and entity effects
		gen state = _n //setting a state ID
		gen state_effects = rnormal(0, 5) //State effects
		expand 1+int((180-1+1) *runiform()) //generate individual-level dataset with 180 setting the limit of sample size. 
		sort state
		bysort state: generate individual = _n
		gen individual_effects = rnormal(0, 2) //individual effects

		*Create continuous variates
		gen conf_school = rnormal() //affects treatment and outcome
		gen corr_y_healthcare = rnormal() //affects only outcome
		gen corr_x_noenglish = rnormal() //affects only treatment

		*Generate treatment (DACA)
		gen daca = (state/10) ///make the probability that an individual unit receives treatment vary across strata groups
			+ conf_school ///confounder
			+ corr_x_noenglish ///variable affecting treatment but not outcome
			+ rnormal() > 0
			
		*Generate outcome Y (employment variable)
		gen salary = 13 + (0.25)*state ///make sure that the strata groups affect the outcome 
			+ conf_school ///counfounder
			+ corr_y_healthcare ///variable affecting outcome but not treatment
			+ (`effectsize')*daca ///true treatment effect varies
			+ state_effects + individual_effects ///entity effects
			+ 0.5*rnormal() //random noise
	
	*Construct unbiased regression models to estimate the treatment parameter + save Betas & p-values
	
	reg salary daca
	mat results1 = r(table)
	return scalar Beta1 = _b[daca]
	return scalar pvalue1 = results1[4,1]

	reg salary daca conf_school corr_y_healthcare i.state
	mat results2 = r(table)
	return scalar Beta2 = _b[daca]
	return scalar pvalue2 = results2[4,1]
	
end

clear
tempfile combined_sims
save `combined_sims', replace emptyok

forvalues i=0.1(0.05)0.55 {
	local effectsize=`i'
	tempfile sims
	simulate Beta_nc=r(Beta1) Pvalue_nc=r(pvalue1) Beta_c=r(Beta2) Pvalue_c=r(pvalue2), reps(500) seed(473732) saving(`sims'): week10MDP, effectsize(`effectsize') 

	use `sims' , clear
	gen effectsize=`effectsize'
	append using `combined_sims'
	save `combined_sims', replace
	
	display as error "The treatment effect size is `i'"
}

use `combined_sims', clear
save "$wd/output/p1MDP.dta", replace


gen sig_nc = 0
replace sig_nc =1 if Pvalue_nc<0.05

gen sig_c = 0
replace sig_c =1 if Pvalue_c<0.05

*Power for each sample size level
bysort effectsize: sum sig_c //the model with controls has an MDE between 0.30 and 0.35
bysort effectsize: sum sig_nc // the bivariate model with no controls always is statistically signicant, no matter the treatment effect size (with the range I tried, specifically). Smallest effect size I simulated was 0.1, so MDE would be smaller than 0.1. 


/*****************************************************
Part 2: Calculating power for DGPs with clustered random errors
******************************************************/


