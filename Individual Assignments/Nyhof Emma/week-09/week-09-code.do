cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\"

********************************* PART 1 **************************************
clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(1,3) // state effects
gen unemp = rnormal(0.032,0.0085)
bysort state: gen temprand_state = rnormal(0.5,0.1)
expand int(runiform(10000,100000))
gen u_ij = rnormal(1,2) // person effects
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<unemp // affects treatment but not outcome
gen hoursworked = rnormal(25,5) if unemployed != 0 // confounder
keep if hoursworked < 20 | unemployed == 1
egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand<0.5
gen age = runiform(18,64) // affects outcome but not treatment

gen wkly_inc = 480 ///
			+ (100 * treatment) ///
			+ (8 * hoursworked) /// 
			+ (4.5 * age) ///
			+ u_i + u_ij

save "week-09-part1.dta", replace

capture program drop week9part1 
program define week9part1, rclass
    syntax, samplesize(integer)
	clear
	use "week-09-part1.dta"
	sample `samplesize', count
	
	return scalar N = `samplesize' 
	
	reg wkly_inc treatment
		mat results1 = r(table)
		return scalar beta1 = results1[1,1]
		return scalar SEM1 = results1[2,1]
		return scalar pval1 = results1[4,1]
	
	reg wkly_inc treatment i.state
		mat results2 = r(table)
		return scalar beta2 = results2[1,1]
		return scalar SEM2 = results2[2,1]
		return scalar pval2 = results2[4,1]
	
	reg wkly_inc treatment i.state hoursworked 
		mat results3 = r(table)
		return scalar beta3 = results3[1,1]
		return scalar SEM3 = results3[2,1]
		return scalar pval3 = results3[4,1]
	
	reg wkly_inc treatment i.state unemployed
		mat results4 = r(table)
		return scalar beta4 = results4[1,1]
		return scalar SEM4 = results4[2,1]
		return scalar pval4 = results4[4,1]
	
	reg wkly_inc treatment i.state hoursworked age
		mat results5 = r(table)
		return scalar beta5 = results5[1,1]
		return scalar SEM5 = results5[2,1]
		return scalar pval5 = results5[4,1]
	
end


local samples 50 500 5000 50000 

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) beta1 = r(beta1) SEM1 = r(SEM1) pval1 = r(pval1) beta2 = r(beta2) SEM2 = r(SEM2) pval2 = r(pval2) beta3 = r(beta3) SEM3 = r(SEM3) pval3 = r(pval3) beta4 = r(beta4) SEM4 = r(SEM4) pval4 = r(pval4) beta5 = r(beta5) SEM5 = r(SEM5) pval5 = r(pval5), reps(100) seed(89743) saving(`sims`x''): week9part1, samplesize(`x') 
	save `sims`x'', replace
}

local samples 500 5000 50000 
use `sims50'

foreach x in `samples' {
    append using `sims`x''
}

	twoway (histogram beta1 if N == 50, start(34) width(3) color(blue%30)) ///
		   (histogram beta1 if N == 50000, start(34) width(3) color(yellow%30)), ///
		   legend(order(1 "N = 50" 2 "N = 50000"))

*	graph save "Graph" "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\reg1_part1.gph"
		   
	twoway (histogram beta5 if N == 50, start(96) width(3) color(blue%30)) ///
		   (histogram beta5 if N == 50000, start(96) width(3) color(yellow%30)), ///
		   legend(order(1 "N = 50" 2 "N = 50000"))
		   
* graph save "Graph" "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\reg5_part1.gph"

	forvalues i = 1/5 {
	table () (N), stat(sd beta`i') stat(mean beta`i' pval`i' SEM`i') stat(range beta`i' pval`i' SEM`i') nototal
	}
	

****************************** PART 2 ******************************************
clear
set seed 74937
set obs 50
gen state = _n
gen u_i = rnormal(1,3) // state effects
gen unemp = rnormal(0.032,0.0085)
bysort state: gen temprand_state = rnormal(0.5,0.1)
expand int(runiform(10000,100000))
gen u_ij = rnormal(1,2) // person effects
bysort state: gen person = _n
gen temprand_person = runiform()
gen unemployed = runiform()<unemp 
gen hoursworked = rnormal(25,5) if unemployed != 0 
keep if hoursworked < 20 | unemployed == 1
egen temprand = rowmean(temprand_state temprand_person)
gen treatment = temprand<0.5

gen channel = 300 * treatment * runiform() // channel

gen wkly_inc = 480 ///
			+ (100 * treatment) ///
			+ (8 * hoursworked) /// 
			+ (0.5 * channel) ///
			+ u_i + u_ij

gen collider = wkly_inc*treatment*rnormal()
			
save "week-09-part2.dta", replace

capture program drop week9part2
program define week9part2, rclass
    syntax, samplesize(integer)
	clear
	use "week-09-part2.dta"
	sample `samplesize', count
	
	return scalar N = `samplesize' 
	
	reg wkly_inc treatment
		mat results1 = r(table)
		return scalar beta1 = results1[1,1]
		return scalar SEM1 = results1[2,1]
		return scalar pval1 = results1[4,1]
	
	reg wkly_inc treatment i.state
		mat results2 = r(table)
		return scalar beta2 = results2[1,1]
		return scalar SEM2 = results2[2,1]
		return scalar pval2 = results2[4,1]
	
	reg wkly_inc treatment i.state channel
		mat results3 = r(table)
		return scalar beta3 = results3[1,1]
		return scalar SEM3 = results3[2,1]
		return scalar pval3 = results3[4,1]
	
	reg wkly_inc treatment i.state collider
		mat results4 = r(table)
		return scalar beta4 = results4[1,1]
		return scalar SEM4 = results4[2,1]
		return scalar pval4 = results4[4,1]
	
	reg wkly_inc treatment i.state channel collider
		mat results5 = r(table)
		return scalar beta5 = results5[1,1]
		return scalar SEM5 = results5[2,1]
		return scalar pval5 = results5[4,1]
	
end


local samples 50 500 5000 50000 

foreach x in `samples'{
	tempfile sims`x'
	simulate N = r(N) beta1 = r(beta1) SEM1 = r(SEM1) pval1 = r(pval1) beta2 = r(beta2) SEM2 = r(SEM2) pval2 = r(pval2) beta3 = r(beta3) SEM3 = r(SEM3) pval3 = r(pval3) beta4 = r(beta4) SEM4 = r(SEM4) pval4 = r(pval4) beta5 = r(beta5) SEM5 = r(SEM5) pval5 = r(pval5), reps(100) seed(89743) saving(`sims`x''): week9part2, samplesize(`x') 
	save `sims`x'', replace
}

local samples 500 5000 50000 
use `sims50'

foreach x in `samples' {
    append using `sims`x''
}

	twoway (histogram beta1 if N == 50, start(131) width(3) color(blue%30)) ///
		   (histogram beta1 if N == 50000, start(131) width(3) color(yellow%30)), ///
		   legend(order(1 "N = 50" 2 "N = 50000"))

	graph save "Graph" "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\reg1_part2.gph"
		   
	twoway (histogram beta3 if N == 50, start(27) width(3) color(blue%30)) ///
		   (histogram beta3 if N == 50000, start(27) width(3) color(yellow%30)), ///
		   legend(order(1 "N = 50" 2 "N = 50000"))

	graph save "Graph" "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\reg3_part2.gph"
	
	twoway (histogram beta4 if N == 50, start(119) width(3) color(blue%30)) ///
		   (histogram beta4 if N == 50000, start(119) width(3) color(yellow%30)), ///
		   legend(order(1 "N = 50" 2 "N = 50000"))
		   
	graph save "Graph" "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-09\reg4_part2.gph"

	forvalues i = 1/5 {
	table () (N), stat(sd beta`i') stat(mean beta`i' pval`i' SEM`i') stat(range beta`i' pval`i' SEM`i') nototal
	}


