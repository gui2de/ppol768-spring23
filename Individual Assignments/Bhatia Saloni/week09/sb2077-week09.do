*Saloni Bhatia 
*Week 09 Assignment 


set seed 896124
clear
set obs 6 //number of schools - assuming that there are 6 schools at the highest level 
generate school = _n
generate u_i = rnormal(0,2)  // SCHOOL EFFECTS could be normally or uniformally distributed
generate urban = runiform()<0.50 //randomly assign urban/rural status
expand 10 //create 10 classroom in each school - within each school we are assuming that we have data from 10 classrooms each. we could also create different number of classrooms in each school 
sort school 
bysort school: generate classroom = _n //create classroom id
generate u_ij = rnormal(0,3) // CLASSROOM EFFECTS - we are saying that they are normally distributed with mean 0 and 3 sd

bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create a variabel for years of teaching experience, specific for each classroom. This is a continuous variable between 5 ans 20. How have been defined teacher experience?
expand 16+int((25-16+1)*runiform()) //generate student level dataset, each school-class will have 16-25 students. 

**creating student level effects, eg: mother edication as categorical variable 
bysort school classroom: generate child = _n //generate student ID
generate e_ijk = rnormal(0,5) //create student level effects 

*generate mother education variable as a categorical variable with 4 different categories 
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
label values mother_educ mother_educ
tabulate mother_educ, generate(meduc)

**now we have different levels and different scores 

*DGP - tells you what your coefficients should be. in real life we dont know the data generating process. we are doing this to see how collider and confounder variable can impact coefficients 
generate score = 70 /// these numbers can be anything depedning on real life 
        + (-2)*urban /// if you're going to an urban area school, on average deduct 
        + 1.5*teach_exp  /// classroom level variation. if your teacher has 5 years of experience, it should led to extra 5*1.5=7.5 marks 
        + 0*meduc1 /// if mother's education is high school, you are not getting anything extra 
        + 2*meduc2 /// if mother went to college, add another 2. not that meduc are dummy variables 
        + 5*meduc3 /// 
        + u_i + u_ij + e_ijk //adding the school level effects, classroom level effects and student level effects becuase there is a lot of variation between these 

		
reg score urban teach_exp meduc2 meduc3		
*check if betas are the same/similar to DGP	
*if we run this 500 times, we should get similar results 	

*lets assume there are no classrooms, only school and students where school would be a strata. in some cases when youre running RCTs in 4 districts. districts could be very different and we can create stratas for districts - it is context dependent, design of an RCT (?), model and DGP
		
*See this Stata blog for more details re: multi-level data simulation
* https://blog.stata.com/2014/07/18/how-to-simulate-multilevellongitudinal-data/



*Part 1: De-biasing a parameter estimate using controls

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.

*generate X

*generate Y = district +

*generate treatment (start with binary) = district (strata should affect if someone is in treatment or not)





*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?) --> this means that covar_1 impacts Y

*what are strata groups?
*what are continuous covariates?


clear 
set obs 5 
gen district = _n
expand 100 (100 in each strata)

*generate 3 covariates (those that you add to the regression, impact of adding control variables)
gen covar_1 = rnormal()
gen covar_2 = rnormal()
gen covar_3 = rnormal()

reg y treatment //(eg: math score on average is 70 and in treatment it is 75 so coefficient for treatment should be 5. but in some cases you have to add controls. what are the right controls??)




*4. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?
*5. Fully describe your results in your README.md file, including figures and tables as appropriate.

*Part 2: Biasing a parameter estimate using controls

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.
*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
*3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
*4. In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
*5. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
*6. Fully describe your results in your README.md file, including figures and tables as appropriate.


*Clear before running code.
clear all

*Part 2:

*Using capture program drop so that re-running the .do file is feasible.
capture program drop RDI
*Define the program.
program define RDI, rclass
syntax, samplesize(integer)  //*Sample size will be the argument in the defined program.
clear 
*set seed 04182023 //Set seed for replicability.
*commenting out the seed part becuase setting the seed inside the program will generate the exact same output every single time
*Create empty observations.
set obs `samplesize'
*Create school observations, like in in-class exercise.
gen school = _n
*Ali's notes say the following code is "school effects," but I don't recall what he means by this.
gen u_i = rnormal(0,2)
*Create new variables that randomly assign the observations to either be rural or ubran.
gen urban = runiform()<0.50
*Create ten classrooms in each school.
expand 10
*Generate classroom IDs by sorting the school variable and then using the subsequent order of observations, _n.
bysort school: generate classroom = _n
*Classroom effects (?)
gen u_ij = rnormal(0,3)
*Creating a variable for years of teaching experience.
bysort school: generate teach_exp = 5+int((20-5+1)*runiform())
*Generate student-level dataset where each school-class will have 16-25 students.
expand 16+int((25-16+1)*runiform())
*Create student IDs
bysort school classroom: generate child = _n
*Create student-level effects
generate e_ijk = rnormal(0,5)
*Let's now create a variable representing a given mother's level of education.
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
*Create labeled categories of various levels of education.
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
*Create the treatment.
gen treat = cond(teach_exp <= 10 & mother_educ <= 1, 1, 0)

gen z = 0.5*treat + rnormal()
*Replicating something we did in class.
generate score = 70 ///
+ 5*z ///
+ (-2)*urban ///
+ 1.5*teach_exp ///
+ mother_educ ///
+ u_i + u_ij + e_ijk

gen h = score + 3*treat + rnormal()

*First regression:
reg score treat
mat a = r(table)
return scalar Beta1 = a[1,1]

*Second regression:
reg score treat urban teach_exp mother_educ
mat a = r(table)
return scalar Beta2 = a[1,1]

*Third regression:
reg score treat h urban teach_exp mother_educ h
mat a = r(table)
return scalar Beta3 = a[1,1]

*Fourth regression:
reg score treat urban teach_exp mother_educ i.school
mat a = r(table)
return scalar Beta4 = a[1,1]

*Fifth regression:
reg score treat urban teach_exp mother_educ i.(school classroom)
mat a = r(table)
return scalar Beta5 = a[1,1]

end

clear
*Defining a temporary space Stata to store data created in loop to follow:
tempfile combinedtwo
*Telling Stata not to present an error message that the tempfile has no data in it.
save `combinedtwo', replace emptyok

forvalues i=1/8 {
local samplesize= 2^`i' 
display as error "iteration = `i'"
tempfile sims 
simulate beta1 = r(Beta1) beta2 = r(Beta2) beta3 = r(Beta3) beta4 = r(Beta4) beta5 = r(Beta5) ///
, reps(50) seed(4454) saving(`sims') /// 
: RDI, samplesize(`samplesize')

use `sims', clear
gen samplesize = `samplesize'
append using `combinedtwo'
save `combinedtwo', replace 
}

use `combinedtwo'
