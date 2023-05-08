capture program drop normal_reg
program define normal_reg, rclass
syntax, samplesize(integer)

clear
set obs 5
gen school = _n
expand `samplesize'

gen freetime = rnormal(11,3) // Confounder
gen mom_educ = rnormal(5,2) // Only affects outcome
gen work_exper = rnormal(3,0.5) // Only affects treatment
gen random_program = freetime + (0.8)*work_exper + rnormal() //Underlying continuous var that will determine treatment status

summ random_program, d  //Find the median (i.e. P50) 

gen program = random_program > r(p50) // Control and Treatment group will be 1:1
tab program 
gen income = (2.3)*program + (1.3)*freetime + mom_educ/10 + 6*rnormal() // Outcome

reg income program freetime mom_educ  // Unbiased reg model
matrix results = r(table)

return scalar N1= e(N)
return scalar beta1 = results[1,1]
return scalar pvalue1 = results[4,1]

reg income mom_educ freetime  // Biased reg model
matrix results = r(table)

return scalar N2= e(N)
return scalar beta2 = results[1,1]
return scalar pvalue2 = results[4,1]

end


clear 
tempfile combined sims
save `combined', replace emptyok

forvalues i=1/4 {
	local ss = 10^`i'
	simulate N=r(N1) beta1=r(beta1) beta2=r(beta2) pval1 = r(pvalue1) pval2 = r(pvalue2), rep(100) saving(`sims', replace): ///
	normal_reg, samplesize(`ss')

	use `sims', clear

	append using `combined'
	save `combined', replace

	}

	
use `combined', clear

gen sig1 = 0
replace sig1 = 1 if pval1 < 0.05 // This is for unbiased model

gen sig2 = 0
replace sig2 = 1 if pval2 < 0.05 // This is for biased model

sum sig1 sig2
bysort N: egen power_unbiased = mean(sig1)
bysort N: egen power_biased = mean(sig2)  // Calculate the "power"

graph box power_unbiased power_biased, by(N) yline(0.8) noout // By graph

