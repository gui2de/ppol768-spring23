set seed 1234
clear all 
set obs 51
gen state = _n // generate state - strata data 

gen s_i = rnormal(6,1) //state_level effects on emission

gen random_number =  runiform(1,10)
xtile cluster = random_number, nq(10) //generate cluster variables 
 
gen c_i = rnormal(5,1) // cluster_level effects on emission

expand 30+int(50-30+1)*runiform() // each state will have 30-50 facilities

gen facility = _n // generate facility level ID
gen f_i = rnormal(50,3) //generate facility level effects 

gen industrial = int(1 + 10 * uniform()) // the facility industry with the number higher, the industry will be more likely to involve in greenhouse emission 

gen activity = rnormal(10,0.5) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years

gen treatment = cluster > 5 // half in the treatment group 

gen emission = 1000 ///
	+ (-100)*treatment /// random assigned   
	+ 60*industrial /// only affect emission 
	+ 80*activity /// only affect emission 
	+ c_i + f_i +s_i
	
gen emission1 = 1000 /// 
	+ (-100)*treatment /// random assigned   
	+ 60*industrial /// only affect emission 
	+ 80*activity /// only affect emission 
	+ c_i ///random error only in the cluser level

save part_two_data, replace 

capture program drop part_two1
program define part_two1, rclass //unbiased model 
	syntax, samplesize(integer)
	use "part_two_data", clear 
	sample `samplesize', count
	reg emission treatment industrial activity 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar pval = a[4,1]
		return scalar N = a[7,1]+2 
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
		return scalar se = a[2,1] 
end 

capture program drop part_two2
program define part_two2, rclass //error only at cluster level  
	syntax, samplesize(integer)
	use "part_two_data", clear 
	sample `samplesize', count
	reg emission1 treatment industrial activity 
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
	simulate beta=r(beta) c_upper =r(c_upper) c_lower = r(c_lower) se=r(se), reps(300) seed(1234) saving(`sims') : part_two`j', samplesize(`i')
	use `sims' , clear
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace
	}
}

gen ci_wide = c_upper - c_lower

table samplesize, stat(mean beta) //mean of beta
table samplesize, stat(mean ci_wide) //mean of ci width 

*construct analytical cis 
gen e_wide = 2*1.6608814*se if samplesize == 100
replace e_wide = 2*1.6474143*se if samplesize == 600
replace e_wide = 2*1.6462451*se if samplesize == 1100
replace e_wide = 2*1.6458089*se if samplesize == 1600

table samplesize if model == 1, stat(mean ci_wide e_wide) //mean of beta
table samplesize if model == 2, stat(mean ci_wide e_wide) //mean of beta



