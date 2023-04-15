**** BeverlyAnn Hippolyte 
**** Week 9 Submission 
**** PPOL 768 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week09"

*** Start of the assignment 

***  Data Generating Process 

*** ## Part 2: Biasing a parameter estimate using controls

*** 1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

*** 2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.

*** 3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)

*** 4. In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

*** 5. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type `h fvvarlist` for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a `program` like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?


***6. Fully describe your results in your `README.md` file, including figures and tables as appropriate.

* Define a program 

capture program drop week9          // Data Generating Process 
program define week9, rclass 
	syntax, samplesize(integer)


** Generate strata groups 
		set obs 10   // number of localities in Bogota
		gen localitie = _n
		gen leffect = rnormal(0,2) // localitie effect
		expand `samplesize' // number of businesses in a localitie  

					
** Generate continuous covariates 

	gen num_child = rnormal()
	gen num_hrs = rnormal()
	gen age_child = rnormal()
	
* generate treatment variable

	generate treatment = num_child + age_child 
	
** Generate intermediate variable

	generate intvar = treatment + 0.2*rnormal()

* generate outcome y

	generate y = localitie/10 + intvar + num_child + num_hrs + 2*rnormal() + 0.5*treatment


* run five regression models 
		reg y treatment 
		reg y treatment i.localitie 
		reg y treatment i.localitie#c.num_child
		reg y treatment i.localitie#c.num_child#c.num_hrs
		reg y treatment i.localitie#c.num_child#c.num_hrs#c.age_child

table
		matrix results = r(table)
		
		return scalar beta = results(beta)

end 

*week9, samplesize(10000)
