cd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880"

global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880"

*program generate sample
capture program drop part1
program define part1, rclass 
*samplesize as syntax
syntax, samplesize(integer)
clear
set seed 2020905
set obs `samplesize'

*Multi-level data
gen school = _n 
gen u_i = rnormal(0,2) // School effects
gen public = runiform()<0.6 //Public and private school
expand 9 // create 9 classroom in each school 
bysort school: gen classroom = _n // create classroom id
gen u_ij = rnormal(0,1) //Classroom effects 

*confounder: weekly hours spend on study in school 
bysort school: gen study_hour = 30+(60-30+1)*runiform()
// student spends 12 hours in school every weekday 12*5=60hours
// minimum 6 hours courses on weekdays in every school 6*5=30hours

expand 27+int((27-8+1)*runiform()) //generate student level data each school have 8 to 27 students
bysort school classroom: gen student = _n //create student id
gen e_ijk = rnormal(0,7) //student level effect

*covariate affect treatment not outcome: student-teacher ratio
gen ratio = runiform(8,27)
egen stu_ratio = cut(ratio), at(8, 14, 21, 27) icodes
label define stu_ratio 0 "small" 1 "moderate" 2 "large"

*treatment variable 
gen treatment = cond(study_hour<=40 & stu_ratio>=2, 1, 0)

*covariate affect outcome not treatment: task difficulty
gen task = round(runiform(0, 2), 1)
label define task 0 "easy" 1 "hard"

gen score = 60 ///
    + 5*treatment ///
	+ (-2)*public ///
	+ (-1)*task   ///
	+ 1*study_hour ///
	+ 0*stu_ratio ///
	+ u_i + u_ij + e_ijk

*full regression model  
reg score treatment public task study_hour stu_ratio
mat a=r(table)
return scalar beta1 = a[1,1]

*omit covariate 
reg score treatment public study_hour task
mat a = r(table)
return scalar beta2 = a[1,1]

*omit confounder study hour
reg score treatment public stu_ratio task 
mat a = r(table)
return scalar n3 = e(N)
return scalar beta3 = a[1,1]

*omit task difficulties(affect Y but not treatment)
reg score treatment public study_hour stu_ratio
mat a = r(table)
return scalar beta4 = a[1,1]

*only treatment 
reg score treatment 
mat a = r(table)
return scalar beta5 = a[1,1]
end 

clear
tempfile part1
save `part1', replace emptyok
forvalues i = 1/4 {
	local samplesize = 10^`i'
	tempfile result
	simulate beta1 = r(beta1) beta2 = r(beta2) ///
	beta3 = r(beta3) beta4 = r(beta4) beta5 = r(beta5), ///
	reps (500) seed(20905) saving(`result', replace): ///
	part1, samplesize(`samplesize')
	use `result' , clear
	gen samplesize = `samplesize'
	append using `part1'
	save `part1', replace
}

save "$wd/part1_results.dta", replace

use "$wd/part1_results.dta",clear


tabstat beta1 beta2 beta3 beta4 beta5, by(samplesize)
twoway (line beta1 samplesize, color(green)) ///
       (line beta2 samplesize, color(red)) ///
	   (line beta4 samplesize, color(grey)) 
        , ytitle("beta estimates") xtitle("sample size") ///
	    legend(order(1 "beta1" 2 "beta2" 4"beta4"))

twoway (line beta3 samplesize, color(pink)) ///
       (line beta5 samplesize, color(blue)) ///
       , ytitle("beta estimates") xtitle("sample size") ///
       legend(order(3 "beta3" 5 "beta5")) 
  

