*Assignment8 
*week 8

//part one 
*set observations 
clear
set obs 10000
set seed 725485
gen x = rnormal()
save part_one_file, replace 

*define program 
capture program drop part_one
program define part_one, rclass 
	syntax, samplesize(integer)
	use "part_one_file", clear 
	sample `samplesize', count
	gen rand = rnormal()
	egen rank = rank(rand)
	gen treatment = rand if rank > 50
	replace treatment = 0 if rank <= 50
	gen y = x + treatment
	reg y x 
	mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1]
end 

*simulate 
clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta), reps(500) seed(725485) saving(`sims') : part_one, samplesize(`samplesize') 
	return list
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
}

*use graph to show 
histogram beta, by(samplesize) xtit("Estimated beta") ytit("density") // beta by samplesize 
table samplesize, stat(variance beta) //variance of beta by samplesize 

//part two 
clear
capture program drop part_two 
program define part_two, rclass 
	syntax, samplesize(integer)
	clear
	set obs `samplesize' 
	gen x2 = rnormal()
	gen rand = rnormal()
	egen rank = rank(rand)
	gen treatment = rand if rank < 50
	replace treatment = 0 if rank >= 50
	gen y = x2 + treatment
	reg y x2
	mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar sme = a[2,1]
end 

*simulate 
clear
tempfile combined_two
save `combined_two', replace emptyok

forvalues i=1/6{
	local samplesize= 10^`i'
	tempfile sims_two
	simulate beta=r(beta), reps(500) seed(725485) saving(`sims_two') : part_two, samplesize(`samplesize') 
	return list
	use `sims_two' , clear
	gen samplesize=`samplesize'
	append using `combined_two'
	save `combined_two', replace
}

*use graph to show 
histogram beta, by(samplesize) xtit("Estimated beta") ytit("density") // beta by samplesize 
table samplesize, stat(variance beta) //variance of beta by samplesize 
