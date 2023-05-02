*Chance Hope								   
*Week 9
   global week-09 "C:\Users\maxis\Desktop\ppol 768 backup\week-09"
   cd "$week-09"

*Part 1: Develop some data generating process with:
*random noise 
*strata groups of different sizes 
*strata groups that affect Y 
*strata groups that affect P(treat = 1) 
*x1 that affects Y
*x2 that affects P(treat = 1) 
*x3 that affects Y and P(treat = 1) 

*How do x1, x2, and x3(confounder) bias results?

*Run 5 regressions with fixed effects 
*Simulate different sample sizes 
*Compare bias and convergence as N increases 
*Display beta mean vs. variance for models as N increases 
*Include the "true" parameter value

capture program drop fincap		
program define fincap, rclass		          // define the program
args    sampsize		     				  // require sample size
*set 	seed 135790							  // set seed
clear

set 	obs 6 					 			  // gen strata (GU grad school) 
gen 	school = _n							  // school variable
gen 	e1 = int(runiform(-4,4))  			  // school effects on Y
gen 	t1 = runiform(0,.1)			          // school effects on treated = 1
gen 	size = ///                            // vary obs per school
        round(rnormal(`sampsize',`sampsize'*.1))      

expand  size								  // gen obs  
bysort  school: gen id = _n 		          // student variable
gen     e2 = 20*(ln(runiform(.5,1.5)))	      // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew    			  	
gen 	t2  = (2/(.01*(age^3.1)))             // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered) 
gen 	t3 = 1000*(limit^-1)                  // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

egen 	rank = rank(t1 + t2 + t3)		      // rank treated = 1 effects
gen 	tsize = _N							  // total sample size
gen 	treatment = rank >= tsize/2			  // assign treatment 50/50 


		*-----||  DGP for financial capability score (Y) ||-----*

		gen y = -55  ///			           	    y | dependent 
		+ 1.5*age    ///                       	  age | positive 
		+ .05*par    ///                  	parcredit | positive  
		+ e1         ///			     	   school | noise
		+ e2         ///				      student | noise
		+ 4*treat + (treat*runiform(0,5)) //  	treat | positive + noise  
		
		replace y = 2*y				 	  // scale y values to ~0-100

					*---------------------------------*

egen zage = std(age)				 // standardize variables
egen zlimit = std(limit)
egen zparcredit = std(parcredit)

xtset, clear						 // set strata for fe
xtset school

xtreg y treat, rob fe	    		 // reg 1
matrix a = r(table)                  // store results 					     
return scalar obs = tsize		 
return scalar b1 = a[1,1]
                                  
xtreg y treat zage, rob fe			 // reg 2 
matrix a = r(table)				     // store results
return scalar b2 = a[1,1]

xtreg y treat zlimit, rob fe		 // reg 3 
matrix a = r(table)				     // store results
return scalar b3 = a[1,1]

xtreg y treat zparcredit, rob fe     // reg 4 
matrix a = r(table)				     // store results
return scalar b4 = a[1,1]

xtreg y tre zage zlim zparc, rob fe	 // reg 5 
matrix a = r(table)				     // store results
return scalar b5 = a[1,1]
 	
end                      
						 *	 SIMULATE  *
				*---------------------------------*					     
clear
tempfile tp1	                              // tempfile
save `tp1', replace emptyok 		   
forvalues i=1/10{						      // simulate loop
	local N = 25*`i'			     	      // indicate strata sample sizes
	tempfile sim						   
	simulate size=r(obs)  ///
			 b1 = r(b1)   ///
			 b2 = r(b2)   ///
			 b3 = r(b3)   ///
			 b4 = r(b4)   ///			
			 b5 = r(b5),  ///     
			 reps(100)    ///
			 seed(135791) ///
			 saving(`sim'): fincap `N'     	
	use `sim', clear
	gen i =`i'
	gen irow = _n
	append using `tp1'                        // save stats in combined file
	save `tp1', replace                		  
	}
	
use `tp1', clear
save using "$w9/part1.dta", replace	
bysort i irow				   		  
scatter b1 b5 size, mcolor(erose%15 chocolate%10)

*-----------------------------------------------------

/*Part 2: Biasing a parameter estimate using controls
	- x4 that affects Y as a f(treatment); (exc. treatment)
	- x5 that affects Y and P(treat = 1)  			  

capture program drop fincap		
program define fincap, rclass		          // define the program
args    sampsize		     				  // require sample size
*set 	seed 135790							  // set seed
clear

set 	obs 6 					 			  // gen strata (GU grad school) 
gen 	school = _n							  // school variable
gen 	e1 = int(runiform(-4,4))  			  // school effects on Y
gen 	t1 = runiform(0,.1)			          // school effects on treated = 1
gen 	size = ///                            // vary obs per school
        round(rnormal(`sampsize',`sampsize'*.1))      

expand  size								  // gen obs  
bysort  school: gen id = _n 		          // student variable
gen     e2 = 20*(ln(runiform(.5,1.5)))	      // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew    			  	
gen 	t2  = (2/(.01*(age^3.1)))             // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered) 
gen 	t3 = 1000*(limit^-1)                  // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

egen 	rank = rank(t1 + t2 + t3)		      // rank treated = 1 effects
gen 	tsize = _N							  // total sample size
gen 	treatment = rank >= tsize/2			  // assign treatment 50/50 


		*-----||  DGP for financial capability score (Y) ||-----*

		gen y = -55  ///			           	    y | dependent 
		+ 1.5*age    ///                       	  age | positive 
		+ .05*par    ///                  	parcredit | positive  
		+ e1         ///			     	   school | noise
		+ e2         ///				      student | noise
		+ 4*treat + (treat*runiform(0,5)) //  	treat | positive + noise  
		
		replace y = 2*y				 	  // scale y values to ~0-100

					*---------------------------------*

egen zage = std(age)				 // standardize variables
egen zlimit = std(limit)
egen zparcredit = std(parcredit)

xtset, clear						 // set strata for fe
xtset school

xtreg y treat, rob fe	    		 // reg 1
matrix a = r(table)                  // store results 					     
return scalar obs = tsize		 
return scalar b1 = a[1,1]
                                  
xtreg y treat zage, rob fe			 // reg 2 
matrix a = r(table)				     // store results
return scalar b2 = a[1,1]

xtreg y treat zlimit, rob fe		 // reg 3 
matrix a = r(table)				     // store results
return scalar b3 = a[1,1]

xtreg y treat zparcredit, rob fe     // reg 4 
matrix a = r(table)				     // store results
return scalar b4 = a[1,1]

xtreg y tre zage zlim zparc, rob fe	 // reg 5 
matrix a = r(table)				     // store results
return scalar b5 = a[1,1]
 	
end                      
						 *	 SIMULATE  *
				*---------------------------------*					     
clear
tempfile tp1	                              // tempfile
save `tp1', replace emptyok 		   
forvalues i=1/10{						      // simulate loop
	local N = 25*`i'			     	      // indicate strata sample sizes
	tempfile sim						   
	simulate size=r(obs)  ///
			 b1 = r(b1)   ///
			 b2 = r(b2)   ///
			 b3 = r(b3)   ///
			 b4 = r(b4)   ///			
			 b5 = r(b5),  ///     
			 reps(100)    ///
			 seed(135791) ///
			 saving(`sim'): fincap `N'     	
	use `sim', clear
	gen i =`i'
	gen irow = _n
	append using `tp1'                        // save stats in combined file
	save `tp1', replace                		  
	}
	
use `tp1', clear
save using "$w9/part1.dta", replace	
bysort i irow				   		  
scatter b1 b5 size, mcolor(erose%15 chocolate%10)

