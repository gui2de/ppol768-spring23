// Hannah Hill
// Week 09

*******************************************************************************
* Part 1                                                                      *
*******************************************************************************
set scheme s1color
clear

// create program
capture program drop trial1
program define trial1, rclass
syntax, samplesize(integer)
	set seed 432023
	set obs `samplesize'
	gen school = _n
	generate u_i = rnormal(0,2)  // SCHOOL EFFECTS
	generate urban = runiform()<0.50 //randomly assign urban/rural status
	expand 10 //create 10 classroom in each school
	bysort school: generate classroom = _n //create classroom id
	generate u_ij = rnormal(0,3) // CLASSROOM EFFECTS

	bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create a variable for years of teaching experience
	expand 16+int((25-16+1)*runiform()) //generate student level dataset, each school-class will have 16-25 students
	bysort school classroom: generate child = _n //generate student ID
	generate e_ijk = rnormal(0,5) //create student level effects 
	*generate mother education variable
	generate temprand = runiform()
	egen educ_mother = cut(temprand), at(0,0.5, 0.9, 1) icodes
	label define educ_mother 0 "HighSchool" 1 "College" 2 ">College"
	gen treat = cond(teach_exp <= 10 & educ_mother <= 1, 1, 0)

// GDP
generate score = 70 ///
        + 5*treat ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0* educ_mother ///
        + u_i + u_ij + e_ijk

	reg score treat
	mat a = r(table)
	return scalar Beta1 = a[1,1]
	reg score treat urban teach_exp educ_mother
	mat a = r(table)
	return scalar Beta2 = a[1,1]
	reg score treat urban teach_exp educ_mother i.school
	mat a = r(table)
	return scalar Beta3 = a[1,1]
	reg score treat urban teach_exp educ_mother i.classroom
	mat a = r(table)
	return scalar Beta4 = a[1,1]
	reg score treat urban teach_exp educ_mother i.(school classroom)
	mat a = r(table)
	return scalar Beta5 = a[1,1]
end

clear
tempfile merge
save `merge', replace emptyok

forvalues i=1/8 {
	local samplesize= 2^`i'
	tempfile sims
	simulate beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
	, reps(500) seed(432023) saving(`sims') ///
	: trial1, samplesize(`samplesize') 
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `merge'
	save `merge', replace
}

twoway (line beta1 samplesize, color(red)) ///
       (line beta2 samplesize, color(orange)) ///
       (line beta3 samplesize, color(green)) ///
       (line beta4 samplesize, color(blue)) ///
       (line beta5 samplesize, color(purple)) ///
       , ytitle("Beta values") xtitle("Sample size") ///
       legend(order(1 "Beta1" 2 "Beta2" 3 "Beta3" 4 "Beta4" 5 "Beta5")) ///
       title("Beta Values Graph")