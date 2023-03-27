***Part 1: De-biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.

set seed 20230327
clear

set obs 6 //number of schools 
generate school = _n
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
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
label values mother_educ mother_educ
tabulate mother_educ, generate(meduc)

// MY ADDITION TO THE SCENARIO
local treat_num = _N/2
  gen x1 = rnormal() // Arbitrary covariate
  gen tutor_program = rnormal()  // 50-50 treatment
    egen rank = rank(tutor_program)
    gen treatment = rank <= `treat_num'

*DGP
generate score = 70 ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0*meduc1 ///
        + 2*meduc2 ///
        + 5*meduc3 ///
        + u_i + u_ij + e_ijk ///
		+ 10*treatment

*Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)

*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?
reg score urban teach_exp meduc2 meduc3 treatment



*Fully describe your results in your README.md file, including figures and tables as appropriate.


***Part 2: Biasing a parameter estimate using controls
*Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable.


*This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.


*When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)


*In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)


*Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?


*Fully describe your results in your README.md file, including figures and tables as appropriate.