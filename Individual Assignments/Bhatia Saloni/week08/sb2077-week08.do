*Assignment - Week08 
*Name - Saloni Bhatia 

*PART1: 
*Step 1 and 2: Develop some data generating process for data X's and for outcome Y. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use `set seed` to make sure it will always create the same data set). Save this data set in your `week-08` folder.

clear 
set obs 10000 //add 10000 observations 
set seed 200 //sp that we get same results each time 
gen x = rnormal()
gen random_num = rnormal()
egen rank = rank(random_num)

save "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*Step 3: Write a do-file defining a `program` that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.

set seed 200
capture program drop example
program define example, rclass
syntax, samplesize(integer) 
clear 

*(a) loads this data
use "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*(b) randomly samples a subset whose sample size is an argument to the program;
sample `samplesize', count

*(c) create the Y's from the X's with a true relationship as an error source;
generate y = 3*x + 1 + rnormal()
  
reg y x
	 
matrix results = r(table)

matrix list results 

return scalar N = e(N)
return scalar beta = results[1,1]
return scalar SEM = results[2,1]
return scalar pval = results[4,1]
return scalar ll = results[5,1]
return scalar ul = results[6,1]
end

example, samplesize(1234)
display r(beta) //2.9958822
display r(SEM) //.02928511
display r(pval) //0
display r(ll) //2.938428
display r(ul) //3.0533364

*Step 4: Using the `simulate` command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.

clear 
tempfile example_temp
save `example_temp', emptyok

*Running simulations for N = 10, 100, 1000, 10000
forvalues i=1/4{

	local samplesize= 10^`i'
	tempfile results 
	simulate N=r(N) beta_coef=r(beta) pvalues=r(pval) sem=r(SEM) ll=r(ll) ul=r(ul) ///
	  , reps(500) seed(200) saving(`results', replace) ///
	  : example, samplesize(`samplesize')

	  preserve
	use `results', clear 
	  append using `example_temp'
	  save `example_temp', replace
	restore
}

use `example_temp', clear

*Step 5: Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

histogram beta, by(N)
graph export "Graph1.png", replace

tw lpolyci beta N
graph export "Graph2.png", replace 

*creating a table 
estpost tabstat beta sem ll ul, by(N) col(stats) s(mean sem max min)
esttab using "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/output_part1", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

*Step 6: 
*Refer to README file in Week08 Folder 
 
**Part 2: Sampling noise in an infinite superpopulation

*Step1: Write a do-file defining a `program` that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.

clear 
set obs 13000 //add 13000 observations 
set seed 250 //sp that we get same results each time 
gen x = rnormal()
gen random_num = rnormal()
egen rank = rank(random_num)

set seed 250
capture program drop example2
program define example2, rclass
syntax, samplesize(integer)
set obs 13000
clear 

*(a) loads this data
use "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*(b) randomly samples a subset whose sample size is an argument to the program;
sample `samplesize', count

*(c) create the Y's from the X's with a true relationship as an error source;
  generate y = 10*x + 5 + rnormal()
  
     reg y x
	 
matrix results = r(table)

return scalar N = e(N)
return scalar beta = results[1,1]
return scalar SEM = results[2,1]
return scalar pval = results[4,1]
return scalar ll = results[5,1]
return scalar ul = results[6,1]

end

matrix list results 

example2, samplesize(13000)
display r(beta) // 9.9944425
display r(SEM) //.02887545
display r(pval) //0
display r(ll) //9.937792
display r(ul) //10.051093

*Step2: Using the `simulate` command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.

clear 
tempfile example_temp2
save `example_temp2', replace emptyok

forvalues i=1/21{
	
	local samplesize= 2^`i' //Doubt: It is only running till i=1/13
	tempfile results2
	simulate N=r(N) beta_coef=r(beta) pvalues=r(pval) sem=r(SEM) ll=r(ll) ul=r(ul), reps(500) seed(250) saving(`results2'): example2, samplesize(`=2^`i'')

	use `results2', clear 
	  append using `example_temp2'
	  save `example_temp2', replace	
}

	forvalues i = 1/6 {
	local samplesize= 10^`i'
	tempfile results3
	simulate N=r(N) beta_coef = r(beta) pvalues = r(pval) sem = r(SEM) ll=r(ll) ul=r(ul) ///
    , reps(500) seed(250) saving(`results3') ///
	: example2, samplesize(`=10^`i'')
  
   use `results3' , clear
   append using `example_temp2'
     save `example_temp2' , replace
}

use `example_temp2', clear

//Doubt: The two loops with different values of N run together only. the code break if run separately

*Step3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

histogram beta_coef, by(N) 
graph export "Graph3.png", replace

*estpost tabstat beta se, by(N) col(stats) s(mean sem max min)
tw lpolyci beta N
graph export "Graph4.png", replace 

estpost tabstat beta sem ll ul, by(N) col(stats) s(mean sem max min)
esttab using "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/output_part2", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

*Step4. Fully describe your results in your `README.md` file, including figures and tables as appropriate.
*Refer to README file in Week08 Folder 

*Step5: In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?

*Step6: Do these results change if you increase or decrease the number of repetitions (from 500)?
*Since, the 500 simulations did not run to perfection, I am yet to try the same for when repititions =! 500













