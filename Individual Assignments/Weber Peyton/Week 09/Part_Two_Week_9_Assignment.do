*PPOL 768, Research Design & Implementation
*Author: Peyton Weber
*Week 9 Assignment 

cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 09"
*Reviewer to change working directory accordingly 
*Clear before running code. 
clear all 

*Part 2: 

*Using capture program drop so that re-running the .do file is feasible. 
capture program drop RDI
*Define the program.
program define RDI, rclass
*Sample size will be the argument in the defined program. 
syntax, samplesize(integer) 
clear
*Create empty observations. 
set obs `samplesize'
*Create school observations, like in in-class exercise. 
gen school = _n
*Ali's notes say the following code is "school effects," but I don't recall what he means by this.
gen u_i = rnormal(0,2)
*Create new variables that randomly assign the observations to either be rural or ubran.
gen urban = runiform()<0.50
*Create ten classrooms in each school. 
expand 10
*Generate classroom IDs by sorting the school variable and then using the subsequent order of observations, _n. 
bysort school: generate classroom = _n 
*Classroom effects (? don't know what this means) 
gen u_ij = rnormal(0,3)
*Creating a variable for years of teaching experience. 
bysort school: generate teach_exp = 5+int((20-5+1)*runiform())
*Generate student-level dataset where each school-class will have 16-25 students.
expand 16+int(10*runiform())
*Create student IDs
bysort school classroom: generate child = _n 
*Create student-level effects
generate e_ijk = rnormal(0,5)
*Let's now create a variable representing a given mother's level of education. 
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
*Create labeled categories of various levels of education. 
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
*Create the treatment. 
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)

gen z = 0.5*treat + rnormal()
*Replicating something we did in class.
generate score = 70 ///
        + 5*z ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* mother_educ ///
        + u_i + u_ij + e_ijk
		
gen h = score + 3*treat + rnormal()

*First regression:
reg score treat
mat a = r(table)
return scalar Beta1 = a[1,1]

*Second regression:
reg score treat urban teach_exp mother_educ 
mat a = r(table)
return scalar Beta2 = a[1,1]

*Third regression: 
reg score treat h urban teach_exp mother_educ 
mat a = r(table)
return scalar Beta3 = a[1,1]

*Fourth regression: 
reg score treat urban teach_exp mother_educ i.school
mat a = r(table)
return scalar Beta4 = a[1,1]

*Fifth regression: 
reg score treat urban teach_exp mother_educ i.(school classroom)
mat a = r(table)
return scalar Beta5 = a[1,1]

return scalar N=`c(N)'

end 

clear
*Defining a temporary space Stata to store data created in loop to follow:
tempfile combinedtwo
*Telling Stata not to present an error message that the tempfile has no data in it.
save `combinedtwo', replace emptyok

forvalues i=1/8 {
	local samplesize= 2^`i'
	display as error "iteration = `i'" 
	tempfile sims
	simulate n=r(N) beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
	, reps(50) seed(4454) saving(`sims') ///
	: RDI, samplesize(`samplesize') 
	 
	use `sims', clear
	gen samplesize = `samplesize'
	append using `combinedtwo'
	save `combinedtwo', replace 
}

tabstat beta1 beta2 beta3 beta4 beta5, by(n)
twoway (lpolyci beta1 n, color(orange) fc(gray%15)) ///
       (lpolyci beta2 n, color(green) fc(gray%15)) ///
       (lpolyci beta3 n, color(purple) fc(gray%15)) ///
       (lpolyci beta4 n, color(blue) fc(gray%15)) ///
       (lpolyci beta5 n, color(red) fc(gray%15)) ///
       , ytitle("Beta values") xtitle("Sample size") ///
       legend(order(2 "Beta1" 4 "Beta2" 6 "Beta3" 8 "Beta4" 10 "Beta5")) ///
       title("Line Graph of Beta Coefficients")

