*Week 09 Assignment
*Daniel Fang

// Part 2: Biasing a parameter estimate using controls

** Develop data generating process
capture program drop regressions
program define regressions, rclass
syntax, samplesize(integer)

clear
set seed 1234

*** School level
set obs `samplesize'
gen school = _n
gen u_i = rnormal(0,2)

*** Set up confounding variables
gen urban = runiform() < 0.5

*** Set up covariates

// NUMBER OF CLASSROOMS
expand 10
bysort school: generate classroom = _n 
gen u_ij = rnormal(0,3)

// years of faculty experience
bysort school: gen teach_exp = 5 + int((20 - 5 + 1) * runiform())
expand 16 + int((25 - 16 + 1) * runiform())

// student ID
bysort school classroom: generate child = _n
generate e_ijk = rnormal(0,5)

// mother education
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"

// treatment
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
gen z = 0.5*treat + rnormal()
generate score = 70 ///
        + 5*z ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* mother_educ ///
        + u_i + u_ij + e_ijk
gen c = score + 3*treat + rnormal()
reg score treat 
mat a = r(table)
return scalar Beta1 = a[1,1]
reg score treat urban teach_exp mother_educ 
mat a = r(table)
return scalar Beta2 = a[1,1]
reg score treat c urban teach_exp mother_educ c 
mat a = r(table)
return scalar Beta3 = a[1,1]
reg score treat urban teach_exp mother_educ i.school
mat a = r(table)
return scalar Beta4 = a[1,1]
reg score treat urban teach_exp mother_educ i.(school classroom)
mat a = r(table)
return scalar Beta5 = a[1,1]
end


clear
tempfile combined2
save `combined2', replace emptyok
forvalues i=1/8 {
	local samplesize= 2^`i'
	tempfile sims
	simulate beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
	, reps(500) seed(1234) saving(`sims') ///
	: regressions, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined2'
	save `combined2', replace
}


tabstat beta1 beta2 beta3 beta4 beta5, by(samplesize)
twoway (line beta1 samplesize, color(red)) ///
       (line beta2 samplesize, color(blue)) ///
       (line beta3 samplesize, color(green)) ///
       (line beta4 samplesize, color(purple)) ///
       (line beta5 samplesize, color(orange)) ///
       , ytitle("Beta values") xtitle("Sample size") ///
       legend(order(1 "Beta1" 2 "Beta2" 3 "Beta3" 4 "Beta4" 5 "Beta5")) ///
       title("Line Graph of Beta Values")
