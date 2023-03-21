********************************************************************************
* PPOL 768: Week 5
* Assignment for Week 8
* Michele Giunti
* March 21st, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/
clear
/*******************************************************************************
1. Sampling noise in a fixed population
*******************************************************************************/
cd "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Research Design Implementation\ppol768-spring23\Individual Assignments\Giunti Michele\week-08"
drop _all
set obs 10000

set seed 69420
gen x = rnormal()

save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/sims1.dta", replace
set seed 69420
capture program drop v1 
program define v1, rclass
syntax anything [if]
clear
use "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/sims1.dta"
args number_sample 
sample `number_sample', count
gen y = 3*x + rnormal()
regress y x
mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar se = a[2,1]
return scalar p = a[4,1]
return scalar lower = a[5,1]
return scalar upper = a[6,1]

end

tempfile sims1
tempfile combined 
clear

save `combined', replace emptyok
forvalues i = 1/4{
	local sample = 10^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(500) seed(69420) : v1 `sample'
	gen samplesize=`i'
	append using `combined'
	qui save `combined', replace
	_dots `i' 0
}
save `sims1', replace

use `sims1' , clear
label define SAMPLE 1 "10" 2 "100" 3 "1000" 4 "10000"
label values samplesize SAMPLE

egen sdbeta = sd(beta)

bysort samplesize : tabstat beta se lower upper, col(stats) s(mean sem max min)

label variable beta "Beta"
label variable se "Standard Deviation"
label variable lower "Lower CI"
label variable upper "Upper CI"
label variable p "p-value"

estpost tabstat beta se lower upper, by(samplesize) col(stats) s(mean sem max min)
esttab using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/tab/tabstatpart1.tex", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

tw (histogram beta, by(samplesize) lc(none) fc(gray) freq width(.1) barwidth(.1))(histogram beta if p < .00001, lc(black) fc(none) freq width(.1) barwidth(.1) legend(order(1 "Beta" 2 "p < 0.05")))
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/betadeviationpart1.png", replace

graph bar (mean) se, over(samplesize) ytitle("Mean of Standard Error") title("Differences in Variance per Sample Size") subtitle("Reductions in Variance Experienced by Different Sample Sizes")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/SEMpart1.png" ,replace

graph bar (sd) beta upper lower, over(samplesize) legend( label(1 "Beta") label(2 "Upper CI") label(3 "Lower CI") ) ytitle("Standard Deviation") title("Differences in Variance per Sample Size") subtitle("Reductions in Variance Experienced by Different Sample Sizes")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/CIBetapart1.png" , replace

save sims1, replace
******************************************************************************
*2. Sampling noise in an infinite superpopulation
*******************************************************************************/
clear
drop _all

set seed 69420
capture program drop v2
program define v2, rclass
syntax anything [if]
clear
args number_sample 
set obs `number_sample'
gen x = rnormal()
gen y = 3*x + rnormal()
regress y x
mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar se = a[2,1]
return scalar p = a[4,1]
return scalar lower = a[5,1]
return scalar upper = a[6,1]
end

tempfile sims2
tempfile combined1
tempfile combined2
save `sims2', replace emptyok
clear

save `combined1', replace emptyok
forvalues i = 1/6{
	local population = 10^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(500) seed(69420) : v2 `population'
	gen table1=`i'
	qui replace table1=10^`i'
	append using `combined1'
	qui save `combined1', replace
	_dots `i' 0
}

clear
save `combined2', replace emptyok
forvalues i = 2/21{
	local population = 2^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(500) seed(69420) : v2 `population'
	gen table2=`i'
	qui replace table2=2^`i'
	append using `combined2'
	qui save `combined2', replace
	_dots `i' 0
}

clear
use `sims2', clear
append using "`combined1'" "`combined2'"
save `sims2', replace


replace table1 = table2 if missing(table1)
drop table2
rename table1 samplesize
sort samplesize

levelsof samplesize, local(levels) 
foreach l of local levels {
	label define SAMPLE2 `l' "`l'", add
	}
	
label values samplesize SAMPLE

egen sdbeta = sd(beta), by(samplesize)

tw (line sdbeta samplesize, xscale(log) xlabel(10 100 1000 10000 100000 1000000) xtitle(N) ytitle(Standard Deviation of Beta) title("Change in the Variance of Beta") subtitle("Logarithm Scale of the Decrease in Standard Deviation")) (scatter sdbeta samplesize), legend(off)
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/betadeviationpart2-500.png", replace

tw (histogram beta if samplesize <= 10000, by(samplesize) lc(none) fc(gray) freq width(.1) barwidth(.1))(histogram beta if p < .00001 & samplesize <= 10000, lc(black) fc(none) freq width(.1) barwidth(.1) legend(order(1 "Beta" 2 "p < 0.05"))) if samplesize <= 10000
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/facetbetapart2-500.png", replace

graph bar (sd) beta upper lower if samplesize < 10000, over(samplesize, lab(angle(45))) legend( label(1 "Beta") label(2 "Upper CI") label(3 "Lower CI") ) ytitle("Standard Deviation") title("Differences in Variance per Sample Size") subtitle("Reductions in Variance Experienced by Different Sample Sizes")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/CIBetapart2-500.png", replace

bysort samplesize : tabstat beta se lower upper, col(stats) s(mean sem max min)

label variable beta "Beta"
label variable se "Standard Deviation"
label variable lower "Lower CI"
label variable upper "Upper CI"
label variable p "p-value"

estpost tabstat beta se lower upper, by(samplesize) col(stats) s(mean sem max min)
esttab using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/tab/tabstatpart2-500.tex", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

save sims2, replace
******************************************************************************
*2b. Sampling noise in an infinite superpopulation (Increase Repetitions)
*******************************************************************************/

clear
drop _all

set seed 69420
capture program drop v2b
program define v2b, rclass
syntax anything [if]
clear
args number_sample 
set obs `number_sample'
gen x = rnormal()
gen y = 3*x + rnormal()
regress y x
mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar se = a[2,1]
return scalar p = a[4,1]
return scalar lower = a[5,1]
return scalar upper = a[6,1]
end

tempfile sims2b
tempfile combined1b
tempfile combined2b
save `sims2b', replace emptyok
clear

save `combined1b', replace emptyok
forvalues i = 1/6{
	local population = 10^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(800) seed(69420) : v2b `population'
	gen table1=`i'
	qui replace table1=10^`i'
	append using `combined1b'
	qui save `combined1b', replace
	_dots `i' 0
}

clear
save `combined2b', replace emptyok
forvalues i = 2/21{
	local population = 2^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(800) seed(69420) : v2b `population'
	gen table2=`i'
	qui replace table2=2^`i'
	append using `combined2b'
	qui save `combined2b', replace
	_dots `i' 0
}

clear
use `sims2b', clear
append using "`combined1b'" "`combined2b'"
save `sims2b', replace


replace table1 = table2 if missing(table1)
drop table2
rename table1 samplesize
sort samplesize

levelsof samplesize, local(levels) 
foreach l of local levels {
	label define SAMPLE2b `l' "`l'", add
	}
	
label values samplesize SAMPLE
egen sdbeta = sd(beta), by(samplesize)

tw (line sdbeta samplesize, xscale(log) xlabel(10 100 1000 10000 100000 1000000) xtitle(N) ytitle(Standard Deviation of Beta) title("Change in the Variance of Beta") subtitle("Logarithm Scale of the Decrease in Standard Deviation")) (scatter sdbeta samplesize), legend(off)
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/betadeviationpart2-800.png" , replace

tw (histogram beta if samplesize <= 10000, by(samplesize) lc(none) fc(gray) freq width(.1) barwidth(.1))(histogram beta if p < .00001 & samplesize <= 10000, lc(black) fc(none) freq width(.1) barwidth(.1) legend(order(1 "Beta" 2 "p < 0.05"))) if samplesize <= 10000
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/facetbetapart2-800.png" , replace

graph bar (sd) beta upper lower if samplesize < 10000, over(samplesize, lab(angle(45))) legend( label(1 "Beta") label(2 "Upper CI") label(3 "Lower CI") ) ytitle("Standard Deviation") title("Differences in Variance per Sample Size") subtitle("Reductions in Variance Experienced by Different Sample Sizes")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/CIBetapart2-800.png" , replace

bysort samplesize : tabstat beta se lower upper, col(stats) s(mean sem max min)

label variable beta "Beta"
label variable se "Standard Deviation"
label variable lower "Lower CI"
label variable upper "Upper CI"
label variable p "p-value"

estpost tabstat beta se lower upper, by(samplesize) col(stats) s(mean sem max min)
esttab using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/tab/tabstatpart2-800.tex", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

save sims2b, replace
******************************************************************************
*2c. Sampling noise in an infinite superpopulation (Decrease Repetitions)
*******************************************************************************/

clear
drop _all

set seed 69420
capture program drop v2c
program define v2c, rclass
syntax anything [if]
clear
args number_sample 
set obs `number_sample'
gen x = rnormal()
gen y = 3*x + rnormal()
regress y x
mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar se = a[2,1]
return scalar p = a[4,1]
return scalar lower = a[5,1]
return scalar upper = a[6,1]
end

tempfile sims2c
tempfile combined1c
tempfile combined2c
save `sims2c', replace emptyok
clear

save `combined1c', replace emptyok
forvalues i = 1/6{
	local population = 10^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(300) seed(69420) : v2c `population'
	gen table1=`i'
	qui replace table1=10^`i'
	append using `combined1c'
	qui save `combined1c', replace
	_dots `i' 0
}

clear
save `combined2c', replace emptyok
forvalues i = 2/21{
	local population = 2^`i'
	qui simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), reps(300) seed(69420) : v2c `population'
	gen table2=`i'
	qui replace table2=2^`i'
	append using `combined2c'
	qui save `combined2c', replace
	_dots `i' 0
}

clear
use `sims2c', clear
append using "`combined1c'" "`combined2c'"
save `sims2c', replace


replace table1 = table2 if missing(table1)
drop table2
rename table1 samplesize
sort samplesize

levelsof samplesize, local(levels) 
foreach l of local levels {
	label define SAMPLE3c `l' "`l'", add
	}
	
label values samplesize SAMPLE
egen sdbeta = sd(beta), by(samplesize)

tw (line sdbeta samplesize, xscale(log) xlabel(10 100 1000 10000 100000 1000000) xtitle(N) ytitle(Standard Deviation of Beta) title("Change in the Variance of Beta") subtitle("Logarithm Scale of the Decrease in Standard Deviation")) (scatter sdbeta samplesize), legend(off)
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/betadeviationpart2-300.png" , replace

tw (histogram beta if samplesize <= 10000, by(samplesize) lc(none) fc(gray) freq width(.1) barwidth(.1))(histogram beta if p < .00001 & samplesize <= 10000, lc(black) fc(none) freq width(.1) barwidth(.1) legend(order(1 "Beta" 2 "p < 0.05"))) if samplesize <= 10000
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/facetbetapart2-300.png" , replace

graph bar (sd) beta upper lower if samplesize < 10000, over(samplesize, lab(angle(45))) legend( label(1 "Beta") label(2 "Upper CI") label(3 "Lower CI") ) ytitle("Standard Deviation") title("Differences in Variance per Sample Size") subtitle("Reductions in Variance Experienced by Different Sample Sizes")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/img/CIBetapart2-300.png" , replace

bysort samplesize : tabstat beta se lower upper, col(stats) s(mean sem max min)

label variable beta "Beta"
label variable se "Standard Deviation"
label variable lower "Lower CI"
label variable upper "Upper CI"
label variable p "p-value"

estpost tabstat beta se lower upper, by(samplesize) col(stats) s(mean sem max min)
esttab using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-08/tab/tabstatpart2-300.tex", replace style(tex) cells("mean semean max min") label nodepvar nomtitle nonumber collabels("Mean" "SEM" "Max" "Min")

save sims2c, replace

******************************************************************************
*3. Comparison of two populations
*******************************************************************************/
clear
use sims1
gen id = 1
save sims1, replace

clear
use sims2

drop if samplesize != 10 & samplesize != 100 & samplesize != 1000 & samplesize != 10000

gen id = 2
label define SAMPLE 1 "10" 2 "100" 3 "1000" 4 "10000"
label values samplesize SAMPLE

append using sims1
label values samplesize SAMPLE

