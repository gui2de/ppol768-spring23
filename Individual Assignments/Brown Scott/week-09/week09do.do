***Part 1: De-biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
cd "D:\2021-2023, Georgetown University\2023 - Spring\Research Design & Implementation\ScottsRepo\ppol768-spring23\Individual Assignments\Brown Scott\week-09"
set seed 20230327
clear

cap prog drop week9part1
prog def week9part1, rclass // Allow returning values to memory

syntax, samplesize(integer)

clear
set obs `samplesize'

// Create strata groups with different sizes
gen stratum = cond(_n <= 500, 1, ///
              cond(_n <= 1500, 2, 3))

// Generate social and economic covariates
gen age = round(rnormal(40, 10))
gen gender = rbinomial(1, 0.5)
gen education = round(rnormal(13, 3))
gen income = rnormal(50000, 20000)
gen employment = rbinomial(1, 0.8)

// Generate binary therapy treatment variable with stratum dependence - CONFOUNDER
gen treatment = .
replace treatment = rbinomial(1, exp(0.5*(stratum-2))) if stratum==1
replace treatment = rbinomial(1, exp(0.1*(stratum-2))) if stratum==2
replace treatment = rbinomial(1, exp(-0.3*(stratum-2))) if stratum==3

// Generate outcome variable (life satisfaction)
gen satisfaction = 60 + 0.5*age + 10*gender + 3*education + 0.0001*income + 5*employment + 5*treatment + rnormal(0, 10) 

// Regression model 1: only intercept
reg satisfaction, noconstant

// Regression model 2: social and economic covariates
reg satisfaction age gender education income employment

// Regression model 3: social and economic covariates + treatment
reg satisfaction age gender education income employment treatment

// Regression model 4: social and economic covariates + stratum fixed effects
reg satisfaction age gender education income employment i.stratum

// Regression model 5: social and economic covariates + treatment + stratum fixed effects
reg satisfaction age gender education income employment treatment i.stratum

end

// Create a loop to collect regression results at different sample sizes and generate histograms
clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval) ///
	  , reps(500) seed(20230327) saving(`sims') ///
	  : week9part1, samplesize(`samplesize') 
	  
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
	
	histogram beta, by(samplesize) width(0.5)
	export graph

}
// CANT GET CODE TO WORK 
*Fully describe your results in your README.md file, including figures and tables as appropriate. COULDN'T GET TO WORK



***Part 2: Biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.


*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.


*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)


*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)


*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?


*Fully describe your results in your README.md file, including figures and tables as appropriate.