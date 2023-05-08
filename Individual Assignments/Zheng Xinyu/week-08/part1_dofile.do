* Week 08 Assignment Xinyu Zheng

cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-08"

clear

capture program drop part1_prog
program define part1_prog, rclass
	*args variable_name mean sd
	syntax, samplesize(integer)
	use "outputs/data.dta", clear
	sample `samplesize', count
	gen y = 30 + 6*x + rnormal(5, 2)
	reg y x
	return scalar n = e(N)
	mat results = r(table)
	return scalar beta = results[1, 1]
	return scalar se = results[2, 1]
	return scalar pval = results[4, 1]
	return scalar ll = results[5, 1]
	return scalar ul = results[6, 1]
end

tempfile part1_result
save `part1_result', emptyok replace

tempfile part1_result_sample
	
foreach s in 10 100 1000 10000 {
	simulate n = r(n) betas = r(beta) ses = r(se) pvals = r(pval) lls = r(ll) uls = r(ul), ///
	reps(500) seed(20230318) saving(`part1_result_sample', replace): part1_prog, samplesize(`s')
	append using `part1_result'
	save `part1_result', replace
}

use `part1_result', replace

* histogram
set scheme sj

histogram betas, ///
by(n, rescale title("Distribution of beta estimates by sample sizes") note("")) ///
w(0.001) frac fc(black) xtitle("beta estimates", size(3))

graph export "outputs/part1_hist.png", replace

* summary table
gen ci = uls - lls

bysort n: outreg2 using outputs/part1_summary.doc, replace sum(log) eqkeep(mean sd) keep(betas ses ci)

use "outputs/part1_result.dta", replace

********************************************************************************
* change the repetition

tempfile part1_result_100
save `part1_result_100', emptyok replace

tempfile part1_result_sample_100
	
foreach s in 10 100 1000 10000 {
	simulate n = r(n) betas = r(beta) ses = r(se) pvals = r(pval) lls = r(ll) uls = r(ul), ///
	reps(100) seed(20230318) saving(`part1_result_sample_100', replace): part1_prog, samplesize(`s')
	append using `part1_result_100'
	save `part1_result_100', replace
}

use `part1_result_100', replace

save "outputs/part1_result_100.dta", replace

* summary table
gen ci = uls - lls

bysort n: outreg2 using outputs/part1_summary_100.doc, replace sum(log) eqkeep(mean sd) keep(betas ses ci)