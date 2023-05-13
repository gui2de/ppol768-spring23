*Elena Spielmann
*PPOL 768
*Week 10 STATA Assignment 05
 

******************************Part 1: Calculating required sample sizes and minimum detectable effects********************************

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
*2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.
*3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. 
*4. Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.
*5. Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.
*6. Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.

// Drop the regressions program if it already exists
capture program drop regressions 

// Define a new program called "regressions" that takes a single argument "samplesize" of type integer and returns rclass
program define regressions, rclass 

    // Clear the current data in memory
    clear 
    
    // Set the number of observations to be the value of the "samplesize" argument
    set obs `samplesize'
    
    // Generate a variable "univ" with values from 1 to "samplesize"
    gen univ = _n
    
    // Generate a normally distributed variable "u_i" with mean 0 and standard deviation 2, representing university-level effects
    generate u_i = rnormal(0,2)  
    
    // Generate a binary variable "urban" that is randomly assigned with a 50/50 chance of being 0 or 1, representing urban/rural status
    generate urban = runiform() < 0.50 
    
    // Expand the data by a factor of 10, creating 10 classrooms in each school
    expand 10 
    
    // Generate a variable "major" with values from 1 to 10, representing different majors within each universities
    bysort univ: generate major = _n 
    
    // Generate a normally distributed variable "u_ij" with mean 0 and standard deviation 3, representing major-level effects
    generate u_ij = rnormal(0,3) 
    
    // Generate a variable "campus_gym" that represents the quality of the campus fitness center ranging from 5 to 20, with equal probability
    bysort univ: generate campus_gym = 5 + int((20-5+1)*runiform()) 
    
    // Expand the data by a random factor between 15 and 27, creating a student-level dataset for each school-class
    expand 15 + int((27-15+1)*runiform()) 
    
    // Generate a variable "stud" with values from 1 to the number of students, representing student ID within each university-major
    bysort univ major: generate stud = _n 
    
    // Generate a normally distributed variable "e_ijk" with mean 0 and standard deviation 5, representing student-level effects
    generate e_ijk = rnormal(0,5) 
    
    // Generate a variable "temprand" that is uniformly distributed between 0 and 1
    generate temprand = runiform()
    
    // Use "cut" and "egen" to generate a categorical variable "par_sport" representing parent's school level playing sports, with values "elementary", "middle", and "highschool"
    egen par_sport = cut(temprand), at(0,0.5, 0.9, 1) icodes
    label define par_sport 0 "elementary" 1 "middle 2 "highschool"
    
    // Generate a binary treatment variable "treat" that is 1 if both "campus_gym" is less than or equal to 10 and "par_sport" is less than or equal to 1, and 0 otherwise
    gen treat = cond(campus_gym <= 10 & par_sport <= 1, 1, 0)
    
    // Generate an outcome variable "score" with a true effect of 5 on "treat", a true effect of -2 on "urban", a true effect of 1.5 on "campus_gym", and a random error term consisting of univ-, major-, and student-level effects
generate score = 70 ///   // generate a variable "score" with the value of 70 plus the sum of the following terms:
        + 5*treat 
        + (-2)*urban 
        + 1.5*campus_gym 
        + 0* par_sport 
        + u_i + u_ij + e_ijk   // the error terms "u_i", "u_ij" and "e_ijk"
reg score treat           // run a regression with "score" as the dependent variable and "treat" as the independent variable
mat a = r(table)          // save the regression results in a matrix "a"
return scalar Beta1 = a[1,1]   // return the coefficient for "treat" and save it in a scalar "Beta1"
return scalar pvalue1 = a[4,1] // return the p-value for "treat" and save it in a scalar "pvalue1"
reg score treat urban campus_gym par_sport   // run a regression 
mat a = r(table)           // save the regression results in a matrix "a"
return scalar Beta2 = a[1,1]    // return the coefficient for "treat" and save it in a scalar "Beta2"
return scalar pvalue2 = a[4,1]  // return the p-value for "treat" and save it in a scalar "pvalue2"
end                      // end of the program definition

clear                    // clear the data in memory
tempfile combined        // create a temporary file "combined"
save `combined', replace emptyok   // save the empty file "combined"
forvalues i=1/9 {           // loop through "i" from 1 to 9
	local samplesize= 2^(`i'-1)     // calculate the sample size as 2^(i-1)
	tempfile sims          // create a temporary file "sims"
	simulate beta_bias = r(Beta1) beta_unbias = r(Beta2) 
	pvalue_bias = r(pvalue1) pvalue_unbias = r(pvalue2) 
	, reps(500) seed(8675309) saving(`sims') 
	: regressions, samplesize(`samplesize')   // run the program "regressions" with the specified sample size
	use `sims' , clear    // use the temporary file "sims" and clear the data in memory
	gen samplesize=`samplesize'    // generate a variable "samplesize" with the calculated sample size
	append using `combined'    // append the temporary file to "combined"
	save `combined', replace    // save the file "combined"
}

gen sig_bias = 0              // Create a variable to indicate statistical significance for biased treatment effect
gen sig_unbias = 0            // Create a variable to indicate statistical significance for unbiased treatment effect
replace sig_bias =1 if pvalue_bias < 0.05  // Set the significant variable to 1 if p-value for biased treatment effect is less than 0.05
replace sig_unbias =1 if pvalue_unbias < 0.05  // Set the significant variable to 1 if p-value for unbiased treatment effect is less than 0.05
mean sig_bias, over(samplesize) // Calculate the mean of the significant variable for different sample sizes (biased)
mean sig_unbias, over(samplesize) // Calculate the mean of the significant variable for different sample sizes (unbiased)
tabstat beta_bias beta_unbias pvalue_bias pvalue_unbias sig_bias sig_unbias, by(samplesize)  // Create a table summarizing the results by sample size

capture program drop treatment // Check if the program already exists and delete it
program define treatment, rclass  // Create a program called 'treatment' that returns results in rclass format
syntax, treat_effect(real)  // Define a syntax for a treatment effect that the user will enter when calling the program
clear                      // Clear the dataset
set obs 1                  // Create a dataset with 1 observation
gen univ = _n            // Create a variable 'univ' with value 1 for the single observation
generate u_i = rnormal(0,2)  // Create school-level random effects with normal distribution
generate urban = runiform()<0.50 // Randomly assign urban/rural status to the univ
expand 10 // Duplicate the observation to create 10 classrooms in each school
bysort univ: generate major = _n // Create a variable 'major' with value 1 to 10 in each univ
generate u_ij = rnormal(0,3) // Create major-level random effects with normal distribution
bysort univ: generate campus_gym = 5+int((20-5+1)*runiform()) // Create a variable for years of teaching experience with a range of 5 to 20 years
expand 15+int((27-15+1)*runiform()) // Generate a student-level dataset, each major-class will have 15-27 students
bysort univ major: generate stud = _n // Create a variable 'stud' with value 1 to 25 in each classroom
generate e_ijk = rnormal(0,5) // Create student-level random effects with normal distribution 
* Generate a variable 'par_sport' representing parent's sports experience
generate temprand = runiform()  // Generate a random variable
egen par_sport = cut(temprand), at(0,0.5, 0.9, 1) icodes  // Divide the random variable into four equal groups to create parental sports experience categories
label define par_sport 0 "elementary" 1 "middle" 2 "highschool"  // Assign labels to the parental sport's categories
gen treat = cond(campus_gym <= 10 & par_sport <= 1, 1, 0)  // Generate a treatment variable based on conditions
// Generate a variable called 'score' as a function of other variables
generate score = 70 ///
        + `treat_effect'*treat /// add a treatment effect to the score
        + (-2)*urban /// add an urban variable with a negative coefficient
        + 1.5*campus_gym  /// add quality of campus gym with a positive coefficient
        + 0* par_sport /// add parent;s sports experience with a zero coefficient
        + u_i + u_ij + e_ijk /// add school, classroom, and student-level effects

// Run a regression of 'score' on 'treat'
reg score treat

// Store the regression table in 'a'
mat a = r(table)

// Store the beta coefficient for 'treat' in 'Beta1'
return scalar Beta1 = a[1,1]

// Store the p-value for 'treat' in 'pvalue1'
return scalar pvalue1 = a[4,1]

// Run a regression 
reg score treat urban campus_gym par_sport

// Store the regression table in 'a'
mat a = r(table)

// Store the beta coefficient for 'treat' in 'Beta2'
return scalar Beta2 = a[1,1]

// Store the p-value for 'treat' in 'pvalue2'
return scalar pvalue2 = a[4,1]

// End of the program 'treatment'
end

clear // clears the existing data in memory
tempfile combined2 // creates a temporary file to store the combined data
save `combined2', replace emptyok // saves an empty file in the temporary file
forvalues i=1/10 { // iterates from 1 to 10
	local treat_effect = `i'/2 // sets the treatment effect to i/2
	tempfile sims // creates a temporary file for simulation results
	simulate beta_bias = r(Beta1) beta_unbias = r(Beta2) ///
	pvalue_bias = r(pvalue1) pvalue_unbias = r(pvalue2) ///
	, reps(500) seed(8675309) saving(`sims') ///
	: treatment, treat_effect(`treat_effect') // simulates the data using the treatment program with the specified treatment effect
	use `sims' , clear // loads the simulated data and clears the existing data in memory
	gen treat_effect =`treat_effect' // generates a variable for the treatment effect
	append using `combined2' // appends the simulated data to the combined data file
	save `combined2', replace // saves the combined data file
}
gen sig_bias = 0 // generates a variable for significant bias
gen sig_unbias = 0 // generates a variable for significant unbiasedness
replace sig_bias =1 if pvalue_bias < 0.05 // sets the value of sig_bias to 1 if pvalue_bias is less than 0.05
replace sig_unbias =1 if pvalue_unbias < 0.05 // sets the value of sig_unbias to 1 if pvalue_unbias is less than 0.05
tabstat beta_bias beta_unbias pvalue_bias pvalue_unbias sig_bias sig_unbias, by(treat_effect) // calculates summary statistics for the variables by the treatment effect level


*****************************Part 2: Part 2: Calculating power for DGPs with clustered random errors***************************************************

*1. Develop some data generating process for data X's and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
*2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.
*3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.
*4. Calculate "exact" 95% confidence interval estimates using the betas you can use the collapse or mean command for this, or use something like lpolyci to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.
*5. Create another DGP in which the random error terms are only determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?
*6. Can you get the "analytical" confidence intervals to be correct using the vce() option in regress?

* Define a program called "CI" that takes one argument, "samplesize", and returns results as rclass
capture program drop CI
program define CI, rclass
syntax, samplesize(integer)

* Clear the memory and set the number of observations to the value of the "samplesize" argument
clear
set obs `samplesize'

* Set the random seed to 8675309 and create a variable called "univ" that contains integers from 1 to the number of observations
set seed 8675309
gen univ = _n

* Generate a variable called "urban" that takes a value of 1 with 50% probability
generate urban = runiform() < 0.50 

* Create 10 replicates of the data by using "expand" and create a cluster variable called "cluster_id"
expand 10 
bysort univ: generate cluster_id = _n 

* Generate random errors for each cluster and add a treatment variable called "treat" for the first university
generate u_i = rnormal(0,2)
expand 15 + int((27-15+1)*runiform()) 
generate u_ij = rnormal(0,3)
gen treat = cond(univ <= 1, 1, 0)

* Generate two outcome variables, "score1" and "score2", using different combinations of variables and random errors
generate score1 = 70 + 5*treat + 3* urban + u_i + u_ij
generate score2 = 70 + 5*treat + 3* urban + u_i

* Run a regression of "score1" on "treat" and "urban", and store the coefficient and confidence interval of the treatment effect under the data generating process (DGP)
reg score1 treat urban 
mat a = r(table)
return scalar Beta_DGP1 = a[1,1]
return scalar CI_DGP1 = a[6,1] - a[5,1]

* Bootstrap the regression of "score1" on "treat" and "urban" 1000 times and store the exact confidence interval of the treatment effect
bootstrap, reps(1000) seed(8675309): reg score1 treat urban
mat a = r(table)
return scalar CI_exact1 = a[6,1] - a[5,1]

* Run a regression of "score1" on "treat" and "urban" with robust standard errors and store the robust confidence interval of the treatment effect
reg score1 treat urban, vce(robust)
mat a = r(table)
return scalar CI_vce1 = a[6,1] - a[5,1]

* Run a regression of "score2" on "treat" and "urban", and store the coefficient and confidence interval of the treatment effect under the DGP
reg score2 treat urban
mat a = r(table)
return scalar Beta_DGP2 = a[1,1]
return scalar CI_DGP2 = a[6,1] - a[5,1]

* Bootstrap the regression of "score2" on "treat" and "urban" 1000 times and store the exact confidence interval of the treatment effect
bootstrap, reps(1000) seed(8675309): reg score2 treat urban
mat a = r(table)
return scalar CI_exact2 = a[6,1] - a[5,1]

* Run a regression of "score2" on "treat" and "urban" with robust standard errors and store the robust confidence interval of the treatment effect
reg score2 treat urban, vce(robust)
mat a = r(table)
return scalar CI_vce2 = a[6,1] - a[5,1]
end

// clear the memory and temporary files
clear
tempfile combined3
save `combined3', replace emptyok

// loop through different sample sizes
forvalues i=1/8 {
	// calculate the sample size for the current iteration
	local samplesize= 2^`i'

	// create a temporary file to store the simulation results
	tempfile sims

	// run the CI program with the current sample size and save the results
	simulate Beta1 = r(Beta_DGP1) CI_len_estimate1 = r(CI_DGP1) CI_len_exact1 = r(CI_exact1) CI_vce1 = r(CI_vce1) ///
	Beta2 = r(Beta_DGP2) CI_len_estimate2 = r(CI_DGP2) CI_len_exact2 = r(CI_exact2) CI_vce2 = r(CI_vce2) ///
	, reps(1) seed(8675309) saving(`sims') ///
	: CI, samplesize(`samplesize') 

	// clear the memory and load the simulation results
	use `sims' , clear

	// add a column for the current sample size and append the results to the output file
	gen samplesize=`samplesize'
	append using `combined3'

	// save the output file
	save `combined3', replace
}

// calculate summary statistics for each sample size
tabstat Beta1 CI_len_estimate1 CI_len_exact1 CI_vce1 Beta2 CI_len_estimate2 CI_len_exact2 CI_vce2, by(samplesize)

twoway (line CI_len_exact1 samplesize, color(red)) // plot exact CI length vs sample size
       (line CI_len_estimate1 samplesize, color(blue))// plot estimated CI length vs sample size
       (line CI_vce1 samplesize, color(green)) // plot robust CI length vs sample size
       , ytitle("CI length") xtitle("Sample size") // set axis labels
       legend(order(1 "Exact CI Length" 2 "Estimate CI Length" 3 "Robust Ci length")) // add legend with labels
       title("Line Graph of CI length") // add title to the graph

twoway (line CI_len_exact2 samplesize, color(red)) // plot exact CI length vs sample size
       (line CI_len_estimate2 samplesize, color(blue)) // plot estimated CI length vs sample size
       (line CI_vce2 samplesize, color(green)) // plot robust CI length vs sample size
       , ytitle("CI length") xtitle("Sample size")  // set axis labels
       legend(order(1 "Exact CI Length" 2 "Estimate CI Length" 3 "Robust Ci length")) // add legend with labels
       title("Line Graph of CI length")  // add title to the graph

