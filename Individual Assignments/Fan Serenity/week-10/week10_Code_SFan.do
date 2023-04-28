*W10 Assignment: Power Calculations 

/*
*Part 1: Calculating required sample sizes and minimum detectable effects

Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.

Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.

Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

Fully describe your results in your README.md file, including figures and tables as appropriate.
*/ 

*_________________________________________________	
*Create program: load the data from above into the program  
capture program drop normal_reg_sanitation
program define normal_reg_sanitation, rclass 
	syntax, num_districts(real) 
	
	*District-level effects (i) 
		*Treatment happens at this level (assuming government implements mechanized de-sludging by randomizing at the district level)
	clear
	set obs `num_districts'
	
	* Let's assume for simplicity this is the # of districts within Uttar Pradesh (UP)  (actual number 75)
	gen district = _n // Assign district ID 
	generate u_i = rnormal(500,500) // District-level error effects 

	*Village/Municipality-level effects (j) 
	expand 10 //+ int((5)*runiform()) 
	 // Assume mean of 15 villages/municipalities per district 
	bysort district: generate village = _n
	generate u_ij = rnormal(1000,1000)

	*Household-level effects (k) 
	expand 10 //+ int((5)*runiform()) 
	 // Assume mean of 15 manual-scavenging households per village/municipality 

	bysort district village: generate hh = _n // generate household ID
	generate e_ijk = rnormal(2000,2000) // Generate household-level effects 

	*generate income_pres = rnormal(10000, 2000)

	*Confounders: affect both the outcome and the likelihood of receiving treatment
	gen scav_years = runiform(1, 30) // Years spent working as manual scavengers: assume that individuals who have worked as manual scavengers for shorter amounts of time are more likely to change into other, higher-paid fields when provided training + mentorship program

	*Covariate: Affects outcome but not treatment 
	gen transit_time = rnormal(60,10) // Time (minutes) to nearest urban centre, ie. proxy for access to 'good' job opportunities: individuals living closer to urban centres should have better job outcomes subject to attending program  
	gen educ = runiform(0,10) // Years of education  

	*Affects treatment but not outcome 
	gen female = round(runiform(0,1), 1)

	*Generate Treatment: Randomize by district 
	generate treatment = 0 
	  gen v_elig = rnormal() // Village-eligibility randomizer
	    bysort village: egen v_rmean = mean(v_elig)
		gen v_elig_ind = v_rmean > 0 
	  gen gen_elig = rnormal() // Randomizing gender 
		gen gen_elig_ind = female > gen_elig //Men have 50% chance (chance that 0 is greater than normal dist); women have 84% chance (chance that 1 is greater than normal dist)  
	  
	*Check the distribution above, to confirm women have greater chance of getting treatment 
	bysort female: sum gen_elig_ind
	  
	replace treatment = 1 if v_elig_ind==1 & gen_elig_ind==1
	*replace treatment = 1 if district<=5 & scav_years<=10 & female==1 
	sum treatment // Overall proportion assigned treatment 

	*DGP (DATA GENERATING PROCESS) 
	gen income = 10000 + rnormal(500, 100) * treatment - 30*scav_years - 40*transit_time + 300*educ + u_i + u_ij + e_ijk  

*Reg model 1: (base) Y and treatment 
	reg income treatment 		
	mat results1 = r(table) 
	return scalar beta1 = results1[1,1] 
	*return scalar SEM1 = results1[2,1] 
	return scalar p1 = results1[4,1]
	*return scalar ci_lower1 = results1[5,1]
	*return scalar ci_upper1 = results1[6,1]		
	
	*This is the same for all of the regressions 
	return scalar subsample_size = e(N)	
		
*Reg model 2: Add village indicators
	reg income treatment i.village 
	mat results2 = r(table) 
	*return scalar subsample_size2 = e(N)
	return scalar beta2 = results2[1,1] 
	*return scalar SEM2 = results2[2,1] 
	return scalar p2 = results2[4,1]
	*return scalar ci_lower2 = results2[5,1]
	*return scalar ci_upper2 = results2[6,1]
	
*Reg model 3: Add confounder, years worked in scavenging 
	reg income treatment i.village scav_years
	mat results3 = r(table) 
	*return scalar subsample_size4 = e(N)
	return scalar beta3 = results3[1,1] 
	*return scalar SEM3 = results3[2,1] 
	return scalar p3 = results3[4,1]
	*return scalar ci_lower4 = results4[5,1]
	*return scalar ci_upper4 = results4[6,1]
	
*Reg model 4: Add covariate - transit time 
	reg income treatment i.village scav_years transit_time 
	mat results4 = r(table) 
	*return scalar subsample_size5 = e(N)
	return scalar beta4 = results4[1,1] 
	*return scalar SEM4 = results4[2,1] 
	return scalar p4 = results4[4,1]
	*return scalar ci_lower5 = results5[5,1]
	*return scalar ci_upper5 = results5[6,1]
	
*Reg model 5: Add covariate - years of education 
	reg income treatment i.village scav_years transit_time educ 
	mat results5 = r(table) 
	*return scalar subsample_size5 = e(N)
	return scalar beta5 = results5[1,1] 
	*return scalar SEM5 = results5[2,1] 
	return scalar p5 = results5[4,1]
	*return scalar ci_lower5 = results5[5,1]
	*return scalar ci_upper5 = results5[6,1]
	
	
/* 
	*Store matrix results 
		*Note: Verified that, as this is a multivariate regression, the scalars below will be extracted from the 'treatment' regression table (as opposed to the table for one of the other independent variables)
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar SEM = results[2,1] 
	return scalar pval = results[4,1]
	return scalar ci_lower = results[5,1]
	return scalar ci_upper = results[6,1]
*/ 


end

*normal_reg, samplesize(100)  
*display r(beta)

*mat list results


*Simulate_____________

clear
tempfile combined 
save `combined', replace emptyok
	
forvalues i=0.5(0.5)6 {
	*N = 2, 4, 8, 16, ..., 1,048,576

		local num_districts = round(2^(`i'))
		tempfile sims
		simulate N=r(subsample_size) beta_coeff1=r(beta1) pval1=r(p1) beta_coeff2=r(beta2) pval2=r(p2) beta_coeff3=r(beta3) pval3=r(p3) beta_coeff4=r(beta4) pval4=r(p4) beta_coeff5=r(beta5) pval5=r(p5), reps(500)	saving(`sims', replace): normal_reg_sanitation, num_districts(`num_districts') 
		
		*gen population_size = `num_districts'
		
		use `sims', clear 
		
		gen runID = `i'  
		order runID, first
		
		append using `combined'
		save `combined', replace
		
}
/* 
forvalues j=1/5 {
	histogram, beta_coeff, by(N) 
} 
*/ 


*Load back in all the simulation regression data 
use `combined', clear
sort N

*drop if beta_coeff1==0 // Drop runs in which all districts were randomly assigned to untreated, i.e. controls

bysort runID: egen N_avg = mean(N)
order N_avg, after(N)
replace N_avg = round(N_avg)

save "stats_power_part1_v1.dta", replace


*Generate power  

forvalues j = 1/5 {
	gen sig`j'=0 
	replace sig`j'=1 if pval`j'<0.05 
	sum sig`j'
	mean sig`j', over(N_avg) 
	
}

save "stats_power_part1_v2.dta", replace








*_________________________________________________

*Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

capture program drop normal_reg_sanitation
program define normal_reg_sanitation, rclass 
	syntax, num_districts(real) 
	
	*District-level effects (i) 
		*Treatment happens at this level (assuming government implements mechanized de-sludging by randomizing at the district level)
	clear
	set obs `num_districts'
	
	* Let's assume for simplicity this is the # of districts within Uttar Pradesh (UP)  (actual number 75)
	gen district = _n // Assign district ID 
	generate u_i = rnormal(500,500) // District-level error effects 

	*Village/Municipality-level effects (j) 
	expand 10 //+ int((5)*runiform()) 
	 // Assume mean of 15 villages/municipalities per district 
	bysort district: generate village = _n
	generate u_ij = rnormal(1000,1000)

	*Household-level effects (k) 
	expand 10 //+ int((5)*runiform()) 
	 // Assume mean of 15 manual-scavenging households per village/municipality 

	bysort district village: generate hh = _n // generate household ID
	generate e_ijk = rnormal(2000,2000) // Generate household-level effects 

	*generate income_pres = rnormal(10000, 2000)

	*Confounders: affect both the outcome and the likelihood of receiving treatment
	gen scav_years = runiform(1, 30) // Years spent working as manual scavengers: assume that individuals who have worked as manual scavengers for shorter amounts of time are more likely to change into other, higher-paid fields when provided training + mentorship program

	*Covariate: Affects outcome but not treatment 
	gen transit_time = rnormal(60,10) // Time (minutes) to nearest urban centre, ie. proxy for access to 'good' job opportunities: individuals living closer to urban centres should have better job outcomes subject to attending program  
	gen educ = runiform(0,10) // Years of education  

	*Affects treatment but not outcome 
	gen female = round(runiform(0,1), 1)

	*Generate Treatment: Randomize by district 
	generate treatment = 0 
	  gen v_elig = rnormal() // Village-eligibility randomizer
	    bysort village: egen v_rmean = mean(v_elig)
		gen v_elig_ind = v_rmean > 0 
	  gen gen_elig = rnormal() // Randomizing gender 
		gen gen_elig_ind = female > gen_elig //Men have 50% chance (chance that 0 is greater than normal dist); women have 84% chance (chance that 1 is greater than normal dist)  
	  
	*Check the distribution above, to confirm women have greater chance of getting treatment 
	bysort female: sum gen_elig_ind
	  
	replace treatment = 1 if v_elig_ind==1 & gen_elig_ind==1
	*replace treatment = 1 if district<=5 & scav_years<=10 & female==1 
	sum treatment // Overall proportion assigned treatment 

	*DGP (DATA GENERATING PROCESS) 
	gen income = 10000 + treat_size * rnormal(500, 100) * treatment - 30*scav_years - 40*transit_time + 300*educ + u_i + u_ij + e_ijk  

*Reg model 1: (base) Y and treatment 
	reg income treatment 		
	mat results1 = r(table) 
	return scalar beta1 = results1[1,1] 
	*return scalar SEM1 = results1[2,1] 
	return scalar p1 = results1[4,1]
	*return scalar ci_lower1 = results1[5,1]
	*return scalar ci_upper1 = results1[6,1]		
	
	*This is the same for all of the regressions 
	return scalar subsample_size = e(N)	
		
*Reg model 2: Add village indicators
	reg income treatment i.village 
	mat results2 = r(table) 
	*return scalar subsample_size2 = e(N)
	return scalar beta2 = results2[1,1] 
	*return scalar SEM2 = results2[2,1] 
	return scalar p2 = results2[4,1]
	*return scalar ci_lower2 = results2[5,1]
	*return scalar ci_upper2 = results2[6,1]
	
*Reg model 3: Add confounder, years worked in scavenging 
	reg income treatment i.village scav_years
	mat results3 = r(table) 
	*return scalar subsample_size4 = e(N)
	return scalar beta3 = results3[1,1] 
	*return scalar SEM3 = results3[2,1] 
	return scalar p3 = results3[4,1]
	*return scalar ci_lower4 = results4[5,1]
	*return scalar ci_upper4 = results4[6,1]
	
*Reg model 4: Add covariate - transit time 
	reg income treatment i.village scav_years transit_time 
	mat results4 = r(table) 
	*return scalar subsample_size5 = e(N)
	return scalar beta4 = results4[1,1] 
	*return scalar SEM4 = results4[2,1] 
	return scalar p4 = results4[4,1]
	*return scalar ci_lower5 = results5[5,1]
	*return scalar ci_upper5 = results5[6,1]
	
*Reg model 5: Add covariate - years of education 
	reg income treatment i.village scav_years transit_time educ 
	mat results5 = r(table) 
	*return scalar subsample_size5 = e(N)
	return scalar beta5 = results5[1,1] 
	*return scalar SEM5 = results5[2,1] 
	return scalar p5 = results5[4,1]
	*return scalar ci_lower5 = results5[5,1]
	*return scalar ci_upper5 = results5[6,1]
	
	
/* 
	*Store matrix results 
		*Note: Verified that, as this is a multivariate regression, the scalars below will be extracted from the 'treatment' regression table (as opposed to the table for one of the other independent variables)
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar SEM = results[2,1] 
	return scalar pval = results[4,1]
	return scalar ci_lower = results[5,1]
	return scalar ci_upper = results[6,1]
*/ 


end

*normal_reg, samplesize(100)  
*display r(beta)

*mat list results


*Simulate_____________

clear
tempfile combined 
save `combined', replace emptyok
	
	*STRATEGY: Loop over different treatment values; do power calculations, see when reach 80% power 
	
forvalues i= {
	*N = 2, 4, 8, 16, ..., 1,048,576

		local num_districts = 8 // Corresponds to N=1600
		tempfile sims
		simulate N=1600 beta_coeff1=r(beta1) pval1=r(p1) beta_coeff2=r(beta2) pval2=r(p2) beta_coeff3=r(beta3) pval3=r(p3) beta_coeff4=r(beta4) pval4=r(p4) beta_coeff5=r(beta5) pval5=r(p5), reps(500)	saving(`sims', replace): normal_reg_sanitation, num_districts(`num_districts') 
		
		*gen population_size = `num_districts'
		
		use `sims', clear 
		
		gen runID = `i'  
		order runID, first
		
		append using `combined'
		save `combined', replace
		
}
/* 
forvalues j=1/5 {
	histogram, beta_coeff, by(N) 
} 
*/ 


*Load back in all the simulation regression data 
use `combined', clear
sort N
/*
*drop if beta_coeff1==0 // Drop runs in which all districts were randomly assigned to untreated, i.e. controls

bysort runID: egen N_avg = mean(N)
order N_avg, after(N)
replace N_avg = round(N_avg)
*/ 
save "stats_MDE_part1_v1.dta", replace


*Generate power  

forvalues j = 1/5 {
	gen sig`j'=0 
	replace sig`j'=1 if pval`j'<0.05 
	sum sig`j'
	mean sig`j', over(N_avg) 
	
}

save "stats_power_part1_v2.dta", replace


























/* 
*Analytical Power Calculations 
power twomeans 500, n1(50) n2(50) power(0.8) sd(100)
*Format: power twomeans [mean] [sample size of 1st pop.] [sample size of 2nd pop.] power standard deviation 
	*Therefore we can see a MDE of an increase in 56.6 points 
	*Power of 0.8 (i.e. 80%) is a standard in the scientific community 
	
power twomeans 500 550, sd(100) 
*Format: power twomeans treatment-mean control-mean standard deviation 


*E.g. Standard normal distribution 
power twomeans 500 510, sd(100)
power twomeans 0 0.05, sd(1)  
	*We get same same results: a difference of 50, when the std is 100, is thus a difference of 0.5 points in std units 
	*In education, a treatment that increases scores by 0.10/0.15 standard deviations would be considered average. Hence, this calculation indicates thata difference of 0.10 std's can be detected with a sample size of N = 3142 in total, i.e. 1/2 that, N = 1571 people per group (1571 for treatment arm, and 1571 for control arm) . 
	 *Quadratic pattern: Cutting the effect size / difference in half requires a four-fold increase in N 

*We want HIGH POWER and LOW MDE 



*Cluster RCT's 
    *Go for more clusters and less students for each, rather than fewer clusters with more students in each 


*/ 



















/*
*Part 2: Calculating power for DGPs with clustered random errors

Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.

Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.

Calculate "exact" 95% confidence interval estimates using the betas you can use the collapse or mean command for this, or use something like lpolyci to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.

Create another DGP in which the random error terms are only determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?

Can you get the "analytical" confidence intervals to be correct using the vce() option in regress?

Fully describe your results in your README.md file, including figures and tables as appropriate.
*/ 