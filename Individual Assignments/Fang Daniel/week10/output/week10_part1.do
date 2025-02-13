*Week 10 Assignment
*Daniel Fang

// Part 1: Calculating required sample sizes and minimum detectable effects

** DGP with varying samplesizes and fixed treatment effects 
capture program drop regressions
program define regressions, rclass
syntax, samplesize(integer)
clear


*** School level
set obs `samplesize'
gen school = _n
gen u_i = rnormal(0,2)   //school specific effects

*** Set up confounding variables
generate urban = runiform() < 0.50

*** Set up covariates

// NUMBER OF CLASSROOMS
expand 10
bysort school: generate classroom = _n 
gen u_ij = rnormal(0,3)

// years of faculty experience
bysort school: gen teach_exp = 5+int((20-5+1) * runiform())

// student ID
expand 16+int((25-16+1)*runiform())
bysort school classroom: gen child = _n
gen e_ijk = rnormal(0,5)

// mother education
gen temprand = runiform()
egen mother_educ = cut(temprand), at(0, 0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 "> College"

// treatment
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
generate score = 70 ///
        + 5*treat ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* mother_educ ///
        + u_i + u_ij + e_ijk
reg score treat
mat a = r(table)
return scalar Beta1 = a[1,1]
return scalar pvalue1 = a[4,1]
reg score treat urban teach_exp mother_educ
mat a = r(table)
return scalar Beta2 = a[1,1]
return scalar pvalue2 = a[4,1]
end


clear
tempfile combined
save `combined', replace emptyok
forvalues i=1/9 {
	local samplesize= 2^(`i'-1)
	tempfile sims
	simulate beta_bias = r(Beta1) beta_unbias = r(Beta2) ///
	pvalue_bias = r(pvalue1) pvalue_unbias = r(pvalue2) ///
	, reps(500) seed(1234) saving(`sims') ///
	: regressions, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
}

gen sig_bias = 0
gen sig_unbias = 0
replace sig_bias =1 if pvalue_bias < 0.05
replace sig_unbias =1 if pvalue_unbias < 0.05
mean sig_bias, over(samplesize)
mean sig_unbias, over(samplesize)

tabstat beta_bias beta_unbias pvalue_bias pvalue_unbias sig_bias sig_unbias, by(samplesize)

	   
* redefine DGP to find the minimum detectable effect size

	
* Define Program

capture program drop treatment
program define treatment, rclass
syntax, treat_effect(real)
clear
*** set observation 1
set obs 1
gen school = _n
gen u_i = rnormal(0,2)   //school specific effects

*** Set up confounding variables
generate urban = runiform() < 0.50

*** Set up covariates

// NUMBER OF CLASSROOMS
expand 10
bysort school: generate classroom = _n 
gen u_ij = rnormal(0,3)

// years of faculty experience
bysort school: gen teach_exp = 5+int((20-5+1) * runiform())

// student ID
expand 16+int((25-16+1)*runiform())
bysort school classroom: gen child = _n
gen e_ijk = rnormal(0,5)

// mother education
gen temprand = runiform()
egen mother_educ = cut(temprand), at(0, 0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 "> College"

// treatment
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
generate score = 70 ///
        + 5*treat ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* mother_educ ///
        + u_i + u_ij + e_ijk
reg score treat
mat a = r(table)
return scalar Beta1 = a[1,1]
return scalar pvalue1 = a[4,1]
reg score treat urban teach_exp mother_educ
mat a = r(table)
return scalar Beta2 = a[1,1]
return scalar pvalue2 = a[4,1]
end

clear
tempfile combined2
save `combined2', replace emptyok
forvalues i=1/10 {
	local treat_effect = `i'/2
	tempfile sims
	simulate beta_bias = r(Beta1) beta_unbias = r(Beta2) ///
	pvalue_bias = r(pvalue1) pvalue_unbias = r(pvalue2) ///
	, reps(500) seed(1234) saving(`sims') ///
	: treatment, treat_effect(`treat_effect') 
	use `sims' , clear
	gen treat_effect =`treat_effect'
	append using `combined2'
	save `combined2', replace
}
gen sig_bias = 0
gen sig_unbias = 0
replace sig_bias =1 if pvalue_bias < 0.05
replace sig_unbias =1 if pvalue_unbias < 0.05
tabstat beta_bias beta_unbias pvalue_bias pvalue_unbias sig_bias sig_unbias, by(treat_effect)