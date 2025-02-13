/* week 9 assignment */

cd "C:/Users/Maeve/GitHub/ppol768-spring23/Individual Assignments/Grady Maeve/week-08"
clear


/* Part 1: Sampling noise in a fixed population */

//Creating the fixed population
	//setting the seed (date)
	set seed 31723

	//set observation count to 10k
	set obs 10000 

	// generate x's

	gen x = rnormal()
	


	//saving data
	save "wk8data", replace
	
// writing a program that a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().

	// beginning a program 
	cap prog drop wk8
	prog def wk8 , rclass 
	
	//making sample size an argument
	syntax, samplesize(integer)

	//loading data
	use "wk8data.dta", clear
	
	//randomly sample a subset 
	sample `samplesize', count
	
	//generate treatment groups
	local treatmentcount = `samplesize'/2
	gen x1 = rnormal() // Arbitrary covariate
	gen rand = rnormal()  // 50-50 treatment
    egen rank = rank(rand)
    gen treatment = rank <= `treatmentcount'


	//generating ys
	gen y = x1 + treatment*runiform()
	
	
	// run regression
	reg y treatment
	
	//returns
	mat returns = r(table)
		return scalar beta = returns[1,1]
		return scalar pval = returns[4,1]
		return scalar lowci = returns[5,1]
		return scalar highci = returns[6,1]
		return scalar SEM = returns[2,1]
		return scalar N = returns[2,1]

	
end

// use simulate to run program 500 times at sample size  N = 10, 100, 1,000, and 10,000. 

clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	display as error "iteration = `i'"
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(31723) saving(`sims') ///
	  : wk8, samplesize(`samplesize') 
		display as error "after simulate command"
		
	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace
}
 


//Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

use `combined', clear

	//Create histogram of beta distribution by sample size
	histogram beta, by(samplesize)
	/*graph export betahist.png*/
	
	histogram se, by(samplesize)
	/*graph export sehist.png*/
	
	gen interval = upperbound - lowerbound
	histogram interval, by(samplesize)
	/*graph export intervalhist.png*/
	
	//create table of standard deviation beta, standard error by sample size
	preserve
	collapse (sd) beta se, by(samplesize)
	list
	restore


/* Part 2: Sampling noise in an infinite superpopulation */

// define a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().

// beginning a program 
	cap prog drop wk8_infinite
	prog def wk8_infinite , rclass 
	
	//making sample size an argument
	syntax, samplesize(integer)

	//loading data
	use "wk8data.dta", clear
	
	//randomly sample a subset 
	sample `samplesize', count
	
	//generate treatment groups
	local treatmentcount = `samplesize'/2
	gen x1 = rnormal() // Arbitrary covariate
	gen rand = rnormal()  // 50-50 treatment
    egen rank = rank(rand)
    gen treatment = rank <= `treatmentcount'

	
	//generating ys
	gen y = x1 + treatment*runiform()
	
	// run regression
	reg y treatment
	
	//returns
	mat returns = r(table)
		return scalar beta = returns[1,1]
		return scalar pval = returns[4,1]
		return scalar lowci = returns[5,1]
		return scalar highci = returns[6,1]
		return scalar SEM = returns[2,1]
		return scalar N = returns[2,1]

	
end


///Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.


clear
tempfile combo_pt2
save `combo_pt2', replace emptyok


forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(31723) saving(`sims') ///
	  : wk8_infinite, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combo_pt2'
	save `combo_pt2', replace
}
 

forvalues i=2/21{
	local samplesize= 2^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
	  , reps(500) seed(31723) saving(`sims') ///
	  : wk8_infinite, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combo_pt2'
	save `combo_pt2', replace
}
 

 use `combo_pt2', clear


///Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

	//Create histogram of beta distribution by sample size
	histogram beta, by(samplesize)
	graph export betahist2.png 
	
	histogram se, by(samplesize)
	graph export sehist2.png
	
	gen interval = upperbound - lowerbound
	histogram interval, by(samplesize)
	graph export intervalhist2.png
	
	//create table of standard deviation beta, standard error by sample size
	preserve
	collapse (sd) beta se, by(samplesize)
	list
	restore


/// create one viz to meaningfully compare part one and part two 


/* i'm getting stuck here*/


/// Do these results change if you increase or decrease the number of repetitions (from 500)?



		clear
		tempfile combo_final
		save `combo_final', replace emptyok


		forvalues i=1/4{
			local samplesize= 10^`i'
			tempfile sims
			simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
			  , reps(100) seed(31723) saving(`sims') ///
			  : wk8_infinite, samplesize(`samplesize') 

			use `sims' , clear
			gen samplesize=`samplesize'
			append using `combo_final'
			save `combo_final', replace
		}
		 

		forvalues i=2/21{
			local samplesize= 2^`i'
			tempfile sims
			simulate beta=r(beta) pval=r(pval)  se = r(SEM) lowerbound = r(lowci) upperbound = r(highci) n = r(N) ///
			  , reps(100) seed(31723) saving(`sims') ///
			  : wk8_infinite, samplesize(`samplesize') 

			use `sims' , clear
			gen samplesize=`samplesize'
			append using `combo_final'
			save `combo_final', replace
		}
		 

		 use `combo_final', clear



	//Create histogram of beta distribution by sample size
	histogram beta, by(samplesize)
	graph export betahist3.png 
	
	
	//create table of standard deviation beta, standard error by sample size
	preserve
	collapse (sd) beta se, by(samplesize)
	list
	restore











