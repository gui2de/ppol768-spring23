********************************************************************************
* PPOL 768: Week 10
* Assignment for Week 10
* Michele Giunti
* April 4th, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/
clear
*cd "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output"
cd "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output"
/*******************************************************************************
1. Calculating required sample sizes and minimum detectable effects
*******************************************************************************/
drop _all
capture program drop mde
program define mde , rclass
syntax, strata(integer) upper_obs(integer) lower_obs(integer)


clear
set obs `strata'

gen region = _n 
gen region_effect = rnormal(0,2)
expand `lower_obs'+int((`upper_obs'-`lower_obs'+1)*runiform())

bysort region : gen artisan = _n
gen artisan_effect = rnormal(0,5)

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

*generate treatment dummy variable which is influeced by region (strata) and business_exp and sales
gen treat = (region/5 + business_exp + sales + rnormal()) > 0 

*generate dependent variable, where treatment variable has some impact(say 2.5 units) 
gen business_success = 3 + (-1)*region + business_exp + 6*customers + 2.5*treat + region_effect + artisan_effect


reg business_success treat
	return scalar p_base=(2 * ttail(e(df_r), abs(_b[treat]/_se[treat])))
	
	
reg business_success treat i.region business_exp
	return scalar p_confounder=(2 * ttail(e(df_r), abs(_b[treat]/_se[treat])))


reg business_success treat i.region business_exp customers
	return scalar p_covarconf=(2 * ttail(e(df_r), abs(_b[treat]/_se[treat])))
	

reg business_success treat i.region customers sales
	return scalar p_covar=(2 * ttail(e(df_r), abs(_b[treat]/_se[treat])))
	

reg business_success treat i.region business_exp sales customers
	return scalar p_full=(2 * ttail(e(df_r), abs(_b[treat]/_se[treat])))
	
end

tempfile sims1
tempfile combined 
tempfile combined2
clear

save `combined', replace emptyok
save `combined2', replace emptyok

forvalues l = 10(10)200{
	use `combined2', clear
	local u = `l'+200
forvalues i = 1/10{
simulate p_base=r(p_base) p_confounder=r(p_confounder) p_covarconf=r(p_covarconf) p_covar=r(p_covar) p_full=r(p_full), r(500): mde, strata(`i') upper_obs(`u') lower_obs(`l')
gen strata=`i'
gen N = e(N)
append using `combined2'
qui save `combined2', replace
	_dots `i' 0
}
append using `combined'
qui save `combined', replace
if `l' == 200 {
	save `sims1', replace
}
else if `l' != 200 {
	clear
	qui save `combined2', replace emptyok
}
}

use `sims1', clear
*save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/sims1.dta", replace
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/sims1.dta", replace

use "sims1.dta", clear

foreach v of varlist p_base p_confounder p_covarconf p_covar p_full{
	gen sig_`v' = 0
	replace sig_`v' = 1 if `v'<.05
	lowess sig_`v' N, mean gen(fit_`v')
}

foreach v of varlist p_base p_confounder p_covarconf p_covar p_full{
bysort N: egen mean_`v' = mean(sig_`v')
}

foreach v of varlist mean_p_base mean_p_confounder mean_p_covarconf mean_p_covar mean_p_full{
bysort N: gen first80_`v' = sum(`v' >= .8) == 1
}

gen sig80 = 0
bysort N: replace sig80 = 1 if first80_mean_p_base == 1 & first80_mean_p_covarconf== 1 & first80_mean_p_confounder ==1 & first80_mean_p_covarconf == 1 & first80_mean_p_covar == 1 & first80_mean_p_full == 1

list N if sig80 == 1


tw line fit_p_base fit_p_confounder fit_p_covarconf fit_p_covar fit_p_full N, legend(order(1 "Base" 2 "Confounder" 3 "Covar+Conf" 4 "Covar" 5 "Full")) title("Power Variations by Sample Size") subtitle("The proportion of regressions in which p<0.05 for the treatment effect") ytitle("Power")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/Sim1.png" , replace


save `sims1', replace
clear
*******************************************************************************************************************
drop _all
capture program drop mde2
program define mde2 , rclass
syntax, strata(integer) groupnumber(integer)


clear
set obs `strata'

gen region = _n 
gen region_effect = rnormal(0,2)
expand `groupnumber'

bysort region : gen artisan = _n
gen artisan_effect = rnormal(0,5)

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

gen treat_effect = rnormal()

gen business_success = 3 + (-1)*region + business_exp + 6*customers + treat_effect*treat + region_effect + artisan_effect


reg business_success treat
	return scalar beta_base=_b[treat]
	
	
reg business_success treat i.region business_exp
	return scalar beta_confounder=_b[treat]


reg business_success treat i.region business_exp customers
	return scalar beta_covarconf=_b[treat]
	

reg business_success treat i.region customers sales
	return scalar beta_covar=_b[treat]
	

reg business_success treat i.region business_exp sales customers
	return scalar beta_full=_b[treat]
	
end

tempfile sims1b



simulate beta_base=r(beta_base) beta_confounder=r(beta_confounder) beta_covarconf=r(beta_covarconf) beta_covar=r(beta_covar) beta_full=r(beta_full), r(1000): mde2, strata(5) groupnumber(43)


save `sims1b',replace
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/sims1b.dta", replace

use "sims1b.dta", clear

estpost tabstat beta_base beta_confounder beta_covarconf beta_covar beta_full, column(statistics) stats(min)
esttab using table1.tex, replace style(tex) cells("min") nonumber nomtitle nonote collabels("MDE") coeflabel(beta_base "Base" beta_confounder "Confounder" beta_covarconf "Conf+Covar" beta_covar "Covariates" beta_full "Full") title("Tabstat of MDE")



/*******************************************************************************
2. Calculating power for DGPs with clustered random errors
*******************************************************************************/
drop _all
capture program drop pow
program define pow , rclass
syntax, cluster(integer) groupnumber(integer)


clear
set obs `cluster'

gen region = _n 


generate rannum = uniform()
egen treat = cut(rannum), group(2)
drop rannum

gen region_effect = rnormal(0,2)

expand `groupnumber'

bysort region : gen artisan = _n
gen artisan_effect = rnormal(0,5)

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

gen business_success = 3 + 5*business_exp + 6*customers + 8*sales + 2.5*treat + region_effect + artisan_effect


reg business_success treat business_exp customers sales 
mat a = r(table)
return scalar N = e(N)
return scalar beta = a[1,1]
return scalar se = a[2,1]
return scalar p = a[4,1]
return scalar lower = a[5,1]
return scalar upper = a[6,1]
	
end

tempfile sims2
tempfile combined5
tempfile combined6

save `combined5', replace emptyok
save `combined6', replace emptyok

forvalues i = 2/20{
forvalues l = 100(100)1000{
simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), r(500): pow, cluster(`i') groupnumber(`l')
gen rep = `l'
append using `combined6'
qui save `combined6', replace
}
gen clu_n = `i'
append using `combined5'
qui save `combined5', replace
}

save `sims2', replace
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/sims2.dta", replace

use "sims2.dta", clear

gen beta_emp = 0
gen upper_emp = 0
gen lower_emp = 0

forvalues i = 2/20{
forvalues l = 100(100)1000{
	qui ci means beta if rep == `l' & clu_n == `i'
	qui replace upper_emp = r(ub) if rep == `l' & clu_n == `i'
    qui replace lower_emp = r(lb) if rep == `l' & clu_n == `i'
	qui replace beta_emp = r(mean) if rep == `l' & clu_n == `i'
}
}

estpost tabstat beta beta_emp lower lower_emp upper upper_emp, columns(statistics) statistics(mean min max)
esttab using table2.tex, replace style(tex) cells("mean min max") noomitted nonumber nomtitle nonote collabels("Mean" "Minimum" "Maximum") order(beta lower upper beta_emp lower_emp upper_emp) coeflabel(beta "Beta" lower "Lower CI" upper "Upper CI" beta_emp "Beta" lower_emp "Lower CI" upper_emp "Upper CI") refcat(beta "\textbf{Analytical}" beta_emp "\hline \textbf{Empirical}", nolabel) title("Overall Differences in Empirical and Analytical Values")



foreach v of varlist beta beta_emp lower lower_emp upper upper_emp {
	lowess `v' rep if clu_n == 2, nograph gen(fit2_`v')
	lowess `v' rep if clu_n == 10, nograph gen(fit10_`v')
	lowess `v' rep if clu_n == 20, nograph gen(fit20_`v')
}

tw rarea fit2_lower fit2_upper rep, sort fintensity(20) color(red%30) || line fit2_beta rep, sort color(red) lpattern(dash) || rarea fit2_lower_emp fit2_upper_emp rep, sort fintensity(20) color(blue%30) || line fit2_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 2 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI1_1.png" , replace

tw rarea fit10_lower fit10_upper rep, sort fintensity(20) color(red%30) || line fit10_beta rep, sort color(red) lpattern(dash) || rarea fit10_lower_emp fit10_upper_emp rep, sort fintensity(20) color(blue%30) || line fit10_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 10 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI2_1.png" , replace

tw rarea fit20_lower fit20_upper rep, sort fintensity(20) color(red%30) || line fit20_beta rep, sort color(red) lpattern(dash) || rarea fit20_lower_emp fit20_upper_emp rep, sort fintensity(20) color(blue%30) || line fit20_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 20 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI3_1.png" , replace


**********************************************************************************************************
drop _all
capture program drop pow2
program define pow2 , rclass
syntax, cluster(integer) groupnumber(integer)


clear
set obs `cluster'

gen region = _n 


generate rannum = uniform()
egen treat = cut(rannum), group(2)
drop rannum

gen region_effect = rnormal(0,2)

expand `groupnumber'

bysort region : gen artisan = _n

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

gen business_success = 3 + 5*business_exp + 6*customers + 8*sales + 2.5*treat + region_effect


reg business_success treat business_exp customers sales 
mat b = r(table)
return scalar N = e(N)
return scalar beta = b[1,1]
return scalar se = b[2,1]
return scalar p = b[4,1]
return scalar lower = b[5,1]
return scalar upper = b[6,1]
	
end

tempfile sims2b
tempfile combined5b
tempfile combined6b

save `combined5b', replace emptyok
save `combined6b', replace emptyok

forvalues i = 2/20{
forvalues l = 100(100)1000{
simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), r(500): pow2, cluster(`i') groupnumber(`l')
gen rep = `l'
append using `combined6b'
qui save `combined6b', replace
}
gen clu_n = `i'
append using `combined5b'
qui save `combined5b', replace
}

save `sims2b', replace
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/sims2b.dta", replace

use "sims2b.dta", clear

gen beta_emp = 0
gen upper_emp = 0
gen lower_emp = 0

forvalues i = 2/20{
forvalues l = 100(100)1000{
	qui ci means beta if rep == `l' & clu_n == `i'
	qui replace upper_emp = r(ub) if rep == `l' & clu_n == `i'
    qui replace lower_emp = r(lb) if rep == `l' & clu_n == `i'
	qui replace beta_emp = r(mean) if rep == `l' & clu_n == `i'
}
}

estpost tabstat beta beta_emp lower lower_emp upper upper_emp, columns(statistics) statistics(mean min max)
esttab using table3.tex, replace style(tex) cells("mean min max") noomitted nonumber nomtitle nonote collabels("Mean" "Minimum" "Maximum") order(beta lower upper beta_emp lower_emp upper_emp) coeflabel(beta "Beta" lower "Lower CI" upper "Upper CI" beta_emp "Beta" lower_emp "Lower CI" upper_emp "Upper CI") refcat(beta "\textbf{Analytical}" beta_emp "\hline \textbf{Empirical}", nolabel) title("Overall Differences in Empirical and Analytical Values")

foreach v of varlist beta beta_emp lower lower_emp upper upper_emp {
	lowess `v' rep if clu_n == 2, nograph gen(fit2_`v')
	lowess `v' rep if clu_n == 10, nograph gen(fit10_`v')
	lowess `v' rep if clu_n == 20, nograph gen(fit20_`v')
}

tw rarea fit2_lower fit2_upper rep, sort fintensity(20) color(red%30) || line fit2_beta rep, sort color(red) lpattern(dash) || rarea fit2_lower_emp fit2_upper_emp rep, sort fintensity(20) color(blue%30) || line fit2_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 2 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI1_2.png" , replace

tw rarea fit10_lower fit10_upper rep, sort fintensity(20) color(red%30) || line fit10_beta rep, sort color(red) lpattern(dash) || rarea fit10_lower_emp fit10_upper_emp rep, sort fintensity(20) color(blue%30) || line fit10_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 10 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI2_2.png" , replace

tw rarea fit20_lower fit20_upper rep, sort fintensity(20) color(red%30) || line fit20_beta rep, sort color(red) lpattern(dash) || rarea fit20_lower_emp fit20_upper_emp rep, sort fintensity(20) color(blue%30) || line fit20_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 20 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI3_2.png" , replace

**********************************************************************************************************
drop _all
capture program drop pow3
program define pow3 , rclass
syntax, cluster(integer) groupnumber(integer)


clear
set obs `cluster'

gen region = _n 


generate rannum = uniform()
egen treat = cut(rannum), group(2)
drop rannum

gen region_effect = rnormal(0,2)

expand `groupnumber'

bysort region : gen artisan = _n
gen artisan_effect = rnormal(0,5)

gen business_exp = rnormal()
gen sales = rnormal()
gen customers = rnormal()

gen business_success = 3 + 5*business_exp + 6*customers + 8*sales + 2.5*treat + region_effect + artisan_effect


reg business_success treat business_exp customers sales, vce(robust)
mat c = r(table)
return scalar N = e(N)
return scalar beta = c[1,1]
return scalar se = c[2,1]
return scalar p = c[4,1]
return scalar lower = c[5,1]
return scalar upper = c[6,1]
	
end

tempfile sims2c
tempfile combined5c
tempfile combined6c

save `combined5c', replace emptyok
save `combined6c', replace emptyok

forvalues i = 2/20{
forvalues l = 100(100)1000{
simulate beta = r(beta) se = r(se) lower = r(lower) upper = r(upper) p = r(p), r(500): pow3, cluster(`i') groupnumber(`l')
gen rep = `l'
append using `combined6c'
qui save `combined6c', replace
}
gen clu_n = `i'
append using `combined5c'
qui save `combined5c', replace
}

save `sims2c', replace
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-10-practice/output/sims2c.dta", replace


use "sims2c.dta", clear


gen beta_emp = 0
gen upper_emp = 0
gen lower_emp = 0

forvalues i = 2/20{
forvalues l = 100(100)1000{
	qui ci means beta if rep == `l' & clu_n == `i'
	qui replace upper_emp = r(ub) if rep == `l' & clu_n == `i'
    qui replace lower_emp = r(lb) if rep == `l' & clu_n == `i'
	qui replace beta_emp = r(mean) if rep == `l' & clu_n == `i'
}
}

estpost tabstat beta beta_emp lower lower_emp upper upper_emp, columns(statistics) statistics(mean min max)
esttab using table4.tex, replace style(tex) cells("mean min max") noomitted nonumber nomtitle nonote collabels("Mean" "Minimum" "Maximum") order(beta lower upper beta_emp lower_emp upper_emp) coeflabel(beta "Beta" lower "Lower CI" upper "Upper CI" beta_emp "Beta" lower_emp "Lower CI" upper_emp "Upper CI") refcat(beta "\textbf{Analytical}" beta_emp "\hline \textbf{Empirical}", nolabel) title("Overall Differences in Empirical and Analytical Values")

foreach v of varlist beta beta_emp lower lower_emp upper upper_emp {
	lowess `v' rep if clu_n == 2, nograph gen(fit2_`v')
	lowess `v' rep if clu_n == 10, nograph gen(fit10_`v')
	lowess `v' rep if clu_n == 20, nograph gen(fit20_`v')
}

tw rarea fit2_lower fit2_upper rep, sort fintensity(20) color(red%30) || line fit2_beta rep, sort color(red) lpattern(dash) || rarea fit2_lower_emp fit2_upper_emp rep, sort fintensity(20) color(blue%30) || line fit2_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 2 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI1_3.png" , replace

tw rarea fit10_lower fit10_upper rep, sort fintensity(20) color(red%30) || line fit10_beta rep, sort color(red) lpattern(dash) || rarea fit10_lower_emp fit10_upper_emp rep, sort fintensity(20) color(blue%30) || line fit10_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 10 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI2_3.png" , replace

tw rarea fit20_lower fit20_upper rep, sort fintensity(20) color(red%30) || line fit20_beta rep, sort color(red) lpattern(dash) || rarea fit20_lower_emp fit20_upper_emp rep, sort fintensity(20) color(blue%30) || line fit20_beta_emp rep, sort color(blue) lpattern(dash_dot) legend(order(2 "Analytical" 4 "Empirical")) title("Beta Coefficient and 95% Significance CIs") subtitle("Convergence at 20 Clusters") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-10/output/CI3_3.png" , replace
