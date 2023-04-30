// Hannah Hill
// Week 09

*******************************************************************************
* Part 1																	  *
*******************************************************************************
clear all 
set scheme s1color

capture program drop ccc
program define ccc, rclass
	syntax, samplesize(integer) 
	clear
	*Create empty observations. 
	set obs `samplesize'
	*Create school observations, following in in-class exercise. 
	gen college = _n
	gen u_i = rnormal(0,2)
	gen urban = runiform()<0.50
	expand 5 // 5 years of data for each college
	bysort college: generate year = 2000 + _n -1
	bysort college year: generate course = _n
	gen u_ij = rnormal(0,3)
	// generate % of remedial courses at each college
	bysort college year: generate remedial = .3+int((.85-.3+1)*runiform())
	*Creating a variable for years of teaching experience. 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	*Generate student-level dataset where each school-class will have 16-25 students.
	expand 16+int(10*runiform())
	*Create student IDs
	bysort college course: generate child = _n 
	*Create student-level effects
	generate e_ijk = rnormal(0,5)
	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	// generate treatment 
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)


// DGP
	bysort college year: generate transfer_rate = runiform() * 0.04 + 0.005 ///
			+ .05*treat ///
			+ (-2)*urban ///
			+ .3*diversity  ///
			+ 1.4*teach_exp ///
			+ .02*remedial ///
			+ 0.2*mother_educ ///
			+ u_i + u_ij + e_ijk
	format transfer_rate %4.2f
 
// bivariate reg
reg transfer_rate treat 
mat a = r(table)
return scalar Beta1 = a[1,1]

// multivariate reg
reg transfer_rate treat urban diversity remedial teach_exp mother_educ 
mat a = r(table)
return scalar Beta2 = a[1,1]

// college fixed effects
reg transfer_rate treat urban diversity remedial teach_exp mother_educ i.college  
mat a = r(table)
return scalar Beta3 = a[1,1]

// year fixed effects
reg transfer_rate treat urban diversity remedial teach_exp mother_educ i.year
mat a = r(table)
return scalar Beta4 = a[1,1]

// two way fixed effects 
reg transfer_rate treat urban diversity remedial teach_exp mother_educ i.(college year)
mat a = r(table)
return scalar Beta5 = a[1,1]

return scalar N=`c(N)'

end 

 
clear
tempfile combined
save `combined', replace emptyok
forvalues i=1/5 {
	local samplesize= `i'
	display as error "iteration = `i'" 
	tempfile sims
	simulate n=r(N) beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
	, reps(500) seed(1234) saving(`sims') ///
	: ccc, samplesize(`samplesize') 
	use `sims' , clear
	append using `combined'
	save `combined', replace
}

tabstat beta1 beta2 beta3 beta4 beta5, by(n)
twoway (lpolyci beta1 n, color(red) fc(gray%15)) ///
       (lpolyci beta2 n, color(orange) fc(gray%15)) ///
       (lpolyci beta3 n, color(green) fc(gray%15)) ///
       (lpolyci beta4 n, color(blue) fc(gray%15)) ///
       (lpolyci beta5 n, color(purple) fc(gray%15)) ///
       , ytitle("Beta estimates") xtitle("Sample size") ///
       legend(order(2 "Beta1" 4 "Beta2" 6 "Beta3" 8 "Beta4" 10 "Beta5")) ///
       title("Beta Coefficients Across Models & Sample Sizes")
	   
	   

*******************************************************************************
* Part 2																	  *
*******************************************************************************
clear all 
set scheme s1color

capture program drop ccc2
program define ccc2, rclass
	syntax, samplesize(integer) 
	clear
	*Create empty observations. 
	set obs `samplesize'
	*Create school observations, following in in-class exercise. 
	gen college = _n
	gen u_i = rnormal(0,2)
	gen urban = runiform()<0.50
	expand 5 // 5 years of data for each college
	bysort college: generate year = 2000 + _n -1
	bysort college year: generate course = _n
	gen u_ij = rnormal(0,3)
	// generate % of remedial courses at each college
	bysort college year: generate remedial = .3+int((.85-.3+1)*runiform())
	*Creating a variable for years of teaching experience. 
	bysort college: generate teach_exp = 2+int((20-2+1)*runiform())
	*Generate student-level dataset where each school-class will have 16-25 students.
	expand 16+int(10*runiform())
	*Create student IDs
	bysort college course: generate child = _n 
	*Create student-level effects
	generate e_ijk = rnormal(0,5)
	// using Simpson Index to create faculty diversity scores: 0 - 100
	// the higher the score, the greater faculty diversity at that campus
	bysort college: generate diversity = 30.5+int((100-30.5+1)*runiform())
	// generate mother's level of education. 
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	// label levels of education 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
	// generate treatment 
	gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)
	// gen z
	gen z = 0.5*treat + rnormal()

// DGP
	bysort college year: generate transfer_rate = runiform() * 0.04 + 0.005 ///
			+ .15*z ///
			+ (-2)*urban ///
			+ .3*diversity  ///
			+ 1.4*teach_exp ///
			+ .02*remedial ///
			+ 0.2*mother_educ ///
			+ u_i + u_ij + e_ijk
	format transfer_rate %4.2f
 
 gen h = transfer_rate + 1.5*treat + rnormal()
 
// bivariate reg
reg transfer_rate treat 
mat a = r(table)
return scalar Beta1 = a[1,1]

// multivariate reg
reg transfer_rate treat urban diversity remedial teach_exp mother_educ 
mat a = r(table)
return scalar Beta2 = a[1,1]

// introduce h
reg transfer_rate treat h urban diversity remedial teach_exp mother_educ   
mat a = r(table)
return scalar Beta3 = a[1,1]

// year fixed effects
reg transfer_rate treat h urban diversity remedial teach_exp mother_educ i.year
mat a = r(table)
return scalar Beta4 = a[1,1]

// two way fixed effects 
reg transfer_rate treat h urban diversity remedial teach_exp mother_educ i.(college year)
mat a = r(table)
return scalar Beta5 = a[1,1]

return scalar N=`c(N)'

end 

 
clear
tempfile merge
save `merge', replace emptyok
forvalues i=1/5 {
	local samplesize= `i'
	display as error "iteration = `i'" 
	tempfile sims2
	simulate n=r(N) beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
	, reps(500) seed(1234) saving(`sims2') ///
	: ccc2, samplesize(`samplesize') 
	use `sims2' , clear
	append using `merge'
	save `merge', replace
}

tabstat beta1 beta2 beta3 beta4 beta5, stats(mean sd min max)
tabstat beta1 beta2 beta3 beta4 beta5, by(n)
twoway (lpolyci beta1 n, color(red) fc(gray%15)) ///
       (lpolyci beta2 n, color(orange) fc(gray%15)) ///
       (lpolyci beta3 n, color(green) fc(gray%15)) ///
       (lpolyci beta4 n, color(blue) fc(gray%15)) ///
       (lpolyci beta5 n, color(purple) fc(gray%15)) ///
       , ytitle("Beta estimates") xtitle("Sample size") ///
       legend(order(2 "Beta1" 4 "Beta2" 6 "Beta3" 8 "Beta4" 10 "Beta5")) ///
       title("Beta Coefficients Across Models & Sample Sizes")
	   
	   