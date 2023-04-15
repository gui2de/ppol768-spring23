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

cap prog drop weeknine          				// program setup 
program define weeknine, rclass						// define the program
		syntax, samplesize(integer) 		// samplesize is an argument to the program 


** Generate strata groups 
		set obs 10   // number of localities in Bogota
		gen localitie = _n // define variable 
		expand 100 // expand localitie 
		gen leffect = rnormal(0,3) // generate local effect 

					
** Generate continuous covariates 
	
	gen num_child = 3 +int((10-2)*runiform()) // number of children ranges from 3 to 10
	gen num_hrs = 2 + int((26-2)*rnormal())  // number of hours working ranges from 2 to 24 
	gen age_child = 5+int((20-11)*runiform()) // child's age ranges from 5 to 14
	
* generate treatment variable

	generate treatment = num_child + num_hrs + rnormal() + (localitie/4)> 0 // treatment variable; confounder is number of children(num_child)

* generate outcome y; treatment variable has an effect of 0.5 units 

	generate y = 2 + localitie/10 + num_child + (3)*age_child + 2*rnormal() + 2.5*treatment + leffect // dependent variable 
	
* regression models 
		reg y treatment 
		reg y treatment i.localitie 
		reg y treatment i.localitie num_child
		reg y treatment i.localitie num_child age_child 
		reg y treatment i.localitie num_child num_hrs
		reg y treatment i.localitie num_child num_hrs age_child 

end


/* DGP 

		generate productivity score  = 2 /// base score is 2
					
					+ (-1)*num_child    /// if the number of children you have is greater than three your score decreases by -1
					+ 3*age_child /// 		if your child is older than five your score increases by 3
					+ 5*num_hrs ///         your hours are more than three, your score increases by 5 
				
		
*/	 

* table
		matrix results = r(table)
		
		return scalar one_beta = _b(treatment)
		

week9, samplesize(100)


/*
** run simulation 
 
	tempfile secondary 
	save `secondary', replace emptyok
		
		forvalues i = 1/6 {
			local female_busin = 10^ `i'
			
			simulate col_beta=r(beta) reps(5): week9, samplesize(`female_busin')
			gen samplesize = `female_busin'
			
			save `secondary'			
			
		}
	
	use `secondary', clear 
			
tempfile nine
save `nine, replace emptyok'


simulate column_beta=r(beta) column_pvalues=r(pval) column_st=r(stderr), reps(5) saving(`nine'): week9, samplesize(10)

	use `nine', clear


*/

