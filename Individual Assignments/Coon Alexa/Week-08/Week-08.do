clear 
cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-08/03_assignment/01_data"


/*Develop some data generating process for data X's and for outcome Y.
Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder. 

FOUND IN DO FILE Week-08-DGP



Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship and an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().
Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.
Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
Fully describe your results in your README.md file, including figures and tables as appropriate.*/ 



clear all
capture program drop week8_p1 //drop program to re-run 
program define week8_p1, rclass
	do Week_08_DGP.do //loading data set
	*syntax, samplesize(10000) //randomly sample subset
	gen y=x+25*rnormal() //create y from x with a true relationship as an error--dont understand exactly what this means

	reg y x
	mat results = r(table)
	return scalar N=results[5,1]
	return scalar beta = results[1,1]
	return scalar pval=results[4,1]
	return scalar se = results[2,1]
	return scalar ci= results[6,1] //is this the correct part of the matrix?
	*display r(table) //how display results within program?
	//why does nothing show up within a program

end

week8_p1, samplesize(10000) //way I chose to add 10000, does this need to stay with the simulate command later?
display r(beta)
display r(pval)
display r(se)
display r(ci)
display r(N)	

tempfile w8_p1_store //do I need to save these into different iterations of tempfiles so they don't save over each other?

clear
forv i = 1/4 {
	//quietly should be added for ease
 simulate beta_coeff=r(beta) pvalues=r(pval) n=r(N) ///
 , reps(500) seed(65465) saving(`w8_p1_store', replace) ///
 : week8_p1, samplesize(`=10^`i'')	
 
 append using `w8_p1_store'
}

/*
simulate beta_coeff=r(beta) pvalues=r(pval), reps(500) seed(65465) saving(`w8_p1_store'): week8_p1, samplesize(10)

simulate beta_coeff=r(beta) pvalues=r(pval), reps(500) seed(65465) saving(`w8_p1_store'): week8_p1, samplesize(100)

simulate beta_coeff=r(beta) pvalues=r(pval), reps(500) seed(65465) saving(`w8_p1_store'): week8_p1, samplesize(10000)

simulate beta_coeff=r(beta) pvalues=r(pval), reps(500) seed(65465) saving(`w8_p1_store'): week8_p1, samplesize(100000)
*/

*use `w8_p1_store', clear //load all the tempfiles
tw lpolyci beta_coeff n //need to make a graph of the regressions
graph export mygraph, as(pdf)
//graph save q1_graph
//export q1_graph //how to save in local folder???

//columns correspond to the statistics, from h file
table (beta_coeff) (result[mean]),
regress beta_coeff n //command, a rather useless table to show that I can make tables
mean beta_coeff n //statistic
return list
matrix list r(C)
putexcel set "C:\Users\Alexandra\Documents\GitHub\ppol768-spring23\Individual Assignments\Coon Alexa\week-05", replace
putexcel A1=matrix (r(C), names) using corr //second attempt to export matrix to excel does not work, moving on 

//TO ASK ABOUT//


//putexcel A1=("beta_coeff") B1=("freq.") C1=("percent") using results, replace//says using doesn't work?
//table export mytable, as(pdf), didn't work
//table (beta_coeff) (n) (pval)
//display table
/*	set seed 65465 // use set seed to make sure it will always create the 	same data set
	syntax, samplesize(integer) //setting a sample size as an argument
	clear 
	*set obs 10000 // one option to add fixed population of 10,000 
	gen x1=rnormal()
	gen random_num=rnormal()
	egen rank =rank(random_num)
	gen treatment=0
	replace treatment=1 if rank>50 ///DGP and load data*/
	
	
/*Q2.
Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship and an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().
Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.
Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
Fully describe your results in your README.md file, including figures and tables as appropriate.
In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?
Do these results change if you increase or decrease the number of repetitions (from 500)?*/
	
	

clear 
set seed 6545 //create random variable, set ouside of the function or it will not vary correctly, if you want the same variation put it in the function it will produce the same results
clear all
capture program drop week8_p2
program define week8_p2, rclass
	//syntax, samplesize(integer)//more advanced proper way to do this
	
	syntax, samplesize(integer)  //arguments as set above in obs, h reclink
	clear
	set obs `samplesize'
	do Week-08-DGP-P2.do //call in DGP
	//gen y = x1+treatment*runiform()
	//reg y treatment
	reg x y
	reg y treatment
	mat results = r(table)
	mat list results //to view 
	return scalar beta = results[1,1]
	return scalar N=results[5,1]
	return scalar pval=results[4,1]
	return scalar se = results[2,1]

end

week8_p2, samplesize(100) 
display r(beta)
display r(pval)
display r(se)
display r(ci)
display r(N)	

//tempfile sims
//simulate beta=r(beta) n=r(N), reps(200) saving(`sims'): week8_p2, samplesize(1000)
//use `sims',clear


tempfile w8_p2_store 

clear
forv i = 1/4 {
	//quietly should be added for ease
 simulate beta_coeff=r(beta) pvalues=r(pval) n=r(N) ///
 , reps(40) seed(65465) saving(`w8_p2_store', replace) ///
 : week8_p2, samplesize(`=10^`i'')	
 
 append using `w8_p2_store'
}


//    Observation number must be between 400 and 2,147,483,619.  (Observation numbers are typed without commas.) --get this error if I go too high..not sure why




//normal_reg //,samplesize(10000)
*display r(beta)

//tempfile sims
//h simulate it is similar to a loop 
//simulate beta_coeff=r(beta) pvalues=r(pval), reps(100) seed(2023) saving(`sims'): normal_reg //,samplesize(10000)
/* reps--number of times seed--number of numbers saving--where to put */ 

//use `sims', clear
	
	
	
	
	
	
	
	
	

	