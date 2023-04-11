**** BeverlyAnn Hippolyte 
**** Week 9 Submission 
**** PPOL 768 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week09"

*** Start of the assignment 

***  Data Generating Process 

** ## Part 1: De-biasing a parameter estimate using controls

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.

*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

*4. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type `h fvvarlist` for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a `program` like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?
*6. Fully describe your results in your `README.md` file, including figures and tables as appropriate.

* DGP around project on the impact of formalization on female entrepenurs in Colombia 
* Essentially my DGP states that the formalization of a business by a female entrepenure increase business profits by 2.5% with the exception of the noise in the model. 

* Define a program 

capture program drop week9          // Data Generating Process 
program define week9, rclass 
syntax, samplesize(integer)
	clear 
* Process for data x

	gen x = rnormal()
			
** Generate continuous covariates 

	gen num_child = rnormal()
	gen num_hrs = rnormal()
	gen age_child = rnormal()


** Generate strata groups 

	clear 
		set obs `samplesize'   // number of localities in Bogota
		gen localitie = _n
		gen leffect = rnormal(0,2) // localitie effect
		expand 4 // number of businesses in a localitie  
		bysort localitie: gen business = _n
		
		gen beffect = rnormal(0,3) // business effect 
		expand int((5+10-1))*rnormal() // number of female entrepreneurs 
		
* generate outcome Y 

	generate y = localitie + num_child + num_hrs *rnormal()

* generate treatment variable

	generate treatment = num_child + age_child 

		reg y treatment 
		reg y treatment i.localitie 
		reg y treatment i.localitie i.business 
		reg y treatment i.localitie i.business num_child num_hrs
		reg y treatment i.localitie i.business num_child num_hrs age_child

		matrix f = r(table)
		
		return scalar beta = f[]
		return scalar pval = f[]
		return scalar std = f[]

end 

	clear 
	tempfile secondary 
	save `secondary', replace emptyok
		
		forvalues i = 1/6 {
			local female_busin = 10^ `i'
			
			simulate col_beta=r(beta) col_std=r(std) col_pval=r(pval), reps(5): week9, samplesize(`female_busin')
			gen samplesize = `female_busin'
			
			save `secondary'			
			
		}
	
			use `secondary', clear 
			
tempfile nine
simulate column_beta=r(beta) column_pvalues=r(pval) column_st=r(stderr), reps(5) saving(`nine'): week9, samplesize(10)

	use `nine', clear
		