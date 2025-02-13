*Elena Spielmann
*PPOL 768
*Week 08 STATA Assignment 03

clear
set seed 8675309

cd "C:\Users\easpi\OneDrive\Documents\ppol768-good\Individual Assignments\Spielmann Elena\week-08"

***********************Part 1: Sampling noise in a fixed population*****************************

*1. Develop some data generating process for data X's and for outcome Y.

*2. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.

*3. Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().

*4. Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.

*5 Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

*6. Fully describe your results in your README.md file, including figures and tables as appropriate.

// Set the number of observations to 10000
set obs 10000

// Generate random normally distributed variable x
gen x = rnormal()

// Save the dataset as "week8_data"
save "week8_data", replace

// Define program "trial1"
capture program drop trial1
program define trial1, rclass
    // Syntax command for specifying an integer argument named "samplesize"
    syntax, samplesize(integer)

    // (a) Load the dataset "week8_data"
    use "week8_data", clear

    // (b) Randomly sample a subset of size "samplesize" from the dataset
    sample `samplesize', count 

    // (c) Create a dependent variable "y" with a true relationship to "x" and an error source
    gen y = 2 + 1.5 * x + 2 * rnormal()

    // (d) Perform a simple linear regression of "y" on "x"
    reg y x 

    // (e) Store the results of the regression in a matrix "a" and return selected values using r()
    mat a = r(table)
    return scalar samp = _N
    return scalar beta = a[1,1]
    return scalar sem = a[2,1]
    return scalar pval = a[4,1]
    return scalar ci_l = a[5,1] 
    return scalar ci_u = a[6,1] 
end

// Save the results of the simulations into a temporary file "combined"
clear
tempfile combined
save `combined', replace emptyok

// Loop through different sample sizes and run the "trial1" program with each sample size
forvalues i = 1/4 {
    local samplesize = 10^`i'
    tempfile sims
    simulate beta = r(beta) pval = r(pval) se = r(sem) lower = r(ci_l) upper = r(ci_u), ///
        reps(500) seed(725485) saving(`sims') : trial1, samplesize(`samplesize') 

    // Use the results from the simulations and append them to "combined"
    use `sims', clear
    gen samplesize = `samplesize'
    append using `combined'
    save `combined', replace
}

// Load the final dataset "combined" into memory
use `combined', clear 

// Display the matrix "a"
mat list a

// Graph the relationship between beta and samplesize
tw (lpolyci beta samplesize, fc(gray%30)), xscale(log) xlab(10 100 1000 10000) yline(1.5)

// Create a histogram of beta by sample size
histogram beta, by(samplesize)

// Collapse data to calculate the mean of beta and standard error by sample size
collapse (mean) beta se, by(samplesize)


***Part 2: Sampling noise in an infinite superpopulation.

*1. Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().


*2. Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.

*3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

*4. Fully describe your results in your README.md file, including figures and tables as appropriate.

*In general, as the sample size or N value increases, the standard errors and p-values tend to decrease, while the t-values tend to increase. This reflects the fact that larger sample sizes or N values provide more precise estimates of the true regression coefficient, making it easier to detect a significant relationship between X and Y.

*The figure shows the estimated regression coefficients for each of the 13,000 simulated regression models as a function of sample size (on the x-axis) and N value (represented by the different colored lines). Each dot represents the estimated coefficient for a single simulated regression model.

*As expected, the estimates are more variable at smaller sample sizes and N values, and become more precise as sample size or N increases. The different colored lines show that the estimated coefficients tend to be more variable at smaller N values, but converge to a more consistent estimate as N increases. This reflects the fact that larger N values provide more stable estimates of the true relationship between X and Y.

*5. In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?

*6. Do these results change if you increase or decrease the number of repetitions (from 500)?

// Clear all existing data
clear all

// Define a STATA program called "week8_p2"
capture program drop week8_p2
program define week8_p2, rclass 
    // Define the syntax of the program to take an integer argument called "samplesize"
    syntax, samplesize(integer) 

    // Clear the existing data
    clear 
    // Set the number of observations to the "samplesize" argument
    set obs `samplesize'

    // Generate a variable "x" that is a random normal distribution
    gen x =rnormal() 
    // Generate a variable "y" that has a true relationship with "x" and an error source
    gen y = 2 + 1.5 * x + 2 * rnormal() 
    // Perform a regression of "y" on "x"
    reg y x 

    // Store the regression output in a matrix "a"
    matrix a = r(table) 
    // Display the matrix "a"
    matrix list a

    // Store several values (sample size, beta coefficient, standard error, p-value, lower and upper bounds of CI) into "r()"
    return scalar samp = _N
    return scalar beta = a[1,1]
    return scalar sem = a[2,1]
    return scalar pval = a[4,1]
    return scalar ci_l = a[5,1] 
    return scalar ci_u = a[6,1] 
end

// Clear existing data
clear
// Create a temporary file to store results
tempfile combined2
save `combined2', replace emptyok

// For loop to generate simulated data for different sample sizes
forvalues i = 1/6 {
    // Set the sample size as a power of 10
    local samplesize = 10^`i'
    // Create a temporary file to store simulation results
    tempfile sims
    // Simulate beta coefficient, p-value, standard error, and lower and upper bounds of CI, 
    // and save the results in the "sims" file
    simulate beta = r(beta) pval = r(pval) se = r(sem) lower = r(ci_l) upper = r(ci_u), ///
        reps(500) seed(5678) saving(`sims') : week8_p2, samplesize(`samplesize') 

    // Load the simulation results from the "sims" file
    use `sims', clear
    // Create a variable called "samplesize" with the value of "samplesize"
    gen samplesize = `samplesize'
    // Append the simulation results to the "combined2" file
    append using `combined2'
    // Save the updated "combined2" file
    save `combined2', replace
}

// Load the "combined2" file
use `combined2', clear 

// Create a histogram of beta coefficients by sample size
histogram beta, by(samplesize)

// Create a graph of beta coefficients against the true value (with confidence intervals)
tw (lpolyci beta samplesize, fc(gray%30)), xscale(log) xlab(10 100 1000 10000) yline(1.5)

// Create a table of mean beta coefficients and standard errors by sample size
collapse (mean) beta se, by(samplesize)

