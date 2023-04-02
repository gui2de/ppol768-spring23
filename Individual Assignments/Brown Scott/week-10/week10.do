cd "D:\2021-2023, Georgetown University\2023 - Spring\Research Design & Implementation\ScottsRepo\ppol768-spring23\Individual Assignments\Brown Scott\week-10"


********************
*PART 1
********************
clear

set seed 20230402

* Set up strata groups
gen stratum = .
replace stratum = 1 if runiform() < 0.2
replace stratum = 2 if runiform() >= 0.2 & runiform() < 0.5
replace stratum = 3 if runiform() >= 0.5 & runiform() < 0.8
replace stratum = 4 if runiform() >= 0.8
label define stratum 1 "Small" 2 "Medium" 3 "Large" 4 "X-Large"
label values stratum stratum

* Generate covariates and treatment indicator
gen income = rnormal(50000, 10000)
gen age = rnormal(40, 10)
gen marriage = rbinomial(1, 0.6)
gen education = rnormal(13, 2)
gen p_treat = .
replace p_treat = 0.2 if stratum == 1
replace p_treat = 0.4 if stratum == 2
replace p_treat = 0.6 if stratum == 3
replace p_treat = 0.8 if stratum == 4
gen treat = rbinomial(1, p_treat)

* Generate outcome variable as a function of covariates and treatment effect
gen noise = rnormal(0, 5)
gen Y = 0.1 * income + 0.2 * age + 0.3 * marriage + 0.4 * education + 0.5 * treat + noise

* Split data into training and testing sets
split sample, p(0.7)

* Estimate regression model without treatment
reg Y income age marriage education if sample == 1

* Estimate regression model with treatment
reg Y income age marriage education treat if sample == 1

* Calculate power for regression model without treatment
gen p = .
predict p if sample == 2 & treat == 0
mean p < 0.05

* Calculate power for regression model with treatment
gen p = .
predict p if sample == 2 & treat == 1
mean p < 0.05

* Determine minimum sample size for 80% power
simulate power, reps(100): reg Y income age marriage education treat if sample == 1 & _n <= `=_N'*0.8'
gen min_n_confounder = _n if power > 0.8 & treat == 1
gen min_n_noconfounder = _n if power > 0.8 & treat == 0
sum min_n_confounder min_n_noconfounder

* Determine minimum detectable effect size at fixed sample size
set obs 10000
gen income = rnormal(50000, 10000)
gen age = rnormal(40, 10)
gen marriage = rbinomial(1, 0.6)
gen education = rnormal(13, 2)
gen p_treat = .
replace p_treat = 0.4 if stratum == 2
gen treat = rbinomial(1, p_treat)
gen noise = rnormal(0, 5)
gen Y = 0.1 * income + 0.2 * age + 0.3 * marriage + 0.4 * education + 0.5 * treat + noise
simulate mde, reps

********************
*PART 2
********************
clear

set seed 20230402

* Generate cluster-level covariates and treatment indicator
set obs 1000
gen clust_id = floor((_n - 1) / 10) + 1
by clust_id: gen clust_income = rnormal(50000, 10000)
by clust_id: gen clust_age = rnormal(40, 10)
by clust_id: gen clust_marriage = rbinomial(1, 0.6)
by clust_id: gen clust_education = rnormal(13, 2)
by clust_id: gen clust_p_treat = .
by clust_id: replace clust_p_treat = 0.4 if clust_id == 2
by clust_id: gen clust_treat = rbinomial(1, clust_p_treat)
by clust_id: gen clust_noise = rnormal(0, 5)
by clust_id: gen clust_Y = 0.1 * clust_income + 0.2 * clust_age + 0.3 * clust_marriage + 0.4 * clust_education + 0.5 * clust_treat + clust_noise

* Generate individual-level covariates by copying cluster-level values
gen income = clust_income[clust_id]
gen age = clust_age[clust_id]
gen marriage = clust_marriage[clust_id]
gen education = clust_education[clust_id]
gen p_treat = clust_p_treat[clust_id]
gen treat = clust_treat[clust_id]
gen noise = rnormal(0, 5)
gen Y = 0.1 * income + 0.2 * age + 0.3 * marriage + 0.4 * education + 0.5 * treat + noise

* Split data into training and testing sets
split sample, p(0.7)

* Estimate regression model without treatment
reg Y income age marriage education if sample == 1

* Estimate regression model with treatment
reg Y income age marriage education treat if sample == 1

* Calculate power for regression model without treatment
gen p = .
predict p if sample == 2 & treat == 0
mean p < 0.05

* Calculate power for regression model with treatment
gen p = .
predict p if sample == 2 & treat == 1
mean p < 0.05

* Determine minimum sample size for 80% power
simulate power, reps(100): reg Y income age marriage education treat if sample == 1 & _n <= `=_N'*0.8'
gen min_n_confounder = _n if power > 0.8 & treat == 1
gen min_n_noconfounder = _n if power > 0.8 & treat == 0
sum min_n_confounder min_n_noconfounder

* Determine minimum detectable effect size at fixed sample size
set obs 10000
gen income = rnormal(50000, 10000)
gen age = rnormal(40, 10)
gen marriage = rbinomial(1, 0.6)
gen education = rnormal(13, 2)
gen p_treat = .
replace p_treat = 0.4 if clust_id == 2
gen treat = rbinomial(1, p_treat)
by clust_id: gen noise = rnormal(0, 5)
by clust_id: gen Y
