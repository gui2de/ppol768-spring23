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
use "${wd}w08_lg953.dta", clear

capture program drop grades 
program define grades, rclass

syntax samplesize(10^`i')

clear 
set obs `samplesize'

gen y = x1 + rnormal()

reg y x1

mat a = r(table)
return scalar N  = e(N)
return scalar SEM = sem(L1 -> y x1)
return scalar beta = a[1,1]
return scalar pval = a[4,1]
return scalar ci means y-x1

end

grades

display r(beta)
display r(pval)

tempfile sims

***Question 4
 
simulate beta_coeff=r(beta) pvalues=r(pval), reps(500) seed(2023) saving(`sims'): normal_reg

use `sims', clear

***Part 2
***Question 1 

***Question 2
