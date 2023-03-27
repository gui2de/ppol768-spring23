***Part 1 
*** Question 1
***X will be hours studied and Y will be the grades obtained by RD graduate students. 

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-08/"

**Question 2 

clear all
capture program drop rd 
program define rd, rclass
clear 
set seed 123
set obs 10000
gen y = runiformint(50,100)
gen random_num = rnormal() 
egen rank = rank(random_num)
gen x1 = runiformint(5,30)

end

rd

save "${wd}w08_lg953.dta", replace

**Question 3 & 4

clear all

capture program drop grades 
program define grades, rclass

syntax , samplesize(integer)

use "${wd}w08_lg953.dta", clear
  sample `samplesize' , count

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar sem = a[2,1]
return scalar pval = a[3,1]
return scalar lci = a[4,1]
return scalar uci = a[5,1]
end

display r(beta)
display r(sem)
display r(pval)
display r(lci)
display r(uci)

clear
tempfile all
  save `all' , replace emptyok


forvalues i = 1/4 {
local samplesize= 10^`i'
tempfile sims
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(500) seed(2023) saving(`sims') ///
	: grades , samplesize(`=10^`i'')
  
   preserve
   use `sims' , clear
   gen samplesize=`samplesize'
   append using `all'
     save `all' , replace
   restore
}

use `all', clear

***Question 5 
***histogram to show the distribution of betas 
histogram beta, by(samplesize) title("Distribution of Betas") ytitle("Density") xtitle("Beta Distribution")
graph export "${wd}/img/betahistogram.png" ,replace
***table to characterize the size of the sem and confidence intervals as N gets large (table exported using LaTex online transformer)
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

esttab using "${wd}/outputquestion5.csv", replace

***graph with diff-in-means of se/ss

graph bar (mean) sem, over(samplesize) ytitle("Standard Error Means") title("Differences in Means of Standard Errors per Sample Size") 
graph export "${wd}/img/diffmeans.png" , replace


***Part 2
***Question 1 & 2 

clear all

capture program drop grades 
program define grades, rclass

syntax , samplesize(integer)

use "${wd}w08_lg953.dta", clear
  sample `samplesize' , count

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar sem = a[2,1]
return scalar beta = a[1,1]
return scalar pval = a[4,1]
return scalar lci = a[5,1]
return scalar uci = a[6,1]

end

clear
tempfile all2
  save `all2' , replace emptyok


forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(500) seed(2023) saving(`sims2') ///
	: grades , samplesize(`=10^`i'')
  
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
	: grades , samplesize(`=2^`i'')
	
	 preserve
   use `sims3' , clear
   gen samplesize=`samplesize'
   append using `all3'
     save `all3' , replace
   restore
}
use `all3', clear

***Question 3, create same figures for comparison 

***histogram to show the distribution of betas 
histogram beta, by(samplesize) title("Distribution of Betas") ytitle("Density") xtitle("Beta Distribution")
graph export "${wd}/img/betahistogram2.png" ,replace

***table to characterize the size of the sem and confidence intervals as N gets large (table exported using LaTex online transformer)
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

esttab using "${wd}/outputquestion5part2.csv", replace

***graph with diff-in-means of se/ss

graph bar (mean) sem, over(samplesize) ytitle("Standard Error Means") title("Differences in Means of Standard Errors per Sample Size") 
graph export "${wd}/img/diffmeans2.png" , replace


***Question 6a (700 repetitions)

clear all

capture program drop grades 
program define grades, rclass

syntax , samplesize(integer)

use "${wd}w08_lg953.dta", clear
  sample `samplesize' , count

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar sem = a[2,1]
return scalar beta = a[1,1]
return scalar pval = a[4,1]
return scalar lci = a[5,1]
return scalar uci = a[6,1]

end

clear
tempfile all2a
  save `all2a' , replace emptyok


forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2a
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(700) seed(2023) saving(`sims2a') ///
	: grades , samplesize(`=10^`i'')
  
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
	: grades , samplesize(`=2^`i'')
	
	 preserve
   use `sims3a' , clear
   gen samplesize=`samplesize'
   append using `all3a'
     save `all3a' , replace
   restore
}
use `all3a', clear


***table to characterize the size of the sem and confidence intervals as N gets large (table exported using LaTex online transformer)
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

esttab using "${wd}/outputquestion5part26a.csv", replace

***Question 6b (200 repetitions)

clear all

capture program drop grades 
program define grades, rclass

syntax , samplesize(integer)

use "${wd}w08_lg953.dta", clear
  sample `samplesize' , count

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar sem = a[2,1]
return scalar beta = a[1,1]
return scalar pval = a[4,1]
return scalar lci = a[5,1]
return scalar uci = a[6,1]

end

clear
tempfile all2b
  save `all2b' , replace emptyok


forvalues i = 1/6 {
local samplesize= 10^`i'
tempfile sims2b
  simulate beta = r(beta) pval = r(pval) sem = r(sem) lci = r(lci) uci=r(uci) ///
    , reps(200) seed(2023) saving(`sims2b') ///
	: grades , samplesize(`=10^`i'')
  
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
	: grades , samplesize(`=2^`i'')
	
	 preserve
   use `sims3b' , clear
   gen samplesize=`samplesize'
   append using `all3b'
     save `all3b' , replace
   restore
}
use `all3b', clear

***table to characterize the size of the sem and confidence intervals as N gets large (table exported using LaTex online transformer)
estpost tabstat beta sem lci uci, by(samplesize) listwise statistics(mean sd) columns(statistics)

esttab using "${wd}/outputquestion5part26b.csv", replace
