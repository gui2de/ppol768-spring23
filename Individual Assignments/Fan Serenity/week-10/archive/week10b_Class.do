capture program drop wk10_demo
program define wk10_demo, rclass

syntax, samplesize(integer)

clear

display as error "1" 
set obs `samplesize'
display as error "2"
local treat = `samplesize'/2

gen treatment = 0 
replace treatment=1 if _n > `treat'

*Generate standard normal distribution for math scores 
display as error "3"
gen math_score = rnormal()
replace math_score = math_score + 0.1 if treatment==1 
*Treatment effect is 0.1 standard deviations 

reg math_score treatment
matrix results = r(table)


return scalar beta = results[1,1]
return scalar pvalue = results[4,1]

end



clear 
tempfile combined sims
save `combined', replace emptyok

*Loop, using simulate, for different sample sizes 
forvalues i = 500(500)5000 {
simulate beta=r(beta) pval=r(pvalue), rep(100) saving(`sims', replace): wk10_demo, samplesize(`i')

use `sims', clear
gen N = `i'
append using `combined'
save `combined', replace

}

gen sig=0
replace sig=1 if pval<0.05

sum sig 
*The mean of this is power!

mean sig, over(N)
*This chart indicates we will achieve power of 0.8 (80%) at N~3000 






*Analytics Power Calculations 
power twomeans 500, n1(50) n2(50) power(0.8) sd(100)
*Format: power twomeans [mean] [sample size of 1st pop.] [sample size of 2nd pop.] power standard deviation 
	*Therefore we can see a MDE of an increase in 56.6 points 
	*Power of 0.8 (i.e. 80%) is a standard in the scientific community 
	
power twomeans 500 550, sd(100) 
*Format: power twomeans treatment-mean control-mean standard deviation 


*E.g. Standard normal distribution 
power twomeans 500 510, sd(100)
power twomeans 0 0.05, sd(1)  
	*We get same same results: a difference of 50, when the std is 100, is thus a difference of 0.5 points in std units 
	*In education, a treatment that increases scores by 0.10/0.15 standard deviations would be considered average. Hence, this calculation indicates thata difference of 0.10 std's can be detected with a sample size of N = 3142 in total, i.e. 1/2 that, N = 1571 people per group (1571 for treatment arm, and 1571 for control arm) . 
	 *Quadratic pattern: Cutting the effect size / difference in half requires a four-fold increase in N 

*We want HIGH POWER and LOW MDE 



*Cluster RCT's 
    *Go for more clusters and less students for each, rather than fewer clusters with more students in each 