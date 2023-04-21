/* Week 09 Assignment*/


/*De-biasing parameter estimate using controls*/


		*** 1 . Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
		
		***2 This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
		
		
* creating program
capture program drop parameterestimates
program define parameterestimates, rclass 
	syntax, m(integer) samplesize(integer)
		
		clear
		set seed 03232023

		set obs `samplesize'
		
		
		//generating strata groups 
		
		generate regions = _n
		generate u_regions = rnormal()
		
		expand 15 + int(30*runiform())
		
		bysort u_regions: gen towns = _n
		generate u_towns = rnormal()  //generating a normal distribution of different town effects
		
		gen police = rnormal() // generating random effects of living in a more heavily policed community 
		
		generate urban = runiform()<0.80   // randomly assigns urban rural status
		
		expand  40000 + int(5000 * runiform()) // creating individual level dataset
		generate u_individual = rnormal(0,5) // indivdual level effects 
		
		gen individual_id = _n
		
		//generating more covariates
		gen sex = runiform()<0.5 // randomly assign 0/1 for male/female
		
		gen income = rnormal(75000, 30000) // randomly assigning income
		
		gen education = 12 + int((4)*runiform()) // randomly assigning years of education 

		gen commute = runiform()>0.2 //randomly assigns 0=does not commute by car, 1 = commutes by car
		
		gen distance = rnormal(10, 2) // generating continuous variable representing distance in miles from nearest urban center
		
		
		/*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)*/
		
		//generating treatment groups 
		
		gen treatment = 0
		replace treatment = 1 if police >= 0.7 & urban == 1 & education >= 20
		// police affects both treatment and citation risk, education affects treatment and not citation risk , and income affects citation risk and not treatment
		
	
		
		
		//DGP
		
		gen citation_risk = 2 +  1.5 *police -  2 * ln(income)  - 2*treatment  + 4* rnormal() + 2 * commute + .5 * distance  + u_regions + u_towns + u_individual
		
		



		***4 Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

		
		if `m' == 1 {
		reg citation_risk treatment //simple regression of outcome on treatment
		}
		else if `m' == 2 {
		reg citation_risk treatment police // confounder
		}
		
		else if `m' == 3 {
		reg citation_risk treatment police education // adding variable that affects treatment not outcome
		} 
		
		else if `m' == 4 {
		reg citation_risk treatment police income commute distance //dropping educationa and adding vars that affect outcome and not treatment (controls)
		}
		
		else if `m' == 5 {
		reg citation_risk treatment police income commute distance i.region i.towns // adding strata
		}
		
		*Store  results 
	mat results = r(table) 
	
	return scalar subsample_size = e(N)
	return scalar beta = results[1,1] 
	return scalar SEM = results[2,1] 
	return scalar pval = results[4,1]
	return scalar ci_lower = results[5,1]
	return scalar ci_upper = results[6,1]
		
		
end 
		
		
	forvalues `m' = 1/5 {

	clear
	tempfile combined 
	save `combined', replace emptyok

	
	forvalues i=1/6 { 
		local samplesize = `i'
		tempfile sims
		simulate N=r(subsample_size) beta_coeff=r(beta) SEM=r(SEM) pvalues=r(pval) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(100) 	saving(`sims', replace): parameterestimates, num_districts(`samplesize') r(`m') 
		gen regressionID = `m'
		gen population_size = `samplesize'
		
		use `sims', clear 
		append using `combined'
		save `combined', replace
	}

}
		
		
		/// should be able to figure out which model is correct, because we know what the beta should be based on our DGP 
		

		*** 5 Fully describe your results in your README.md file, including figures and tables as appropriate.
		
		
		
		
		
		
/*Biasing parameter estimates using controls */

	**1 Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

	**2 This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

	
	**3 When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)

	
	**4 In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

	
	**5 Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

	
	**6 Fully describe your results in your README.md file, including figures and tables as appropriate.