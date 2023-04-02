***Part 1: De-biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

cd "D:\2021-2023, Georgetown University\2023 - Spring\Research Design & Implementation\ScottsRepo\ppol768-spring23\Individual Assignments\Brown Scott\week-09"

set seed 20230327
clear

set obs 1000

gen patient_id = _n
gen treatment = rbinomial(1, 0.5) // random assignment into treatment with paxlovid
gen age = rnormal(60, 5)
gen male = rbinomial(1, 0.5) // random assignment for male
gen health = rnormal(50, 12) // health level w/ a mean of 50

// Outcomes
gen life_expectancy = 82 - 0.5*treatment + 0.5*age + 0.25*male + 0.10*age*prexisting_risk_level + rnormal(0, 5)


*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?



*Fully describe your results in your README.md file, including figures and tables as appropriate.


***Part 2: Biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.


*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.


*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)


*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)


*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?


*Fully describe your results in your README.md file, including figures and tables as appropriate.