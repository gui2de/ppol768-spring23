set seed 1234
clear all 
set obs 51
gen state = _n // generate state - strata data 
gen s_i = rnormal(5,0.1) // state_level effects on emission

expand 30+int(50-30+1)*runiform() // each state will have 30-50 facilities

bysort state: gen facility = _n // generate facility level ID
gen f_i = rnormal(2,0.1) //facility-level effects on emission 

gen industrial = int(1 + 10 * uniform()) // the facility industry with the number higher, the industry will be more likely to involve in greenhouse emission 
gen activity = rnormal(10,0.5) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years
gen rand = state + 10*industrial + rnormal() // the possibility of getting treatment depends on strata(state)
egen rank = rank(rand)
sort rank
gen treatment = rank > 1013 // half in the treatment group 

gen emission = 1000 ///
	+ 40*state /// strata
	+ (-10)*treatment /// t = industrial + state 
	+ 60*industrial /// counfonder 
	+ 80*activity /// only affect emission 
	+ s_i + f_i 

save part_one_file, replace 

capture program drop part_one1
program define part_one1, rclass //unbiased model 
	syntax, samplesize(integer)
	use "part_one_file", clear 
	sample `samplesize', count
	reg emission treatment i.state industrial 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1] 
end 

capture program drop part_one2
program define part_one2, rclass //biased model 
	syntax, samplesize(integer)
	use "part_one_file", clear 
	sample `samplesize', count
	reg emission treatment  
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1]
end 

clear
tempfile combined
save `combined', replace emptyok

forvalues i=100(500)2000{
	forvalues j=1(1)2{
	tempfile sims
	simulate beta=r(beta) p=r(pval), reps(300) seed(1234) saving(`sims') : part_one`j', samplesize(`i')
	use `sims' , clear
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace	
	}
}

gen sig = 1 if p <= 0.05 
replace sig = 0 if p > 0.05 

table samplesize model, stat(mean sig)

use "part_one_file.dta", clear
reg emission treatment i.state industrial
reg emission treatment
power onemean 1843 1833, sd(610) power(0.8) // with non-biasing control 
power onemean 2881 600, sd(610) power(0.8) // without non-biasing control-3



