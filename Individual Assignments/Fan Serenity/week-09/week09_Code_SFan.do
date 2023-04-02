*Serenity Fan (kaf121)
*Last Updated: April 2nd, 2023 
*Week 9 Assignment Code 

*_________________________________________________
*MULTI-LEVEL SIMULATION: MANUAL SCAVENGING INTERVENTION (TRAINING & MENTORSHIP IN THE FACE OF SANITATION AUTOMATION)

*Define Variables and units 

* Y = Income in 1 year 
* X0 = Income today (average set at 10,000 INR/month , as per https://swachhindia.ndtv.com/after-skill-training-manual-scavengers-return-to-cleaning-sewers-30490/ )
* X1 = Treatment: Number of days spent attending training 
* X2 = Years of education (continuous covariate #1)
* X3 = Years to date spent working in manual scavenging field (continuous covariate #2)
* X4 = Door-to-door transit time to city centre (continuous covariate #2)
* X5 = Gender (indicator variable)
* Y = Probability of leaving the manual scavenging field 
* i = District level (75 districts in UP)
* j = Villagel-level (panchiyat) or municipality 
* k = Household-level 





*_________________________________________________
*Part 1: De-biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*Plan 
	*generate X 
	*geneate Y = district
	*generate treatment (start with binary) = district 

*	We will consult and work with the Ministry of Social Justice and Empowerment to decide upon the unit of randomization of sanitation mechanization within UP, likely at either the district or village level. This will be based upon the administrative level to which the funding for the desludging machines will be allocated.  

*The Cluster RCT will have 2 Treatment Arms and 1 Control Arm:  

* Control Arm: Infrastructure projects happening, but we do NOT implement any intervention, i.e. we treat the location-specific government mechanization as an exogenous change
* Treatment Arm 1: In areas where sanitation mechanization is happening, we will provide some combination of job training, certification, employment services, mentorship, etc. 
* Treatment Arm 2:  In areas where sanitation mechanization happening, provide cash transfer as comparison with Treatment Arm 1, where the cash transfer is equivalent in value to the amount spent in the 2nd arm 
	
clear 
set seed 111

*District-level effects (i) 
	*Treatment happens at this level (assuming government implements mechanized de-sludging by randomizing at the district level)
set obs 10 
* Let's assume for simplicity this is the # of districts within Uttar Pradesh (UP)  (actual number 75)
gen district = _n // Assign district ID 
generate u_i = rnormal(500,100) // District effects 


*Village/Municipality-level effects (j) 
expand 100 + int((50)*runiform()) 
 // Assume mean of 100 villages/municipalities per district 
bysort district: generate village = _n
generate u_ij = rnormal(500,100)


*Household-level effects (k) 
expand 100 + int((50)*runiform()) 
 // Assume mean of 100 manual-scavenging households per village/municipality 

bysort district village: generate hh = _n // generate household ID
generate e_ijk = rnormal(1000,500) // Generate household-level effects 

generate income_pres = rnormal(10000, 2000)

*Confounders: affect both the outcome and the likelihood of receiving treatment
gen scav_years = runiform(1, 30) // Years spent working as manual scavengers: assume that individuals who have worked as manual scavengers for shorter amounts of time are more likely to change into other, higher-paid fields when provided training + mentorship program

*Covariate: Affects outcome but not treatment 
gen transit_time = rnormal(60,10) // Time (minutes) to nearest urban centre, ie. proxy for access to 'good' job opportunities: individuals living closer to urban centres should have better job outcomes subject to attending program  
gen educ = runiform(0,10) // Years of education  

*Affects treatment but not outcome 
gen female = round(runiform(0,1), 1)

*Generate Treatment: Apply treatment to the 1st 5 districts (assuming that the district numbers have already been randomized), to female manual scavengers with less than 10 years of experience in the field
generate treatment = 0 
replace treatment = rnormal(10000, 1000) if district<=5 & scav_years<=10 & female==1 


*DGP (DATA GENERATING PROCESS) 
gen income_future = income_pres ///
	+ treatment ///
	+ 50*(30-scav_years) ///
	+ 40*(60-transit_time) ///
	+ 300*educ ///
	+ u_i /// 
	+ u_ij /// 
	+ e_ijk /// 
	+ 1000*rnormal() // Add noise 


reg y treat 



*This DGP should include strata groups (e.g. race) and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups (e.g. race). You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)





*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?

reg Y treatment 
reg Y treatment i.district 
reg Y treatment i.district confounder
reg Y treatment i.district confounder covar2
reg Y treatment i.district confounder covar3
reg Y treatment i.district confounder covar2 covar3 

*i.district --> Converts integer values to categorical variables 
* i.e. If district can take on 4 values (1,2,3,4), then will create 4 dummy variables, i.e. district1 is 1 for district 1 and 0 otherwise, 
*    district2 is 1 for district 2 and 0 otherwise, 
*    ... 
*    and district4 is not used due to multi-collinearity 


*Fully describe your results in your README.md file, including figures and tables as appropriate.










*_________________________________________________
*Part 2: Biasing a parameter estimate using controls

*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.

*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)

*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?

*Fully describe your results in your README.md file, including figures and tables as appropriate.