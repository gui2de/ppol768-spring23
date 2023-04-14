set seed 1234
clear all 
set obs 51
gen state = _n // generate state - strata data 

gen s_i = rnormal(60,4) //state_level effects on emission

gen random_number =  runiform(1,10)
xtile cluster = random_number, nq(10) //generate cluster variables 
 
gen sc_i = rnormal(5,1) // cluster_level effects on emission

expand 30+int(50-30+1)*runiform() // each state will have 30-50 facilities

gen facility = _n // generate facility level ID
gen scf_i = rnormal(50,3) //generate facility level effects 

gen activity = rnormal(100,5) // The average number activities the facility has related to greenhouse emission (using GHG protocal) in the past 10 years

gen treatment = cluster > 5 // half in the treatment group 

gen emission = 1000 ///
	+ (-100)*treatment /// random assigned   
	+ 80*activity /// only affect emission 
	+ s_i + sc_i +scf_i
	
gen emission1 = 1-00 /// 
	+ (-100)*treatment /// random assigned   
	+ 80*activity /// only affect emission 
	+ sc_i +scf_i ///random error only in the cluser level

save part_two_data, replace 

capture program drop part_two1
program define part_two1, rclass //unbiased model 
	syntax, samplesize(integer)
	use "part_two_data", clear 
	sample `samplesize', count
	reg emission treatment activity 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
end 

capture program drop part_two2
program define part_two2, rclass //error only at cluster level  
	syntax, samplesize(integer)
	use "part_two_data", clear 
	sample `samplesize', count
	reg emission1 treatment activity 
		mat a = r(table)
		return scalar beta = a[1,1]
		return scalar c_upper = a[6,1]
		return scalar c_lower = a[5,1]
end

clear
tempfile combined
save `combined', replace emptyok

forvalues i=100(500)2000{
	forvalues j=1(1)2{
	tempfile sims
	simulate beta=r(beta) c_upper =r(c_upper) c_lower = r(c_lower), reps(300) seed(1234) saving(`sims') : part_two`j', samplesize(`i')
	use `sims' , clear 
	gen samplesize=`i'
	gen model = `j'
	append using `combined'
	save `combined', replace
	}
}

gen ci_wide = c_upper - c_lower

table samplesize model, stat(mean beta) //mean of beta
table samplesize model, stat(mean ci_wide) //mean of ci width 

*calculate exact CI
bysort samplesize model: egen mean = mean(beta)
bysort samplesize model: egen sd = sd(beta)
gen ll = mean-1.96*sd
gen ul = mean+1.96*sd
gen ci_wide_e = ul - ll

bysort samplesize: gen simulation = _n 

*graphs 
forvalues i = 1(1)2 {
	forvalues j = 100(500)1600 {
		graph twoway rcap c_upper c_lower simulation if model == `i' & samplesize == `j' ///
			|| rcap ul ll simulation if model == `i' & samplesize == `j', ///
			ytitle("95% condifence interval") ///
			xtitle("Simulations") /// 
			legend(label(1 "Analytical CI") label(2 "Exact CI")) ///
			title("Sample size = `j'")
	}
}
