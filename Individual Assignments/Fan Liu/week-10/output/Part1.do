capture program drop regressions
program define regressions, rclass
syntax, samplesize(integer)
clear
set obs `samplesize'
gen school = _n
generate u_i = rnormal(0,2)  // SCHOOL EFFECTS
generate urban = runiform()<0.50 //randomly assign urban/rural status
expand 10 //create 10 classroom in each school
bysort school: generate classroom = _n //create classroom id
generate u_ij = rnormal(0,3) // CLASSROOM EFFECTS
bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create a variabel for years of teaching experience
expand 16+int((25-16+1)*runiform()) //generate student level dataset, each school-class will have 16-25 students
bysort school classroom: generate child = _n //generate student ID
generate e_ijk = rnormal(0,5) //create student level effects 
*generate mother education variable
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
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

capture program drop treatment
program define treatment, rclass
syntax, treat_effect(real)
clear
set obs 1
gen school = _n
generate u_i = rnormal(0,2)  // SCHOOL EFFECTS
generate urban = runiform()<0.50 //randomly assign urban/rural status
expand 10 //create 10 classroom in each school
bysort school: generate classroom = _n //create classroom id
generate u_ij = rnormal(0,3) // CLASSROOM EFFECTS
bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create a variabel for years of teaching experience
expand 16+int((25-16+1)*runiform()) //generate student level dataset, each school-class will have 16-25 students
bysort school classroom: generate child = _n //generate student ID
generate e_ijk = rnormal(0,5) //create student level effects 
*generate mother education variable
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
generate score = 70 ///
        + `treat_effect'*treat ///
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
