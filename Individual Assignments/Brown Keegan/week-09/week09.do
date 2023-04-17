********************************************************************************
* PPOL 768
* Week 9
* Keegan Brown
********************************************************************************
clear 
cd "/Users/keeganbrown/Desktop/Georgetown/RD/Assignments (Non-Repository) /week-09"

/*
1. Develop some data generating process for data X's and for outcome Y, with some 
(potentially multi-armed) treatment variable and treatment effect. Like last 
week, you should strongly consider "simulating" data along the lines of your 
group project.*/ 

capture program first drop 
program define first, rclass 

syntax, 
	set seed (16390)

	gen school = runiform(1,10)
	gen gender = runiform(1,2)
	gen randomid = runiform()
	sort randomid
	gen treatment_status = _n <=.8*(_N) // setting treatment status to 80% of the random
	gen bmi = -0.9*treatment_status + rnormal() 
	reg bmi x // performs regression 
	mat results = r(table)
	return scalar n = e(N) // provides n for later pull 
	return scalar beta = results[1, 1]
	return scalar ser = results[2, 1]
	return scalar pval = results[4, 1]
	return scalar cilow = results[5, 1]
	return scalar cihigh = results[6, 1]

	end 




/*2. This DGP should include strata groups and continuous covariates, as well as 
random noise. Make sure that the strata groups affect the outcome Y and are 
of different sizes, and make the probability that an individual unit receives 
treatment vary across strata groups. You will want to create the strata groups 
first, then use a command like expand or merge to add them to an 
individual-level data set. */ 

capture program second drop 
program define second , rclass 

syntax, strata(integer) obs_in_strata(integer)


clear
set obs `strata'

gen race = _n 
expand `obs_in_strata'

	set seed (16390)

	gen school = runiform(1,10)
	gen gender = runiform(1,2)
	gen randomid = runiform()
	sort randomid
	gen treatment_status = _n <=.8*(_n) // setting treatment status to 80% of the random
	gen bmi = -0.9*treatment_status + gender*rnormal()
	reg bmi school gender treatment_status race // performs regression 
	mat results = r(table)
	return scalar n = e(N) // provides n for later pull 
	return scalar beta = results[1, 1]
	return scalar ser = results[2, 1]
	return scalar pval = results[4, 1]
	return scalar cilow = results[5, 1]
	return scalar cihigh = results[6, 1]

	end 


/* 3. Make sure that at least one of the continuous covariates also affects both the 
outcome and the likelihood of receiving treatment (a "confounder"). Make sure 
that another one of the covariates affects the outcome but not the treatment. 
Make sure that another one affects the treatment but not the outcome. 
(What do these do?) */ 



/*4. Construct at least five different regression models with combinations of 
these covariates and strata fixed effects. 
(Type h fvvarlist for information on using fixed effects in regression.) 
Run these regressions at different sample sizes, using a program like 
last week. Collect as many regression runs as you think you need for each, 
and produce figures and tables comparing the biasedness and convergence of 
the models as N grows. Can you produce a figure showing the mean and variance 
of beta for different regression models, as a function of N? Can you visually 
compare these to the "true" parameter value?*/

/* 5. 
Fully describe your results in your README.md file, including figures
 and tables as appropriate.
 */ 
 
 
********************************************************************************
*Part 2
********************************************************************************

/* 1. Develop some data generating process for data X's and for outcome Y, 
with some (potentially multi-armed) treatment variable.*/ 

/* 2. This DGP should include strata groups and continuous covariates, as well as 
random noise. Make sure that the strata groups affect the outcome Y and are of 
different sizes, and make the probability that an individual unit receives 
treatment vary across strata groups. You will want to create the strata groups
 first, then use a command like expand or merge to add them to an 
 individual-level data set. */ 

/* 3. When creating the outcome, make sure there is an intermediate variable 
that is a function of treatment. Have this variable determine Y in the true 
DGP, not the treatment variable itself. (This is a "channel".)*/ 

/* 4. In addition, create a second independent variable that is a function of 
both Y and the treatment variable. (This is a "collider".)*/ 

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






// pulled from ali code online 

capture program drop reg_conf
program define reg_conf , rclass
syntax, anything 


clear
set obs `strata'



gen region = _n 
expand `obs_in_strata' //ah1152: making uniform size strata to keep things simple, you can revert it back once your code us working

*I removed region and artisan effects to simplify the model, I've instead added random noise in DGP

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

*generate treatment dummy variable which is influeced by region (strata) and business_exp and sales
gen treat = (region/(5) + business_exp + sales + rnormal()) > 0 

*generate dependent variable, where treatment variable has some impact(say 2.5 units) 
gen business_success = 3 + (-1)*region + business_exp + 6*customers + 2.5*treat + 2*rnormal()



reg business_success treat
	return scalar model_1=_b[treat]
	
reg business_success treat i.region
	return scalar model_2=_b[treat]

reg business_success treat i.region business_exp 
	return scalar model_3=_b[treat]

reg business_success treat i.region customers sales
	return scalar model_4=_b[treat]

reg business_success treat  business_exp sales customers
	return scalar model_5=_b[treat]
end

simulate model_1=r(model_1) model_2=r(model_2) ///
           model_3=r(model_3) model_4=r(model_4) ///
           model_5=r(model_5)  ///
  , r(150): reg_conf, strata(5) obs_in_strata(500)
