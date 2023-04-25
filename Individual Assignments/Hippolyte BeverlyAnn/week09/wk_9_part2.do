**** BeverlyAnn Hippolyte 
**** Week 9 Submission 
**** PPOL 768 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week09"

*** Start of the assignment 

***  Data Generating Process 

* Define a program 

capture program drop week9          // Data Generating Process 
program define week9, rclass 
	syntax, samplesize(integer)


** generate strata groups 
		set obs 10   // number of localities in Bogota
		gen localitie = _n
		gen leffect = rnormal(0,2) // localitie effect
		expand `samplesize' // number of businesses in a localitie  

					
** generate continuous covariates 

	gen num_child = rnormal()
	gen num_hrs = rnormal()
	gen age_child = rnormal()
	
* generate treatment variable

	generate treatment = 1.2*num_child + 0.5*age_child
	
** generate channel variable 

	generate channel = 1.5*treatment

* generate outcome y

	generate y = (localitie/10) + channel + num_child + num_hrs + 2*rnormal() + 0.5*treatment
	
** generate collider variable 

	generate collider = y + treatment
	
* run five regression models

*** first regression 
		reg y treatment 
		mat results = r(table) // 
		return scalar base_beta1 = results[1,1]
		return scalar N_observations = `r(N)'
	
** second regression 
		reg y treatment i.localitie 	
		mat results = r(table) // 
		return scalar base_beta2 = results[1,1]
	
		
** third regression 
		reg y treatment i.localitie channel
		mat results = r(table) // 
		return scalar base_beta3 = results[1,1]
		
** fourth regression 
		reg y treatment i.localitie treatment collider
		mat results = r(table) // 
		return scalar base_beta4 = results[1,1]
		
** fifth regression 
		reg y treatment i.localitie treatment channel collider	
		mat results = r(table) // 
		return scalar base_beta5 = results[1,1]

end 


*_______________________________________
** run simulation
	clear 
	tempfile secondary 
	save `secondary', replace emptyok //  
		
		forvalues i=1/4{
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

	graph box base_beta? , over(sample_size) yline(0.5) noout

	graph export bias_50.png, replace 
