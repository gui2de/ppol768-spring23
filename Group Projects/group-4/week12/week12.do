* week 12
cd "C:\Users\zheng\Desktop\research design\week12\outputs"

global dashboard "dashboard.xlsx"

clear

********************************************************************************
* DGP
********************************************************************************

set seed 20230414

* State level
set obs 12  // one multi-sector CAT state and 10 RGGI states
gen state = _n
recode state (1 = "06") (2 = "09") (3 = "10") (4 = "23") (5 = "24") (6 = "25") (7 = "33") (8 = "34") (9 = "36") (10 = "44") (11 = "50") (12 = "51"), gen(state_abb)

gen ui = rnormal(30, 6)

*treatment
gen treatment = 0 // RGGI
replace treatment = 1 if state == 1 // California

* Sector level
expand 9 // 9 main sectors
bysort state: gen sector = _n
*tostring sector, replace
gen uij = rnormal(20, 5)

* Company level
expand 300 + int(500 - 300 + 1) * runiform()
bysort state sector: gen company = _n
*tostring company, replace
gen uijk = rnormal(40, 6)

* Time level
expand 7  // 2010-2016
bysort state sector company: gen year = 2009 + _n
gen uijkt = rnormal(15, 2)

* instrument for manipulation
gen m = runiform()

* covariate generation
** revenue
gen revenue = rnormal(100, 10)
replace revenue = revenue * (-1) if m > 0.6 & m < 0.62 // generate revenue outliers
replace revenue = 120 if company == 300 // generate duplicated 

**energy_efficiency
gen energy_efficiency = runiform()

** R&D investment
gen rd = rnormal(10, 1)
replace rd = rd * (-1) if m > 0.22 & m < 0.26 // generate rd outliers

** whether develop new tech or not (binary)
gen new_tech = round(runiform(0, 2), 1)
replace new_tech* = 999 if new_tech == 2 // generate missing new_tech

* generate emission data
gen emission = 50 ///
	- 20*treatment ///
	+ 30*revenue ///
	- 5*energy_efficiency ///
	- 15*rd ///
	- 8*new_tech ///
	+ ui + uij + uijk + uijkt
replace emission = . if m > 0.4 & m < 0.45 //generate emission missing 
replace emission = 400 if company > 480 // generate duplicated emission inputs

drop ui uij uijk uijkt m

egen id = concat(state_abb sector company) // generate unique company id
destring id, replace

* reshape to survey like data
reshape wide revenue energy_efficiency rd new_tech emission, i(id) j(year)

gen m = runiform()
replace id = id[_n - 1] if m < 0.05 // generate duplicated id
drop m

*global varlist emission mul_cat revenue energy_efficiency rd new_tech

* date
gen time_start = runiformint(tc(1jan2024 00:00:00), tc(31May2024 00:00:00))

gen time_diff = runiformint(tc(00:02:00), tc(23:59:59))

gen time_end = time_start + time_diff

format time_start %tCDD_Month_CCYY_HH:MM:SS

format time_end %tCDD_Month_CCYY_HH:MM:SS

/* generate survey_status = incomplete
	   gen survey_status = 1 // complete
	   replace survey_status = 0 if m > 0.88 | m < 0.1 // incomplete

	   * generate missing id
	   replace id = . if m > 0.9
*/

********************************************************************************
* HFC
********************************************************************************

* check duplicate id

duplicates tag id, gen(duplicate)

preserve
drop if duplicate != 0
keep id time_start time_end
export excel using "$dashboard", sheet("duplicated_id", modify) firstrow(variables)
restore

drop if duplicate != 0
drop duplicate

* check missing values in covariates

preserve
egen nm = rowmiss(revenue* energy_efficiency* rd* new_tech* emission*)
drop if nm != 0
drop nm
export excel using "$dashboard", sheet("var_missing", modify) firstrow(variables)
restore

reshape long revenue energy_efficiency rd new_tech emission, i(id) j(year) // reshape to long table to facilitate checks below

* check duplicated values in covariates
sort id year
bysort id: gen same1 = 1 if emission[_n - 1] == emission[_n]
bysort id: gen same2 = 1 if energy_efficiency[_n - 1] == energy_efficiency[_n] // no obs
bysort id: gen same3 = 1 if rd[_n - 1] == rd[_n] // no obs
bysort id: gen same4 = 1 if revenue[_n - 1] == revenue[_n]

preserve
keep if same1 == 1 | same4 == 1
keep id year emission revenue
export excel using "$dashboard", sheet("duplicated_covariates", modify) firstrow(variables)
restore

* check distribution

hist revenue, ///
	by(year, title("Distribution of revenue by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("Revenue (Million $)")
graph export "hist_revenue_origin.png", replace

hist energy_efficiency, ///
	by(year, title("Distribution of energy efficiency by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("Energy Efficiency (%)")
graph export "hist_energy_efficiency_origin.png", replace

hist rd, ///
	by(year, title("Distribution of R&D investment by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("R&D investment ($)")
graph export "hist_randd_origin.png", replace

hist emission, ///
	by(year, title("Distribution of emission by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("GHG emission (Million tons)")
graph export "hist_emission_origin.png", replace

catplot treatment
graph export "hist_treatment_origin.png", replace

catplot new_tech
graph export "hist_mew_tech_origin.png", replace

count if revenue <= 0 // 5568

preserve
drop if emission <= 0
hist revenue, ///
	by(year, title("Distribution of revenue by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("Revenue (Million $)")
graph export "hist_revenue.png", replace
restore

count if rd <= 0 // 10920
preserve
drop if rd <= 0
hist rd, ///
	by(year, title("Distribution of R&D investment by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("R&D investment ($)")
graph export "hist_randd.png", replace
restore

count if emission <= 0 // 69625
preserve
drop if emission <= 0
hist emission, ///
	by(year, title("Distribution of emission by year") note("")) ///
	fcolor(none) lcolor(black) ///
	xtitle("GHG emission (Million tons)")
graph export "hist_emission.png", replace
restore

count if new_tech == 999 // 68841

* check outliers
** NOTE: energy efficiency does not have outliers

foreach var in revenue rd emission { 
	preserve
	qui sum `var' if `var' > 0 , d   // according to the analysis above, we do not consider values below 0
	gen sds = (`var' - r(mean))/(r(sd)) 
	keep if abs(sds) > 3 & !missing(`var') // present obs > 2sd
	export excel using "$dashboard", sheet("outliers_`var'",modify) firstrow(variables)
	restore
}

* check date and time
gen abn_time = 0
replace abn_time =1 if  time_diff <= tc(00:05:00)

preserve
keep if abn_time == 1
keep id time_start time_end
export excel using "$dashboard", sheet("duration_less_than_5min", modify) firstrow(variables)
restore