cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-08"

use "outputs/part2_result.dta", clear

keep if inlist(n, 10, 100, 1000, 10000)

gen part = 2

tempfile part2_result
save `part2_result'

use "outputs/part1_result.dta", clear

cap drop part

gen part = 1

append using `part2_result'
save `part2_result', replace

set scheme s2color

tw ///
   (histogram betas if part == 1, w(0.01) color(blue%20) start(5.7)) ///
   (histogram betas if part == 2, w(0.01) color(orange%20) start(5.7)) ///
   , by(n, rescale title("Distribution of beta estimates by sample sizes") note("")) ///
   xtitle("beta estimates", size(3)) ///
   legend(order(1 "part1" 2 "part2"))
   
 graph export "outputs/part1_part2_hist.png", replace

 *******************************************************************************
 * change repepition time
 
use "outputs/part2_result_100.dta", clear

gen part = 2

tempfile part2_result_100
save `part2_result_100'

use "outputs/part1_result_100.dta", clear

cap drop part

gen part = 1

append using `part2_result_100'
save `part2_result_100', replace

tw ///
   (histogram betas if part == 1, w(0.01) color(blue%20) start(5.7)) ///
   (histogram betas if part == 2, w(0.01) color(orange%20) start(5.7)) ///
   , by(n, rescale title("Distribution of beta estimates by sample sizes") note("")) ///
   xtitle("beta estimates", size(3)) ///
   legend(order(1 "part1" 2 "part2"))
   
 graph export "outputs/part1_part2_hist_100.png", replace
