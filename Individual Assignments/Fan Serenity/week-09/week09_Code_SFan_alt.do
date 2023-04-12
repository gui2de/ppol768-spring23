*Serenity Fan (kaf121)
*Last Updated: April 11th, 2023 
*Week 9 Assignment Code 

*RE-SUBMISSION

*_________________________________________________
*MULTI-LEVEL SIMULATION: MANUAL SCAVENGING INTERVENTION (TRAINING & MENTORSHIP IN THE FACE OF SANITATION AUTOMATION)

*Define Model: Variables and units 

* Y = Income in 1 year in future (i.e. post program) 
* X0 = Income today (average set at 10,000 INR/month , as per https://swachhindia.ndtv.com/after-skill-training-manual-scavengers-return-to-cleaning-sewers-30490/ )
* X1 = Treatment: Number of days spent attending employment training, mentorship, and services  
* X2 = Years of education (continuous covariate #1)
* X3 = Years to date spent working in manual scavenging field (continuous covariate #2)
* X4 = Door-to-door transit time to city centre (continuous covariate #2)
* X5 = Gender (indicator variable)

* i = District level (75 districts in UP)
* j = Village-level (panchiyat) or municipality 
* k = Household-level 


*_________________________________________________
*Part 1: De-biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*This DGP should include strata groups (e.g. race) and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups (e.g. race). You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

*Fully describe your results in your README.md file, including figures and tables as appropriate.



*_________________________________________________	
*Create program: load the data from above into the program  
capture program drop normal_reg_sanitation
program define normal_reg_sanitation, rclass 
	syntax, num_districts(integer) 
	
	*District-level effects (i) 
		*Treatment happens at this level (assuming government implements mechanized de-sludging by randomizing at the district level)
	clear
	set obs `num_districts'
	
	* Let's assume for simplicity this is the # of districts within Uttar Pradesh (UP)  (actual number 75)
	gen district = _n // Assign district ID 
	generate u_i = rnormal(500,100) // District-level error effects 

	*Village/Municipality-level effects (j) 
	expand 100 + int((50)*runiform()) 
	 // Assume mean of 100 villages/municipalities per district 
	bysort district: generate village = _n
	generate u_ij = rnormal(500,100)

	*Household-level effects (k) 
	expand 100 + int((50)*runiform()) 
	 // Assume mean of 100 manual-scavenging households per village/municipality 

	bysort district village: generate hh = _n // generate household ID
	generate e_ijk = rnormal(1000,500) // Generate household-level effects 

	generate income_pres = rnormal(10000, 2000)

	*Confounders: affect both the outcome and the likelihood of receiving treatment
	gen scav_years = runiform(1, 30) // Years spent working as manual scavengers: assume that individuals who have worked as manual scavengers for shorter amounts of time are more likely to change into other, higher-paid fields when provided training + mentorship program

	*Covariate: Affects outcome but not treatment 
	gen transit_time = rnormal(60,10) // Time (minutes) to nearest urban centre, ie. proxy for access to 'good' job opportunities: individuals living closer to urban centres should have better job outcomes subject to attending program  
	gen educ = runiform(0,10) // Years of education  

	*Affects treatment but not outcome 
	gen female = round(runiform(0,1), 1)

	*Generate Treatment: Apply treatment to the 1st 5 districts (this assumes that the district numbers have already been randomized in our dataset), to female manual scavengers with at most 10 years of experience in the field
	generate treatment = 0 
	replace treatment = 1 if district<=5 & scav_years<=10 & female==1 

	*DGP (DATA GENERATING PROCESS) 
	gen income_future = 10000 + rnormal(10000, 1000) * treatment - 30*scav_years - 40*transit_time + 300*educ + u_i + u_ij + e_ijk  

*Reg model 1: (base) Y and treatment 
	reg income_future treatment 		
	mat results1 = r(table) 
	return scalar beta1 = results1[1,1] 
	return scalar SEM1 = results1[2,1] 
	*return scalar pval1 = results1[4,1]
	*return scalar ci_lower1 = results1[5,1]
	*return scalar ci_upper1 = results1[6,1]		
	
	*This is the same for all of the regressions 
	return scalar subsample_size = e(N)	
		
*Reg model 2: Add district indicators
	reg income_future treatment i.district 
	mat results2 = r(table) 
	*return scalar subsample_size2 = e(N)
	return scalar beta2 = results2[1,1] 
	return scalar SEM2 = results2[2,1] 
	*return scalar pval2 = results2[4,1]
	*return scalar ci_lower2 = results2[5,1]
	*return scalar ci_upper2 = results2[6,1]
	
*Reg model 3: Add present income 
	reg income_future treatment i.district income_pres 
	mat results3 = r(table) 
	*return scalar subsample_size3 = e(N)
	return scalar beta3 = results3[1,1] 
	return scalar SEM3 = results3[2,1] 
	*return scalar pval3 = results3[4,1]
	*return scalar ci_lower3 = results3[5,1]
	*return scalar ci_upper3 = results3[6,1]
	
*Reg model 4: Add confounder, years worked in scavenging 
	reg income_future treatment i.district income_pres scav_years
	mat results4 = r(table) 
	*return scalar subsample_size4 = e(N)
	return scalar beta4 = results4[1,1] 
	return scalar SEM4 = results4[2,1] 
	*return scalar pval4 = results4[4,1]
	*return scalar ci_lower4 = results4[5,1]
	*return scalar ci_upper4 = results4[6,1]
	
*Reg model 5: Add covariates 
	reg income_future treatment i.district income_pres scav_years transit_time educ 
	mat results5 = r(table) 
	*return scalar subsample_size5 = e(N)
	return scalar beta5 = results5[1,1] 
	return scalar SEM5 = results5[2,1] 
	*return scalar pval5 = results5[4,1]
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
	
forvalues i = 1/5 {
	*N = 2, 4, 8, 16, ..., 1,048,576

		local num_districts = 2^`i'
		tempfile sims
		simulate N=r(subsample_size) beta_coeff1=r(beta1) SEM1=r(SEM1) beta_coeff2=r(beta2) SEM2=r(SEM2) beta_coeff3=r(beta3) SEM3=r(SEM3) beta_coeff4=r(beta4) SEM4=r(SEM4) beta_coeff5=r(beta5) SEM5=r(SEM5), reps(500) 	saving(`sims', replace): normal_reg_sanitation, num_districts(`num_districts') 
		
		*gen population_size = `num_districts'
		
		use `sims', clear 
		
		gen ID = `i'  
		order ID, first
		
		append using `combined'
		save `combined', replace
		
}



*Load back in all the simulation regression data 
use `combined', clear
sort N

save "stats_sanitation_alt_v1.dta", replace


 
*SIMULATION END 




*_________________________________________________
*DATA VISUALIZATION START 
clear 
use stats_sanitation_alt_v1.dta

*drop mean_beta mean_SEM mean_pvalues mean_ci_lower mean_ci_upper

*Make graphs 
forvalues r = 1/5 { 
	
*Graph 
sum beta if r==`r' 
*histogram beta_coeff if r==`r', by(N)
histogram beta_coeff, by(N)
graph export "beta_graph_sanitation_alt_`r'.png", replace

*Figures for table 
bysort ID: egen mean_beta = mean(beta)
bysort ID: egen mean_SEM = mean(SEM)
*bysort N r: egen mean_pvalues = mean(pvalues)
*bysort N r: egen mean_ci_lower = mean(ci_lower)
*bysort N r: egen mean_ci_upper = mean(ci_upper)

save "stats_sanitation_alt_v2.dta", replace

*Input graphs into markdown! Save, then make in markdown folder, then insert preliminary observations, for both parts. 

} 

*histo















*_________________________________________________
*Part 2: Biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)

*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

*Fully describe your results in your README.md file, including figures and tables as appropriate.


/*

*Collider DGP 
gen income_future = 10000 + rnormal(10000, 1000) * treatment - 30*scav_years - 40*transit_time + 300*educ + u_i + u_ij + e_ijk  

*Collider is caused by both treatment and outcome (future earnings) variables 
gen mhealth = rnormal(10000, 1000) * treatment + income_future

*Now include the collider in at least one of the regressions, to test how it biases the estimate 

*/