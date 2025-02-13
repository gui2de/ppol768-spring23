*	 																		   *
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 08 						       *
*						      Updated: April 2023						       *
*							      08-wk.do								       *
*																			   *
* 							   - Program Setup -							   *

*	version 17             	    // Version no. for backward compatibility
*	set more off                // Disable partitioned output
	
	global main		 "/Users/jasmineadams/Dropbox/R Stata"
    global myrepo    "$main/repositories/Rsrch-Dsgn"
    global classrepo "$main/repositories/ppol768-spring23"
	global w8 "$classrepo/Individual Assignments/Adams Jasmine/week-08/outputs"
	global p1data    "$w8/p1data.dta"
	global p1results "$w8/p1results.dta"
	global p2results "$w8/p2results.dta"
	cd 				 "$w8"
	
* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *

* Question 1.1----------------- 
clear
capture program drop dgp		
program define dgp, rclass		 // define the program
args samplesize
clear
set obs `samplesize'				 // set sample size
gen x = rnormal()					 // generate random data for x
gen y = x*runiform() 				 // create y from x with error source
reg y x

matrix a = r(table)					 // store results matrix
matrix list a						 // display matrix
return scalar N = `samplesize'		 // store values
return scalar beta = a[1,1]
return scalar SEM = a[2,1]
return scalar pval = a[4,1]
return scalar CI_lower = a[5,1]
return scalar CI_upper = a[6,1]

end

dgp 100

* Question 1.2-----------------

clear
cd	"$w8"							 // set working directory
set seed 12344						 // create replicable results
insobs 10000						 // set fixed number of obs
gen x = rnormal()					 // generate random data for x
save "$w8/finitepop.dta", replace		 // save in week-08 folder


* Question 1.3-----------------

capture program drop p1data		
program define p1data, rclass		 // define the program

clear

cd	"$w8"							 // set working directory
use "finitepop.dta" 					 // use fixed dataset

args samplesize						 // require a defined sample size
display as error "Define samplesize" // set reminder to define the sample size

sample `samplesize', count           // randomly sample defined number of obs
gen y = x*runiform() 				 // create y from x with error source
reg y x

matrix a = r(table)					 // store results matrix
matrix list a						 // display matrix
return scalar N = `samplesize'		 // store results 
return scalar beta = a[1,1]
return scalar SEM = a[2,1]
return scalar pval = a[4,1]
return scalar CI_lower = a[5,1]
return scalar CI_upper = a[6,1]

end

* Question 1.4-----------------

clear
tempfile results
save `results', replace emptyok 		   // create tempfile to store results

forvalues i=1/4{						   // loop to collect regression stats
	local samplesize1= 10^`i'			   // indicate sample sizes to simulate
	tempfile sims						   
	simulate samplesize = r(N) beta=r(beta) stderror=r(SEM) pvalue=r(pval) ///
	cilower = r(CI_lower) ciupper = r(CI_upper), ///
	reps(500) seed(12345) saving(`sims'): p1data `samplesize1' // use program
	use `sims', clear
	append using `results'               
	save `results', replace                // save stats in combined tempfile
	}
	
use `results', clear					   // view all results

gen   fixed = 1							   // label results from part 1
label variable fixed "Part 1 Results"
label define fixed 0 "Part 2" 1 "Part 1"   // labels 
label values fixed fixed						
label variable cilower "CI Lower"
label variable ciupper "CI Upper"
label variable beta "Beta"
label variable stderror "Standard Error"
label variable samplesize "N"
label variable pvalue "P-value"
save "$w8/p1results.dta", replace		   // save results in folder 

* Question 1.5-----------------

use "$p1results", clear

scatter std beta, by(samp, ixaxes) by(, note(, size(zero))) ///
subtitle(,  margin(vsmall) fcolor(none) lcolor(none) pos(6)) ///
mcolor("125 99 118%15") xlabel(#2) 
graph save "$w8/graphp1.gph", replace

tabstat beta stderror pval cilo ciup , by(samp)


* PART 2
* Question 2.1-----------------

capture program drop p2data
program define p2data, rclass
	args samplesize						
	display as error "Define samplesize"

clear
set obs `samplesize'                // unfixed number of obs
gen x = rnormal()   
gen y = x*runiform() 				// create y from x with error source
reg y x

matrix a = r(table)					// define results matrix
return scalar N = `samplesize'		// store results 
return scalar beta = a[1,1]
return scalar SEM = a[2,1]
return scalar pval = a[4,1]
return scalar CI_lower = a[5,1]
return scalar CI_upper = a[6,1]

end

* Question 2.2-----------------

clear
tempfile results2
save `results2', replace emptyok

forvalues i=1/6{
	local samplesize10 = 10^`i'
	tempfile sims2
	simulate samplesize = r(N) beta=r(beta) stderror=r(SEM) pvalue=r(pval) ///
	cilower = r(CI_lower) ciupper = r(CI_upper), ///
	reps(500) seed(12346) saving(`sims2'): p2data `samplesize10'
	use `sims2', clear
	append using `results2'
	save `results2', replace
	}

forvalues i=2/21 {
	local samplesize2= 2^`i'
	tempfile sims3
	simulate samplesize = r(N) beta=r(beta) stderror=r(SEM) pvalue=r(pval) ///
	cilower = r(CI_lower) ciupper = r(CI_upper), ///
	reps(500) seed(12347) saving(`sims3'): p2data `samplesize2'
	use `sims3', clear
	append using `results2'
	save `results2', replace
	}
use `results2', clear

gen   infinite = 1							// label results from part 1
label variable infinite "Part 2 Results"
label define infinite 1 "Part 2" 0 "Part 1"
label values infinite infinite 
label variable beta "Beta"
label variable stderror "Standard Error"
label variable cilower "CI Lower"
label variable ciupper "CI Upper"
label variable samplesize "Sample Size"
label variable pvalue "P-value"
save "$w8/p2results.dta", replace 			// save results in folder


* Question 2.3-----------------

use "$p2results", clear

xtile ssize = samplesize, nquantiles(4)
label variable ssize "N"
label define ssize 1 "4-100" 2 "128-2k" 3 "4.1k-100k" 4 "131k-2.1M"
label values ssize ssize

replace pval = round(pval, .0000001) 						// pt 2 table
tabstat beta stderror pval cilower ciupper, by(ssize)

graph hbox b std if beta < 4, over(ss) ///              	// pt 2 box plot
box(1, fcolor(teal) lcolor(teal) lwidth(thin)) ///
box(2, lcolor(emidblue) fcolor(emidblue) lwidth(thin)) ///
marker(1, mcolor(teal%20)) marker(2, mcolor(emidblue%20)) ///
subtitle(, fcolor(none) lcolor(black)) legend(on nostack ///
size(medsmall) nobox ring(0) region(lwidth(vthin)) pos(5)) 
graph save "$w8/graphp2.gph", replace

* Question 2.4---------------------
* Question 2.5---------------------

use "$p2results", clear
append using "$p1results"             // append results from part 1 to part 2
save "finalresults.dta", replace
use "finalresults", clear

gen 	p10s = inlist(samples, 10, 100, 1000, 10000) // indicate powers of 10

replace fixed = 0 if fixed ==.					 	 // recode missing values
replace infinite = 0 if infinite ==.
label 	variable p10s "N=Powers of 10"

scatter ciu cil samp if p10 == 1, by(infinite)  ///     scatter plot comparing
sort mcolor("163 148 159 %10" "125 99 118 %10") ///		CIs bw pt 1 and 2
xlabel(minmax) xscale(log) legend( nobox pos(5) ///
ring(0 0) cols(2) size(medsmall) ) subtitle(,   ///
nobox pos(6) size(medium)) by(, note(, size(zero))) 
graph save "$w8/graphp3.gph", replace

tabstat b stder cilo ciup if p10s == 1 & infin ==0, by(sampl) // comparison
tabstat b stder cilo ciup if p10s == 1 & infin ==1, by(sampl) // tables

* Question 2.6---------------------

bysort 	samplesize infinite: gen srow = _n			 // indicate different 
gen     reps = 5   if srow >  495					 // number of reps
replace reps = 10  if srow <= 495 & srow > 485
replace reps = 25  if srow <= 485 & srow > 460
replace reps = 75  if srow <= 460 & srow > 385
replace reps = 150 if srow <= 385 & srow > 235
replace reps = 235 if srow <= 235 

graph dot stder if samp == 100, over(reps) by(infinite) /// dot plot comparing
marker(1,mcolor(olive)) subtitle(, pos(6) fcolor(none) ///  reps bw pt 1 and 2
lcolor(none)) ytitle("Mean Standard Error") ///
by(, note(, size(zero)))

graph save "$w8/graphp4.gph", replace

