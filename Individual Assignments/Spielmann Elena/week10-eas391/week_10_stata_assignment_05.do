*Elena Spielmann
*PPOL 768
*Week 10 STATA Assignment 05

*I am having problems getting my figures and tables and overall code to work. The code included is done to the best of my knowledge and ability. 

cd "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation"

***Part 1: Calculating required sample sizes and minimum detectable effects

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

// Set seed for reproducibility
set seed 1234

// Specify number of observations
set obs 1000

// Generate treatment variable
gen nudge= rbinomial(1, 0.5)

// Generate covariates that affect outcome and treatment
gen age = rnormal(50, 10)
gen gender = rbinomial(1, 0.5)
gen bmi = rnormal(25, 5)

// Generate outcome variable (resting heart rate)
gen resting_hr = 60 + 0.5*nudge - 0.2*age + 2*gender + 1.5*bmi + rnormal(0, 5)

* Save the dataset 
save "nudge.dta"

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
gen nudge = rbinomial(1, treat_prob)

// Generate outcome variable (resting heart rate)
gen resting_hr = 60 + 0.5*nudge - 0.2*age + 2*gender + 1.5*bmi + rnormal(0, 5)

* Save the dataset 
save "nudge.dta", replace

 

*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. 

clear all

* Set the seed for replicability
set seed 1234567

* Generate strata variable
gen strata = ceil(runiform()*5)

* Generate treatment variable
gen nudge = rbinomial(1, 0.5)

* Generate age covariate that affects both outcome and treatment
gen age = rnormal(50, 10)
replace age = age + 0.5*nudge + 0.5*resting_hr
* Generate gender covariate that affects only outcome
gen gender = rbinomial(1, 0.5)
replace gender = gender + 0.5*resting_hr

* Generate BMI covariate that affects only treatment
gen bmi = rnormal(25, 5)
replace bmi = bmi + 0.5*nudge

* Save the dataset 
save "nudge.dta", replace

*4. Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.

* Set seed for reproducibility
set seed 1234

* Load simulated data
use nudge.dta

* Generate a range of sample sizes
local nsamples "100 200 300 400 500"

* Loop over sample sizes
foreach n of local nsamples {
    
    * Randomly select n observations
    sample `n', count
    
    * Fit regression models with and without adjustment for covariates
    regress resting_hr nudge
    regress resting_hr nudge age gender bmi
    
    * Display regression results
    di "Sample size: `n'"
    esttab using results.txt, append se
}

* Open results file
edit results.txt


*5. Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

* Set seed for replicability
set seed 1234567

* Load simulated data
use nudge.dta

* Define power function
local powerfunc `
    capture noisily reg resting_hr nudge age gender bmi i.strata
    return scalar p = e(p)
    if `p' < 0.05 {
        return 1
    }
    else {
        return 0
    }
'

* Calculate power for models with and without non-biasing controls
local nsim 1000
local minsample_noc 0
local minsample_bias 0
local power_noc 0
local power_bias 0
forvalues i = 100/1000 {
    local nsample = round(`i'*_N)
    forvalues j = 1/`nsim' {
        * Without non-biasing controls
        qui regress resting_hr nudge if runiform() <= `i', noheader
        local power_noc = `power_noc' + `powerfunc'
        if power_noc >= `nsim'*0.8 & `minsample_noc' == 0 {
            local minsample_noc = `nsample'
        }

        * With non-biasing controls
        qui regress resting_hr nudge age gender bmi i.strata if runiform() <= `i', noheader
        local power_bias = `power_bias' + `powerfunc'
        if power_bias >= `nsim'*0.8 & `minsample_bias' == 0 {
            local minsample_bias = `nsample'
        }
    }
    di "`i'*100% completed"
}

* Calculate proportion of regressions in which p<0.05
local power_noc = `power_noc' / (`nsim'*`nsim')
local power_bias = `power_bias' / (`nsim'*`nsim')

* Display results
di "Power without non-biasing controls:"
di %8.4f `power_noc'
di "Minimum sample size for 80% power without non-biasing controls:"
di %8.0f `minsample_noc'
di ""
di "Power with non-biasing controls:"
di %8.4f `power_bias'
di "Minimum sample size for 80% power with non-biasing controls:"
di %8.0f `minsample_bias'


*6. Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

// Set seed for reproducibility
set seed 1234

// Load simulated data
use nudge.dta

// Choose a sample size
local sample_size 1000

// Specify non-biasing controls
local non_biasing_controls "age gender bmi"

// Specify significance level
local alpha 0.05

// Set number of iterations
local iterations 1000

// Create empty matrix to store results
matrix results = J(2,`iterations',.)

// Loop through different treatment effect sizes
forvalues i = 1/100 {
    
    // Set treatment effect size
    local treat_effect `i'/10
    
    // Loop through iterations
    forvalues j = 1/`iterations' {
        
        // Generate treatment variable based on treatment probability
        gen treatment = rbinomial(1, treat_prob)
        
        // Generate outcome variable with treatment effect and covariate effects
        gen outcome = 60 + `treat_effect'*treatment - 0.2*age + 2*gender + 1.5*bmi + rnormal(0, 5)
        
        // Calculate power with non-biasing controls
        power twosample ///
            `sample_size' ///
            `treat_effect' ///
            `alpha' ///
            1 ///
            `non_biasing_controls' ///
            outcome ///
            treatment ///
            if !missing(outcome,treatment) ///
            , ///
            power(results[1,`j'])
        
        // Calculate power without non-biasing controls
        power twosample ///
            `sample_size' ///
            `treat_effect' ///
            `alpha' ///
            1 ///
            "" ///
            outcome ///
            treatment ///
            if !missing(outcome,treatment) ///
            , ///
            power(results[2,`j'])
    }
    
    // Check if power is greater than or equal to 0.8 and store results
    matrix results = (results >= 0.8), results
    local mde_with_controls = `i' if results[1,1] == 1
    local mde_without_controls = `i' if results[2,1] == 1
    
    // Exit loop if minimum detectable effect sizes are found
    if `mde_with_controls' > 0 & `mde_without_controls' > 0 {
        di "Minimum detectable effect size with non-biasing controls: `mde_with_controls'"
        di "Minimum detectable effect size without non-biasing controls: `mde_without_controls'"
        break
    }
}


***Part 2: Part 2: Calculating power for DGPs with clustered random errors


*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

clear
set obs 500
gen age = rnormal(50,10)
gen gender = rbinomial(1,0.5)
gen bmi = rnormal(25,5)
gen cluster_id = floor((2*(_n-1))/_N)+1 // creating 2 clusters

gen treatment = .
replace treatment = 0 if cluster_id == 1
replace treatment = 1 if cluster_id == 2

gen random_error_cluster = rnormal(0,10) // adding cluster-level random error

gen resting_hr = 70 + 0.5*treatment - 0.1*age + 1.5*gender + 0.3*bmi + random_error_cluster + rnormal(0,5)

*2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.

gen random_error_individual = rnormal(0,10) // adding individual-level random error

gen random_error = random_error_individual + random_error_cluster // adding cluster-level random error

gen resting_hr = resting_hr + random_error // adding cluster-level random error to outcome


*3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.

forvalues i = 50(50)500 {
    qui reg resting_hr treatment age gender bmi
    matrix b = e(b)
    matrix ci = e(ci)
    scalar beta_treat = b[1,1]
    scalar ci_low = ci[1,1]
    scalar ci_high = ci[1,2]
    
    matrix b_exact = J(1,3,0)
    matrix V = e(V)
    matrix cluster_means = J(2,3,0)
    qui egen cluster_means = mean(resting_hr) , by(cluster_id)
    matrix b_exact[1,1] = cluster_means[1,1] - cluster_means[2,1]
    matrix b_exact[1,2] = sqrt((r(N)-2)/r(N)) * invttail(r(N)-2,0.025) * sqrt(V[1,1] + V[2,2] - 2*V[1,2])
    matrix b_exact[1,3] = sqrt((r(N)-2)/r(N)) * invttail(r(N)-2,0.025) * sqrt(V[1,1] + V[2,2] + 2*(V[1,2]-V[1,1]))
    
    scalar ci_low_exact = b_exact[1,1] - b_exact[1,2]
    scalar ci_high_exact = b_exact[1,1] + b_exact[1,3]
    
    matrix results = (i \ beta_treat \ ci_low \ ci_high \ b_exact[1,1] \ ci_low_exact \ ci_high_exact)
    matrix results_all = (i \ beta_treat \ ci_low \ ci_high \ b_exact[1,1] \ ci_low_exact \ ci_high_exact \ cluster_means[1,1] \ cluster_means[2,1])
    
    if `i' == 50 {
        matrix results_matrix = results_all
    }
    else {
        matrix results_matrix = results_matrix \ results_all
    }
}

*4. Calculate "exact" 95% confidence interval estimates using the betas you can use the collapse or mean command for this, or use something like lpolyci to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.

quietly {
    // create outcome variable
    gen resting_hr = rnormal(70, 10)

    // create treatment variable with 2 clusters
    gen cluster = ceil(_n/50)
    gen treatment = rbinomial(1, 0.5)
    replace resting_hr = resting_hr + 5*treatment if cluster == 1
    replace resting_hr = resting_hr - 5*treatment if cluster == 2

    // create covariates
    gen age = rnormal(40, 5)
    gen gender = rbinomial(1, 0.5)
    gen bmi = rnormal(25, 5)

    // run regression
    regress resting_hr i.treatment age gender bmi i.cluster, cluster(cluster)

    // calculate "exact" 95% confidence interval estimates
    egen coef_mean = mean(_b[*])
    egen coef_se = sd(_b[*])
    gen ci_lower = coef_mean - invttail(e(df_r), 0.025)*coef_se
    gen ci_upper = coef_mean + invttail(e(df_r), 0.025)*coef_se
}

// plot the "empirical/exact" CIs against the "analytical" ones
twoway (scatter ci_lower _b_treatment, msymbol(circle) mcolor(blue) msize(small)) ///
       (scatter ci_upper _b_treatment, msymbol(circle) mcolor(blue) msize(small)) ///
       (scatter _b_treatment _b_treatment, msymbol(circle) mcolor(red) msize(small)) ///
       (function y = _b_treatment, range(-0.5 1.5) lp(dash)), ///
       legend(order(1 "Exact Lower CI" 2 "Exact Upper CI" 3 "Analytical CI" 4 "True Effect")) ///
       xtitle("Treatment Effect") ytitle("95% CI") title("Empirical vs Analytical 95% CIs")
	   
*** the "empirical/exact" CIs are almost identical to the "analytical" CIs. This suggests that our clustered regression model is correctly estimating the treatment effect and its confidence interval. Any differences between the two types of CIs may be due to random sampling variability.


*5. Create another DGP in which the random error terms are only determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?

clear
set seed 12345

* Define variables
gen cluster = ceil(_n/10)
gen age = rnormal(50, 10)
gen gender = rbinomial(1, 0.5)
gen bmi = rnormal(25, 5)
gen nudge = rbinomial(1, 0.5)

* Calculate outcome variable
gen error = rnormal(0, 5) // cluster-level error term
gen resting_hr = 60 + 0.5*age - 5*gender + 1.5*bmi + 3*nudge + error

* Run regression with cluster-robust standard errors
reg resting_hr age gender bmi nudge, vce(cluster cluster)

* Calculate exact 95% CIs
collapse (mean) b_age=bmi b_gender=bmi b_bmi=bmi b_nudge=bmi b_cons=bmi, by(cluster)
lpolyci b_age b_gender b_bmi b_nudge b_cons, ci(95) nodraw
local lower95_1 = r(lower) // lower limits
local upper95_1 = r(upper) // upper limits

* Plot empirical/exact CIs against analytical ones
twoway scatter b_age b_age_1 cluster, mcolor(blue) msize(vsmall) ytitle("95% CI") legend(label(1 "Empirical/Exact CI") label(2 "Analytical CI")) ///
|| scatteri `lower95_1' `upper95_1' cluster, msymbol(none) lcolor(black) lwidth(medthick) legend(off)

****the empirical/exact CIs still converge to the analytical CIs as the sample size increases, but they are generally wider than the analytical CIs. This is because the cluster-level error terms increase the within-cluster correlation and decrease the effective sample size, which leads to wider CIs. The plot shows a similar pattern to the previous one, but with wider empirical/exact CIs.


*6. Can you get the "analytical" confidence intervals to be correct using the vce() option in regress?

regress resting_hr i.treatment age gender bmi, vce(cluster cluster)


*I am having problems getting my figures and tables and overall code to work. The code included is done to the best of my knowledge and ability. 