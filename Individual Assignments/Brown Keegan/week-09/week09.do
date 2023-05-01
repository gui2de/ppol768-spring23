********************************************************************************
* PPOL 768
* Week 9
* Keegan Brown
********************************************************************************
clear all 
cd "/Users/keeganbrown/Desktop/Georgetown/RD/Assignments (Non-Repository) /Brown Keegan/week-09"

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

tempfile part1

capture program first drop 
program define first, rclass 
	syntax anything 

	clear 
	set obs 3
	gen school =_n
	set seed 16390
	gen u_i = rnormal() // produces random dispersion values assigned to school
	gen urban = runiform()<0.33 // in the context of the G3 one only 1 rural
	expand `anything' // for the purpose of this assignment expanding directly to Sample
	gen gender = runiformint(0,1) // setting gender with uniform distribution
	gen bmi = rnormal(25,7) // setting bmi random across


	gen athlete = cond(school == 1, runiformint(0,1), ///
                cond(school == 2, 0, ///
                cond(school == 3, 0, .)))
	
	gen id = _n // student id 
	sort school 
	generate  treatment_status = (rnormal()+(1/school))>0
	
	
	gen activity = school + -3*bmi + 2*urban + 5*athlete + 3*treatment_status
	

	reg activity treatment_status athlete 
	mat results = r(table)
		return scalar model_1=_b[treatment_status]
		return scalar N1 = e(N)
	
	reg activity treatment_status i.school athlete 
	mat results = r(table)
		return scalar model_2=_b[treatment_status]
		

	reg activity treatment_status i.school gender athlete 
	mat results = r(table)
		return scalar model_3=_b[treatment_status]
	

	reg activity treatment_status athlete i.school
	mat results = r(table)
		return scalar model_4=_b[treatment_status]


	reg activity treatment_status urban bmi athlete 
	mat results = r(table)
		return scalar model_5=_b[treatment_status]

	end 
	
save `part1', replace emptyok	

/*4. Construct at least five different regression models with combinations of 
these covariates and strata fixed effects. 


(Type h fvvarlist for information on using fixed effects in regression.) 
Run these regressions at different sample sizes, using a program like 
last week. Collect as many regression runs as you think you need for each, 
and produce figures and tables comparing the biasedness and convergence of 
the models as N grows. Can you produce a figure showing the mean and variance 
of beta for different regression models, as a function of N? Can you visually 
compare these to the "true" parameter value?*/


tempfile combined
save `combined', replace emptyok
	tempfile sims

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error "ss"
	simulate N1 = r(N1) model_1=r(model_1) model_2=r(model_2) ///
         model_3=r(model_3) model_4=r(model_4) ///
         model_5=r(model_5), saving(`sims', replace) ///
         reps(150): first `ss' 
		 
		 use `sims', clear 
		 
		 append using `combined'
			save `combined', replace 
	}
  
/* 5. Fully describe your results in your README.md file, including figures
 and tables as appropriate.
 */ 
 use `combined', clear

graph box model_1 model_2 model_3 model_4 model_5, over(N) yline(3) noout

graph export "outputs/part1_box.png", replace
 
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

clear all 


tempfile part2

capture program second drop 
program define second, rclass 
	syntax anything 

	clear 
	set obs 3
	gen school =_n
	set seed 16390
	gen u_i = rnormal() // produces random dispersion values assigned to school
	gen urban = runiform()<0.33 // in the context of the G3 one only 1 rural
	expand `anything' // for the purpose of this assignment expanding directly to Sample
	gen gender = runiformint(0,1) // setting gender with uniform distribution
	gen bmi = rnormal(25,7) // setting bmi random across

	
	

	gen athlete = cond(school == 1, runiformint(0,1), ///
                cond(school == 2, 0, ///
                cond(school == 3, 0, .)))
	
	gen id = _n // student id 
	sort school 
	generate  treatment_status = (rnormal()+(1/school))>0
	gen restinghr = bmi*2*treatment_status // collider 
	
	
	gen activity = -.5*school -3*bmi + 2*urban + 5*athlete + 3*treatment_status + restinghr //
	gen priorwearable = -1*activity*-3*treatment_status // channel 

	reg activity treatment_status athlete 
	mat results = r(table)
		return scalar model_1=_b[treatment_status]
		return scalar N1 = e(N)
	
	reg activity treatment_status i.school athlete 
	mat results = r(table)
		return scalar model_2=_b[treatment_status]
		

	reg activity treatment_status i.school gender athlete 
	mat results = r(table)
		return scalar model_3=_b[treatment_status]
	

	reg activity treatment_status athlete i.school priorwearable
	mat results = r(table)
		return scalar model_4=_b[treatment_status]


	reg activity treatment_status urban bmi athlete restinghr 
	mat results = r(table)
		return scalar model_5=_b[treatment_status]

	end 
	
save `part2', replace emptyok

// using the above but extending to strata groups and continuos covariates and 
// 


tempfile combined2
save `combined2', replace emptyok
	tempfile sims

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error "ss"
	simulate N1 = r(N1) model_1=r(model_1) model_2=r(model_2) ///
         model_3=r(model_3) model_4=r(model_4) ///
         model_5=r(model_5), saving(`sims', replace) ///
         reps(150): second `ss' 
		 
		 use `sims', clear 
		 
		 append using `combined2'
			save `combined2', replace 
	}
  

/* 5. Construct at least five different regression models with combinations of 
these covariates and strata fixed effects. (Type h fvvarlist for information 
on using fixed effects in regression.) Run these regressions at different 
sample sizes, using a program like last week. Collect as many regression 
runs as you think you need for each, and produce figures and tables comparing 
the biasedness and convergence of the models as N grows. Can you produce a 
figure showing the mean and variance of beta for different regression models, 
as a function of N?*/ 


/* 6. Fully describe your results in your README.md file, including figures and 
tables as appropriate. */  


use `combined2', clear

graph box model_1 model_2 model_3 model_4 model_5, over(N) yline(3) noout

graph export "outputs/part2_box.png", replace



