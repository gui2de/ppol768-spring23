********************************************************************************
* PPOL 768
* Week 9
* Keegan Brown
********************************************************************************
clear all 
cd "/Users/keeganbrown/Desktop/Georgetown/RD/Assignments (Non-Repository) /Brown Keegan/week-10"


********************************************************************************
** Part 1: Calculating required sample sizes and minimum detectable effects
********************************************************************************


/*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.*/

/*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.*/

/*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.
*/

tempfile part1 
capture program first drop 
set level 95, permanently 
program define first, rclass 
	syntax anything 

clear 
	set obs 3
	gen school = _n
	set seed 16390
	expand `anything'
	gen student_id = _n 
	gen urban = school 
	replace urban = 1 if school == 1
	replace urban = 0 if school != 1 
	gen student_athlete = 1 if (student_id < .1*_N) & urban == 1 // this is confounder 
	replace student_athlete = 0 if student_athlete != 1
	gen bmi = rnormal(25,7) -5*student_athlete 
	gen scholarship = runiform(0,1)
				


	gen treatment_status = (rnormal()+(1/school))>0 // this impacts treatment but not outcome
	gen gym_access = runiform(0,1) if treatment_status == 1 // this will effect outcome but not treatment 
	replace gym_access = 0 if treatment_status == 0

	gen activity = -1*school + 1.25*treatment_status + 2*urban + 5*student_athlete + 3*gym_access + -.5*bmi^2+ .1*scholarship + rnormal(0,1) 

	reg activity treatment_status
	mat results = r(table)
		return scalar p_base= _b[treatment_status]
		return scalar t_value = _b[treatment_status]/_se[treatment_status]									
		return scalar df=(2*((e(N)/2)-1))	
		return scalar mde1 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))
		return scalar N1=e(N)
	
	reg activity treatment_status student_athlete
	mat results = r(table)
		return scalar p_confounder=_b[treatment_status]
		return scalar mde2 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status student_athlete gym_access
	mat results = r(table)
		return scalar p_cc=_b[treatment_status]
		return scalar min = (_se[treatment_status] * _se[treatment_status]) / (((1.25 / 2.8) ^ 2) / 0.95 / 0.05)
		return scalar mde3 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status gym_access school urban 
	mat results = r(table)
		return scalar p_covar=_b[treatment_status]
		return scalar mde4 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status student_athlete gym_access urban bmi school 
	mat results = r(table)
		return scalar p_sink= _b[treatment_status]
		return scalar mde5 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	end 
	
save `part1', replace emptyok

/*4. Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.*/

tempfile combined
save `combined', replace emptyok
	tempfile sims

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error "ss"
	simulate N1 = r(N1) model_1=r(p_base) mde1 = r(mde1) /// 
		model_2=r(p_confounder) mde2 = r(mde2) ///
         model_3=r(p_cc) mde3 = r(mde3) min = r(min) model_4=r(p_cc) mde4 = r(mde4) ///
         model_5=r(p_sink) mde5 = r(mde5), saving(`sims', replace) ///
         reps(150): first `ss' 
		 
		 use `sims', clear 
		 
		 append using `combined'
			save `combined', replace 
	}
  

graph twoway line mde1 mde2 mde3 mde4 mde5 N

graph export "outputs/part1_line.png", replace
  
/*5. Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.*/




/*6. Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.*/

clear all 

tempfile part1_2 
capture program one_2 drop 
program define one_2, rclass 
	syntax anything 

clear 
	set obs 3
	gen school = _n
	set seed 16390
	expand 500
	gen student_id = _n 
	gen urban = school 
	replace urban = 1 if school == 1
	replace urban = 0 if school != 1 
	gen student_athlete = 1 if (student_id < .1*_N) & urban == 1 // this is confounder 
	replace student_athlete = 0 if student_athlete != 1
	gen bmi = rnormal(25,7) -5*student_athlete 
	gen scholarship = runiform(0,1)
				

	gen treatment_status = (rnormal()+(1/school))>0 // this impacts treatment but not outcome
	gen gym_access = runiform(0,1) if treatment_status == 1 // this will effect outcome but not treatment 
	replace gym_access = 0 if treatment_status == 0

	gen activity = -1*school + `anything'*treatment_status + 2*urban + 5*student_athlete + 3*gym_access + -.5*bmi^2+ .1*scholarship + rnormal(0,1) 

	reg activity treatment_status
	mat results = r(table)
		return scalar p_base= _b[treatment_status]
		return scalar t_value = _b[treatment_status]/_se[treatment_status]									
		return scalar df=(2*((e(N)/2)-1))	
		return scalar mde1 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))
		return scalar N1=e(N)
	
	reg activity treatment_status student_athlete
	mat results = r(table)
		return scalar p_confounder=_b[treatment_status]
		return scalar mde2 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status student_athlete gym_access
	mat results = r(table)
		return scalar p_cc=_b[treatment_status]
		return scalar min = (_se[treatment_status] * _se[treatment_status]) / (((1.25 / 2.8) ^ 2) / 0.95 / 0.05)
		return scalar mde3 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status gym_access school urban 
	mat results = r(table)
		return scalar p_covar=_b[treatment_status]
		return scalar mde4 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	reg activity treatment_status student_athlete gym_access urban bmi school 
	mat results = r(table)
		return scalar p_sink= _b[treatment_status]
		return scalar mde5 = 2.8 * (sqrt((_se[treatment_status]*_se[treatment_status] / e(N)) * 0.95 * 0.05))

	end 
	
save `part1_2', replace emptyok

/*4. Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.*/

tempfile combined1_2
save `combined1_2', replace emptyok
tempfile sims2

    forvalues j=1/4{
		display as error `j'
	local treatment_effect = 2*rnormal(0,1)^`j'
	simulate N1 = r(N1) model_1=r(p_base) mde1 = r(mde1) /// 
		model_2=r(p_confounder) mde2 = r(mde2) ///
         model_3=r(p_cc) mde3 = r(mde3) min = r(min) model_4=r(p_cc) mde4 = r(mde4) ///
         model_5=r(p_sink) mde5 = r(mde5), saving(`sims2', replace) ///
         reps(150): one_2 `treatment_effect'
		 
		 
		 use `sims2', clear 
		 
		 append using `combined1_2'
			save `combined1_2', replace 
	}


/*7. Fully describe your results in your `README.md` file, including figures and tables as appropriate.*/

graph bar mde1 mde2 mde3 mde4 mde5


graph export "outputs/part1_bar.png", replace

********************************************************************************
**Part 2: Calculating power for DGPs with clustered random errors
********************************************************************************

/*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.*/ 

/*2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.*/


clear all 


tempfile part2

capture program second drop 
program define second, rclass 
	syntax anything 
clear 

set obs 3
	gen school = _n
	set seed 16390
	expand `anything'
	gen student_id = _n 
	gen urban = school 
	replace urban = 1 if school == 1
	replace urban = 0 if school != 1 
	gen student_athlete = 1 if (student_id < .1*_N) & urban == 1 // this is confounder 
	replace student_athlete = 0 if student_athlete != 1
	gen bmi = rnormal(25,7) -5*student_athlete 
	gen scholarship = runiform(0,1)
				


	gen treatment_status = (rnormal()+(1/school))>0 // this impacts treatment but not outcome
	gen gym_access = runiform(0,1) if treatment_status == 1 // this will effect outcome but not treatment 
	replace gym_access = 0 if treatment_status == 0
	gen school_effect = school*3

	gen activity = -1*school + 1.25*treatment_status + 2*urban + 5*student_athlete + 3*gym_access + -.5*bmi^2+ .1*scholarship + rnormal(0,1) 
	
	reg activity treatment_status gym_access urban bmi school_effect
	mat results = r(table)
		return scalar N1 = e(N)
		return scalar p_sink= _b[treatment_status]
		return scalar p_sink_se = _se[treatment_status]
		
	end 
	
save `part2', replace emptyok

// using the above but extending to strata groups and continuos covariates and 
// 



tempfile combined2
save `combined2', replace emptyok
	tempfile sims3

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error "ss"
	simulate N1 = r(N1) model_1=r(p_sink) SE = r(p_sink_se), ///
	saving(`sims3', replace) ///
	reps(150): second `ss' 
		 use `sims3', clear 
		 
		 append using `combined2'
			save `combined2', replace 
	}
  
  


///
 

gen ll = model_1-1.96*SE
gen ul = model_1+1.96*SE
gen exact = 1.25 

append using `combined2'
save `combined2', replace

/*3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.*/

sort N1 exact
bysort N1: gen repeat = _n



foreach s in 30 300 3000 30000 {
graph twoway rcap ul ll repeat if N1 == `s' ///
	|| rcap ul ll repeat if N1 == `s' & exact == 1, ///
	ytitle("95% condifence interval") ///
	xtitle("Simulation repeat") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("Sample size = `s'")
	

}

/*4. Calculate "exact" 95% confidence interval estimates using the betas you can use the `collapse` or `mean` command for this, or use something like `lpolyci` to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.*/

graph export "outputs/part2_A.png", replace

/*5. Create another DGP in which the random error terms are _only_ determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?*/
clear 
tempfile part2x

capture program second_1 drop 
program define second_1, rclass 
	syntax anything 
clear 

set obs 3
	gen school = _n
	set seed 16390
	expand `anything'
	gen student_id = _n 
	gen urban = school 
	replace urban = 1 if school == 1
	replace urban = 0 if school != 1 
	gen student_athlete = 1 if (student_id < .1*_N) & urban == 1 // this is confounder 
	replace student_athlete = 0 if student_athlete != 1
	gen bmi = 25
	gen scholarship = 1
				


	gen treatment_status = (rnormal()+(1/school))>0 // this impacts treatment but not outcome
	gen gym_access = 1 if treatment_status == 1 // this will effect outcome but not treatment 
	replace gym_access = 0 if treatment_status == 0
	gen school_effect = school*3*rnormal()

	gen activity = -1*school + 1.25*treatment_status + 2*urban + 5*student_athlete + 3*gym_access + -.5*bmi^2+
	
	reg activity treatment_status gym_access urban bmi school_effect
	mat results = r(table)
		return scalar N1 = e(N)
		return scalar p_sink= _b[treatment_status]
		return scalar p_sink_se = _se[treatment_status]
		
	end 
	
save `part2x', replace emptyok

sort N1 exact
bysort N1: gen repeat = _n



foreach s in 30 300 3000 30000 {
graph twoway rcap ul ll repeat if N1 == `s' ///
	|| rcap ul ll repeat if N1 == `s' & exact == 1, ///
	ytitle("95% condifence interval") ///
	xtitle("Simulation repeat") /// 
	legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
	title("Sample size = `s'")
	

}

graph export "outputs/part2_A.png", replace

// using the above but extending to strata groups and continuos covariates and 
// 



tempfile combined2_2
save `combined2_2', replace emptyok
	tempfile sims4

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error "ss"
	simulate N1 = r(N1) model_1=r(p_sink) SE = r(p_sink_se), ///
	saving(`sims4', replace) ///
	reps(150): second_1 `ss' 
		 use `sims4', clear 
		 
		 append using `combined2_2'
			save `combined2_2', replace 
	}
  

graph export "outputs/part2_B.png", replace

/*6. Can you get the "analytical" confidence intervals to be correct using the `vce()` option in `regress`?*/

/*7. Fully describe your results in your `README.md` file, including figures and tables as appropriate.*/
