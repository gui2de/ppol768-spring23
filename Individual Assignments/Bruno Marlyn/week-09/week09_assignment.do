/*Marlyn Bruno
Assignment 09 */

/*****************************************************
Part 1: De-biasing a parameter estimate using controls 
******************************************************/

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
global wd "/Users/marlyn/GitHub/ppol768-spring23/Individual Assignments/Bruno Marlyn/week-09"

clear
set seed 893553
set obs 50 //50 US states

*2 create STRATA and entity effects
gen state = _n //setting a state ID
gen state_effects = rnormal(0, 5) //State effects
expand 3+int((159-3+1) *runiform()) //generate county-leveldataset. Range of 3 to 159 counties based on actual data of US states (Delaware has least no. of counties with 3 and Georgia has most with 159)
sort state
bysort state: generate county = _n
gen county_effects = rnormal(0, 2) //county effects

*generate X = DACA approvals
gen daca = 1 + int((5-1+1)*runiform()) //create a variable that measures DACA approvals (in thousands). For purposes of this simulation, counties have between 1,000 to 5,000 approvals in a uniform distribution

*3. gen different covariates 
gen randomcutoff = runiform()
gen bluecounty = 0 //dummy confounder
replace bluecounty = 1 if randomcutoff > 0.5
gen mean_years_school = rnormal(14, 2) //mean years of schooling at county level. Confounder.
gen healthspend_per_capita = runiform(8, 13) //in thousands of dollars. Covariate affects unemployment but not the treatment 
gen non_english_household = runiform(15, 25) //% of population that speaks another language that is not English at home. covariate affects daca approvals but not unemployment 

*generate Y = unemployment
gen unemployment = 60 + (-0.5)*daca + (-1)*bluecounty + (-2)*mean_years_school + (-1)*healthspend_per_capita + (0)*non_english_household + state_effects + county_effects 

/*gen unemployment = 60
+ (-0.5)*daca //unemployment rate will go down 0.5 points for additional 1000 daca approvals
+ (-1)*bluestate //blue states will be related to smaller unemployment rates
+ (-2)*mean_years_school //states with higher means of school years will have less unemployment
+ (-1)*healthspend_per_capita //unemployment and healthcare spendings are negatively correlated
+ (0)*non_english_household //doesn't affect unemployment */
	
*4. Construct at least five different regression models with combinations of these covariates and strata fixed effects.
reg unemployment daca
reg unemployment daca bluecounty
reg unemployment daca bluecounty mean_years_school 
reg unemployment daca bluecounty mean_years_school healthspend_per_capita 
reg unemployment daca bluecounty mean_years_school healthspend_per_capita non_english_household
reg unemployment daca bluecounty mean_years_school healthspend_per_capita non_english_household i.state //state fixed effects added - CHECK: DO WE WANT COUNTY-LEVEL?

save "$wd/output/part1.dta", replace

*Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each

capture program drop regressionruns //Before defining program, drop it
program define regressionruns, rclass //define program that will allow us to return values to memory
syntax, samplesize(integer) ////sample size is an argument to the program

	clear
	use "$wd/output/part1.dta"
	set obs `samplesize' //CHECK: ARE WE SUPPOSED TO DO THIS FOR THE FIXED DATASET WE CREATED?

	reg unemployment daca bluesetate mean_years_school non_english_household i.state //confounders only
	mat results1 = r(table) //save matrix of results as "results"
    return scalar n1 = `samplesize' 
	return scalar beta1 = results1[1,1]
	return scalar sem1 = results1[2,1] 
    return scalar pval1 = results1[4,1]
	return scalar lowerCI1 = results1[5,1]
	return scalar upperCI1 = results1[6,1]
	
	*CHECK: then do for each of the other four regressions??
	
end

*Run simulations

*Produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value? GRAPH WITH N AT X-AXIS AND MEAN AND VARIANCE ON Y. IMPOSE LINE FOR TRUE PARAMETER VALUE

histogram beta_coef, by(samplesize)

/*****************************************************
Part 2: Biasing a parameter estimate using controls
******************************************************/

*for questions 1 and 2, I'm using the same data from the data generating process I created in Part 1

*3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
gen economic_opportunity = runiform(1, 10) //daca -> economic_opportunity -> unemployment. This is a hypothetical channel for the sake of this assignment. Higher values translate as more economic or job opportunities 

*4. Create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".) unemployment -> median_income AND daca -> median_income
gen median_income = rnormal(73, 30) //in thousands of dollars

*save dataset for later program
*save "simulations", replace

*5. Construct at least five different regression models with combinations of these covariates and strata fixed effects
reg unemployment daca bluesetate mean_years_school non_english_household i.state //confounders only
reg unemployment daca bluesetate mean_years_school non_english_household economic_opportunity i.state //with channel
reg unemployment daca bluesetate mean_years_school non_english_household  median_income i.state //with collider
reg unemployment daca bluesetate mean_years_school non_english_household economic_opportunity median_income i.state  //with both channel and collider
reg unemployment daca bluesetate mean_years_school non_english_household economic_opportunity median_income  //with both channel and collider and no state fixed effects

*Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each


*Run simulations

*Produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?




****************Notes from Lab*******************
*regress
reg Y treatmentreg Y treatment i.district
reg Y treatment i.district confounder
reg Y treatment i.district confounder covar_1
reg Y treatment i.district confounder covar_1 covar_2
reg Y treatment i.district confounder covar_1 covar_2 covar_3

*Should be able to figure out which regression gives us the right treatment effect because we're already establishing the treatment effect through the data generating process
