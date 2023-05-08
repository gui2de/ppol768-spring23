*******************************************************************************
** clean workspace, set dir, load data, quick view of data
*******************************************************************************
* nate spilka
* 2023-04-30

* clean workspace 
cls
clear all

* set dir
cd "/Users/nathanielhugospilka/Documents/research_methods_2023/research_design/ppol768-spring23/Individual Assignments/Spilka Nathaniel/week-09"

*******************************************************************************
** Part 1: De-biasing a parameter estimate using controls
*******************************************************************************

set seed 950703

* urban, suburban, and rural campuses
set obs 3

* campus ID and campus effects
generate campus = _n
generate campus_effects = rnormal(0, 2)

* creating individual-level observations
expand 150
generate participant = _n

* treatment - strata by campus type (~50/50 across each campus)
generate treatment = (rnormal() + (.03/campus))>0
* tab treatment campus

* number of hours sleeping
generate sleeping_hrs = rnormal(7, 2)

* healthy eating score from 0 to 10 (a higher score means healthier eating)
generate eating = rnormal(5, 2)

* number of steps a day (average is from Mayo Clinic)
generate steps = rnormal(3500, 1500)

* generate y (BMI) based on the variables above
generate bmi = (campus_effects + 3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
*summ bmi

* checking distributions by campus
*histogram bmi, by(campus)

regress bmi treatment
regress bmi treatment sleeping_hrs
regress bmi treatment sleeping_hrs eating
* we see that once steps are included, the effect of the treatment becomes less robust.
regress bmi treatment sleeping_hrs eating steps
regress bmi treatment sleeping_hrs eating campus_effects


clear

capture program drop prt1prgrm 
program define prt1prgrm, rclass 
syntax, sample_size(integer)
	
	* urban, suburban, and rural campuses
	set obs 3

	* campus ID and campus effects
	generate campus = _n
	generate campus_effects = rnormal(0, 2)

	* creating individual-level observations
	expand `sample_size'
	generate participant = _n

	* treatment - strata by campus type (~50/50 across each campus)
	generate treatment = (rnormal() + (.03/campus))>0
	* tab treatment campus

	* number of hours sleeping
	generate sleeping_hrs = rnormal(7, 2)

	* healthy eating score from 0 to 10 (a higher score means healthier eating)
	generate eating = rnormal(5, 2)

	* number of steps a day (average is from Mayo Clinic)
	generate steps = rnormal(3500, 1500)

	* generate y (BMI) based on the variables above
	generate bmi = (campus_effects + 3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
	*summ bmi

	* checking distributions by campus
	*histogram bmi, by(campus)

	regress bmi treatment
	return scalar simple_reg = _b[treatment]
	regress bmi treatment sleeping_hrs
    return scalar less_biased_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating
	return scalar even_less_biased_reg = _b[treatment]
	* we see that once steps are included, the effect of the treatment becomes less robust.
	regress bmi treatment sleeping_hrs eating steps
	return scalar semi_biased_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating campus_effects
	return scalar noice_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating steps campus_effects
	return scalar most_biased_reg = _b[treatment]

end

*prt1prgrm, sample_size(10000)

* simulations

clear
tempfile simulations
save `simulations', replace emptyok

local vals 15 150 1500 15000 150000

foreach var of local vals {

	tempfile simulations_temp
	
	simulate ///
	sr = r(simple_reg) ///
	lbr = r(less_biased_reg) ///
	elbr = r(even_less_biased_reg) ///
	sbr = r(semi_biased_reg) ///
	nr = r(noice_reg) ///
	mbr = r(most_biased_reg), ///
	reps(150) seed(950703) saving(`simulations_temp', replace): prt1prgrm, sample_size(`var') 
	
	use `simulations_temp', clear
	append using `simulations'
	save `simulations', replace
	
}

// I'm getting the following error here:
// observation number out of range
//     Observation number must be between 150 and 2,147,483,619.  (Observation numbers are typed without
//     commas.)
// an error occurred when simulate executed prt1prgrm

// To complete this part of the assignment, I would create histograms of each of the betas from the different regressions to show how the biasness and convergence manifest as a function of n

// I would anticipate that the values would collapse around the "true" value of beta as the sample size increases. 


*******************************************************************************
** Part 2: Biasing a parameter estimate using controls
*******************************************************************************

cls
clear

set seed 950703

capture program drop prt2prgrm 
program define prt2prgrm, rclass 
syntax, sample_size(integer)
	
	* urban, suburban, and rural campuses
	set obs 3

	* campus ID and campus effects
	generate campus = _n
	generate campus_effects = rnormal(0, 2)

	* creating individual-level observations
	expand `sample_size'
	generate participant = _n

	* treatment - strata by campus type (~50/50 across each campus)
	generate treatment = (rnormal() + (.03/campus))>0
	* tab treatment campus

	* number of hours sleeping
	generate sleeping_hrs = rnormal(7, 2)

	* healthy eating score from 0 to 10 (a higher score means healthier eating)
	generate eating = rnormal(5, 2)

	* number of steps a day (average is from Mayo Clinic)
	generate steps = rnormal(3500, 1500)

	* generate y (BMI) based on the variables above
	generate bmi = (campus_effects + 3*treatment + 2*sleeping_hrs + 2*eating + 1.5*steps + rnormal(26.5, 6))/200
	*summ bmi
	
	generate collider_var =  3*treatment + 1.5*steps

	* checking distributions by campus
	*histogram bmi, by(campus)

	regress bmi treatment
	return scalar simple_reg = _b[treatment]
	regress bmi treatment sleeping_hrs
    return scalar less_biased_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating
	return scalar even_less_biased_reg = _b[treatment]
	* we see that once steps are included, the effect of the treatment becomes less robust.
	regress bmi treatment sleeping_hrs eating collider_var
	return scalar semi_biased_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating campus_effects
	return scalar noice_reg = _b[treatment]
	regress bmi treatment sleeping_hrs eating steps campus_effects
	return scalar most_biased_reg = _b[treatment]

end

*prt1prgrm, sample_size(10000)

* simulations

clear
tempfile simulations2
save `simulations2', replace emptyok

local vals 15 150 1500 15000 150000

foreach var of local vals {

	tempfile simulations_temp2
	
	simulate ///
	sr = r(simple_reg) ///
	lbr = r(less_biased_reg) ///
	elbr = r(even_less_biased_reg) ///
	sbr = r(semi_biased_reg) ///
	nr = r(noice_reg) ///
	mbr = r(most_biased_reg), ///
	reps(150) seed(950703) saving(`simulations_temp2', replace): prt2prgrm, sample_size(`var') 
	
	use `simulations_temp2', clear
	append using `simulations2'
	save `simulations2', replace
	
}

// I'm getting the same error here:
// observation number out of range
//     Observation number must be between 150 and 2,147,483,619.  (Observation numbers are typed without
//     commas.)
// an error occurred when simulate executed prt1prgrm

// To complete this part of the assignment, I would create histograms of each of the betas from the different regressions to show how the biasness and convergence manifest as a function of n

// I would anticipate that the values would collapse around the "true" value of beta as the sample size increases. 








