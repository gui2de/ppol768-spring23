***week10
clear all
global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/outputs"

clear all

***Part 1.1. to 1.3 - DGP, strata, expand, covar and confound

capture program drop mde
program define mde, rclass
syntax, samplesize(integer) 
clear

set obs 4
gen strata = _n  

***1.2.Generate strata groups and continuous covariates

expand `samplesize'

***Define confounder affecting both treatment and outcome, confounder
gen cov_xy = rnormal()
***1.3.Make sure that another one affects the treatment but not the outcome
gen cov_x = rnormal()
***1.3.Make sure that another one of the covariates affects the outcome but not the treatment
gen cov_y = rnormal()

***1.2. Generate random noise 
gen random = rnormal() + cov_x + cov_xy + strata
 
***Define treatment
gen treatment=0
replace treatment=1 if random> 2.610203 

***Define dependent variable with treatment having an effect and so the covariates
***Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder")
gen y = runiform(50,70)+ 5*treatment + 20*rnormal() + 10*cov_y - 15*cov_xy + strata

***ARE TRULY UNBIASED:1.4.Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes



reg y treatment i.strata cov_xy

mat a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar pval = a[4,1]


end

***1.4.Program: Run these regressions at different sample sizes
***check data and program ok with mde, samplesize(100)

clear
tempfile all
  save `all' , replace emptyok

tempfile sims

forvalues i = 100(50)600 {
local samplesize=  `i'
  simulate   ///
   beta=r(beta) pval = r(pval) N = r(N) , reps(500) saving(`sims',replace) ///
	: mde, samplesize(`samplesize') 
  
   use `sims' , clear
   gen samplesize=`samplesize' * 4
   append using `all'
     save `all' , replace
 
} 

use `all', clear

save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/outputs/sims.dta" , replace


***1.5.Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

gen sig = 0
replace sig =1 if pval<0.05
*power for each sample size level
mean sig, over(N)

*sample size needed to detect MDE of 50 points when mean is 500 and sd is 100 and power is 80%
power twomeans 500 550, sd(100)  power(0.8)

*you can generate a table as well if you want to know the sample size at different MDEs
power twomeans 0 0.1(0.05)0.8, table 

***Plot the power

collapse (mean) sig, by(N)

gen y=0.8

twoway (scatter sig N) (line y N)

graph export"/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/img/graph.png", as(png) name("Graph")


***PART 2
clear all

capture program drop cre
program define cre, rclass
syntax, samplesize(integer) 
clear

***define that I have 100 schools
set obs 100
***adding an id to each school aka the cluster
gen schoolid=_n

***add cov 
gen cov_xy = rnormal()
gen cov_x = rnormal()
gen cov_y = rnormal()
***adding a random school effect 
***only effect of the school on grades
gen schooleffect = rnormal() + cov_x + cov_xy

***split treatment and control at the school level 
gen treatment =0
replace treatment=1 if _n>=51

***expand to "add students" to the schools 
expand 10 
sort schoolid

***generate the dependent variable mathscore is at the individual level
gen mathscore = rnormal(40,10) + 2.5*treatment + 5*cov_y - 7*cov_xy + schooleffect

reg mathscore treatment cov_xy

matrix a = r(table)
return scalar N  = e(N)
return scalar beta = a[1,1]
return scalar lci = a[5,1]
return scalar uci = a[6,1]
end

display r(beta)
display r(lci)
display r(uci)


***mean 500 lower mean 500 upper and then compare to the single regression 

***take mean uper and mean lower and gives me av bound , are the boundes the same or have a wider disstribution
clear
tempfile all2
  save `all2' , replace emptyok

tempfile sims2

forvalues i = 100(10)100 {
local samplesize=  `i'
  simulate   ///
   beta=r(beta) lci = r(lci) uci = r(uci) N = r(N) , reps(500) saving(`sims2',replace) ///
	: cre, samplesize(`samplesize') 
  
   use `sims2' , clear
   gen samplesize=`samplesize'
   append using `all2'
     save `all2' , replace
 
} 

use `all2', clear

save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/outputs/sims2.dta" , replace


***graph the power where k are the clusters of schools and m is the students per school/cluster
power twomeans 0, k1(100) k2(100) m1(10) m2(10) power(0.8) sd(1) table

***note: at what level are you clustering, ONLY MORE power from more cluster 

***2.4. calculate exact CI, and append 
collapse (mean) mean = beta (sd) sd = beta, by(N)
gen lex = mean-1.96*sd
gen uex = mean+1.96*sd

append using "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/outputs/sims2.dta"

save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-10/outputs/sims_polyci.dta", replace

***UNABLE TO PLOT
***2.4.plot against analytical

gen obs = _n

forvalues i = 100(10)100 {
	
	twoway lpolyci lci uci, level(95)
}


/**plot practice options
twoway rcap lci uci obs || scatter beta obs

twoway lpolyci lci uci, level(95) || scatter beta

lpoly beta N, level(95) kernel(epan2) ci legend(cols(2) pos(6))

***tw (lpolyci beta N)
pctile 

tw (line mean, lcolor(blue)) ///
(line lci, lpattern(dash) lcolor(blue%40)) ///
(line uci, lpattern(dash) lcolor(blue%40)) ///
(line lex, lpattern(dash) lcolor(red%40)) ///
(line uex, lpattern(dash) lcolor(red%40)) ///
(rarea lci uci, color(blue%20)) ///
(rarea lex uex, color(red%20))

twoway scatter lci uci obs, color(%8 %8)    ||
         line    lex uex obs            ,   ||
         rarea   lci uci obs              , color(gray%20)
         title(Analytical vs exact) 

*/


***1.5.Create another DGP in which the random error terms are only determined at the cluster level. Rerun previous part 




***1.6. Get the analytical to be correct 

***1.7. Figures and tables 
