/* Week 09 Assignment*/

/* simulating liklihood of getting a traffic ticket after a behavioral intervention*/

	/*De-biasing parameter estimate using controls*/
global wd "C:/Users/Maeve/GitHub/ppol768-spring23/Individual Assignments/Grady Maeve/week-09"

		/* Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect.
		
		Requirements:
		 *strata groups of different sizes
		 *continuous covariates
		 *random noise
		 *strata groups affect the outcome 
		 *p(individual receives treatment) must vary accross strata groups
		 *at least one continuous covariate also affects both outcome and liklihood of receiving treatment
		 *at least one covariate affects outcome and not treatment
		 *at least one covariate affects treatment and not outcome
*/
		
		
* creating program
capture program drop parameterestimates
program define parameterestimates, rclass 
	syntax, samplesize(integer)
		
		clear
		set seed 03232023

		set obs `samplesize'
		
		
		//generating strata groups 
		
		generate regions = _n //generating regions instead of states b/c I want something closer to counties
		generate u_regions = rnormal() //random effects of regions
		
		expand 15 + int(30*runiform()) //expanding to towns 
		
		bysort u_regions: gen towns = _n
		generate u_towns = rnormal()  //generating a normal distribution of different town effects
		
		gen police = rnormal() // generating random effects of living in a more heavily policed community, of course this isn't truly random in real life, but i'm not generating race here because I don't know how to approximate that distribution well at all
		
		generate urban = runiform()<0.80   // randomly assigns urban rural status
		
		expand  40000 + int(5000 * runiform()) // creating individual level dataset
		generate u_individual = rnormal(0,5) // indivdual level effects 
		
		gen individual_id = _n  //individual id
		
		//generating more covariates
		gen sex = runiform()<0.5 // randomly assign 0/1 for male/female
		
		gen income = rnormal(75000, 30000) // randomly assigning income
		
		gen education = 12 + int((4)*runiform()) // randomly assigning years of education 

		gen commute = runiform()>0.2 //randomly assigns 0=does not commute by car, 1 = commutes by car
		
		gen distance = rnormal(10, 2) // generating continuous variable representing distance in miles from nearest urban center
		
			
		//generating treatment groups 
		
		gen treatment = 0
		replace treatment = 1 if police >= 0.7 & urban == 1 & education >= 20 // police affects both treatment and citation risk, education affects treatment and not citation risk , and income affects citation risk and not treatment
		
		
		//DGP
		
		gen citation_risk = 2 +  1.5 *police -  2 * ln(income)  - 2*treatment  + 4* rnormal() + 2 * commute + .5 * distance  + u_regions + u_towns + u_individual
		
		
		/*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.)*/

		
		//model 1
		reg citation_risk treatment //simple regression of outcome on treatment
		return scalar m1_beta = _b[treatment]
		
		//model 2
		reg citation_risk treatment police i.region i.towns  // confounder
		return scalar m2_beta = _b[treatment]
		
		//model 3
		reg citation_risk treatment police education i.region i.towns  // adding variable that affects treatment not outcome
		return scalar m3_beta = _b[treatment]
		
		//model 4
		reg citation_risk treatment police income commute distance i.region i.towns  //dropping education and adding vars that affect outcome and not treatment 
		return scalar m4_beta = _b[treatment]
		
		//model 5
		reg citation_risk treatment police education income commute distance i.region i.towns // adding strata
		return scalar m5_beta = _b[treatment]
		
		
end 
			
/*Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each */ 
		

/*running siulations*/
		
		

	clear
	tempfile combined 
	save `combined', replace emptyok

	
	forvalues i=10(50)100 { 
		local samplesize = `i'
		tempfile sims
		simulate m1 = r(m1_beta) m2 = r(m2_beta) m3 = r(m3_beta) m4 = r(m4_beta) m5 = r(m5_beta), reps(50) saving(`sims'): parameterestimates, samplesize(`samplesize')
		

		use `sims', clear 
		gen samplesize = `samplesize'
		append using `combined'
		save `combined', replace
		display as error "this is samplesize `i'"
	}

use `combined', clear
save "$wd/debias_results.dta", replace
		
		
/*produce figures and tables comparing the biasedness and convergence of the models as N grows. 

requirements: 
*figure showing the mean and variance of beta for different regression models, as a function of N
*Can you visually compare these to the "true" parameter value?*/
		
		
		
		
		
		
		
/*Biasing parameter estimates using controls */

	/* Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect.
		
		Requirements:
		 *strata groups of different sizes
		 *continuous covariates
		 *random noise
		 *strata groups affect the outcome 
		 *p(individual receives treatment) must vary accross strata groups
		 *at least one collider (function of both Y and the treatment variable)
		 *at least one channel (intermediate variable that is a function of treatment)*/
		 
				
* creating program
capture program drop parameterbiasestimates
program define parameterestimates, rclass 
	syntax, samplesize(integer)
		
		clear
		set seed 03232023

		set obs `samplesize'
		
		
		//generating strata groups 
		
		generate regions = _n //generating regions instead of states b/c I want something closer to counties
		generate u_regions = rnormal() //random effects of regions
		
		expand 15 + int(30*runiform()) //expanding to towns 
		
		bysort u_regions: gen towns = _n
		generate u_towns = rnormal()  //generating a normal distribution of different town effects
		
		gen police = rnormal() // generating random effects of living in a more heavily policed community, of course this isn't truly random in real life, but i'm not generating race here because I don't know how to approximate that distribution well at all
		
		generate urban = runiform()<0.80   // randomly assigns urban rural status
		
		expand  40000 + int(5000 * runiform()) // creating individual level dataset
		generate u_individual = rnormal(0,5) // indivdual level effects 
		
		gen individual_id = _n  //individual id
		
		//generating more covariates
		gen sex = runiform()<0.5 // randomly assign 0/1 for male/female
		
		gen income = rnormal(75000, 30000) // randomly assigning income
		
		gen education = 12 + int((4)*runiform()) // randomly assigning years of education 

		gen commute = runiform()>0.2 //randomly assigns 0=does not commute by car, 1 = commutes by car
		
		gen distance = rnormal(10, 2) // generating continuous variable representing distance in miles from nearest urban center
		
		//Generating channel
		gen registeredvoter = 0.8*treatment  // treatment was derived from registered voter rolls 
		
		//generating treatment groups 
		
		gen treatment = 0
		replace treatment = 1 if police >= 0.7 & urban == 1 & education >= 20 // police affects both treatment and citation risk, education affects treatment and not citation risk , and income affects citation risk and not treatment
		
		
		//DGP
		
		gen citation_risk = 2 +  1.5 *police -  2 * ln(income)  - 2*treatment  + 4* rnormal() + 2 * commute + .5 * distance  + u_regions + u_towns + u_individual
		
		//collider
		gen collider = 5*treatment + 2*citation_risk
		
		/*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.)*/

		
		//model A
		reg citation_risk treatment //simple regression of outcome on treatment
		return scalar mA_beta = _b[treatment]
		
		//model B
		reg citation_risk treatment police i.region i.towns  // confounder
		return scalar mB_beta = _b[treatment]
		
		//model C
		reg citation_risk treatment police registeredvoter i.region i.towns  // channel
		return scalar mC_beta = _b[treatment]
		
		//model D
		reg citation_risk treatment police collider i.region i.towns  //collider
		return scalar mD_beta = _b[treatment]
		
		//model E
		reg citation_risk treatment police collider registeredvoter i.region i.towns // all
		return scalar mE_beta = _b[treatment]
		
		
end 
			
/*Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each */ 
		

/*running siulations*/
		
		

	clear
	tempfile combined2 
	save `combined2', replace emptyok

	
	forvalues i=10(50)100 { 
		local samplesize = `i'
		tempfile sims
		simulate mA = r(mA_beta) mB = r(mB_beta) mC = r(mC_beta) mD = r(mD_beta) mE = r(mE_beta), reps(50) saving(`sims'): parameterbiasestimates, samplesize(`samplesize')
		

		use `sims', clear 
		gen samplesize = `samplesize'
		append using `combined2'
		save `combined2', replace
		display as error "this is samplesize `i'"
	}

use `combined2', clear
save "$wd/bias_results.dta", replace



	
	**5 Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

	
	**6 Fully describe your results in your README.md file, including figures and tables as appropriate.