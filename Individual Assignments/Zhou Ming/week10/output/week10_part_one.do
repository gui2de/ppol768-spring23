********************************************************************************
* DGP with varying samplesizes and fixed treatment effects 
********************************************************************************
cd "/Users/zhouming/Desktop/week10/output"

clear all 
set obs 51
gen state = _n // generate state - strata data 
gen party = 1 // democrat 
replace party = 0 if state >25 // republican 

expand 30+int(50-30+1)*runiform() // each state will have 30-50 facilities

local N = _N
	
local N_2 = `N'/2

bysort state: gen facility = _n // generate facility level ID

gen industrial = int(1 + 10 * uniform()) // the facility industry with the number higher, the industry will be more likely to involve in greenhouse emission 
gen activity = rnormal(100,8) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years
gen rand = party + 10*industrial + rnormal() // the possibility of getting treatment depends on strata(state)
egen rank = rank(rand)
sort rank
gen treatment = rank > `N_2' // half in the treatment group 

gen emission = 500 /// outcome variable 
		- 50*treatment /// t = industrial + party
		+ 10*state /// strata - state 
		- 40*party /// confounder - change at the state level 
		+ 50*activity /// only affect emisson
		+ rnormal(100, 10)

save part_one_data, replace 

global data_1 "part_one_data.dta"

capture program drop part_one1
program define part_one1, rclass //unbiased model 
	syntax, samplesize(integer)
	use "$data_1", clear 
	sample `samplesize', count
	reg emission treatment i.party industrial activity
		mat a = r(table)
		return scalar pval = a[4,1]
		return scalar n = e(N)
end 

capture program drop part_one2
program define part_one2, rclass //biased model - omitted variable bias  
	syntax, samplesize(integer)
	use "$data_1", clear 
	sample `samplesize', count
	reg emission treatment 
		mat a = r(table)
		return scalar pval = a[4,1]
		return scalar n = e(N)
end 

clear
tempfile combined
save `combined', replace emptyok

foreach i in 100 234 235 1957 1958{
	forvalues j=1(1)2{
	tempfile sims
	simulate p=r(pval), reps(300) seed(1234) saving(`sims') : part_one`j', samplesize(`i')
	use `sims' , clear
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace	
	}
}

gen sig = 1 if p <= 0.05 // generate sig if the result is significant
replace sig = 0 if p > 0.05  

bysort model samplesize: egen sig_pob = mean(sig)  
collapse (mean) sig_pob, by(model samplesize)


table samplesize model, stat(mean sig)

********************************************************************************
*redefine DGP to find the minimum detectable effect size
********************************************************************************

clear
	
*Define Program*****************************************************************
capture program drop part_one3 
program define part_one3, rclass  
	clear 
	syntax, samplesize(integer) treatment(integer) model(integer)
	set obs 51
	gen state = _n // generate state - strata data 
	gen party = 1 // party, with value of 1 = democrat 
	replace party = 0 if state > 25 // party, with value of 0 = democrat 

	expand 30+int(50-30+1)*runiform() // each state will have 30-50 facilities
	
	local N = _N
	
	local N_2 = `N'/2

	bysort state: gen facility = _n // generate facility level ID

	gen industrial = int(1 + 10 * uniform()) // the facility industry - only affect treatment
	
	gen activity = rnormal(100,8) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years 
	
	gen rand = party + 10*industrial + rnormal() // the possibility of getting treatment depends on strata(state)
	egen rank = rank(rand)
	sort rank
	gen treatment = rank > `N_2' // half in the treatment group
	
	gen emission = 500 /// outcome variable 
		- `treatment'*treatment /// t = industrial + party
		+ 10*state /// strata - state 
		- 40*party /// confounder - change at the state level 
		+ 50*activity /// only affect emisson
		+ rnormal(100, 10)
		
	sample `samplesize', count
	if `model' == 1 {
		reg emission treatment i.party activity // unbiased model
		mat a = r(table)
		return scalar pval = a[4,1]
	}
	else if `model' == 2{
		reg emission treatment //biased model
		mat a = r(table)
		return scalar pval = a[4,1]
	}
end 

*simulation*********************************************************************

clear
tempfile combined2 
save `combined2', replace emptyok

foreach treatment in 5 20 43 50 { // unbiased model choose the samplesize to be 100 
	tempfile sims
	simulate p=r(pval), reps(500) seed(1234) saving(`sims',replace) : ///
	part_one3, samplesize(100) treatment(`treatment') model(1)
	use `sims' , clear
	gen treatment = `treatment'
	gen model = 1
	append using `combined2'
	save `combined2', replace	
}

foreach treatment in 5 50 100 200 240 245 247 248 250{ // biased model choose the samplesize to be 100 
	tempfile sims
	simulate p=r(pval), reps(500) seed(1234) saving(`sims',replace) : ///
	part_one3, samplesize(100) treatment(`treatment') model(2)
	use `sims' , clear
	gen treatment = `treatment'
	gen model = 2
	append using `combined2'
	save `combined2', replace	
}

gen sig = 1 if p <= 0.05 // generate sig if the result is significant
replace sig = 0 if p > 0.05  

bysort model treatment: egen sig_pob = mean(sig) 
collapse (mean) sig_pob, by(model treatment)
 
table samplesize model treatment, stat(mean sig)
