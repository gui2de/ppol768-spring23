*Chance Hope
*Week 10
global week10 "C:\Users\maxis\Desktop\ppol768backup\week-10"
cd "$week10"
clear

*Pt.1
power twomeans 725 735, power(.8) sd(20)

capture program drop prog10		
program define prog10, rclass 
args nlower nupper effect
clear
set obs 6 

* School 
generate school = _n 
gen school_effects  = rnormal(0,2)
* Student
gen random =`nlower'+int((`nupper'-`nlower'+1)*runiform())
expand random
generate student = _n
* Age
bysort school: gen age = 20+int((30-20+1)*runiform())  
* Grades
gen grades =runiform(2,4) 
*Income
gen temprand =runiform()<.3
gen income =runiform(300,9000)
replace income = 0 if temprand == 1

* Variable effects 
gen treat_school = school*rnormal()
gen treat_age = (age/10)*rnormal()
gen treat_grades = grades*rnormal()
gen student_effects = rnormal(0,3)
gen age_effects = age-25
gen income_effects = (.5*income)/1000
*Treatment
gen treat_total = 2*(treat_school+treat_age+treat_grades) 
egen rank =rank(treat_total)
gen samplesize = _N
gen treatment = rank >.5*samplesize
*DGP
generate score = 720 + (`effect'*treatment) + runiform(0,7)*(school_effects +student_effects+age_effects+income_effects)

*Regressions
*1	
xtset, clear	
xtset school  					     
xtreg score treatment 	
matrix a = r(table)
return scalar N = _N
return scalar beta1 = a[1,1]
return scalar pvalue1 = a[4,1]
*2
xtreg score treatment income age grade
matrix a = r(table)
return scalar N = _N
return scalar beta2 = a[1,1]
return scalar pvalue2 = a[4,1]
end

*Part 1.1
clear
tempfile combined
save `combined', replace emptyok

forvalues i = 1/6 {
  local nlower=5*`i'
  local nupper = 5*`i'*1.03
  tempfile sims1
  simulate beta1=r(beta1) beta2=r(beta2) N=r(N) pvalue1=r(pvalue1) pvalue2=r(pvalue2), reps(200) seed(163075) saving(`sims1'): prog10 `nlower' `nupper' 10
  use `sims1', clear
  gen reps = _N
  append using `combined'
  save `combined', replace
}
 
use `combined', clear
save "week10pt1", replace 

use "week10pt1", clear

replace N = round(N, 30) 
gen sig1 = pvalue1 < 0.05 
bysort N: egen power1 = mean(sig1)

gen sig2 = pvalue2 < 0.05 
bysort N: egen power2 = mean(sig2)

*Graphs Part 1.1
scatter power1 N
scatter power2 N

*Part 1.2

clear
tempfile combined
save `combined', replace emptyok

forvalues i = 5/12 {
  local effectsize=`i'
  tempfile sims1
  simulate beta1=r(beta1) beta2=r(beta2) N=r(N) pvalue1=r(pvalue1) pvalue2=r(pvalue2), reps(50) seed(604352) saving(`sims1'): prog10 17 17 `effectsize'
  use `sims1', clear
  gen effectsize = `effectsize'
  append using `combined'
  save `combined', replace
}
 
use `combined', clear
save "week10pt1.2.dta", replace 

use "week10pt1.2.dta", clear

replace N = round(N, 5) 
gen sig1 = pvalue1 < 0.05 
bysort effectsize: egen power1 = mean(sig1)

gen sig2 = pvalue2 < 0.05 
bysort  effectsize: egen power2 = mean(sig2)

*Graphs Part 1.2
scatter power1 effectsize
scatter power2 effectsize

*Pt. 2
capture program drop prog102		
program define prog102, rclass 
args nlower nupper effect
clear
set obs 20 

* School clusters
generate school = _n 
gen school_effects  = rnormal(0,2)
gen treatment = runiform() < 0.5
* Student
gen random =`nlower'+int((`nupper'-`nlower'+1)*runiform())
expand random
generate student = _n
* Age
bysort school: gen age = 20+int((30-20+1)*runiform())  
* Grades
gen grades =runiform(2,4) 
*Income
gen temprand =runiform()<.3
gen income =runiform(300,9000)
replace income = 0 if temprand == 1

* Variable effects 
gen student_effects = rnormal(0,3)
gen age_effects = age-25
gen income_effects = (.5*income)/1000

*DGP
generate score = 720 + (`effect'*treatment) + runiform(0,7)*(school_effects +student_effects+age_effects+income_effects)

*Regressions
*1	
reg score treatment income age grade	
matrix a = r(table)
return scalar N = _N
return scalar beta1 = a[1,1]
return scalar ci_upper1 = a[6,1]
return scalar ci_lower1 = a[5,1]
*2
reg score treatment income age grade, vce(robust)
matrix a = r(table)
return scalar N = _N
return scalar beta2 = a[1,1]
return scalar ci_upper2 = a[6,1]
return scalar ci_lower2 = a[5,1]
end

clear
tempfile combined
save `combined', replace emptyok

forvalues i = 1/6 {
  local nlower=5*`i'
  local nupper = 5*`i'*1.03
  tempfile sims1
  simulate beta1=r(beta1) beta2=r(beta2) N=r(N) ci_upper1=r(ci_upper1) ci_lower1=r(ci_lower1)   ci_upper2=r(ci_upper2) ci_lower2=r(ci_lower2), reps(50) seed(160775) saving(`sims1'): prog102 `nlower' `nupper' 10
  use `sims1', clear
  gen reps = _N
  append using `combined'
  save `combined', replace
}
 
use `combined', clear
replace N = round(N, 100) 
save "week10pt2", replace 

use "week10pt2", clear

collapse (mean) mean1 = beta1 (sd) sd1 = beta1, by(N)
gen eci_lower1 = mean-1.96*sd
gen eci_upper1 = mean+1.96*sd

append using "week10pt2"
save "week10pt2", replace 
use "week10pt2", clear

collapse (mean) mean2 = beta2 (sd) sd2 = beta2, by(N)
gen eci_lower2 = mean-1.96*sd
gen eci_upper2 = mean+1.96*sd

append using "week10pt2"
save "week10pt2", replace 
use "week10pt2", clear

bysort N: egen aci_lower1 = mean(ci_lower1)
bysort N: egen aci_lower2 = mean(ci_lower2)
bysort N: egen aci_upper1 = mean(ci_upper1)
bysort N: egen aci_upper2 = mean(ci_upper2)
gen analyticrange1 = aci_upper1 - aci_lower1
gen analyticrange = aci_upper2 - aci_lower2
gen exactrange1 = eci_upper1 - eci_lower1
gen exactrange = eci_upper2 - eci_lower2
graph twoway bar exactrange N, ylabel(0(5)20)
graph twoway bar analyticrange N


*Part 2b
capture program drop prog102b		
program define prog102b, rclass 
args nlower nupper effect
clear
set obs 20 

* School clusters
generate school = _n 
gen school_effects  = rnormal(0,2)
gen treatment = runiform() < 0.5
* Variable effects
gen sim_age = 20+int((30-20+1)*runiform()) 
gen age_effects = sim_age-25

gen temprand =runiform()<.3
gen sim_income =runiform(300,9000)
replace sim_income = 0 if temprand == 1
gen income_effects = (.5*sim_income)/1000

* Student
gen random =`nlower'+int((`nupper'-`nlower'+1)*runiform())
expand random
generate student = _n
* Age
bysort school: gen age = 20+int((30-20+1)*runiform())  
* Grades
gen grades =runiform(2,4) 
*Income
gen temprand2 =runiform()<.3
gen income =runiform(300,9000)
replace income = 0 if temprand == 1

*DGP
generate score = 720 + (`effect'*treatment) + runiform(0,7)*(school_effects +age_effects+income_effects)

*Regressions
*1	
reg score treatment income age grade	
matrix a = r(table)
return scalar N = _N
return scalar beta1 = a[1,1]
return scalar ci_upper1 = a[6,1]
return scalar ci_lower1 = a[5,1]
*2
reg score treatment income age grade, vce(robust)
matrix a = r(table)
return scalar N = _N
return scalar beta2 = a[1,1]
return scalar ci_upper2 = a[6,1]
return scalar ci_lower2 = a[5,1]
end

clear
tempfile combined
save `combined', replace emptyok

forvalues i = 1/6 {
  local nlower=5*`i'
  local nupper = 5*`i'*1.03
  tempfile sims1
  simulate beta1=r(beta1) beta2=r(beta2) N=r(N) ci_upper1=r(ci_upper1) ci_lower1=r(ci_lower1)   ci_upper2=r(ci_upper2) ci_lower2=r(ci_lower2), reps(50) seed(160775) saving(`sims1'): prog102b `nlower' `nupper' 10
  use `sims1', clear
  gen reps = _N
  append using `combined'
  save `combined', replace
}
 
use `combined', clear
replace N = round(N, 100) 
save "week10pt2b", replace 

use "week10pt2b", clear

collapse (mean) mean1 = beta1 (sd) sd1 = beta1, by(N)
gen eci_lower1 = mean-1.96*sd
gen eci_upper1 = mean+1.96*sd

append using "week10pt2b"
save "week10pt2b", replace 
use "week10pt2b", clear

collapse (mean) mean2 = beta2 (sd) sd2 = beta2, by(N)
gen eci_lower2 = mean-1.96*sd
gen eci_upper2 = mean+1.96*sd

append using "week10pt2b"
save "week10pt2b", replace 
use "week10pt2b", clear

bysort N: egen aci_lower1 = mean(ci_lower1)
bysort N: egen aci_lower2 = mean(ci_lower2)
bysort N: egen aci_upper1 = mean(ci_upper1)
bysort N: egen aci_upper2 = mean(ci_upper2)
gen analyticrange1 = aci_upper1 - aci_lower1
gen analyticrange = aci_upper2 - aci_lower2
gen exactrange1 = eci_upper1 - eci_lower1
gen exactrange = eci_upper2 - eci_lower2
graph twoway bar exactrange N, ylabel(0(5)30)
graph twoway bar analyticrange N
 