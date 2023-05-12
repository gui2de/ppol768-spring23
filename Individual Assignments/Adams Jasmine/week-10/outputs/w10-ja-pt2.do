*	 																		   *
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 10 						       *
*						      Updated: May 2023						       	   *
*							     w10-ja-pt2.do								   *
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
capture program drop cscore3		
program define cscore3, rclass		          // define the program
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
		
expand  ssize								  // gen obs
gen 	id = _n								  // obs id 
bysort 	sch: gen e1=(5*sch)+runiform(1,6)-5   // cluster effects on Y
gen		clust = int(e1)
gen 	t1 = clust*runiform(-.01,.01)     	  // cluster effects on treated = 1
gen     e2 = rnormal(0,3) 	  	   			  // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew 
xtile 	xage = age, nquantiles(6)   	 	  // 		  	
gen  	t2 = xage+runiform(-1,0)              // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered)
gen     invlim = -1*limit 					  // 
xtile 	xlimit = invlim, nquantiles(6)   	  // assign higher # to low values	
gen 	t3 = xlimit+runiform(0,1)             // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

egen 	rank = rank(t1 +t2 +t3)	  			  // rank treated = 1 effects
bysort 	clust: egen clrank = total(rank/_N)   // rank effects by cluster
gen 	treatment = clrank >= _N/2			  // assign cluster treatment 50/50 
		      
		        
		*-----------------||  DGP for credit score (Y) ||----------------*	
		gen y = 550		   ///				       	 y | dependent 
		- 1.3*`effect'     ///				  constant | balance large teffects
		+ 3*age   	   	   ///                     age | positive 
		+ 0.1*par          ///               parcredit | positive  
		+ 2*e1             ///			   	   cluster | noise
		+ 5*e2             ///		 		   student | noise
		+ `effect'*(treat*rnormal(1,.5))      // treat | positive +noise        		
		replace y = round(y, 1)
		*----------------------------------------------------------------*						 		 

reg 	y treatment, vce(rob)   			  // reg 1 
matrix 	a = r(table)				     		  
return 	scalar obs = `obs'
return 	scalar b0 = a[1,1]
return 	scalar ciupper0 = a[6,1]
return 	scalar cilower0 = a[5,1]

reg 	y treat age lim parcr, vce(rob)       // reg 2 
matrix 	a = r(table)				     		  
return 	scalar b1 = a[1,1]
return 	scalar ciupper1 = a[6,1]
return 	scalar cilower1 = a[5,1]

end 

*-----------------------------------SIMULATE-1----------------------------------

clear
tempfile tp1		                       	  // tempfile
save `tp1', replace emptyok 		   
forvalues i=1/10{						  	  // simulate loop
	local N = 500*`i'					  	  // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) b0=r(b0) b1=r(b1)	  ///
			 cilower0=r(cilower0) 			  ///			  
			 cilower1=r(cilower1)			  ///
			 ciupper0=r(ciupper0) 			  ///
			 ciupper1=r(ciupper1), 			  ///
			 reps(50) seed(135799)           ///
			 saving(`sim'): cscore3 `N' 30    	
	use `sim', clear
	append using `tp1'                    	  // save in combined file
	save `tp1', replace                		  
	}
	
use 	`tp1', clear						  // data cleaning
replace size = round(size, 10)
label 	variable size "Sample Size"
save 	"$w10/part2a.dta", replace	

*------------------------------------ANALYZE-1----------------------------------

use 	"part2a.dta", clear  
bysort 	size: egen acilower = mean(cilower1)
bysort 	size: egen aciupper = mean(ciupper1)
gen    	acirange = aciupper - acilower  
	
	
reg		b1 if size == 500
matrix 	a = r(table)	
matrix 	list a		     		  
gen 	eciupper = a[6,1] if size == 500
gen 	ecilower = a[5,1] if size == 500   

forvalues i=1/10 {
	reg		b1 if size == `i'*500
	matrix 	a = r(table)	
	matrix 	list a		     		  
	replace eciupper = a[6,1] if size == `i'*500
	replace ecilower = a[5,1] if size == `i'*500
	}	
gen 	ecirange = eciupper - ecilower    

tabstat acilower ecilower aciupper eciupper acirange ecirange, by(size) 

graph 	bar acirange, over(size) ///
		bar(1, fcolor(dknavy) ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Analytic Range")
graph 	save "$w10/graphp2a.gph", replace                         

graph 	bar ecirange, over(size) ///
		bar(1, fcolor("204 153 0%80") ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Exact Range")  
graph 	save "$w10/graphp2b.gph", replace
             
*/

*-----------------------------------PROGRAM-2-----------------------------------

clear		
capture program drop cscore4		
program define cscore4, rclass		          // define the program
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
		
expand  ssize								  // gen obs
gen 	id = _n								  // obs id 
bysort 	sch: gen e1=(5*sch)+runiform(1,6)-5   // cluster effects on Y
gen		clust = int(e1)
gen 	t1 = clust*runiform(-.01,.01)     	  // cluster effects on treated = 1
gen     e2 = rnormal(0,3) 	  	   			  // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew 
xtile 	xage = age, nquantiles(6)   	 	  // 		  	
gen  	t2 = xage+runiform(-1,0)              // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered)
gen     invlim = -1*limit 					  // 
xtile 	xlimit = invlim, nquantiles(6)   	  // assign higher # to low values	
gen 	t3 = xlimit+runiform(0,1)             // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

egen 	rank = rank(t1 +t2 +t3)	  			  // rank treated = 1 effects
bysort 	clust: egen clrank = total(rank/_N)   // rank effects by cluster
gen 	treatment = clrank >= _N/2			  // assign cluster treatment 50/50 
		      
		        
		*-----------------||  DGP for credit score (Y) ||----------------*	
		gen y = 550		   ///				       	 y | dependent 
		- 1.3*`effect'     ///
		+ 3*age   	   	   ///                     age | positive 
		+ 0.1*par          ///               parcredit | positive  
		+ 2*e1             ///			   	   cluster | noise
		+ `effect'*(treat*rnormal(1,.5))      // treat | positive +noise        		
		replace y = round(y, 1)
		*----------------------------------------------------------------*						 		 

xtset 	clust
xtreg 	y treat age lim parcr, vce(rob) re	  // reg 1
matrix 	a = r(table)				     		  
return 	scalar obs = `obs'
return 	scalar b0 = a[1,1]
return 	scalar ciupper0 = a[6,1]
return 	scalar cilower0 = a[5,1]

reg 	y treatment age lim parcr, vce(rob)	  // reg 2 
matrix 	a = r(table)				     		  
return 	scalar b1 = a[1,1]
return 	scalar ciupper1 = a[6,1]
return 	scalar cilower1 = a[5,1]

end 

*-----------------------------------SIMULATE-2----------------------------------

clear
tempfile tp2		                       	  // tempfile
save `tp2', replace emptyok 		   
forvalues i=1/10{						  	  // simulate loop
	local N = 500*`i'					  	  // indicate sample sizes
	tempfile sim						   
	simulate size=r(obs) b0=r(b0) b1=r(b1)	  ///
			 cilower0=r(cilower0) 			  ///			  
			 cilower1=r(cilower1)			  ///
			 ciupper0=r(ciupper0) 			  ///
			 ciupper1=r(ciupper1), 			  ///
			 reps(50) seed(135799)            ///
			 saving(`sim'): cscore4 `N' 30    	
	use `sim', clear
	append using `tp2'                    	  // save in combined file
	save `tp2', replace                		  
	}
	
use 	`tp2', clear						  // data cleaning
replace size = round(size, 10)
label 	variable size "Sample Size"
save 	"$w10/part2b.dta", replace		

*------------------------------------ANALYZE-1----------------------------------

use 	"part2b.dta", clear  
bysort 	size: egen acilower = mean(cilower1)
bysort 	size: egen aciupper = mean(ciupper1)
gen    	acirange = aciupper - acilower  

bysort 	size: egen acilower0 = mean(cilower0)
bysort 	size: egen aciupper0 = mean(ciupper0)
gen    	acirange0 = aciupper0 - acilower0 
	
reg		b0 if size == 500
matrix 	a = r(table)	
matrix 	list a		     		  
gen 	eciupper0 = a[6,1] if size == 500
gen 	ecilower0 = a[5,1] if size == 500   

forvalues i=1/10 {
	reg		b0 if size == `i'*500
	matrix 	a = r(table)	
	matrix 	list a		     		  
	replace eciupper0 = a[6,1] if size == `i'*500
	replace ecilower0 = a[5,1] if size == `i'*500
}
	
reg		b1 if size == 500
matrix 	a = r(table)	
matrix 	list a		     		  
gen 	eciupper = a[6,1] if size == 500
gen 	ecilower = a[5,1] if size == 500   

forvalues i=1/10 {
	reg		b1 if size == `i'*500
	matrix 	a = r(table)	
	matrix 	list a		     		  
	replace eciupper = a[6,1] if size == `i'*500
	replace ecilower = a[5,1] if size == `i'*500
}

gen    	ecirange = eciupper - ecilower    

tabstat acilower ecilower aciupper eciupper acirange ecirange, by(size) 

graph 	bar acirange, over(size) ///
		bar(1, fcolor(dknavy) ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Analytic Range")
graph 	save "$w10/graphp2c.gph", replace                         

graph 	bar ecirange, over(size) ///
		bar(1, fcolor("204 153 0%80") ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Exact Range")
graph 	save "$w10/graphp2d.gph", replace

graph 	bar acirange0, over(size) ///
		bar(1, fcolor(dknavy) ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Analytic Range")
graph 	save "$w10/graphp2e.gph", replace 

graph 	bar ecirange0, over(size) ///
		bar(1, fcolor("204 153 0%80") ///
		lcolor(none)) ///
		legend(ring(0) pos(2)) ///
		ytitle("Exact Range")
graph 	save "$w10/graphp2f.gph", replace


