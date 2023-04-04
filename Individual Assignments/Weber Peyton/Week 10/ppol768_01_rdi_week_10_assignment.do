*PPOL 768-01: Research, Design, and Implementation
*Week 10 Assignment Do File
*Author: Peyton Weber
*Last edited: April 4, 2023

*April 4, 2023: 
cd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 10"
*Reviewer to adjust working directory appropriately. 

capture program drop ppol768 // drop program if already defined 
program define ppol768, rclass // define program and use rclass to create results matrix 
syntax, samplesize(integer) // sample size is the program argument 
clear
set obs `samplesize' // setting varying observation levels
gen school = _n // create school variable 
generate u_i = rnormal(0,2)  // generate arbitrary school effects 
generate urban = runiform()<0.50 //randomly assign urban and rural status for schools 
expand 10 //create ten classrooms for each school
bysort school: generate classroom = _n //create classroom id for all schools 
generate u_ij = rnormal(0,3) // generate arbitrary classroom effects 
bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create variable for years of teaching experience
expand 16+int((25-16+1)*runiform()) // Each school's classrooms will have 16-25 students
bysort school classroom: generate child = _n // create student ID
generate e_ijk = rnormal(0,5) // create arbitrary student level effects 
*generate mother education variable
generate temprand = runiform() // random variable generation 
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes // create mothers' education variable 
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College" // label mother education var
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0) // creating the treatment 
generate score = 70 /// replicating something we did in class 
        + 5*treat ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* mother_educ ///
        + u_i + u_ij + e_ijk
		
*First regression: 
reg score treat // regress y on x 
mat a = r(table) // create a matrix to recall the scalars 
return scalar beta1 = a[1,1] // recall the beta coefficient after running the regression 
return scalar pvalue1 = a[4,1] // recall the p-value after running the regression 

*Second regression: 
reg score treat urban teach_exp mother_educ // regress y on x and additional covariates 
mat a = r(table) // create a matrix to recall the scalars 
return scalar beta2 = a[1,1] // recall the beta coefficient after running the regression 
return scalar pvalue2 = a[4,1] // recall the p-value after running the regression 

end

clear
tempfile combo
save `combo', replace emptyok
forvalues i=1/8 {
	local samplesize= 2^(`i')
	tempfile sims
	simulate beta_biased = r(beta1) beta_nobias = r(beta2) /// the first regression is intentionally biased 
	pvalue_biased = r(pvalue1) pvalue_nobias = r(pvalue2) ///
	, reps(500) seed(1234) saving(`sims') ///
	: ppol768, samplesize(`samplesize') // recall the defined program, ppol768 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combo'
	save `combo', replace // the "replace" fuction is crucial in a loop 
}

gen sig_biased = 0
replace sig_biased =1 if pvalue_biased < 0.05
gen sig_nobias = 0
replace sig_nobias =1 if pvalue_nobias < 0.05

mean sig_biased, over(samplesize)
mean sig_nobias, over(samplesize)

tabstat beta_biased beta_nobias pvalue_biased pvalue_ nobias sig_biased sig_nobias, by(samplesize)

exit

capture program drop treatment
program define treatment, rclass
syntax, treat_effect(real)
clear
set seed 1234
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
		
*First regression: 
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
tempfile combo2
save `combo2', replace emptyok
forvalues i=1/10 {
	local treat_effect = `i'/2
	tempfile sims
	simulate beta_bias = r(Beta1) beta_unbias = r(Beta2) ///
	pvalue_bias = r(pvalue1) pvalue_unbias = r(pvalue2) ///
	, reps(500) seed(1234) saving(`sims') ///
	: treatment, treat_effect(`treat_effect') 
	use `sims' , clear
	gen treat_effect =`treat_effect'
	append using `combo2'
	save `combo2', replace
}

