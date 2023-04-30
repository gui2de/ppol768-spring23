*Elena Spielmann
*PPOL 768
*Week 09 STATA Assignment 04

global wd "C:/Users/easpi/OneDrive/Desktop/Georgetown MPP/MPP Spring 2023/Research Design and Implmentation/Week09"

********************Part 1: De-biasing a parameter estimate using controls*************

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

*4. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

*5. Fully describe your results in your README.md file, including figures and tables as appropriate.


clear
// Set the number of observations to 62, representing 62 cities in New York
set obs 62 

// Create strata and entity effects
gen city = _n //setting a city ID
gen city_effects = rnormal(0, 5) //city effects
expand 1+int((968-1+1) *runiform()) //generate individual-level dataset. Range of 1,000 to 968,000 individuals in each city with smart watches 
sort city
bysort city: generate individual = _n
gen individual_effects = rnormal(0, 2) //individual effects

//Create continuous variates
gen conf_education = rnormal() //affects treatment and outcome
gen corr_y_gym_membership = rnormal() //affects only outcome
gen corr_x_age = rnormal() //affects only treatment

//Generate treatment (digital nudge)
gen nudge = (city/10) ///make the probability that an individual unit receives treatment vary across strata groups
	+ conf_education ///confounder
	+ corr_x_age ///variable affecting treatment but not outcome
	+ rnormal() > 0
	
//Generate outcome Y (heart rate)
gen heartrate = 13 + (0.25)*city ///make sure that the strata groups affect the outcome 
	+ conf_education ///counfounder
	+ corr_y_gym_membership ///variable affecting outcome but not treatment
	+ (2)*nudge ///treatment effect 
	+ city_effects + individual_effects ///entity effects
	+ 0.5*rnormal() //random noise

//Construct at least five regression models
reg heartrate nudge //simple bivariate model
reg heartrate nudge conf_education i.city //unbiased model
reg heartrate nudge conf_education i.city corr_x_age //biased
reg heartrate nudge conf_education i.city corr_y_gym_membership //biased
reg heartrate nudge conf_education i.city corr_x_age corr_y_gym_membership //biased


// Define program to run regressions at different sample sizes

capture program drop regressionruns //Before defining program, drop it
program define regressionruns, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program
	
	//Setting parameters
	clear
	set obs 62
	
	//DGP
		//Create STRATA and entity effects
		gen city = _n //setting a city ID
		gen city_effects = rnormal(0, 5) //City effects
		expand 1+int((`samplesize'-1+1) *runiform()) //generate individual-level dataset. Range of 1,000 to "infinite" individuals in each city with wearables
		sort city
		bysort city: generate individual = _n
		gen individual_effects = rnormal(0, 2) //individual effects

		//Create continuous variates
		gen conf_education = rnormal() //affects treatment and outcome
		gen corr_y_gym_membership = rnormal() //affects only outcome
		gen corr_x_age = rnormal() //affects only treatment

		//Generate treatment (nudge)
		gen nudge = (city/10) ///make the probability that an individual unit receives treatment vary across strata groups
			+ conf_education ///confounder
			+ corr_x_age ///variable affecting treatment but not outcome
			+ rnormal() > 0
			
		//Generate outcome Y (heart rate)
		gen heartrate = 13 + (0.25)*city ///make sure that the strata groups affect the outcome 
			+ conf_education ///counfounder
			+ corr_y_gym_membership ///variable affecting outcome but not treatment
			+ (2)*nudge ///true treatment effect is 2
			+ city_effects + individual_effects ///entity effects
			+ 0.5*rnormal() //random noise
	
	//Running regressions and saving Betas 
	reg heartrate nudge //simple bivariate model
	return scalar bivar_B = _b[nudge]
	
	reg heartrate nudge conf_education i.city //unbiased model
	return scalar unbiased_B = _b[nudge]
	
	reg salary daca conf_education i.city corr_x_age //biased
	return scalar biased1_B = _b[nudge]
	
	reg salary daca conf_education i.city corr_y_gym_membership //biased
	return scalar biased2_B = _b[nudge]

	reg salary daca conf_education i.city corr_x_age corr_y_gym_membership //biased
	return scalar biased3_B = _b[nudge]
	
end

*Run simulations

clear
tempfile combined_sims
save `combined_sims', replace emptyok

forvalues i=50(200)850 {
	local samplesize=`i'
	tempfile sims
	simulate bivar=r(bivar_B) unbias=r(unbiased_B) bias1=r(biased1_B) bias2=r(biased2_B) bias3 =r(biased3_B), reps(150) seed(8675309) saving(`sims'): regressionruns, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_sims'
	save `combined_sims', replace
	
	display as error "This is sample size `i'"
}

use `combined_sims', clear
save "$wd/output/part1.dta", replace

exit 

//Produce figures and tables comparing the biasedness and convergence of the models as N grows.
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

//Make twoway area graphs
twoway rarea min_bivar max_bivar samplesize, title("Bivariate") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bivariate.gph", replace

twoway rarea min_unbias max_unbias samplesize, title("City + Confounder") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/unbias.gph", replace

twoway rarea min_bias1 max_bias1 samplesize, title("Biased Model 1") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias1.gph", replace

twoway rarea min_bias2 max_bias2 samplesize, title("Biased Model 2") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias2.gph", replace

twoway rarea min_bias3 max_bias3 samplesize, title("Biased Model 3") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/bias3.gph", replace

//Combine the five models' graphs
graph combine "$wd/output/bivariate.gph" "$wd/output/unbias.gph" "$wd/output/bias1.gph" "$wd/output/bias2.gph" "$wd/output/bias3.gph", altshrink 

//Table of summary stats
estpost tabstat bivar unbias bias1 bias2 bias3, col(stat) stat(mean sd semean min max) 

// Clear all existing data and programs
clear all 



********************Part 2: Biasing a parameter estimate using controls****************


*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.
*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
*3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
*4. In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
*5. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
*6. Fully describe your results in your README.md file, including figures and tables as appropriate.


capture program drop regressionruns2 //Before defining program, drop it
program define regressionruns2, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program
	
//Setting parameters
clear
set obs 50
	
//DGP
//Create strata and entity effects
gen city = _n //setting a city ID
gen city_effects = rnormal(0, 5) //City effects
expand 1+int((`samplesize'-1+1) *runiform()) //generate individual-level dataset. Range of 1,000 to "infinite" individuals in each city with smart watches
sort city
bysort city: generate individual = _n
gen individual_effects = rnormal(0, 2) //individual effects

//Create continuous variates
gen conf_education = rnormal() //affects treatment and outcome
gen corr_y_gym_membership = rnormal() //affects only outcome
gen corr_x_age = rnormal() //affects only treatment

//Generate treatment (nudge)
gen nudge = (city/10) + conf_education + corr_x_age + rnormal() > 0
		
//Generate channel
gen channel_stepcount = 2*nudge
			
//Generate outcome Y (heartrate)
gen heartrate= 13 + ((0.25)*city) + conf_education + corr_y_gym_membership + channel_stepcount + ((2)*nudge) + city_effects + individual_effects + 0.5*rnormal()	

//Generate collider
gen collider_social = 2*nudge + 1.5*heartrate
	
//Running regressions and saving Betas
reg heartrate nudge //simple bivariate model
return scalar bivar_B = _b[nudge]
	
reg heartrate nudge conf_education i.city //unbiased model
return scalar unbiased_B = _b[nudge]
	
reg heartrate nudge conf_education i.city channel_stepcount //biased
return scalar biased1_B = _b[nudge]
	
reg heartrate nudge conf_education i.city collider_social //biased
return scalar biased2_B = _b[nudge]

reg heartrate nudge conf_education i.city channel_stepcount collider_social //biased
return scalar biased3_B = _b[nudge]
	
end

//Run simulations

clear
tempfile combined_sims_2
save `combined_sims_2', replace emptyok

forvalues i=50(200)850 {
	local samplesize=`i'
	tempfile sims
	simulate bivar=r(bivar_B) unbias=r(unbiased_B) bias1=r(biased1_B) bias2=r(biased2_B) bias3 =r(biased3_B), reps(150) seed(8675309) saving(`sims'): regressionruns2, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined_sims_2'
	save `combined_sims_2', replace
	
	display as error "This is sample size `i'"
}

use `combined_sims_2', clear
save "$wd/output/part2.dta"

exit 

//Produce figures and tables comparing the biasedness and convergence of the models as N grows.
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

//Make twoway area graphs
twoway rarea min_bivar max_bivar samplesize, title("Bivariate") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bivariate.gph", replace

twoway rarea min_unbias max_unbias samplesize, title("City + Confounder") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2unbias.gph", replace

twoway rarea min_bias1 max_bias1 samplesize, title("Biased Model 1") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias1.gph", replace

twoway rarea min_bias2 max_bias2 samplesize, title("Biased Model 2") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias2.gph", replace

twoway rarea min_bias3 max_bias3 samplesize, title("Biased Model 3") ylin(2, lcolor(midgreen)) ytitle("Estimated Effect Size") xtitle("Sample Size") yscale(range (0 10))
graph save "Graph" "$wd/output/p2bias3.gph", replace

//Combine the five models' graphs
graph combine "$wd/output/p2bivariate.gph" "$wd/output/p2unbias.gph" "$wd/output/p2bias1.gph" "$wd/output/p2bias2.gph" "$wd/output/p2bias3.gph", altshrink 

