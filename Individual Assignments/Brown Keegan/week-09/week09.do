********************************************************************************
* PPOL 768
* Week 9
* Keegan Brown
********************************************************************************
clear all 
cd "/Users/keeganbrown/Desktop/Georgetown/RD/Assignments (Non-Repository) /week-09"

/*
1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.*/ 


/*2. This DGP should include strata groups and continuous covariates, as well as 
random noise. Make sure that the strata groups affect the outcome Y and are 
of different sizes, and make the probability that an individual unit receives 
treatment vary across strata groups. You will want to create the strata groups 
first, then use a command like expand or merge to add them to an 
individual-level data set. */ 




/* 3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. 
(What do these do?) */ 


capture program first drop 
program define first, rclass 

syntax, samplesize(interger)


clear
	set seed (16390)
	set obs `samplesize'
	gen school = _n
	gen u_i = rnormal(0,3) // produces random dispersion values assigned to school
	gen urban = runiform()<0.33 // in the context of the G3 one only 1 rural
	expand 500 // for the purpose of this assignment expanding directly to Sample
	gen gender = runiformint(0,1) // setting gender with uniform distribution
	gen bmi = rnormal (15, 40) // setting bmi random across
	gen athlete = cond( school == 1, runiformint(0,1), ///
				  cond( school == 2, 0, ///
				  cond( school == 3, 0))) // this is outcome confounder - e.g. student athletes may be less responsive to nudge and are only present at one spot
	generate id = _n // student id 
	generate student_id
	
	sort school 
	generate treatment_status = _n < .8*(_N) // after last line this should be confuounder based on the location - underreporting the rurual 

	
	generate activity = school + -3*bmi + 2*urban + 5*athlete + 3*treatment_status


	reg activity treatment_status
	mat results = r(table)
		return scalar model_1=a[1,1]
	
	reg activity treatment_status i.school 
	mat results = r(table)
		return scalar model_2=a[1,1]

	reg activity treatment_status i.school urban 
	mat results = r(table)
		return scalar model_3=a[1,1]

	reg activity treatment_status athlete 
	mat results = r(table)
		return scalar model_4=a[1,1]

	reg activity treatment_status urban athlete i.school 
	mat results = r(table)
		return scalar model_5=a[1,1]

	end 
	

/*4. Construct at least five different regression models with combinations of 
these covariates and strata fixed effects. 


(Type h fvvarlist for information on using fixed effects in regression.) 
Run these regressions at different sample sizes, using a program like 
last week. Collect as many regression runs as you think you need for each, 
and produce figures and tables comparing the biasedness and convergence of 
the models as N grows. Can you produce a figure showing the mean and variance 
of beta for different regression models, as a function of N? Can you visually 
compare these to the "true" parameter value?*/

simulate model_1=r(model_1) model_2=r(model_2) ///
           model_3=r(model_3) model_4=r(model_4) ///
           model_5=r(model_5) ///
  , r(150): first, strata(5) obs_in_strata(500)
  
/* 5. Fully describe your results in your README.md file, including figures
 and tables as appropriate.
 */ 
 
 
********************************************************************************
*Part 2
********************************************************************************

/* 1. Develop some data generating process for data X's and for outcome Y, 
with some (potentially multi-armed) treatment variable.*/ 

/* 2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives 
treatment vary across strata groups. You will want to create the strata groups
 first, then use a command like expand or merge to add them to an 
 individual-level data set. */ 

/* 3. When creating the outcome, make sure there is an intermediate variable 
that is a function of treatment. Have this variable determine Y in the true 
DGP, not the treatment variable itself. (This is a "channel".)*/ 

/* 4. In addition, create a second independent variable that is a function of 
both Y and the treatment variable. (This is a "collider".)*/ 



// using the above but extending to strata groups and continuos covariates and 
// 
capture program second drop 
program define second, rclass 

syntax, samplesize(interger)


clear
	set seed (16390)
	set obs `samplesize'
	gen school = _n
	gen u_i = rnormal(0,2) // produces random dispersion values assigned to school
	gen urban = runiform()<0.50
	expand 10
	bysort school: generate classroom = _n 
	gen u_class = rnormal (0,3)
	bysort school: gen teach_exp = 3+int((24-6)*runiform())
	expand 16+int((25-16+1)*runiform())
	bysort school classroom: generate child = _n
	generate u_student = rnormal(0,5)
	generate temprand = runiform()
	egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
	label define mother_educ 0 "None" 1 "HS" 2 "College"
	
	gen z= 0.6*treat + rnormal()
	generate score = 70 ///
	+ 5*zx ///
	+ (-2)*urban ///
	+1.5*teach_exp ///
	+ u_i + u_class + u_student
	
	gen h = score + 3*treat + rnormal()

	reg score treat 
	mat results = r(table)
		return scalar model_1=a[1,1]
	
	reg score treat urban teach_exp mother educ 
	mat results = r(table)
		return scalar model_2=a[1,1]

	reg  score treat h urban teach_exp mother_educ h 
	mat results = r(table)
		return scalar model_3=a[1,1]

	reg score treat urban teach_exp mother_educ i.school
	mat results = r(table)
		return scalar model_4=a[1,1]

	reg score treat urban teach_exp mother_educ i.(school classroom)
	mat results = r(table)
		return scalar model_5=a[1,1]

	end 

	clear 
	tempfile combined 
	save `combined', replace emptyok 

	
	forvalues i=1/8 {
	local samplesize= 2^`i' 
	display as error "iteration = `i'"
	tempfile sims 
	simulate beta1 = r(model_1) beta2 = r(model_2) beta3 = r(model_3) beta4 = r(model_4) beta5 = r(model_5) ///
	, reps(50) seed(16390) saving(`sims') /// 
	: second, samplesize(`samplesize')

	use `sims', clear
	gen samplesize = `samplesize'
	append using `combined'
	save `combined', replace 
	}

	use `combined'

/* 5. Construct at least five different regression models with combinations of 
these covariates and strata fixed effects. (Type h fvvarlist for information 
on using fixed effects in regression.) Run these regressions at different 
sample sizes, using a program like last week. Collect as many regression 
runs as you think you need for each, and produce figures and tables comparing 
the biasedness and convergence of the models as N grows. Can you produce a 
figure showing the mean and variance of beta for different regression models, 
as a function of N?*/ 





simulate model_1=r(model_1) model_2=r(model_2) ///
           model_3=r(model_3) model_4=r(model_4) ///
           model_5=r(model_5) ///
  , r(150): second, strata(5) obs_in_strata(500)

/* 6. Fully describe your results in your README.md file, including figures and 
tables as appropriate. */  






