*We will get the Sample size using Stata commands for power calculation
*how many obs do we need for MDE of 0.1 sd when power is 80% 

power twomeans 0 0.1, power(0.8) sd(1)  

/*
Performing iteration ...

Estimated sample sizes for a two-sample means test
t test assuming sd1 = sd2 = sd
Ho: m2 = m1  versus  Ha: m2 != m1

Study parameters:

        alpha =    0.0500
        power =    0.8000
        delta =    0.1000
           m1 =    0.0000
           m2 =    0.1000
           sd =    1.0000

Estimated sample sizes:

            N =     3,142
  N per group =     1,571


So, for MDE to be 0.1 sd, we need 3142 observations (equally divided between treat and control)

*/


/*
We can now double check these numbers using simulation

*/

capture program drop wk10_demo
program  define wk10_demo, rclass
clear 
set obs 3142 //generate a dataset of 3142 observations
gen treatment = 0
replace treatment= 1 if _n<=1571 //divide them into control and treatment
gen y=rnormal() + 0.1*treatment  //treatment effect = 0.1 sd
reg y treatment   //run the correct model
	matrix results =r(table)  //store results
	return scalar beta = _b[treat]
	return scalar pval = results[4,1]
end

**do this 1000 times. And if our calculations are correct, we should get p values <0.05 around 800 times (800 out 1000 = 80% power)
simulate beta=r(beta) pvalue=r(pval), seed(439845) rep(1000): wk10_demo
gen sig = pvalue < 0.05  //generate dummy variable for statistical significance
summ sig  //This number might not be exactly 0.80 but should be pretty close to it 

