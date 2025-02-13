cd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880"

global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880"

*Part 2

*program generate sample
capture program drop part2
program define part2, rclass 
*samplesize as syntax
syntax, samplesize(integer)
clear
set seed 74204
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

*treatment variable 
gen treatment = round(runiform(0,1),1)

*channel: determine Y, not treatment 
gen channel = 2*treatment+rnormal(20, 5)

*generate Y
gen score = 60 ///
    +3*channel ///
	+(-1)*public ///
	+2*study_hour ///
	+u_i+u_ij+e_ijk
	
*collider: both Y and treatment 
gen tuition = 50*score - 2*treatment + rnormal() 

*true model
reg score channel public study_hour  
mat a = r(table)
return scalar beta1 = a[1,1]
*treatment omit channel
reg score treatment public study_hour 
mat a = r(table)
return scalar beta2 = a[1,1]
*both channel and treatment 
reg score treatment channel public study_hour
mat a = r(table)
return scalar beta3 = a[1,1]
*both treatment and collider 
reg score treatment tuition public study_hour
mat a = r(table)
return scalar beta4 = a[1,1]
*treatment, collider and channel
reg score treatment tuition channel public study_hour
mat a = r(table)
return scalar beta5 = a[1,1]

end

clear
tempfile part2
save `part2', replace emptyok
forvalues i = 1/5 {
	local samplesize = 5^`i'
	tempfile result
	simulate beta1 = r(beta1) beta2 = r(beta2) ///
	beta3 = r(beta3) beta4 = r(beta4) beta5 = r(beta5), ///
	reps(500) seed(1427) saving(`result', replace): ///
	part2, samplesize(`samplesize')
	use `result' , clear
	gen samplesize = `samplesize'
	append using `part2'
	save `part2', replace
}

save "$wd/part2_results.dta", replace

use "$wd/part2_results.dta",clear

tabstat beta1 beta2 beta3 beta4 beta5, by(samplesize)
twoway (line beta1 samplesize, color(red)) ///
       (line beta2 samplesize, color(orange)) ///
       (line beta3 samplesize, color(pink)) ///
       (line beta4 samplesize, color(blue)) ///
	   (line beta5 samplesize, color(green)) ///
        , ytitle("beta estimates") xtitle("sample size") ///
	    legend(order(1 "beta1" 2 "beta2" 3 "beta3" 4 "beta4" 5 "beta5"))
