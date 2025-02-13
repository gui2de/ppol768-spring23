*Chance Hope
*Week 9
global week9 "C:\Users\maxis\Desktop\ppol768backup\week-09"
cd "$week9"
clear

*Pt.1
capture program drop prog1		
program define prog1, rclass 
args nlower nupper 
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
generate score = 720 + runiform(0,7)*(treatment + school_effects +student_effects+age_effects+income_effects)

* Regressions
*1	
xtset, clear	
xtset school  					     
xtreg score treatment 	
matrix a = r(table)
return scalar N = _N
return scalar beta1 = a[1,1]
*2
xtreg score treatment age
matrix a = r(table)
return scalar N = _N
return scalar beta2 = a[1,1]
*3
xtreg score treatment income	
matrix a = r(table)
return scalar N = _N
return scalar beta3 = a[1,1]
*4
xtreg score treatment income age	
matrix a = r(table)
return scalar N = _N
return scalar beta4 = a[1,1]
*5
xtreg score treatment income age grade
matrix a = r(table)
return scalar N = _N
return scalar beta5 = a[1,1]
end

clear
tempfile combined
save `combined', replace emptyok

forvalues i = 1/4 {
  local nlower=100*`i'
  local nupper = 100*`i'*1.03
  tempfile sims1
  simulate beta1=r(beta1) beta2=r(beta2) beta3=r(beta3) beta4=r(beta4) beta5=r(beta5) N=r(N), reps(500) seed(163075) saving(`sims1'): prog1 `nlower' `nupper'
  use `sims1', clear
  gen samplesize = _N
  append using `combined'
  save `combined', replace
}
 
use `combined', clear
save "week9pt1", replace

gen samplecat =round(N, 600)
bysort samplecat: egen xbeta1 = mean(beta1)
bysort samplecat: egen xbeta2 = mean(beta2)
bysort samplecat: egen xbeta3 = mean(beta3)
bysort samplecat: egen xbeta4 = mean(beta4)
bysort samplecat: egen xbeta5 = mean(beta5)
egen tag = tag(samplec)

list samplec xbeta* if tag == 1, noobs

graph hbox beta1 beta2 beta3 beta4 beta5, by(samplecat)
 
*Pt. 2
capture program drop prog2		
program define prog2, rclass 
args nlower nupper 
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
*Collider
gen collider = runiform(0,6)

* Variable effects 
gen treat_school = school*rnormal()
gen treat_age = (age/10)*rnormal()
gen treat_grades = grades*rnormal()
gen student_effects = rnormal(0,3)
gen age_effects = age-25
gen income_effects = (.5*income)/1000
gen treat_collider = collider*rnormal()
gen collider_effects = collider-3
*Treatment
gen treat_total = 2*(treat_school+treat_age+treat_grades+treat_collider) 
egen rank =rank(treat_total)
gen N = _N
gen treatment = rank >.5*N

*Mediator
gen mediator = runiform(1,3)*treatment
*DGP
generate score = 720 + runiform(0,7)*(mediator + school_effects +student_effects+age_effects+income_effects + collider_effects)
	
* Regressions
*1	
xtset, clear	
xtset school  					     
xtreg score treatment 	
matrix a = r(table)
return scalar N = _N
return scalar beta1 = a[1,1]
*2
xtreg score treatment mediator
matrix a = r(table)
return scalar N = _N
return scalar beta2 = a[1,1]
*3
xtreg score treatment collider	
matrix a = r(table)
return scalar N = _N
return scalar beta3 = a[1,1]
*4
xtreg score treatment income age grade collider
matrix a = r(table)
return scalar N = _N
return scalar beta4 = a[1,1]
*5
xtreg score treatment income age grade mediator collider 
matrix a = r(table)
return scalar N = _N
return scalar beta5 = a[1,1]
end

prog2 400 440

clear
tempfile combined2
save `combined2', replace emptyok

forvalues i = 1/4 {
  local nlower=100*`i'
  local nupper = 100*`i'*1.03
  tempfile sims2
  simulate beta1=r(beta1) beta2=r(beta2) beta3=r(beta3) beta4=r(beta4) beta5=r(beta5) N=r(N), reps(500) seed(163075) saving(`sims2'): prog2 `nlower' `nupper'
  use `sims2', clear
  gen samplesize = _N
  append using `combined2'
  save `combined2', replace
}
 
use `combined2', clear
save "week9pt2", replace

gen samplecat =round(N, 600)
bysort samplecat: egen xbeta1 = mean(beta1)
bysort samplecat: egen xbeta2 = mean(beta2)
bysort samplecat: egen xbeta3 = mean(beta3)
bysort samplecat: egen xbeta4 = mean(beta4)
bysort samplecat: egen xbeta5 = mean(beta5)
egen tag = tag(samplec)

list samplec xbeta* if tag == 1, noobs
sum samplecat
sum xbeta1 
sum xbeta2
sum xbeta3
sum xbeta4
sum xbeta5

graph hbox beta1 beta3 beta4 beta5 beta2, by(samplecat)


