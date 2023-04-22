**** BeverlyAnn Hippolyte 
**** Week 9 Submission 
**** PPOL 768 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week09"

****Bev Code
*W9


*_______________________________________
*PART 1 
* Define a program 

cap prog drop weeknine          				// program setup 
program define weeknine, rclass				// define the program
		syntax, samplesize(integer) 		// samplesize is an argument to the program 

		clear // ADDED CLEAR HERE 
** Generate strata groups 
		set obs 10   // number of localities in Bogota
		gen localitie = _n // define variable 
		expand `samplesize' // expand localitie 
		gen leffect = rnormal(0,3) // generate local effect 

					
** Generate continuous covariates 
	
	gen num_child = 3 +int((10-2)*runiform()) // number of children ranges from 3 to 10
	gen num_hrs = 2 + int((26-2)*rnormal())  // number of hours working ranges from 2 to 24 
	gen age_child = 5+int((20-11)*runiform()) // child's age ranges from 5 to 14
	
* generate treatment variable

	generate treatment = num_child + num_hrs + rnormal() + (localitie/4)> 0 // treatment variable; confounder is number of children(num_child)

* generate outcome y; treatment variable has an effect of 0.5 units 

	generate y = 2 + localitie/10 + num_child + (3)*age_child + 2*rnormal() + 2.5*treatment + leffect // dependent variable 
	
	/* DGP 

		generate productivity score  = 2 /// base score is 2
					
					+ (-1)*num_child    /// if the number of children you have is greater than three your score decreases by -1
					+ 3*age_child /// 		if your child is older than five your score increases by 3
					+ 5*num_hrs ///         your hours are more than three, your score increases by 5 
				
*/


*** first regression

	reg y treatment 
	mat results = r(table) // ADDED THIS, TO GET MATRIX/TABLE OF REGRESSION RESULTS
	return scalar base_beta1 = results[1,1]
	return scalar SEM1 = results[2,1] // ADDED THIS, AS THE STANDARD ERROR IS GOOD TO KNOW AS WELL TO CHARACTERIZE THE VARIANCE IN THE BETA ESTIMATES 
	
	*ADDED THE FOLLOWING, SO THAT WE CAN TRACK WHAT N EACH REGRESSION RESULT WAS PRODUCED AT AS WELL IN THE FINAL DATASET
	return scalar N_observations = e(N)
	

	
** second regression 

	reg y treatment i.localitie 
	mat results = r(table) // ADDED THIS, TO GET MATRIX/TABLE OF REGRESSION RESULTS
	return scalar base_beta2 = results[1,1]
	

*** third regression 

	reg y treatment i.localitie num_child
	mat results = r(table) // 
	return scalar base_beta3 = results[1,1]
	
*** fourth regression 
	reg y treatment i.localitie num_child num_hrs
	mat results = r(table) // 
	return scalar base_beta4 = results[1,1]
	

** fifth regression 
	
	reg y treatment i.localitie num_child num_hrs age_child 	
	mat results = r(table) // 
	return scalar base_beta5 = results[1,1]
	
	
end

*_______________________________________
** run simulation
	clear 
	tempfile secondary 
	save `secondary', replace emptyok //  
		
		forvalues i=1/5{
			local samplesize = 10^ `i' //   
			tempfile bias
			simulate N = r(N_observations) base_beta1=r(base_beta1) base_beta2=r(base_beta2) base_beta3=r(base_beta3) base_beta4=r(base_beta4) base_beta5=r(base_beta5) , reps(500) saving(`bias', replace): weeknine, samplesize(`samplesize') // 
			
			use `bias', clear // ADDED CLEAR HERE	
			gen sample_size = `samplesize'
			append using `secondary'
			save `secondary', replace
			
	}
	
	use `secondary', clear 

	
*** Graph betas for each sample size 

	graph box base_beta? , over(sample_size) yline(2.5) noout

	graph export confounder.png, replace 
