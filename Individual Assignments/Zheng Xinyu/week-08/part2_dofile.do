* Week 08 Assignment Xinyu Zheng

cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-08"

clear

capture program drop part2_prog
program define part2_prog, rclass
	*args variable_name mean sd
	syntax, samplesize(integer)
	clear
	set obs `samplesize'
	gen x = rnormal(25, 10)
	*egen rank = rank(x)
	*gen treatment = 1 if rank < `samplesize' / 2
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
		
tempfile part2_result
save `part2_result', emptyok replace

tempfile part2_result_sample

forvalues n = 2/21  {
	simulate n = r(n) betas = r(beta) ses = r(se) pvals = r(pval) lls = r(ll) uls = r(ul), ///
		reps(500) seed(20230318) saving(`part2_result_sample', replace): part2_prog, samplesize(`= 2^`n'')
	append using `part2_result'
	save `part2_result', replace
}

forvalues n = 1/6  {
	simulate n = r(n) betas = r(beta) ses = r(se) pvals = r(pval) lls = r(ll) uls = r(ul), ///
		reps(500) seed(20230318) saving(`part2_result_sample', replace): part2_prog, samplesize(`= 10^`n'')
	append using `part2_result'
	save `part2_result', replace
}

use `part2_result', replace

save "outputs/part2_result.dta", replace

* histogram
set scheme sj

histogram betas, ///
by(n, rescale title("Distribution of beta estimates by sample sizes") note("")) ///
w(0.001) frac fc(black) xtitle("beta estimates", size(3))

graph export "outputs/part2_hist.png", replace

* summary table
gen ci = uls - lls

levelsof n, local(size)

foreach i in 8 16 24 26 {
	preserve
    keep if n <= `: word `i' of `size'' & n >= `: word `= `i' - 7' of `size''
	bysort n: outreg2 using outputs/part2_summary_`i'.doc, replace sum(log) eqkeep(mean sd) keep(betas ses ci)
    restore
}

********************************************************************************
* change repetiiton time
	
tempfile part2_result_100
save `part2_result_100', emptyok replace

tempfile part2_result_sample_100

forvalues n = 1/4  {
	simulate n = r(n) betas = r(beta) ses = r(se) pvals = r(pval) lls = r(ll) uls = r(ul), ///
		reps(100) seed(20230318) saving(`part2_result_sample_100', replace): part2_prog, samplesize(`= 10^`n'')
	append using `part2_result_100'
	save `part2_result_100', replace
}

save "outputs/part2_result_100.dta", replace

bysort n: outreg2 using outputs/part2_summary_100.doc, replace sum(log) eqkeep(mean sd) keep(betas ses ci)


