*Serenity Fan 
*Last Updated: ______ 

*_________________________________________________
*Part 1: De-biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*Plan 
	*generate X 
	*geneate Y = district
	*generate treatment (start with binary) = district 
	
clear 
set obs 5 
gen district = _n 
expand 100 

*Generate 3 covariates 
gen covar1 = rnormal() 
gen covar2 = rnormal() 
gen covar3 = rnormal() 

reg y treat 



*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.



*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)





*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

reg Y treatment 
reg Y treatment i.district 
reg Y treatment i.district confounder
reg Y treatment i.district confounder covar2
reg Y treatment i.district confounder covar3
reg Y treatment i.district confounder covar2 covar3 

*i.district --> Converts integer values to categorical variables 
* i.e. If district can take on 4 values (1,2,3,4), then will create 4 dummy variables, i.e. district1 is 1 for district 1 and 0 otherwise, 
*    district2 is 1 for district 2 and 0 otherwise, 
*    ... 
*    and district4 is not used due to multi-collinearity 


*Fully describe your results in your README.md file, including figures and tables as appropriate.





*_________________________________________________
*Part 2: Biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)

*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

*Fully describe your results in your README.md file, including figures and tables as appropriate.