**** BeverlyAnn Hippolyte 
**** Week 9 Submission 
**** PPOL 768 

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week09"

****Bev Code
*W9


*_______________________________________
*PART 1 
* Define a program 

cap prog drop weekten          				// program setup 
program define weekten, rclass				// define the program
		syntax, samplesize(integer) 		// samplesize is an argument to the program 

	
		clear
** Generate strata groups 
		set obs `samplesize'   // number of localities in Bogota
		local treat = `samplesize'/10
		
		*gen localitie = _n // define variable 
		expand `samplesize' // expand localitie 
		
							
** Generate continuous covariates 
	
	gen num_child = 0 +int((10-2)*runiform()) // number of children ranges from 3 to 10
	gen num_hrs = 2 + int((26-2)*runiform())  // number of hours working ranges from 2 to 24 
	gen age_child = 5+int((20-11)*rnormal()) // child's age ranges from 5 to 14
	
* generate treatment variable
	
	generate treatment = num_child + age_child +rnormal()  // generate treatment variable inclusive of a confounder 
	replace treatment = 1 if _n >`treat'
	

* generate outcome y; treatment variable has an effect of 0.5 units; inclusive of confounder 

	generate y = 0.5 + num_child + age_child+ 0.5*treatment+ rnormal() // dependent variable 
	replace y = y + 0.8 if treatment == 1
	
	/* DGP 

		generate productivity score  = 2 /// base score is 2
					
					+ (-1)*num_child    /// if the number of children you have is greater than three your score decreases by -1
					+ 3*age_child /// 		if your child is older than five your score increases by 3
					+ 5*num_hrs ///         your hours are more than three, your score increases by 5 
				
*/


*** first regression

	reg y treatment 
	mat results = r(table) // ADDED THIS, TO GET MATRIX/TABLE OF REGRESSION RESULT
	return scalar beta1 = results[1,1] // return beta 
	return scalar pval = results[4,1] // return p value
	
	
end 


*_______________________________________
** run simulation
	clear 
	tempfile secondary bias
	save `secondary', replace emptyok //
		
		forvalues i= 100(100)1500{ 
			simulate beta=r(beta1) pval=r(pval), reps(500) saving(`bias', replace): weekten, samplesize(`i') // 
			
			use `bias', clear //	
			gen N = `i'
			append using `secondary'
			save `secondary', replace
			
}
	
gen power=0
replace power=1 if pval<0.05

sum power
*The mean of this is power!

mean power, over(N)




