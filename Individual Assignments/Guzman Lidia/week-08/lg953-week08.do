****THIS IS THE FINAL WEEK8 ASSIGNMENT
clear all

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-08/"

clear all
***PART1
***1.2. Dofile fixed pop
set seed 123 
set obs 10000

***create indep var
gen x1 = rnormal()

save "${wd}/outputs/week8.dta", replace

***1.3.defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().

capture program drop rd 
program define rd, rclass
syntax, samplesize(integer) 

clear 
use "${wd}/outputs/week8.dta", clear

sample `samplesize', count 


gen y = rnormal(50,10) + 0.5*x1 

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar sem = a[2,1]
return scalar pval = a[3,1]
return scalar lci = a[4,1]
return scalar uci = a[5,1]
end 


clear
tempfile all
  save `all' , replace emptyok

***1.4. Simulate, run 500 times
forvalues i = 1/4 {
local samplesize= 10^`i'
tempfile sims
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(500) seed(2023) saving(`sims') ///
	: rd, samplesize(`samplesize')
  
   preserve
   use `sims' , clear
   gen samplesize=`samplesize'
   append using `all'
     save `all' , replace
   restore
}

use `all', clear

***1.5. Create one figure one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

***table to characterize the size of the sem and confidence intervals as N gets large
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

***histogram to show the distribution of betas 
histogram beta, by(samplesize) title("Distribution of Betas") ytitle("Density") xtitle("Beta Distribution")
graph export "${wd}/img/betahistogram.png" ,replace

***graph with diff-in-means of se/ss

graph bar (mean) sem, over(samplesize) ytitle("Standard Error Means") title("Differences in Means of Standard Errors per Sample Size") 
graph export "${wd}/img/diffmeans.png" , replace



/*

exit
simulate beta=r(beta) sem=r(sem) pval =r(pval), reps(500): rd

exit 

rd, samplesize(1000)




clear 
use "week8.dta", clear

sample 100, count 
*/
****PART2 ****CHECK FROM HERE****

***Part 2.1. define program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().

clear all

program define week8p2, rclass
syntax, ss(integer)
clear
set obs `ss'


gen x1 = rnormal()
gen y = rnormal(50,10) + 0.5*x1 

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar sem = a[2,1]
return scalar pval = a[3,1]
return scalar lci = a[4,1]
return scalar uci = a[5,1]


end


***2.2. Run simulation 500 times 

clear
tempfile all2
  save `all2' , replace emptyok


forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(500) seed(2023) saving(`sims2') ///
	: week8p2 , ss(`=10^`i'')
  
   preserve
   use `sims2' , clear
   gen samplesize=`samplesize'
   append using `all2'
     save `all2' , replace
   restore
}

use `all2', clear

clear 
tempfile all3
save `all3' , replace emptyok
***first twenty powers of two is 2/21 and 2 exponent
forvalues i = 2/21{
	local samplesize= 2^`i'
	tempfile sims3
	 simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(500) seed(2023) saving(`sims3') ///
	: week8p2 , ss(`=2^`i'')
	
	 preserve
   use `sims3' , clear
   gen samplesize=`samplesize'
   append using `all3'
     save `all3' , replace
   restore
}
use `all3', clear

***2.3. Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.

***table to characterize the size of the sem and confidence intervals as N gets large 

estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

***histogram to show the distribution of betas 
histogram beta, by(samplesize) title("Distribution of Betas") ytitle("Density") xtitle("Beta Distribution")
graph export "${wd}/img/betahistogram2.png" ,replace

***graph with diff-in-means of se/ss

graph bar (mean) sem, over(samplesize) ytitle("Standard Error Means") title("Differences in Means of Standard Errors per Sample Size") 
graph export "${wd}/img/diffmeans2.png" , replace

***2.6. Do these results change if you increase to 700 repetitions or decrease to 200? 

***2.6.a Doing 700 repetitions 

clear all

program define week8p2a, rclass
syntax, ss(integer)
clear
set obs `ss'


gen x1 = rnormal()
gen y = rnormal(50,10) + 0.5*x1 

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar sem = a[2,1]
return scalar pval = a[3,1]
return scalar lci = a[4,1]
return scalar uci = a[5,1]

end

clear
tempfile all2a
  save `all2a' , replace emptyok
  

forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2a
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(700) seed(2023) saving(`sims2a') ///
	: week8p2a , ss(`=10^`i'')
  
   preserve
   use `sims2a' , clear
   gen samplesize=`samplesize'
   append using `all2a'
     save `all2a' , replace
   restore
}

use `all2a', clear

clear 
tempfile all3a
save `all3a' , replace emptyok
***first twenty powers of two is 2/21 and 2 exponent
forvalues i = 2/21{
	local samplesize= 2^`i'
	tempfile sims3a
	 simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(700) seed(2023) saving(`sims3a') ///
	: week8p2a , ss(`=2^`i'')
	
	 preserve
   use `sims3a' , clear
   gen samplesize=`samplesize'
   append using `all3a'
     save `all3a' , replace
   restore
}
use `all3a', clear

**table to characterize the size of the sem and confidence intervals as N gets large
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)


***2.6.b Doing 200 repetitions 

clear all

program define week8p2b, rclass
syntax, ss(integer)
clear
set obs `ss'


gen x1 = rnormal()
gen y = rnormal(50,10) + 0.5*x1 

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar sem = a[2,1]
return scalar pval = a[3,1]
return scalar lci = a[4,1]
return scalar uci = a[5,1]

end

clear
tempfile all2b
  save `all2b' , replace emptyok
  

forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2b
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(200) seed(2023) saving(`sims2b') ///
	: week8p2b , ss(`=10^`i'')
  
   preserve
   use `sims2b' , clear
   gen samplesize=`samplesize'
   append using `all2b'
     save `all2b' , replace
   restore
}

use `all2b', clear

clear 
tempfile all3b
save `all3b' , replace emptyok
***first twenty powers of two is 2/21 and 2 exponent
forvalues i = 2/21{
	local samplesize= 2^`i'
	tempfile sims3b
	 simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(200) seed(2023) saving(`sims3b') ///
	: week8p2b , ss(`=2^`i'')
	
	 preserve
   use `sims3b' , clear
   gen samplesize=`samplesize'
   append using `all3b'
     save `all3b' , replace
   restore
}
use `all3b', clear

**table to characterize the size of the sem and confidence intervals as N gets large
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)
