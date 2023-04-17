*Assignment - Week08 
*Name - Saloni Bhatia 

**Part 1: Sampling noise in a fixed population
*1. Develop some data generating process for data X's and for outcome Y.
*2. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use `set seed` to make sure it will always create the same data set). Save this data set in your `week-08` folder.
*3. Write a do-file defining a `program` that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.
*4. Using the `simulate` command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.
*5. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
*6. Fully describe your results in your `README.md` file, including figures and tables as appropriate.

*Step 1: Develop some data generating process for data X's and for outcome Y. Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use `set seed` to make sure it will always create the same data set). Save this data set in your `week-08` folder.

clear 
*add 10000 observations 
set obs 10000
set seed 200
gen x1 = rnormal()
gen random_num = rnormal()
egen rank = rank(random_num)

save "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*Step 2: Write a do-file defining a `program` that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.

capture program drop example
program define example, rclass
syntax, samplesize(integer) 

*(a) loads this data
 use "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*(b) randomly samples a subset whose sample size is an argument to the program;
sample `samplesize', count

*(c) create the Y's from the X's with a true relationship as an error source;
  generate y = 3*x + 1 + rnormal()
  
     reg y x
	 
matrix results = r(table)

matrix list results 

return scalar N = `e(N)'
return scalar beta = results[1,1]
return scalar SEM = results[2,1]
return scalar pval = results[4,1]
return scalar ll = results[5,1]
return scalar ul = results[6,1]
end

example, samplesize(1234)
display r(beta)
display r(SEM)
display r(pval)
display r(ll)
display r(ul)

exit

*Step 3: Using the `simulate` command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.

tempfile example_temp
tempfile results
save `results', emptyok

forvalues i=1/4{

	local samplesize= 10^`i'
	tempfile example_temp
	simulate N=r(N) beta_coef=r(beta) pvalues=r(pval) ///
	  , reps(500) seed(200) saving(`example_temp' , replace) ///
	  : example, samplesize(`samplesize')

	use `example_temp'
	  append using `results'
	  save `results' , replace

}

use `results', clear

*Step 4: Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

histogram beta, by(N)
*generating a histogram of betas for samplesize=10
local style "start(-0.5) barwidth(0.09) width(.1) fc(gray) freq"
tw ///
(histogram beta, `style' lc(red) ) ///
(histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ) ///
, by(N) xtit("") legend(on ring(0) pos(1) order(2 "p < 0.05") region(lc(none)))

*creating a table 
tw lpolyci beta samplesize

*Doubts: 
*1. The histogram is centered around 3, I am not sure why. I am getting errors such as '=10000 invalid name'. How to solve for this?
*2. I am not sure how to generate multiple tables and figures becuase of which I have not yet uploaded a README file. 
*3. How should I load my 2000 values? aren't they going to my tempfile? iif yes, how do i check?
*4. the results do not return in a matric format 

*________________________________________________________________________________________*

**Part 2: Sampling noise in an infinite superpopulation.

*1. Write a do-file defining a `program` that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.
*2. Using the `simulate` command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.
*3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
*4. Fully describe your results in your `README.md` file, including figures and tables as appropriate.
*5. In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?
*6. Do these results change if you increase or decrease the number of repetitions (from 500)?

*1. Write a do-file defining a `program` that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into `r()`.

capture program drop example2
program define example2, rclass
syntax, samplesize(integer) 

*(a) loads this data
 use "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia Saloni/week08/outputs/w08-dataset.dta", replace

*(b) randomly samples a subset whose sample size is an argument to the program;
sample `samplesize', count

*(c) create the Y's from the X's with a true relationship as an error source;
  generate y = 10*x + 5 + rnormal()
  
     reg y x
	 
matrix results = r(table)

return scalar N = `e(N)'
return scalar beta = results[1,1]
return scalar SEM = results[2,1]
return scalar pval = results[4,1]
return scalar ll = results[5,1]
return scalar ul = results[6,1]

end

matrix list results 

example2, samplesize(1234)
display r(beta)
display r(SEM)
display r(pval)
display r(ll)
display r(ul)

exit

*2. Using the `simulate` command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.

forvalues i=1/21{
	local samplesize= 2^`i'
tempfile example_temp2
simulate beta_coef=r(beta) pvalues=r(pval), reps(500) seed(200) saving(`example_temp2'): example2, samplesize(`samplesize')
}


forvalues i=1/6{
	local samplesize= 10^`i'
tempfile example_temp2
simulate beta_coef=r(beta) pvalues=r(pval), reps(500) seed(200) saving(`example_temp2'): example2, samplesize(`samplesize')
}

exit

*3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.














*Doubts:
*1) Even though I used the same code as in Part 1, stata says 'file w08-dataset.dta not found' - why?
*2) The simulation runs for a long time but I dont know how to analyize it or ensure that my code is correct. How do I analyze the output? 
*3) Similar issue as Part 1 regarding lack of graphs and tables in README 
*4) How to check that both my simulation loops were run?
*5)I could not visualize Part 1 and Part 2 together meaningfully, and create a comparison table











