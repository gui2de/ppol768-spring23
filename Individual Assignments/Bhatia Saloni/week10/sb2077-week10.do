*Week10 
*Saloni Bhatia 


*Part 1: Calculating required sample sizes and minimum detectable effects

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

capture program drop manualscav
program define manualscav, rclass //defining a program 
	syntax, samplesize(integer)
	clear 

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

set obs 4
gen strata = _n  
expand `samplesize'

*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.
	
	gen cov_xy = rnormal()
	gen cov_x = rnormal()
	gen cov_y = rnormal()
	
gen random = rnormal() + cov_x + cov_xy + strata 

gen treatment = 0 
summ treatment, detail 
replace treatment = 1 if random>`r(p50)'

gen y = runiform(50,70) + 3*treatment + 20*rnormal() + 10*cov_y - 15*cov_xy + strata

*Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.

reg y treatment i.strata cov_xy

mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar pval = a[4,1]

end

clear
tempfile combined 
save `combined', replace emptyok
	tempfile sims

    forvalues i= 100(50)600 {
	local samplesize = `i'

	simulate beta=r(beta) pval=r(pval) N=r(N), reps(500) saving(`sims', replace): manualscav, samplesize(`samplesize')
	

	use `sims', clear
	gen samplesize=`samplesize' * 4
	append using `combined'
	save `combined', replace

	}

use `combined'

save "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week10/output", replace

*Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect"

gen sig = 0 
replace sig = 1 if pval<0.05
mean sig, over(N)

*Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

power twomeans 500 550, sd(100)  power(0.8)

*Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

power twomeans 0 0.1(0.05)0.8, table

collapse (mean) sig, by(N)

gen y=0.8

twoway (scatter sig N) (line y N)

graph export outputgraph.png

*Part 1 has been done using my code from Week09, taking reference for power calaculations from a fellow classmate's work 

/*
Part 2: Calculating power for DGPs with clustered random errors

1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.
3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.
4. Calculate "exact" 95% confidence interval estimates using the betas you can use the collapse or mean command for this, or use something like lpolyci to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.
5. Create another DGP in which the random error terms are only determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?
6. Can you get the "analytical" confidence intervals to be correct using the vce() option in regress?
7. Fully describe your results in your README.md file, including figures and tables as appropriate.
*/

capture program drop manualscav10
program define manualscav10, rclass //defining a program 
	syntax, samplesize(integer)
	clear 
	
set obs 4
gen cluster = _n  

gen cov_xy = rnormal()
	gen cov_x = rnormal()
	gen cov_y = rnormal()
	
gen random = rnormal() + cov_x + cov_xy

gen treatment =0
replace treatment=1 if _n>=51

expand 10 
sort cluster 

gen y = runiform(50,70) + 2.5*treatment + 10*cov_y - 15*cov_xy + random

reg y treatment cov_xy

matrix a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]

end
