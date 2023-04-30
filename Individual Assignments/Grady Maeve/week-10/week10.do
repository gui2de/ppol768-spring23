/*Week 10 Assignment*/

global wd "C:/Users/Maeve/GitHub/ppol768-spring23/Individual Assignments/Grady Maeve/week-10"

/*Part One: Calculating required sample sizes and minimun detectable effects*/

/*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.
Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.*/


/*using DGP from week 09 part one*/

clear

set seed 03232023
		
		
* creating program
capture program drop parameterestimates
program define parameterestimates, rclass 
syntax, samplesize(integer)
		
		clear
		set obs 5
				
		//generating strata groups 
		
		generate regions = _n //generating regions instead of states b/c I want something closer to counties
		generate u_regions = rnormal() //random effects of regions
		
		expand 15  //expanding to towns 
		
		bysort u_regions: gen towns = _n
		generate u_towns = rnormal()  //generating a normal distribution of different town effects
		
		gen police = rnormal() // generating random effects of living in a more heavily policed community, of course this isn't truly random in real life, but i'm not generating race here because I don't know how to approximate that distribution well at all
		
		generate urban = runiform()<0.80   // randomly assigns urban rural status
		
		expand  `samplesize' // creating individual level dataset
		generate u_individual = rnormal(0,5) // indivdual level effects 
		
		gen individual_id = _n  //individual id
		
		//generating more covariates
		gen sex = runiform()<0.5 // randomly assign 0/1 for male/female
		
		gen income = rnormal(75000, 30000) // randomly assigning income
		
		gen education = 12 + int((4)*runiform()) // randomly assigning years of education 

		gen commute = runiform()>0.2 //randomly assigns 0=does not commute by car, 1 = commutes by car
		
		gen distance = rnormal(10, 2) // generating continuous variable representing distance in miles from nearest urban center
		
			
		//generating treatment groups 
		
		generate random_treatment = police + .7*urban + .5*education + region/5
		sum random_treatment
		local meantreat r(mean)
		gen treatment = 0
		replace treatment = 1 if random_treatment >= `meantreat' // police affects both treatment and citation risk, education affects treatment and not citation risk , and income affects citation risk and not treatment
		
		
		
		//DGP
		
		gen citation_risk = 2 +  1.5 *police -  2 * ln(income)  - 2*treatment  + 4* rnormal() + 2 * commute + .5 * distance  + u_regions + u_towns + u_individual
		
		
		/*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.)*/

		
		//model 1
		reg citation_risk treatment //simple regression of outcome on treatment
		return scalar  m1_p = 2*(ttail(e(df_r), abs(_b[treatment]/_se[treatment])))
		return scalar mde1 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		
		//model 2
		reg citation_risk treatment police i.region // confounders
		return scalar m2_p = 2*(ttail(e(df_r), abs(_b[treatment]/_se[treatment])))
		return scalar mde2 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		
		//model 3
		reg citation_risk treatment police i.region education income // confounders and covariates
		return scalar m3_p = 2*(ttail(e(df_r), abs(_b[treat]/_se[treat])))
		return scalar mde3 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		return scalar n= e(N)
		
end 
			


/*running simulations*/
		
		

	clear
	tempfile combined 
	save `combined', replace emptyok

	
	forvalues i=5(5)40 { 
		local samplesize = `i'
		tempfile sims
		simulate n=r(n) p1=r(m1_p) p2=r(m2_p) p3=r(m3_p) mde1=r(mde1) mde2=r(mde2) mde3=r(mde3), reps(500) saving(`sims'): parameterestimates, samplesize(`samplesize')
		

		use `sims', clear 
		gen samplesize = `samplesize'
		append using `combined'
		save `combined', replace
		display as error "this is samplesize `i'"
	}

use `combined', clear
save "$wd/outputs/partone.dta", replace

/* calculating power*/
bysort samplesize:gen howmany = _N

foreach p of varlist p1 p2 p3{
	gen significant_`p' = 0
	replace significant_`p' = 1 if `p' <.05
	
	sort samplesize
	by samplesize: egen sig_in_samplesize`p' = total(significant_`p')
	
	gen power`p' = sig_in_samplesize`p'/howmany
	
	
}
	

	tab samplesize powerp1 
	
	tab samplesize powerp2
	
	tab samplesize powerp3
	
	twoway line samplesize powerp1, xscale(range(0,1)) xlabel(0(.1)1)
	graph save "$wd/outputs/p1.png", replace
	
	twoway line samplesize powerp2, xscale(range(0,1)) xlabel(0(.1)1)
		graph save "$wd/outputs/p2.png", replace
	
	twoway line samplesize powerp3, xscale(range(0,1)) xlabel(0(.1)1)
		graph save "$wd/outputs/p3.png", replace
		
	graph combine "$wd/outputs/p1.png" "$wd/outputs/p2.png" "$wd/outputs/p3.png"
	graph save "$wd/outputs/powerbysamplesize.png", replace
	
	/*in the increments here, the smallest sample size at which >80% of regressions will return a beta coefficient on the treatment variable with a p-value <= .05 is 10 for model 2 and 15 for model 3. The first model does not have sufficient power at any sample size tested.*/
	
	/*MDE with fixed sample size*/
	
clear
drop _all	
	* creating program
capture program drop mdeestimates
program define mdeestimates, rclass 
syntax, treateffect(integer)
		
		clear
		set obs 5
				
		//generating strata groups 
		
		generate regions = _n //generating regions instead of states b/c I want something closer to counties
		generate u_regions = rnormal() //random effects of regions
		
		expand 15  //expanding to towns 
		
		bysort u_regions: gen towns = _n
		generate u_towns = rnormal()  //generating a normal distribution of different town effects
		
		gen police = rnormal() // generating random effects of living in a more heavily policed community, of course this isn't truly random in real life, but i'm not generating race here because I don't know how to approximate that distribution well at all
		
		generate urban = runiform()<0.80   // randomly assigns urban rural status
		
		expand  10 // creating individual level dataset
		generate u_individual = rnormal(0,5) // indivdual level effects 
		
		gen individual_id = _n  //individual id
		
		//generating more covariates
		gen sex = runiform()<0.5 // randomly assign 0/1 for male/female
		
		gen income = rnormal(75000, 30000) // randomly assigning income
		
		gen education = 12 + int((4)*runiform()) // randomly assigning years of education 

		gen commute = runiform()>0.2 //randomly assigns 0=does not commute by car, 1 = commutes by car
		
		gen distance = rnormal(10, 2) // generating continuous variable representing distance in miles from nearest urban center
		
			
		//generating treatment groups 
		
		generate random_treatment = police + .7*urban + .5*education + region/5
		sum random_treatment
		local meantreat r(mean)
		gen treatment = 0
		replace treatment = 1 if random_treatment >= `meantreat' // police affects both treatment and citation risk, education affects treatment and not citation risk , and income affects citation risk and not treatment
		
		
		
		//DGP
		
		gen citation_risk = 2 +  1.5 *police -  2 * ln(income)  - `treateffect'*treatment  + 4* rnormal() + 2 * commute + .5 * distance  + u_regions + u_towns + u_individual
		
		
		/*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.)*/

		
		//model 1
		reg citation_risk treatment //simple regression of outcome on treatment
		return scalar  m1_p = 2*(ttail(e(df_r), abs(_b[treatment]/_se[treatment])))
		return scalar mde1 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		
		//model 2
		reg citation_risk treatment police i.region // confounders
		return scalar m2_p = 2*(ttail(e(df_r), abs(_b[treatment]/_se[treatment])))
		return scalar mde2 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		
		//model 3
		reg citation_risk treatment police i.region education income // confounders and covariates
		return scalar m3_p = 2*(ttail(e(df_r), abs(_b[treat]/_se[treat])))
		return scalar mde3 = 2.8 * (sqrt((_se[treatment]*_se[treatment] / e(N)) * 0.95 * 0.05))
		return scalar n= e(N)
		
end 
			
	

/*running siulations*/
		
		

	clear
	tempfile combined 
	save `combined', replace emptyok

	
	forvalues i=1(1)5 { 
		local treateffect = `i'
		tempfile sims
		simulate n=r(n) p1=r(m1_p) p2=r(m2_p) p3=r(m3_p) mde1=r(mde1) mde2=r(mde2) mde3=r(mde3), reps(500) saving(`sims'): mdeestimates, treateffect(`treateffect')
		

		use `sims', clear 
		gen treateffect = `treateffect'
		append using `combined'
		save `combined', replace
		display as error "this is treateffect `i'"
	}

	/* calculating power*/


foreach p of varlist p1 p2 p3{
	gen significant_`p' = 0
	replace significant_`p' = 1 if `p' <.05
	
	sort treateffect
	by treateffect: egen sig_in_treateffect`p' = total(significant_`p')
	
	gen power`p' = sig_in_treateffect`p'/500
	
	
}
	

	tab treateffect powerp1
	twoway line treateffect powerp1, xscale(range(0,1)) xlabel(0(.1)1)
	graph save "$wd/outputs/mde1.png", replace
	
	tab treateffect powerp2
	twoway line treateffect powerp2, xscale(range(0,1)) xlabel(0(.1)1)
	graph save "$wd/outputs/mde2.png", replace
	
	tab treateffect powerp3
	twoway line treateffect powerp3, xscale(range(0,1)) xlabel(0(.1)1)
	graph save "$wd/outputs/mde3.png", replace
	
	graph combine "$wd/outputs/mde1.png" "$wd/outputs/mde2.png" "$wd/outputs/mde3.png", altshrink
	graph save "$wd/outputs/mde_all.png", replace
	
	

	
	

	
	
	
	
	
	
	
	
	
	
	
	
		