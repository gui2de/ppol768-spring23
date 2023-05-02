*******************************************************************************
** clean workspace, set dir, load data, quick view of data
*******************************************************************************
* nate spilka
* 2023-04-30

* clean workspace 
cls
clear all

* set dir
cd "/Users/nathanielhugospilka/Documents/research_methods_2023/research_design/ppol768-spring23/Individual Assignments/Spilka Nathaniel/week-10"

*******************************************************************************
** Part 1: Sampling noise in a fixed population
*******************************************************************************

* 1
cls
clear all
set seed 950703

* creating 10,000 random x values from a normal distribution - then save the data
set obs 10000

* treatment variable (50/50)
generate treatment = rnormal(1)>1

* number of hours sleeping
generate sleeping_hrs = rnormal(7, 2)

* healthy eating score from 0 to 10 (a higher score means healthier eating)
generate eating = rnormal(5, 2)

* number of steps a day (average is from Mayo Clinic)
generate steps = rnormal(3500, 1500)

* generate y (BMI) based on the variables above
generate bmi = (3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
*summ bmi

save "data1", replace 

* 2
cls
clear all
set seed 950703

* Strata - urban, suburban, and rural campuses
set obs 3

* campus ID and campus effects
generate campus = _n
generate campus_effects = rnormal(0, 10)

expand 150

generate participant = _n

* treatment - strata by campus type (~50/50 across each campus)
generate treatment = rnormal(1, campus_effects)>0
tab treatment campus

* number of hours sleeping
generate sleeping_hrs = rnormal(7, 2)

* healthy eating score from 0 to 10 (a higher score means healthier eating)
generate eating = rnormal(5, 2)

* number of steps a day (average is from Mayo Clinic) - affects both outcome and treatment
generate steps = rnormal(3500, 1500)+.2*treatment

* generate y (BMI) based on the variables above
generate bmi = (campus_effects + 3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
*summ bmi

save "data2", replace 

use  "data2.dta", clear

local numbs 250 350 450 550

foreach val of local numbs {
	
	sample `val', count
	
	regress bmi treatment
	power oneslope 0 _b[treatment], power(0.8)
	
	regress bmi treatment sleeping_hrs eating steps campus_effects
	power oneslope 0 _b[treatment], power(0.8)
	
	regress bmi treatment sleeping_hrs eating campus_effects
	power oneslope 0 _b[treatment], power(0.8)
	
}

cls
clear

use  "data2.dta", clear

local numbs .1 .2 .3 .4 .5

foreach val of local numbs {
	
	power oneslope 0 `val', n(450)
	
}


*******************************************************************************
** Part 2: Calculating power for DGPs with clustered random errors
*******************************************************************************

cls
clear all
set seed 950703

* clusters - all campuses
set obs 64

* campus ID and campus effects
generate campus = _n
generate campus_effects = rnormal(0, 10)

* 30 at each institution
expand 30

generate participant = _n

* treatment - strata by campus type (~50/50 across each campus)
generate treatment = rnormal(1, campus_effects)>0
*tab treatment campus

* number of hours sleeping
generate sleeping_hrs = rnormal(7, 2)

* healthy eating score from 0 to 10 (a higher score means healthier eating)
generate eating = rnormal(5, 2)

* number of steps a day (average is from Mayo Clinic) - affects both outcome and treatment
generate steps = rnormal(3500, 1500)+.2*treatment

* generate y (BMI) based on the variables above
generate bmi = (campus_effects + 3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
*summ bmi
    
	regress bmi treatment sleeping_hrs eating steps campus_effects
    matrix ci = e(ci)
    scalar ci_low = ci[1,1]
    scalar ci_high = ci[1,2]

regress bmi treatment sleeping_hrs eating steps campus_effects, vce(robust)
