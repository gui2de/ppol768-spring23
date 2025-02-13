set seed 1234
clear all 
set obs 100
gen company = _n // generate company ID
gen c_i = rnormal(3,0.1) // company_level effects on emission

expand 3+int(6-3+1)*runiform() // each company will have 3-6 facility 
bysort company: gen facility = _n // generate facility ID 
gen state = int(1 + 50 * uniform()) // the facility locates in which state
bysort state: gen state_i = rnormal(30,3) // state_level effects on emission
gen industrial = int(1 + 10 * uniform()) // the facility industry with the number higher, the industry will be more likely to involve in greenhouse emission 
gen activity = rnormal(10,0.5) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years
gen rand = industrial + 2*activity + rnormal() // the possibility of getting treatment depends on industy and activity 
egen rank = rank(rand)
gen treatment = rank >= 257 // half in the treatment group 

gen x = (-50)*treatment*rnormal(5,3)

gen emission = 100 ///
	+ (-50)*treatment ///
	+ 3*industrial ///
	+ 5*activity ///
	+ state_i + c_i 
	
gen collider = emission*3 + treatment*4

save part_two_file, replace 

capture program drop part_two1
program define part_two1, rclass 
	syntax, samplesize(integer)
	use "part_two_file", clear 
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

capture program drop part_two2
program define part_two2, rclass 
	syntax, samplesize(integer)
	use "part_two_file", clear 
	sample `samplesize', count
	reg emission treatment i.state 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1]
end 

capture program drop part_two3
program define part_two3, rclass 
	syntax, samplesize(integer)
	use "part_two_file", clear 
	sample `samplesize', count
	reg emission treatment i.state collider 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1]
end

capture program drop part_two4
program define part_two4, rclass 
	syntax, samplesize(integer)
	use "part_two_file", clear 
	sample `samplesize', count
	reg emission treatment i.state activity collider 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1]
end

capture program drop part_two5
program define part_two5, rclass 
	syntax, samplesize(integer)
	use "part_two_file", clear 
	sample `samplesize', count
	reg emission treatment i.state activity industrial 
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

forvalues i=100(100)500{
	forvalues j=1(1)5{
	tempfile sims
	simulate beta=r(beta), reps(300) seed(1234) saving(`sims') : part_two`j', samplesize(`i')
	use `sims' , clear
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace	
	}
}

table samplesize model, stat(variance beta)
table samplesize model, stat(mean beta)

bysort model samplesize: egen variance = sd(beta)
bysort model samplesize: egen mean = mean(beta)

graph box beta if model == 1, over(samplesize)
graph box beta if model == 2, over(samplesize)
graph box beta if model == 3, over(samplesize)
graph box beta if model == 4, over(samplesize)
graph box beta if model == 5, over(samplesize)
