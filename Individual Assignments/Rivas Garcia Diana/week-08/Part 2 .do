********************************************************************************

*Question 2

********************************************************************************

clear all

capture program drop trial2
program define trial2, rclass
syntax, samplesize(integer)

forvalues i=1/4{

local samplesize= 10^`i'clear
set obs `samplesize'
gen x= runiform(0,10)


*(b) randomly samples a subset whose sample size is an argument to the program
sample `samplesize', count 

*(c) create the Y's from the X's with a true relationship an an error source;

gen y=  x + x*runiform()

*(d) performs a regression of Y on one X;
*egen rank= rank(x)
*gen rank1= rank if rank==1
*reg y rank1 
reg x y
*(e) returns the N, beta, SEM, p-value, and confidence intervals into r().*/

mat a = r(table)
*mat list results //cannot figure out how to return N? 

 return scalar samp = _N
 return scalar beta = a[1,1]
 return scalar sem = a[2,1]
 return scalar pval = a[2,1]
 return scalar ci_l= a[5,1] 
 return scalar ci_u= a[6,1] 


}
end

*I generated this loop and there is no error but I end up without a dataset.
