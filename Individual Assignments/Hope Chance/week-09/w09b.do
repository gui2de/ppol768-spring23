*Chance Hope
*Week 9
   global w9 "$C:\Users\maxis\Desktop\ppol768-spring23\Individual Assignments\Hope Chance\week-09"
   cd "$w9"
/*
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
capture program drop prog1		
program define prog1, rclass 
args    nlower nupper // school size bounds
set seed 896124
clear
set obs 6 				// number of schools 
generate school = _n
generate effect_school = rnormal(0,2)  // SCHOOL EFFECTS
generate treat_school = school*rnormal() // TREAT EFFECTS
expand `nlower'+int((`nupper'-`nlower'+1)*runiform()) // student level dataset

* Student
generate student = _n //generate student ID
generate effects_student = rnormal(0,5)
* Age
bysort school: gen age = 21+int((30-21+1)*runiform())  
* Grades
gen grades = runiform(2,4) 
*Income
gen temprand = runiform()<.3
gen income = runiform(300,9000)
replace income = 0 if temprand == 1

gen treat_age = (age-20)*rnormal
gen treat_grades = ()

egen rank = rank(t1 + t2 + t3 + t4)		  // rank treatment effects
gen tsize = _N							  // total sample size
gen treatment = rank >= tsize/2			  // assign treatment 50/50 


gen 
local treat_num = `samplesize'/2
egen rank = rank(rand)
gen treatment = rank <= `treat_num'

  // DGP
  gen y = x1 + treatment*runiform() // Heterogeneous, positive effect
generate treatment = runiform()<0.50 //randomly assign urban/rural status

*DGP
generate score = 70 + (-2)*urban + 1.5*teach_exp + 0*meduc1 + 2*meduc2 + 5*meduc3 + u_i + u_ij + e_ijk
		
reg score urban teach_exp meduc2 meduc3		
*check if betas are the same/similar to DGP	

    xtset, clear
    xtset school
    xtreg score treatment, rob fe
    matrix a = r(table)
    return scalar obs = tsize
    return scalar b0 = a[1,1]

    xtreg score treatment zage, rob fe
    matrix a = r(table)
    return scalar bage = a[1,1]

    xtreg score treatment zlimit, rob fe
    matrix a = r(table)
    return scalar blimit = a[1,1]

    xtreg score treatment zparcredit, rob fe
    matrix a = r(table)
    return scalar bparcred = a[1,1]

    xtreg score treatment zage zlimit zparcredit, rob fe
    matrix a = r(table)
    return scalar b1 = a[1,1]
end

clear
tempfile tp1
save `tp1', replace emptyok
forvalues i=1/10 {
    local N = 50*`i'
    tempfile sim
    simulate size=r(obs) b0 = r(b0) bage = r(bage) blimit = r(blimit) bparcred = r(bparcred) b1 = r(b1), reps(100) seed(135791) saving(`sim'): fincap_modified `N'
    use `sim', clear
    gen i = `i'
    gen irow = _n
    append using `tp1'
    save `tp1', replace
}

use `tp1', clear
save "$w9/part1.dta", replace
sort i irow

scatter b0 b1 i, mcolor(navy%10 sienna%10) ytitle("Betas") xtitle("Sample Size") legend(pos(5) ring(0) lab(1 "No controls") lab(2 "Controls"))
 
/* Part 2: Biasing a parameter estimate using controls-------------------------
	- x4 that affects Y as a f(treatment); (exc. treatment)
	- x5 that affects Y and P(treat = 1) */
  
capture program drop fincap2		
program define fincap2, rclass		          // define the program
args    obs		     				          // require sample size
*set 	seed 135793							  // set seed
clear

set 	obs 6 					 			  // gen strata (GU grad school) 
gen 	school = _n							  // school variable
gen 	e1 = rnormal(1.5)  			          // school effects on Y
gen 	t1 = school+runiform(-3,3)			  // school effects on treated = 1
*gen 	size = ///                            // vary obs per school
*       round(rnormal(`obs',`obs'*.1))      
gen 	size = ///                            // vary obs per school
        round(rnormal(200,200*.1))      

expand  size								  // gen obs  
bysort  school: gen id = _n 		          // student variable
gen     e2 = rnormal(0,2) 	      		  	  // student effects on Y 
				     
gen 	age = int(rnormal(25,3))              // age  
replace age = age+runiformint(5,10) if age<20 // (min = 20); right skew 
xtile 	xage = age, nquantiles(6)   	 	  // 		  	
gen  	t2 = xage+runiform(-3,3)              // age effects on treated = 1 
											  
gen 	limit = rnormal(20000,3500)           // credit limit (mean centered)
gen     invlim = -1*limit 					  // 
xtile 	xlimit = invlim, nquantiles(6)   	  // assign higher # to low values	
gen 	t3 = xlimit+runiform(-3,3)            // limit effects on treated = 1

gen     parcredit = int(rnormal(750,35))      // parents credit 

gen 	female = runiformint(0,1)			  // gender (collider)
gen 	t4 = (2*female)+runiform(-3,3)        // gender effects on treated = 1

egen 	rank = rank(t1 + t2 + t3 + t4)		  // rank treatment effects
gen 	tsize = _N							  // total sample size
gen 	treatment = rank >= tsize/2			  // assign treatment 50/50 

gen 	reward = 10000*treat*rbeta(4,2)       // reward (mediator) (left skew)
gen 	u1 = runiformint(1,12)				  //
replace reward = 0 if u1 == 6				  // 0 reward = 0 treatment effect

tabstat t1 t2 t3 e1 e2, ///					  // Review effect sizes  			
statistics(mean min max) ///
columns(statistics) format(%9.0g)
 
 
		*-----||  DGP for financial capability score (Y) ||-----*

		gen y1 =  0  ///			           	   y1 | dependent 
		+ 1.2*age    ///                       	  age | positive 
		+ .05*par    ///                  	parcredit | positive  
		+ e1         ///			     	   school | noise
		+ e2         ///				      student | noise
		+ female*rnormal(-2)		      ///  female | negative + noise
		+ .0003*(reward*rnormal(1,.25))   ///   treat | positive + noise  

					*---------------------------------*

egen y = std(y1)                      // standardize variables
egen zage = std(age)				 
egen zlimit = std(limit)
egen zparcredit = std(parcredit)
egen zreward = std(reward)

xtset, clear						 // set strata for fe
xtset school

xtreg y treat, rob fe	    		 // reg 1
matrix a = r(table)                  // store results 					     
return scalar obs = tsize		 
return scalar b0 = a[1,1]

xtreg y treat zreward, rob fe		 // reg  
matrix a = r(table)				     // store results
return scalar breward = a[1,1]

xtreg y treat female, rob fe		 // reg  
matrix a = r(table)				     // store results
return scalar bfem = a[1,1]

xtreg y treat zr fem za, rob fe	 	 // reg  
matrix a = r(table)				     // store results
return scalar bconf = a[1,1]

xtreg y tr zr fem za zl zp, rob fe	 // reg  
matrix a = r(table)				     // store results
return scalar b1 = a[1,1]

end                      
				*---------*--SIMULATE--*---------*					     
clear
tempfile tp2	                              // tempfile
save `tp2', replace emptyok 		   
forvalues i=1/10{						      // simulate loop
	local N = 50*`i'			     	      // indicate strata sample sizes
	tempfile sim						   
	simulate size=r(obs)            ///
			 b0 = r(b0)             ///
			 bage = r(bage)         ///
			 blimit = r(blimit)     ///
			 bparcred = r(bparcred) ///			
			 b1 = r(b1),            ///     
			 reps(100)              ///
			 seed(135791)           ///
			 saving(`sim'): fincap `N'     	
	use `sim', clear
	gen i =`i'
	gen irow = _n
	append using `tp2'                        // save stats in combined file
	save `tp2', replace                		  
	}
	
use `tp2', clear
save "$w9/part2.dta", replace	
sort i irow			   		  

scatter b0 b1 i, ///
		mcolor(erose%12 sienna%10) ///
		ytitle("Betas") ///
		xtitle("Sample Size") ///
		legend(pos(5) ///
		ring(0) ///
		lab(1 "No controls") ///
		lab(2 "Controls"))
