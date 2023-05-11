*	 																		   *
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 09 						       *
*						      Updated: April 2023						       *
*							        09-wk.do								   *
*																			   *
* 							   - Program Setup -							   *

*  version 17        // Version no. for backward compatibility
   set more off      // Disable partitioned output	
   global main 		"/Users/jasmineadams/Dropbox/R Stata"
   global myrepo   	"$main/repositories/Rsrch-Dsgn"
   global classrepo	"$main/repositories/ppol768-spring23"
   global w9 "$classrepo/Individual Assignments/Adams Jasmine/week-09/outputs"
   cd 				"$w9"
/*______________________________________________________________________________

Part 1: Develop some data generating process with:
	- random noise 
	- strata groups of different sizes 
	- strata groups that affect Y 
	- strata groups that affect P(treat = 1) 
	- x1 that affects Y
	- x2 that affects P(treat = 1) 
	- x3 that affects Y and P(treat = 1) 

	How do x1, x2, and x3(confounder) bias results?

	- Run 5 regressions with fixed effects 
	- Simulate different sample sizes 
	- Compare bias and convergence as N increases 
	- Display beta mean vs. variance for models as N increases 
		- Include the "true" parameter value
*/
clear		
capture program drop cscore		
program define cscore, rclass		          // define the program
args    obs effect		     			      // require sample size
clear
									        
set 	obs 5 					 			  // gen strata (GU grad school) 
gen     r1 = runiform()					      // values between 0 & 1
sort 	r1									  // order rows low to high
gen     pct = r1[_n+1]-r1  					  // pct = intervasl bw rows
replace pct = 1-r1 if pct == .				  // incl. interval bw last row & 1 
set 	obs 6								  // add 6th strata group
replace pct = r1[1] if pct == . 			  // incl. interval bw 0 & 1st row 
replace pct = (.9/6) + .1*(pct)			      // sum of varied strata = 1
gen 	ssize = pct*`obs'               	  // vary obs per school

gen     school = _n							  // school variable
gen 	e1 = rnormal(1.5)  			          // school effects on Y
gen 	t1 = school+runiform(-2,2)			  // school effects on treated = 1    
		
expand  ssize								  // gen obs
bysort  school: gen schoolid = _n 		      // student id by school
gen 	id = _n								  // obs id 
gen     e2 = rnormal(0,2) 	      			  // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew 
xtile 	xage = age, nquantiles(6)   	 	  // 		  	
gen  	t2 = xage+runiform(-1,1)              // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered)
gen     invlim = -1*limit 					  // 
xtile 	xlimit = invlim, nquantiles(6)   	  // assign higher # to low values	
gen 	t3 = xlimit+runiform(1,2)             // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

egen 	rank = rank(t1 + t2 + t3)		      // rank treated = 1 effects
gen 	treatment = rank >= _N/2			  // assign treatment 50/50 
		        
		*-----------------||  DGP for credit score (Y) ||----------------*	
		gen y = 0          ///				       	 y | dependent 
		+ 7.6*age   	   ///                     age | positive 
		+ .67*par   	   ///               parcredit | positive  
		+ 9.5*e1           ///			   	    school | noise
		+ 9.5*e2           ///		 		   student | noise
		+ `effect'*(treat*rnormal(1,.5))      // treat | positive +noise 		
		replace y = round(y, 1)
		*----------------------------------------------------------------*

xtset, 	clear						 		  // set strata for fe
xtset 	school

xtreg 	y treatment, rob fe   				  // reg 1 
matrix 	a = r(table)				     		  
return 	scalar obs = `obs'
return 	scalar b0 = a[1,1]
return 	scalar p0 = a[4,1]

xtreg 	y treat age limit parcredit, rob fe   // reg 2 
matrix 	a = r(table)				     		  
return 	scalar b1 = a[1,1]
return 	scalar p1 = a[4,1]
                                  
xtreg 	y treat age, rob fe			 		  // reg 3 
matrix 	a = r(table)				
return 	scalar age = a[1,1]

xtreg 	y treat limit, rob fe		 		  // reg 4 
matrix 	a = r(table)				 
return 	scalar limit = a[1,1]

xtreg 	y treat parcredit, rob fe    		  // reg 5 
matrix 	a = r(table)				
return 	scalar parcredit = a[1,1]

end                       

				*---------*--SIMULATE--*---------*					     
clear
tempfile tp1	                              // tempfile
save `tp1', replace emptyok 		   
forvalues i=4/7{						      // simulate loop
	local N = round(3^`i',10)			      // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) b0=r(b0) b1=r(b1)    ///
			 age=r(age) limit=r(limit) 		  ///
			 parcredit=r(parcredit), 		  ///    
			 reps(500) seed(135791)           ///
			 saving(`sim'): cscore `N' 25     	
	use `sim', clear
	append using `tp1'                        // save stats in combined file
	save `tp1', replace                		  
	}	
use 	`tp1', clear
replace size = round(size, 10)
xtile 	csize = size, nquantiles(4)
label 	define csize 1 "80" 2 "240" 3 "730" 4 "2190"
label 	values csize csize
save 	"$w9/part1.dta", replace	


use 	"part1.dta", clear 			   		  
tabstat b0 age limit parcredit b1 
scatter b0 b1 csize, ///
		mcolor(erose%10 sienna%10) ///
		ytitle("Betas") ///
		xtitle("Sample Size") ///
		legend(pos(5) ///
		ring(0) ///
		lab(1 "No controls") ///
		lab(2 "Controls")) ///
		xlabel(, valuelabel)
graph	save "$w9/graphp1.gph", replace

 
/* Part 2: Biasing a parameter estimate using controls-------------------------
	- x4 that affects Y as a f(treatment); (exc. treatment)
	- x5 that affects Y and P(treat = 1) */

clear		
capture program drop cscore2		
program define cscore2, rclass		          // define the program
args    obs effect		     			      // require sample size
clear
									        
set 	obs 5 					 			  // gen strata (GU grad school) 
gen     r1 = runiform()					      // values between 0 & 1
sort 	r1									  // order rows low to high
gen     pct = r1[_n+1]-r1  					  // pct = intervasl bw rows
replace pct = 1-r1 if pct == .				  // incl. interval bw last row & 1 
set 	obs 6								  // add 6th strata group
replace pct = r1[1] if pct == . 			  // incl. interval bw 0 & 1st row 
replace pct = (.9/6) + .1*(pct)			      // sum of varied strata = 1
gen 	ssize = pct*`obs'               	  // vary obs per school

gen     school = _n							  // school variable
gen 	e1 = rnormal(1.5)  			          // school effects on Y
gen 	t1 = school+runiform(-2,2)			  // school effects on treated = 1    
		
expand  ssize								  // gen obs
bysort  school: gen schoolid = _n 		      // student id by school
gen 	id = _n								  // obs id 
gen     e2 = rnormal(0,2) 	      			  // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew 
xtile 	xage = age, nquantiles(6)   	 	  // 		  	
gen  	t2 = xage+runiform(-1,1)              // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered)
gen     invlim = -1*limit 					  // 
xtile 	xlimit = invlim, nquantiles(6)   	  // assign higher # to low values	
gen 	t3 = xlimit+runiform(1,2)  			  // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

gen 	female = runiformint(0,1)			  // gender (collider)
gen 	t4 = 2*female					      // gender effects on treated = 1

egen 	rank = rank(t1 + t2 + t3 + t4)		  // rank treated = 1 effects
gen 	treatment = rank >= _N/2			  // assign treatment 50/50 

gen 	u1 = runiformint(1,3)                 // treatment on treatment
gen 	ttreatment = treatment				  
replace ttreat = 0 if treat == 1 & u1 == 1 
		        
		*-----------------||  DGP for credit score (Y) ||----------------*	
		gen y = 0          ///				       	 y | dependent 
		+ 7.6*age   	   ///                     age | positive 
		+ .67*par   	   ///               parcredit | positive  
		+ 9.5*e1           ///			   	    school | noise
		+ 9.5*e2           ///		 		   student | noise
		+ -20*female       ///					female | negative
		+ (`effect'*1.5)*(tt*rnormal(1,.5))   // treat | positive +noise 		
		replace y = round(y, 1)
		*----------------------------------------------------------------*

xtset, 	clear						 		  // set strata for fe
xtset 	school

xtreg 	y treatment, rob fe   				  // reg 1 
matrix 	a = r(table)				     		  
return 	scalar obs = `obs'
return 	scalar b0 = a[1,1]
return 	scalar p0 = a[4,1]

xtreg 	y trea fem ag lim parcr, rob fe   	  // reg 2 
matrix 	a = r(table)				     		  
return 	scalar b1 = a[1,1]
return 	scalar p1 = a[4,1]

xtreg 	y trea tt fem ag lim parcr, rob fe    // reg 3 
matrix 	a = r(table)				     		  
return 	scalar b1tt = a[1,1]

xtreg 	y treat ttreat, rob fe    		   	  // reg 4 
matrix 	a = r(table)				
return 	scalar ttreat = a[1,1]

xtreg 	y treat female, rob fe    		      // reg 5 
matrix 	a = r(table)				
return 	scalar female = a[1,1]
                                  
xtreg 	y treat age, rob fe			 		  // reg 6 
matrix 	a = r(table)				
return 	scalar age = a[1,1]

xtreg 	y treat limit, rob fe		 		  // reg 7 
matrix 	a = r(table)				 
return 	scalar limit = a[1,1]

xtreg 	y treat parcredit, rob fe    		  // reg 8 
matrix 	a = r(table)				
return 	scalar parcredit = a[1,1]

end   			
	
				*---------*--SIMULATE--*---------*					     
clear
tempfile tp2	                              // tempfile
save `tp2', replace emptyok 		   
forvalues i=4/7{						      // simulate loop
	local N = round(3^`i',10)			      // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) b0=r(b0) b1=r(b1)    ///
			 b1tt=r(b1tt) ttreat=r(ttreat)    ///
			 female=r(female) age=r(age) 	  ///
			 limit=r(limit) 		 		  ///
			 parcredit=r(parcredit), 		  ///    
			 reps(500) seed(135792)           ///
			 saving(`sim'): cscore2 `N' 25     	
	use `sim', clear
	append using `tp2'                        // save stats in combined file
	save `tp2', replace                		  
	}	
use 	`tp2', clear
replace size = round(size, 10)
xtile 	csize = size, nquantiles(4)
label 	define csize 1 "80" 2 "240" 3 "730" 4 "2190"
label 	values csize csize
save 	"$w9/part2.dta", replace	


use 	"part2.dta", clear 			   		  
tabstat b0 age limit parcredit female ttreat
tabstat b0 b1 b1tt
scatter b0 b1 csize, ///
		mcolor("168 135 36%12" "115 128 77%12") ///
		ytitle("Betas") ///
		xtitle("Sample Size") ///
		legend(pos(5) ///
		ring(0) ///
		lab(1 "No controls") ///
		lab(2 "Controls")) ///
		xlabel(, valuelabel)
graph	save "$w9/graphp2.gph", replace	   		  
		