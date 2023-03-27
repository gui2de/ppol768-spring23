*Elena Spielmann
*PPOL 768
*Week 09 STATA Assignment 04

cd "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation"

***Part 1: De-biasing a parameter estimate using controls

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

// Set seed for reproducibility
set seed 1234

// Specify number of observations
set obs 1000

// Generate treatment variable
gen treatment = rbinomial(1, 0.5)

// Generate covariates that affect outcome and treatment
gen age = rnormal(50, 10)
gen gender = rbinomial(1, 0.5)
gen bmi = rnormal(25, 5)

// Generate outcome variable (resting heart rate)
gen resting_hr = 60 + 0.5*treatment - 0.2*age + 2*gender + 1.5*bmi + rnormal(0, 5)



*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
// Set seed for reproducibility

clear all

set seed 1234

// Specify number of strata groups and individuals per group
local nstrata 5
local npergroup 200

// Generate strata variable
gen strata = ""
forvalues i = 1/`nstrata' {
    replace strata = "`i'" if _n <= `npergroup'*`i'
}

// Generate covariates that affect outcome and treatment
gen age = rnormal(50, 10)
gen gender = rbinomial(1, 0.5)
gen bmi = rnormal(25, 5)

// Generate treatment probability that varies by strata
gen treat_prob = .
replace treat_prob = 0.1 if strata == "1"
replace treat_prob = 0.2 if strata == "2"
replace treat_prob = 0.3 if strata == "3"
replace treat_prob = 0.4 if strata == "4"
replace treat_prob = 0.5 if strata == "5"

// Generate treatment variable based on treatment probability
gen treatment = rbinomial(1, treat_prob)

// Generate outcome variable (resting heart rate)
gen resting_hr = 60 + 0.5*treatment - 0.2*age + 2*gender + 1.5*bmi + rnormal(0, 5)
 

*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

clear all

* Set the seed for replicability
set seed 1234567

* Generate strata variable
gen strata = ceil(runiform()*5)

* Generate treatment variable
gen nudge = rbinomial(1, 0.5)

* Generate age covariate that affects both outcome and treatment
gen age = rnormal(50, 10)
replace age = age + 0.5*nudge + 0.5*resting_heart_rate

* Generate gender covariate that affects only outcome
gen gender = rbinomial(1, 0.5)
replace gender = gender + 0.5*resting_heart_rate

* Generate BMI covariate that affects only treatment
gen bmi = rnormal(25, 5)
replace bmi = bmi + 0.5*nudge

*4. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

clear all
set seed 12345

* Generate simulated data
set obs 10000
gen age = rnormal(50, 10)
gen gender = rbinomial(1, 0.5)
gen bmi = rnormal(25, 5)
gen strata = ceil(runiform()*5)
gen treatment_prob = rnormal(0.5, 0.2)
replace treatment_prob = 0.1 if strata == 1
replace treatment_prob = 0.2 if strata == 2
replace treatment_prob = 0.3 if strata == 3
replace treatment_prob = 0.4 if strata == 4
replace treatment_prob = 0.5 if strata == 5
gen treatment = rbinomial(1, treatment_prob)
gen nudge = rnormal(0, 2)
gen Y = 60 - 0.5 * age + 1.5 * gender + 1.2 * bmi + 2 * treatment + nudge + 3 * strata + rnormal(0, 5)

* Set up sample sizes
local N "100 200 500 1000 2000 5000 10000"

* Define regression models
local models "reg Y treatment i.strata i.gender i.age i.bmi, fe
              reg Y treatment i.strata i.gender, fe
              reg Y treatment i.strata, fe
              reg Y i.strata, fe
              reg Y i.strata i.gender i.age i.bmi, fe"

* Loop over sample sizes and regression models
foreach n of local N {
    di "N = `n'"
    foreach model of local models {
        di "Model: `model'"
        clear
        set obs `n'
        gen age = rnormal(50, 10) in 1/`n'
        gen gender = rbinomial(1, 0.5) in 1/`n'
        gen bmi = rnormal(25, 5) in 1/`n'
        gen strata = ceil(runiform()*5) in 1/`n'
        gen treatment_prob = rnormal(0.5, 0.2) in 1/`n'
        replace treatment_prob = 0.1 if strata == 1 in 1/`n'
        replace treatment_prob = 0.2 if strata == 2 in 1/`n'
        replace treatment_prob = 0.3 if strata == 3 in 1/`n'
        replace treatment_prob = 0.4 if strata == 4 in 1/`n'
        replace treatment_prob = 0.5 if strata == 5 in 1/`n'
        gen treatment = rbinomial(1, treatment_prob) in 1/`n'
        gen nudge = rnormal(0, 2) in 1/`n'
        gen Y = 60 - 0.5 * age + 1.5 * gender + 1.2 * bmi + 2 * treatment + nudge + 3 * strata + rnormal(0, 5) in 1/`n'
        qui `model'
        qui est store `model'
    }}
    * Generate summary statistics for each model
    local summary ""
    foreach model of local models
	
*To generate a table that compares the parameter estimates for each model, I need to store the parameter estimates for each model in a separate "estimation set".

estimates clear
foreach model in models {
    qui reg outcome treatment age gender bmi i.strata if _n <= `n'
    qui est store `model'
}

esttab *, se(%14.8f) p(%14.8f) b(3) star(* 0.1 ** 0.05 *** 0.01) mtitle("Model 1" "Model 2" "Model 3" "Model 4" "Model 5") collabels(none) unstack noobs


*This should produce a graph that shows the mean and variance of beta for each model as a function of N, along with the true parameter value. I should be able to compare the estimates to the true value to see how well the models perform as sample size increases.

estimates clear
qui reg outcome treatment age gender bmi i.strata
estimates store true

foreach model in models {
    qui reg outcome treatment age gender bmi i.strata if _n <= `n'
    qui est store `model'
}

estimates table true `models', b(%14.8f)
marginsplot, by(`models') xsample(`nsample') yline(0)


*5. Fully describe your results in your README.md file, including figures and tables as appropriate.

*I am having problems getting my figures and tables and overall code to work. The code included is done to the best of my knowledge and ability. I assume that my resulting figures and tables would show the following:

*Biasedness and convergence of the models as N grows: This involves comparing the regression estimates of the models at different sample sizes. Biasedness can be assessed by comparing the estimates to the true parameter value (if available). Convergence can be assessed by examining how the estimates change as sample size increases. Tables can be used to display the estimates for each model and sample size, while figures can be used to visually compare the estimates across models and sample sizes.

*Mean and variance of beta for different regression models, as a function of N: This involves computing the mean and variance of the estimated coefficients (beta) for each model and sample size, and plotting them against sample size (N). The "true" parameter value can also be plotted for comparison. The figure should allow for easy comparison of the estimates across models and sample sizes, and should show how the estimates converge to the true value as sample size increases.


***Part 2: Biasing a parameter estimate using controls


*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.
*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
*3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
*4. In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
*5. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
*6. Fully describe your results in your README.md file, including figures and tables as appropriate.

*For this scenario, a good option for the channel variable could be "physical activity level". This variable can be affected by the treatment (fitbit nudge) and can also affect the outcome (resting heart rate) through its impact on an individual's fitness level.

*A good option for the collider variable could be "medication use". This variable can be influenced by both the treatment and the outcome. For example, if an individual has a high resting heart rate, they may be more likely to take medication for hypertension. Similarly, if an individual receives the fitbit nudge and experiences a decrease in their resting heart rate, they may be less likely to take medication for hypertension.

* Generate data for outcome variable (resting heart rate) and treatment variable (nudge)
clear all
set obs 10000
gen treatment = rbinomial(1,0.5)
gen Y = 65 + 0.3*treatment + rnormal(0, 10)

*Create channel variable (physical activity level) that is a function of treatment
gen channel = 2*treatment + rnormal(0, 1)

* Create collider variable (medication use) that is a function of both Y and treatment
gen collider = 0.5*Y - 0.8*treatment + rnormal(0, 1)

* Create strata variable and assign probabilities of treatment within each stratum
gen strata = rbinomial(3,0.5)
egen p_treatment = mean(treatment), by(strata)

* Create different regression models with combinations of covariates and fixed effects
local models "reg Y treatment i.strata i.gender i.age i.bmi channel collider, fe
reg Y treatment i.strata i.gender i.age i.bmi channel, fe
reg Y treatment i.strata i.gender i.age i.bmi collider, fe
reg Y treatment i.strata i.gender i.age i.bmi channel collider i.gender#c.collider i.bmi#c.channel, fe
reg Y treatment i.strata i.gender i.age i.bmi channel collider i.gender#c.collider i.age#c.channel, fe"

*Run regressions at different sample sizes and store coefficients
forvalues n = 100 100 1000 10000 {
    qui set obs `n'
    qui foreach model of local models {
        qui `model'
        qui est store `model'
    }
    qui suest `: list est*'
    qui mat b = e(b)
    qui mat V = e(V)
    qui svmat b_`n' = b'
    qui svmat V_`n' = V'
}

*Compute mean and variance of beta for each regression model as a function of sample size
local models_list "Model 1: Channel, Collider, and all Covariates
Model 2: Channel and all Covariates
Model 3: Collider and all Covariates
Model 4: Channel, Collider, Interaction Effects, and all Covariates"
matrix list models = `models_list'
forvalues i = 1/`=rows(models)' {
    local model = word(models[`i',1],2)
    qui mata: b_meanvar = st_matrix("b_10000") : st_matrix("V_10000")
    matrix b_meanvar = b_meanvar'
    matrix model_bv = b_meanvar[.,colnames(b_meanvar) : substr(colnames(b_meanvar),1,strlen("`model'")) == "`model'"]
    matrix list model_bv
}

*I am having problems getting my figures and tables and overall code to work. The code included is done to the best of my knowledge and ability. 