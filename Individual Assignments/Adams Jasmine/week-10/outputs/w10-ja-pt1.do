*	 																		   *
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 10 						       *
*						      Updated: May 2023						       	   *
*							     w10-ja-pt1.do								   *
*																			   *
* 							   - Program Setup -							   *

   set more off     	
   global main 		"/Users/jasmineadams/Dropbox/R Stata"
   global myrepo   	"$main/repositories/Rsrch-Dsgn"
   global classrepo	"$main/repositories/ppol768-spring23"
   global w10 "$classrepo/Individual Assignments/Adams Jasmine/week-10/outputs"
   cd 				"$w10"
*-----------------------------------PROGRAM-1-----------------------------------

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

cscore 	1000000 20							  // get an idea of mean and sd
xtreg 	y i.treat age lim parcred, rob fe  
margins treatment
sum 	y

cscore	1000000 5
xtreg 	y i.treat age lim parcred, rob fe
margins treatment
sum 	y

power 	twomeans 705 725, power(0.8) sd(40)	  // power calculations
power 	twomeans 710 715, power(0.8) sd(38)                          
        
*-----------------------------------SIMULATE-1----------------------------------
								     
clear
tempfile tp3	                          	  // tempfile
save `tp3', replace emptyok 		   
forvalues i=3/15{						  	  // simulate loop
	local N = `i'*10					  	  // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) p0 = r(p0) p1=r(p1), ///
			 reps(500) seed(135799)           ///
			 saving(`sim'): cscore `N' 20    	
	use `sim', clear
	append using `tp3'                    	  // save in combined file
	save `tp3', replace                		  
	}
	
use `tp3', clear							  // data cleaning
replace size = round(size, 10)
label 	variable size "Sample Size"
label 	variable p0 "No Controls"
label 	variable p1 "Controls"
save 	"$w10/part1a.dta", replace	

*------------------------------------ANALYZE-1----------------------------------

use "part1a.dta", clear 
											  // power calculations
bysort size: egen pw0= total((p0 < 0.05)/_N)  
bysort size: egen pw = total((p1 < 0.05)/_N)
label variable pw0 "Power (No Controls)"
label variable pw "Power (Controls)" 
											  // power vs. N (no controls)
scatter pw0 size, 							  ///                            
yline(.8, lpattern(dash) lcolor("204 153 0")) ///
mcolor("204 153 0%80") legend(pos(5) ring(0))
graph save "$w10/graphp1a0.gph", replace
											  // power vs. N (controls)
scatter pw size, 							  ///							 
yline(.8, lpattern(dash) lcolor(navy)) 		  ///
mcolor(dknavy%80) legend(pos(5) ring(0))
graph save "$w10/graphp1a.gph", replace

*-----------------------------------SIMULATE-2----------------------------------

clear
tempfile tp4	                          	  // tempfile
save `tp4', replace emptyok 		   
forvalues i=1/5{						  	  // simulate loop
	local effect = `i'*5			   	 	  // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) p0 = r(p0) p1=r(p1), /// 
			 reps(500) seed(135799)           ///
			 saving(`sim'): cscore 130 `effect'    	
	use `sim', clear
	gen effect =`i'*5
	append using `tp4'                        // save in combined file
	save `tp4', replace                		  
	}
	
use `tp4', clear							  // data cleaning
replace size = round(size, 10)
label variable size "Sample Size"
label variable p0 "No Controls"
label variable p1 "Controls"
label variable effect "Effect Size"
save "$w10/part1b.dta", replace				   		  

*------------------------------------ANALYZE-2----------------------------------

use "part1b.dta", clear
											  // power calculations
bysort effect: egen pw0= total((p0 < 0.05)/_N) 
bysort effect: egen pw = total((p1 < 0.05)/_N)
label variable pw0 "Power (No Controls)"
label variable pw "Power (Controls)" 
											  // power vs. N (no controls)
scatter pw0 effect, 						  ///                            
yline(.8, lpattern(dash) lcolor("204 153 0")) ///
mcolor("204 153 0%80") legend(pos(5) ring(0))
graph save "$w10/graphp1b0.gph", replace
											  // power vs. N (controls)
scatter pw effect, 							  ///							   
yline(.8, lpattern(dash) lcolor(navy)) 		  ///
mcolor(dknavy%80) legend(pos(5) ring(0))
graph save "$w10/graphp1b.gph", replace

*-----------------------------------SIMULATE-3----------------------------------

clear
tempfile tp5	                          	  // tempfile
save `tp5', replace emptyok 		   
forvalues i=15/21{						  	  // simulate loop
	local N = `i'*100			   	  	  	  // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) p1 = r(p1),   		  /// 
			 reps(500) seed(135799)  		  ///
			 saving(`sim'): cscore `N' 5    	
	use `sim', clear
	append using `tp5'                        // save in combined file
	save `tp5', replace                		  
	}
	
use `tp5', clear							  // data cleaning
replace size = round(size, 10)
label 	variable size "Sample Size"
label 	variable p1 "Controls"
save 	"$w10/part1c.dta", replace			   		  

*------------------------------------ANALYZE-3----------------------------------

use "part1c.dta", clear 
											  // power calculations
bysort size: egen pw = total((p1 < 0.05)/_N)     
label variable pw "Power (Controls)" 
											  // power vs. N (controls)
scatter pw size, 							  ///							   
yline(.8, lpattern(dash) lcolor(navy)) 		  ///
mcolor(dknavy%80) legend(pos(5) ring(0))
graph save "$w10/graphp1c.gph", replace

