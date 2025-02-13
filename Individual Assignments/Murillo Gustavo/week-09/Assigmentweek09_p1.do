*******************************************************************************
*** PPOL 768-01
*** Student: Gustavo Murillo Velazquez
*** Week 09 Assignment - Part 1
*******************************************************************************

cd "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-09/"

set seed 2023
clear 

capture program drop week09
program define week09, rclass
	syntax, strata(integer) samplesize(integer)
	clear
	
set obs 10
gen school = _n
gen school_effects = rnormal(1,2)  // school effects
gen urban = runiform()<0.50 //randomly assign urban/rural status
expand 6 //creating 6 classroom in each school
bysort school: generate classroom = _n //create classroom id
generate class_effects = rnormal(0,3) // generation classroom effects

expand 20+int((35-20+1)*runiform()) //generate student level dataset, each school-class will have 20-35 students
bysort school classroom: generate child = _n //generate student ID
generate student_effects = rnormal(0,5) //create student level effects 

gen parent_income = runiform()*80000 + 20000
gen parent_edu = round(runiform()*15)
gen student_iq = round(rnormal(100, 15))

* Variable to determine students whose family already receive government assistance
gen public_assist = .
replace public_assist = 1 if runiform() < 0.3
replace public_assist = 0 if runiform() >= 0.3

* Treatment variable
gen treatment = .
replace treatment = 1 if runiform() < 0.5
replace treatment = 0 if runiform() >= 0.5

**Changing treatment variable to give more weight to those observations who already receive public assistance
replace treatment = 1 if public_assist == 1 & treatment == 0 & runiform() < 0.8
replace treatment = 0 if public_assist == 0 & treatment == 1 & runiform() < 0.9


*DGP
gen GPA = 10 + parents_edu*0.2 + parents_income*0.1 + iq*0.5 + treatment*5 + rnormal()


*Regression 1: 
reg GPA treatment
mat a = r(table)
return scalar Beta1 = a[1,1]

*Regression 2: 
reg GPA treatment urban student_iq parent_edu 
mat a = r(table)
return scalar Beta2 = a[1,1]

*Regression 3: 
reg GPA treatment urban student_iq parent_edu i.school  
mat a = r(table)
return scalar Beta3 = a[1,1]

*Regression 4: 
reg GPA treatment urban student_iq parent_edu i.classroom
mat a = r(table)
return scalar Beta4 = a[1,1]

*Regression 5: 
reg GPA treatment urban student_iq parent_edu  i.(school classroom)
mat a = r(table)
return scalar Beta5 = a[1,1]

return scalar N=`c(N)'

end

clear

tempfile combined
save `combined', replace emptyok
tempfile sims

forvalues i=1/8 {
	local samplesize= `i'
	tempfile sims
	simulate N=r(N) beta1=r(Beta1) beta2=r(Beta2) beta3=r(Beta3) beta4=r(Beta4) beta5=r(Beta5), reps(500) seed(2023) saving(`sims', replace): regressions, samplesize(`samplesize')
	
	use `sims' , clear
	append using `combined'
	save `combined', replace
}
}

tabstat beta1 beta2 beta3 beta4 beta5, by(samplesize)

twoway (histogram beta1 n, color(red)) ///
       (histogram beta2 samplesize, color(blue)) ///
       (histogram beta3 samplesize, color(green)) ///
       (histogram beta4 samplesize, color(purple)) ///
       (histogram beta5 samplesize, color(orange)) ///
       , ytitle("Beta Values") xtitle("Sample Size") ///
       legend(order(1 "Beta1" 2 "Beta2" 3 "Beta3" 4 "Beta4" 5 "Beta5")) ///
       title("Line Graph of Beta Values")
