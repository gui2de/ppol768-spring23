*Part 1: De-biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

*Fully describe your results in your README.md file, including figures and tables as appropriate.

capture program drop manualscav
program define manualscav, rclass //defining a program 
	syntax, samplesize(integer) 
	clear 

*generating strata groups that affect the outcome Y and are of different sizes, thr pobability that individuals receive treatment varies across stratas 
set obs 4
gen strata = _n  
expand `samplesize'

*generating 3 continuous covariates 1) affects both the outcome and the likelihood of receiving treatment (a "confounder") 2) affects the outcome but not the treatment 3) affects the treatment but not the outcome.
gen cov_xy = rnormal()
gen cov_x = rnormal()
gen cov_y = rnormal()

*generating random noise 
gen random = rnormal() + cov_x + cov_xy + strata

*generating treatment - 50th percentile 
gen treatment=0
summ treatment, detail
replace treatment=1 if random>`r(p50)'

*generating y 
gen y = runiform(50,70)+ 3*treatment + 20*rnormal() + 10*cov_y - 15*cov_xy + strata

*reg1 
reg y treatment
return scalar beta_m1 = _b[treatment]
return scalar N = `e(N)'

*reg2
reg y treatment i.strata
return scalar beta_m2 = _b[treatment]


*reg3
reg y treatment cov_xy
return scalar beta_m3 = _b[treatment]


*reg4
reg y treatment i.strata cov_xy
return scalar beta_m4 = _b[treatment]

*reg5
reg y treatment cov_xy cov_x cov_y
return scalar beta_m5 = _b[treatment]

*reg6
reg y treatment i.strata cov_x cov_y
return scalar beta_m6 = _b[treatment]

*reg7
reg y treatment i.strata cov_xy cov_x cov_y
return scalar beta_m7 = _b[treatment]

end


clear
tempfile combined 
save `combined', replace emptyok
	tempfile sims

    forvalues i=1/4{
		display as error `9'
	local samplesize = 10^`i'

	simulate N=r(N) b1=r(beta_m1) b2=r(beta_m2) b3=r(beta_m3) b4=r(beta_m4) b5=r(beta_m5) b6=r(beta_m6) b7=r(beta_m7), reps(500) saving(`sims', replace): manualscav, samplesize(`samplesize')
	

	use `sims', clear

	append using `combined'
	save `combined', replace

	}

*Graph 
use `combined', clear 

graph box b1 b2 b3 b4 b5 b6 b7, over(N) yline(1.5) noout

graph export beta.png, replace 

*Part 2: Biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

*Fully describe your results in your README.md file, including figures and tables as appropriate.

capture program drop manualscav
program define manualscav, rclass
syntax, samplesize(integer) 
clear

set obs 4
gen strata = _n  

expand `samplesize'

gen cov_xy = rnormal()
gen cov_x = rnormal()
gen cov_y = rnormal()

gen random = rnormal() + cov_x + cov_xy + strata

gen treatment=0
summ treatment, detail
replace treatment=1 if random>`r(p50)'

*generating y 
gen y = runiform(50,70)+ 3*treatment + 20*rnormal() + 10*cov_y - 15*cov_xy + strata


*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
gen channel = (2.8)*treatment + runiform()


*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
gen collider = (0.8)*treat + (1.4)*y + rnormal()


*reg1 
reg y treatment
return scalar beta_m1 = _b[treatment]
return scalar N = `e(N)'

*reg2
reg y treatment i.strata
return scalar beta_m2 = _b[treatment]

*reg3
reg y treatment i.strata collider 
return scalar beta_m3 = _b[treatment]

*reg4
reg y treatment i.strata channel 
return scalar beta_m4 = _b[treatment]

*reg5
reg y treatment i.strata channel collider 
return scalar beta_m5 = _b[treatment]

*reg6
reg y treatment cov_xy
return scalar beta_m6 = _b[treatment]

*reg7
reg y treatment i.strata cov_xy
return scalar beta_m7 = _b[treatment]

*reg8
reg y treatment cov_xy cov_x cov_y
return scalar beta_m8 = _b[treatment]

*reg9
reg y treatment i.strata cov_x cov_y
return scalar beta_m9 = _b[treatment]

*reg10
reg y treatment i.strata cov_xy cov_x cov_y
return scalar beta_m10 = _b[treatment]

end

clear
tempfile combined 
save `combined', replace emptyok
	tempfile sims

    forvalues i=1/4{
	local samplesize = 10^`i'
	simulate N=r(N) b1=r(beta_m1) b2=r(beta_m2) b3=r(beta_m3) b4=r(beta_m4) b5=r(beta_m5) b6=r(beta_m6) b7=r(beta_m7) b8=r(beta_m8) b9=r(beta_m9) b10=r(beta_m10), reps(500) saving(`sims', replace): manualscav, samplesize(`samplesize')

	use `sims', clear

	append using `combined'
	save `combined', replace

	}

*Graph 
use `combined', clear 

graph box b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 , over(N) yline(1.5) noout

graph export beta_part2.png, replace 






