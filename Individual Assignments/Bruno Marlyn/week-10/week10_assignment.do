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
			+ (2)*daca ///true treatment effect is 2
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

forvalues i=20(40)100 {
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

*CHECK w/ALI: My simulations are producing observations that are stat sig. for each simulated run so the overall power is 100%

*Power for each sample size level
mean sig_nc, over(samplesize)
mean sig_c, over(samplesize)


*Find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

*with non-biasing controls

power twomeans 0 2, power(0.8) sd(0.3374665)

*CHECK: is mean1 0 (null effect) and mean2 = 2 (true treatment effect)? How do we determine what SD is without a dataset? 

/*
Performing iteration ...

Estimated sample sizes for a two-sample means test
t test assuming sd1 = sd2 = sd
H0: m2 = m1  versus  Ha: m2 != m1

Study parameters:

        alpha =    0.0500
        power =    0.8000
        delta =    0.8690
           m1 =    0.0000
           m2 =    0.8690
           sd =    0.3375

Estimated sample sizes:

            N =         8
  N per group =         4

So, for MDE to be 0.8690 sd, we need 8,000 individuals (equally divided between DACA and control undocumented groups). Note: programmed N to be expressed in thousands.
*/ 





/*****************************************************
Part 2: Calculating power for DGPs with clustered random errors
******************************************************/





/* OLD CODE FROM WEEK 9 TO REFERENCE AND ADAPT AS NEEDED


*Produce figures and tables comparing the biasedness and convergence of the models as N grows.
egen min_bivar = min(bivar), by(samplesize)
egen max_bivar = max(bivar), by(samplesize)

egen min_unbias = min(unbias), by(samplesize)
egen max_unbias = max(unbias), by(samplesize)

egen min_bias1 = min(bias1), by(samplesize)
egen max_bias1 = max(bias1), by(samplesize)

egen min_bias2 = min(bias2), by(samplesize)
egen max_bias2 = max(bias2), by(samplesize)

egen min_bias3 = min(bias3), by(samplesize)
egen max_bias3 = max(bias3), by(samplesize)

*Make twoway area graphs
twoway rarea min_bivar max_bivar samplesize, title("Bivariate") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bivariate.gph", replace

twoway rarea min_unbias max_unbias samplesize, title("State + Confounder") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/unbias.gph", replace

twoway rarea min_bias1 max_bias1 samplesize, title("Biased Model 1") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias1.gph", replace

twoway rarea min_bias2 max_bias2 samplesize, title("Biased Model 2") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias2.gph", replace

twoway rarea min_bias3 max_bias3 samplesize, title("Biased Model 3") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias3.gph", replace

*Combine the five models' graphs
graph combine "$wd/output/bivariate.gph" "$wd/output/unbias.gph" "$wd/output/bias1.gph" "$wd/output/bias2.gph" "$wd/output/bias3.gph", altshrink 

*Table of summary stats
estpost tabstat bivar unbias bias1 bias2 bias3, col(stat) stat(mean sd semean min max) 


-----
capture program drop regressionruns2 //Before defining program, drop it
program define regressionruns2, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program
	
*Setting parameters
clear
set obs 50
	
*DGP
*Create strata and entity effects
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
gen daca = (state/10) + conf_school + corr_x_noenglish + rnormal() > 0
		
*Generate channel
gen channel_jobchange = 2*daca
			
*Generate outcome Y (labor variable)
gen salary = 13 + ((0.25)*state) + conf_school + corr_y_healthcare + channel_jobchange + ((2)*daca) + state_effects + individual_effects + 0.5*rnormal()	

*Generate collider
gen collider_luck = 2*daca + 1.5*salary
	
*Running regressions and saving Betas
reg salary daca //simple bivariate model
return scalar bivar_B = _b[daca]
	
reg salary daca conf_school i.state //unbiased model
return scalar unbiased_B = _b[daca]
	
reg salary daca conf_school i.state channel_jobchange //biased
return scalar biased1_B = _b[daca]
	
reg salary daca conf_school i.state collider_luck //biased
return scalar biased2_B = _b[daca]

reg salary daca conf_school i.state channel_jobchange collider_luck //biased
return scalar biased3_B = _b[daca]
	
end

*Run simulations

clear
tempfile combined_sims_2
save `combined_sims_2', replace emptyok

forvalues i=50(200)850 {
	local samplesize=`i'
	tempfile sims
	simulate bivar=r(bivar_B) unbias=r(unbiased_B) bias1=r(biased1_B) bias2=r(biased2_B) bias3 =r(biased3_B), reps(150) seed(782092) saving(`sims'): regressionruns2, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_sims_2'
	save `combined_sims_2', replace
	
	display as error "This is sample size `i'"
}

use `combined_sims_2', clear
save "$wd/output/part2.dta"

exit 

*Produce figures and tables comparing the biasedness and convergence of the models as N grows.
egen min_bivar = min(bivar), by(samplesize)
egen max_bivar = max(bivar), by(samplesize)

egen min_unbias = min(unbias), by(samplesize)
egen max_unbias = max(unbias), by(samplesize)

egen min_bias1 = min(bias1), by(samplesize)
egen max_bias1 = max(bias1), by(samplesize)

egen min_bias2 = min(bias2), by(samplesize)
egen max_bias2 = max(bias2), by(samplesize)

egen min_bias3 = min(bias3), by(samplesize)
egen max_bias3 = max(bias3), by(samplesize)

*Make twoway area graphs
twoway rarea min_bivar max_bivar samplesize, title("Bivariate") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bivariate.gph", replace

twoway rarea min_unbias max_unbias samplesize, title("State + Confounder") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2unbias.gph", replace

twoway rarea min_bias1 max_bias1 samplesize, title("Biased Model 1") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias1.gph", replace

twoway rarea min_bias2 max_bias2 samplesize, title("Biased Model 2") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias2.gph", replace

twoway rarea min_bias3 max_bias3 samplesize, title("Biased Model 3") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias3.gph", replace

*Combine the five models' graphs
graph combine "$wd/output/p2bivariate.gph" "$wd/output/p2unbias.gph" "$wd/output/p2bias1.gph" "$wd/output/p2bias2.gph" "$wd/output/p2bias3.gph", altshrink */

