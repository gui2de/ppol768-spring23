********************************************************************************
* PPOL 768: Week 5
* Assignment for Week 9
* Michele Giunti
* March 28th, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/
clear
cd "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output"
/*******************************************************************************
1. De-biasing a parameter estimate using controls
*******************************************************************************/
drop _all
capture program drop debias
program define debias , rclass
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
gen treat = (region/(5) + business_exp + sales + rnormal()) > 0 

*generate dependent variable, where treatment variable has some impact(say 2.5 units) 
gen business_success = 3 + (-1)*region + business_exp + 6*customers + 2.5*treat + region_effect + artisan_effect



reg business_success treat
	return scalar treatment_base=_b[treat]
	
	
reg business_success treat i.region
	return scalar treatment_fe=_b[treat]


reg business_success treat i.region business_exp 
	return scalar treatment_confounder=_b[treat]
	

reg business_success treat i.region customers sales
	return scalar treatment_covar=_b[treat]
	

reg business_success treat business_exp sales customers
	return scalar treatment_confounder_covar=_b[treat]
	
	
reg business_success treat i.region business_exp sales customers
	return scalar treatment_full=_b[treat]
	return scalar N = e(N)
	
	
end

tempfile sims1
tempfile combined 
tempfile combined2
clear

save `combined', replace emptyok
save `combined2', replace emptyok

forvalues l = 300(100)800{
	use `combined2', clear
	local u = `l'+200
forvalues i = 1/10{
simulate treatment_base=r(treatment_base) treatment_fe = r(treatment_fe) treatment_confounder=r(treatment_confounder) treatment_covar=r(treatment_covar) treatment_confounder_covar=r(treatment_confounder_covar) treatment_full=r(treatment_full), r(500): debias, strata(`i') upper_obs(`u') lower_obs(`l')
gen strata=`i'
gen N = e(N)
append using `combined2'
qui save `combined2', replace
	_dots `i' 0
}
append using `combined'
qui save `combined', replace
if `l' == 800 {
	save `sims1', replace
}
else if `l' != 800 {
	clear
	qui save `combined2', replace emptyok
}
}

use `sims1', clear
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/sims1.dta", replace

foreach v of varlist treatment_base treatment_fe treatment_confounder treatment_covar treatment_confounder_covar treatment_full{
	lowess `v' N, mean nograph gen(fit_`v')
}


rename fit_treatment_base fit_base
rename fit_treatment_fe fit_fe
rename fit_treatment_confounder fit_conf
rename fit_treatment_covar fit_covar
rename fit_treatment_confounder_covar fit_conf_covar
rename fit_treatment_full fit_full



foreach var of varlist treatment_base treatment_fe treatment_confounder treatment_covar treatment_confounder_covar treatment_full{
	gen min_`var' = .
	gen max_`var' = .
}




levelsof N, local(Ns)
foreach var of varlist treatment_base treatment_fe treatment_confounder treatment_covar treatment_confounder_covar treatment_full{
	qui foreach i in `Ns' {
			sum `var' if N == `i', detail
			replace min_`var' = r(min) if N == `i'
			replace max_`var' = r(max) if N == `i'
			}
}

rename min_treatment_base min_base
rename max_treatment_base max_base
rename min_treatment_fe min_fe
rename max_treatment_fe max_fe
rename min_treatment_confounder min_confounder
rename max_treatment_confounder max_confounder
rename min_treatment_covar min_covar
rename max_treatment_covar max_covar
rename min_treatment_confounder_covar min_confounder_covar
rename max_treatment_confounder_covar max_confounder_covar
rename min_treatment_full min_full
rename max_treatment_full max_full

foreach var of varlist min_base max_base min_fe max_fe min_confounder max_confounder min_covar max_covar min_confounder_covar max_confounder_covar min_full max_full{
	lowess `var' N, nograph gen(fit_`var')
}

save `sims1', replace

twoway rarea fit_min_base fit_max_base N , sort fintensity(20) color(%10) || line fit_base N , sort || rarea fit_min_fe fit_max_fe N , sort fintensity(20) color(%10) || line fit_fe N , sort lpattern(dash) || rarea fit_min_confounder fit_max_confounder N , sort fintensity(20) color(%10) || line fit_conf N , lpattern(longdash_dot) sort || rarea fit_min_covar fit_max_covar N , sort fintensity(20) color(%10) || line fit_covar N , lpattern(dash_dot) sort || rarea fit_min_confounder_covar fit_max_confounder_covar N , sort fintensity(20) color(%10) || line fit_conf_covar N , lpattern (shortdash) sort || rarea fit_min_full fit_max_full N , sort fintensity(20) color(%10) || line fit_full N, lpattern(shortdash_dot) sort legend(order(2 "Base" 4 "Fixed Effect" 6 "Confounder" 8 "Covariates" 10 "Conf + Covar" 12 "Full") pos(3) col(1) stack) title("Change in Coefficients based on Model Used") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison1.png" , replace

twoway rarea fit_min_base fit_max_base N , sort fintensity(20) color(purple%30) || line fit_base N , color(purple) sort || rarea fit_min_confounder fit_max_confounder N , sort fintensity(20) color(blue%30) || line fit_conf N , color(blue) sort || rarea fit_min_fe fit_max_fe N , sort fintensity(20) color(red%30) || line fit_fe N , sort color(red) lpattern(dash) legend(order(2 "Base" 4 "Confounder" 6 "Fixed Effects")) title("First Separator (Base, Confounder, FE)") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison2.png" , replace

twoway rarea fit_min_confounder_covar fit_max_confounder_covar N , sort fintensity(20) color(green%30) || line fit_conf_covar N , lpattern (shortdash) sort color(green) || rarea fit_min_full fit_max_full N , sort fintensity(20) color(yellow%30) || line fit_full N, lpattern(shortdash_dot) sort || rarea fit_min_covar fit_max_covar N , sort fintensity(20) color(brown%30) || line fit_covar N , lpattern(dash_dot) color(brown) sort legend(order(2 "Conf + Covar" 4 "Full" 6 "Covar")) title("Second Separator (Conf + Covar, Covar, Full)") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison3.png" , replace



estpost tabstat treatment_base treatment_fe treatment_confounder treatment_covar treatment_confounder_covar treatment_full, col(stat) stat(mean sd semean min max) 

esttab using table.tex, replace style(tex) cells("mean sd semean min max") nonumber nomtitle nonote collabels("Mean" "SD" "SE" "Min" "Max") coeflabel(treatment_base "Base" treatment_fe "Fixed Effects" treatment_confounder "Confounder" treatment_covar "Covariates" treatment_confounder_covar "Conf + Covar" treatment_full "Full") label title("Tabstat of Simulation 1")

save `sims1', replace

/*******************************************************************************
2. Biasing a parameter estimate using controls
*******************************************************************************/
clear
drop _all
capture program drop bias
program define bias , rclass
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


gen treat = (region/(5) + rnormal()) > 0 

gen postal = 3 + .25*treat + rnormal()


gen business_success = 3 + (-1)*region + business_exp + 4*sales + 6*customers + 2.5*postal + region_effect + artisan_effect

gen capital = 2 + 1.7*business_success + .5*postal + rnormal()




reg business_success postal
	return scalar channel_base=_b[postal]
	
reg business_success postal i.region
	return scalar channel_fe=_b[postal]

reg business_success postal i.region capital
	return scalar channel_collider=_b[postal]

reg business_success postal i.region customers sales business_exp
	return scalar channel_covar=_b[postal]

reg business_success postal capital business_exp sales customers
	return scalar channel_collider_covar=_b[postal]
	
reg business_success postal i.region business_exp sales customers
	return scalar channel_full=_b[postal]
	
reg business_success postal i.region capital business_exp sales customers
	return scalar channel_full_collider=_b[postal]
	return scalar N = e(N)
end


tempfile sims2
tempfile combined_2 
tempfile combined2_2
clear

save `combined_2', replace emptyok
save `combined2_2', replace emptyok

forvalues l = 300(100)800{
	use `combined2_2', clear
	local u = `l'+200
forvalues i = 1/10{
simulate channel_base=r(channel_base) channel_fe = r(channel_fe) channel_collider=r(channel_collider) channel_covar=r(channel_covar) channel_collider_covar=r(channel_collider_covar) channel_full=r(channel_full) channel_full_collider = r(channel_full_collider), r(500): bias, strata(`i') upper_obs(`u') lower_obs(`l')
gen strata=`i'
gen N = e(N)
append using `combined2_2'
qui save `combined2_2', replace
	_dots `i' 0
}
append using `combined_2'
qui save `combined_2', replace
if `l' == 800 {
	save `sims2', replace
}
else if `l' != 800 {
	clear
	qui save `combined2_2', replace emptyok
}
}

use `sims2', clear
save "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/sims2.dta", replace

foreach v of varlist channel_base channel_fe channel_collider channel_covar channel_collider_covar channel_full channel_full_collider{
	lowess `v' N, mean nograph gen(fit_`v')
}


rename fit_channel_base fit_base
rename fit_channel_fe fit_fe
rename fit_channel_collider fit_conf
rename fit_channel_covar fit_covar
rename fit_channel_collider_covar fit_conf_covar
rename fit_channel_full fit_full
rename fit_channel_full_collider fit_full_collider


foreach var of varlist channel_base channel_fe channel_collider channel_covar channel_collider_covar channel_full channel_full_collider{
	gen min_`var' = .
	gen max_`var' = .
}


levelsof N, local(Ns)
foreach var of varlist channel_base channel_fe channel_collider channel_covar channel_collider_covar channel_full channel_full_collider{
	qui foreach i in `Ns' {
			sum `var' if N == `i', detail
			replace min_`var' = r(min) if N == `i'
			replace max_`var' = r(max) if N == `i'
			}
}

rename min_channel_base min_base
rename max_channel_base max_base
rename min_channel_fe min_fe
rename max_channel_fe max_fe
rename min_channel_collider min_collider
rename max_channel_collider max_collider
rename min_channel_covar min_covar
rename max_channel_covar max_covar
rename min_channel_collider_covar min_collider_covar
rename max_channel_collider_covar max_collider_covar
rename min_channel_full min_full
rename max_channel_full max_full
rename min_channel_full_collider min_full_collider
rename max_channel_full_collider max_full_collider

foreach var of varlist min_base max_base min_fe max_fe min_collider max_collider min_covar max_covar min_collider_covar max_collider_covar min_full max_full min_full_collider max_full_collider{
	lowess `var' N, nograph gen(fit_`var')
}

save `sims2', replace

twoway rarea fit_min_base fit_max_base N , sort fintensity(20) color(%10) || line fit_base N , sort || rarea fit_min_fe fit_max_fe N , sort fintensity(20) color(%10) || line fit_fe N , sort lpattern(dash) || rarea fit_min_collider fit_max_collider N , sort fintensity(20) color(%10) || line fit_conf N , lpattern(longdash_dot) sort || rarea fit_min_covar fit_max_covar N , sort fintensity(20) color(%10) || line fit_covar N , lpattern(dash_dot) sort || rarea fit_min_collider_covar fit_max_collider_covar N , sort fintensity(20) color(%10) || line fit_conf_covar N , lpattern (shortdash) sort || rarea fit_min_full fit_max_full N , sort fintensity(20) color(%10) || line fit_full N, lpattern(shortdash_dot) || rarea fit_min_full_collider fit_max_full_collider N , sort fintensity(20) color(%10) || line fit_full_collider N, lpattern(longdash) sort legend(order(2 "Base" 4 "Fixed Effect" 6 "Collider" 8 "Covariates" 10 "Coll + Covar" 12 "Full" 14 "Full + Coll") pos(3) col(1) stack) title("Change in Coefficients based on Model Used") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison1_2.png" , replace

twoway rarea fit_min_base fit_max_base N , sort fintensity(20) color(purple%30) || line fit_base N , color(purple) sort || rarea fit_min_collider fit_max_collider N , sort fintensity(20) color(blue%30) || line fit_conf N , color(blue) sort || rarea fit_min_fe fit_max_fe N , sort fintensity(20) color(red%30) || line fit_fe N , sort color(red) lpattern(dash) legend(order(2 "Base" 4 "Collider" 6 "Fixed Effects")) title("First Separator (Base, Collider, FE)") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison2_2.png" , replace

twoway rarea fit_min_collider_covar fit_max_collider_covar N , sort fintensity(20) color(green%30) || line fit_conf_covar N , lpattern (shortdash) sort color(green) || rarea fit_min_full fit_max_full N , sort fintensity(20) color(yellow%30) || line fit_full N, lpattern(shortdash_dot) sort || rarea fit_min_covar fit_max_covar N , sort fintensity(20) color(brown%30) || line fit_covar N , lpattern(dash_dot) color(brown) sort || rarea fit_min_full_collider fit_max_full_collider N , sort fintensity(20) color(orange%30) || line fit_full_collider N, lpattern(longdash) color(orange) sort legend(order(2 "Collider + Covar" 4 "Full" 6 "Covar" 8 "Full+Collider")) title("Second Separator (Coll+Covar, Collider, Full, Coll+Full)") subtitle("Shaded Areas for 95% CI") ytitle("Beta Coefficient")
graph export "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/ppol768-spring23/Individual Assignments/Giunti Michele/week-09/output/Comparison3_2.png" , replace

estpost tabstat channel_base channel_fe channel_collider channel_covar channel_collider_covar channel_full channel_full_collider, col(stat) stat(mean sd semean min max) 

esttab using table2.tex, replace style(tex) cells("mean sd semean min max") nonumber nomtitle nonote collabels("Mean" "SD" "SE" "Min" "Max") coeflabel(channel_base "Base" channel_fe "Fixed Effects" channel_collider "Collider" channel_covar "Covariates" channel_collider_covar "Collider + Covar" channel_full "Full" channel_full_collider "Full + Collider") title("Tabstat of Simulation 2") label


save `sims2', replace
