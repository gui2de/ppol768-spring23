cd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week10-js4880"

global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week10-js4880"


clear 
*8 high schools
set obs 8 
*generate school level data
gen school = _n 

*confounder: rural school have poor quality and less incentive to take after school tutor 
gen rural = round(runiform(0,1),1)

*class level
expand 20+int((30-20+1)*runiform())
bysort school: gen class = _n

*covariate: affect treatment not outcome
gen family = runiform(8,27)
egen family_inc = cut(family), at(8, 14, 21, 27) icodes
label define family 0 "below" 1 "moderate" 2 "wealth"

*treatment 
gen random = rural + 2*family_inc + rnormal()
egen rank = rank(random)
gen treatment = 0 
replace treatment = 1 if rank > _N/2

*strata level data? 
expand 10+int((20-10+1)*runiform())
bysort school class: gen student = _n

*average score last semester: affect only outcome not treatment
gen average = rnormal(70,5)

*generate score 
gen score = 40 ///
    + 5*treatment ///
	+ (-7)*rural ///
	+ 2*average  ///
	+ rnormal(30, 5)
	
save part1_output, replace

*program generate sample
capture program drop part1
program define part1, rclass 
*samplesize as syntax
syntax, samplesize(integer) r(integer)
use "$wd/part1_output", clear
sample `samplesize', count

*true model
	if `r' == 1 {
		reg score treatment rural average 
	}
*omit confounder 
	else if `r' == 2 {
	    reg score treatment average 
	}
*add covariate
	else if `r' == 3 {
	    reg score treatment i.rural average family_inc 
	}

	return scalar n = e(N)
	mat results = r(table) 
	return scalar pval = results[4, 1]
end

clear

* simulate
tempfile combined
save `combined', replace emptyok

    foreach size in 309 774 1548 2322 3097 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`combined', replace): ///
			part1, samplesize(`size') r(1)
		gen reg = 1
		append using `part1_result'
		save `part1', replace
	}
	
foreach size in 309 774 1548 2322 3097 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			part1, samplesize(`size') r(2)
		gen reg = 2
		append using `combined'
		save `combined', replace
	}

foreach size in 100 201 302 403 504 605 {
		simulate n = r(n) pval = r(pval), ///
			reps(500) saving(`simulation', replace): ///
			part1, samplesize(`size') r(3)
		gen reg = 3
		append using `combined'
		save `combined', replace
	}











