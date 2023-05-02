*******************************************************************************
*** PPOL 768-01
*** Student: Gustavo Murillo Velazquez
*** Week 04 Assignment
*******************************************************************************


** Setting A Global Working Directory
clear
cd "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-10/"

clear
set seed 2023

set obs 10


*Strata
gen school = _n
gen u_i = rnormal(0,5)  // school effects
gen urban = runiform()<0.50 //randomly assign urban/rural status
expand 6 //creating 6 classroom in each school
bysort school: generate classroom = _n //create classroom id
generate u_ij = rnormal(0,3) // generation classroom effects
expand 20+int((35-20+1)*runiform()) //generate student level dataset, each school-class will have 20-35 students
bysort school classroom: generate child = _n //generate student ID
generate e_ijk = rnormal(0,5) //create student level effects 

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
gen GPA = 10 + parent_edu*0.2 + parent_income*0.1 + student_iq*0.5 + treatment*5 + rnormal()

save "wk-10-p1.dta", replace

capture program drop part1
program define part1, rclass
syntax, samplesize(integer)
clear

use "wk-10-p1.dta"

sample `samplesize', count
	
	return scalar N = `samplesize' 
	
	reg GPA treatment student_iq parent_edu 
		mat results = r(table)
		return scalar beta = results[1,1]
		return scalar SEM = results[2,1]
		return scalar pval = results[4,1]
	
	
end

local samples 100 150 200 250

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) Beta = r(beta) SEM = r(SEM) pvalue = r(pval), reps(100) seed(2023) saving(`sims`x''): part1, samplesize(`x') 
	save `sims`x'', replace
}

local samples 150 200 250
use `sims100'

foreach x in `samples' {
    append using `sims`x''
}
generate sig = 0
replace sig = 1 if pvalue < 0.05
sum sig
mean sig, over(N)
