
* Part 1 Sampling noise in a fixed population * 
cd "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Individual Assignments\Lei J\week_08"
clear
set seed 12345
set obs 10000
gen x1=rnormal(0,1)
gen x2=rnormal(0,1)
save "Data_X.dta", replace


capture program drop reg_N

program define reg_N, rclass
syntax, obs(integer)

	use "Data_X.dta", replace 
	sample `obs', count
	gen y = 5 * x1 + 3 * x2  + runiform(0, 0.3)
	reg y x1
	local t = _b[x1] / _se[x1]
	return scalar N = r(N)
	
	return scalar SEM = _se[x1]
	return scalar beta = _b[x1]
	return scalar p = 2 * ttail(e(df_r), abs(`t'))
	return scalar CI_l = _b[x1] - invttail(e(df_r), 0.025) * _se[x1]
	return scalar CI_u = _b[x1] + invttail(e(df_r), 0.025) * _se[x1]

end



forvalues i = 1/4 {

	local j = 10^`i'
	
	mat B`i' = J(500,5,0)
	mat colnames B`i' = "beta" "sem" "pval" "cil" "ciu"
	simulate, reps(500): reg_N, obs(`j')

	forval s = 1/500{
		mat B`i'[`s',1] = r(beta)
		mat B`i'[`s',2] = r(SEM)
		mat B`i'[`s',3] = r(p)
		mat B`i'[`s',4] = r(CI_l)
		mat B`i'[`s',5] = r(CI_u)
	}
}


forval i = 1/3{
	clear 
	local j = 10^`i'	
	svmat B`i', names(col)
	ge nobs = `j'
	tempfile temp`i'
	save `temp`i'', replace 
}

clear 
svmat B4, names(col)
	ge nobs = 10000
	forval i = 1/3{
	append using `temp`i''
	}
	
* Mean stuff * 

collapse (mean) beta sem pval cil ciu, by(nobs)

ge temp = _n

ge trueb = 5 

* FIGURE * 
/*
twoway (scatter beta nobs) (scatter sem nobs) (rcap cil ciu nobs), ///
legend(order(1 "Point Est" 2 "SE" 3 "CI"))
*/

twoway (scatter beta temp) (scatter sem temp) (rcap cil ciu temp) (connect trueb temp), ///
legend(order(1 "Point Est" 2 "SE" 3 "CI" 4 "True Beta")) scheme(plotplainblind) ///
xlabel(1 "10" 2 "100" 3 "1000" 4 "10000" 5 "100000") xtitle("N(Obs)") 


graph export "figure1.pdf", replace 


* TABLE * 
export delimited using "table1.csv", replace 



* Part 2 Sampling noise in an infinite suppopulation * 

forvalues i = 1/6 {

	local j = 10^`i'
	
	mat B`i' = J(500,5,0)
	mat colnames B`i' = "beta" "sem" "pval" "cil" "ciu"
	simulate, reps(500): reg_N, obs(`j')

	forval s = 1/500{
		mat B`i'[`s',1] = r(beta)
		mat B`i'[`s',2] = r(SEM)
		mat B`i'[`s',3] = r(p)
		mat B`i'[`s',4] = r(CI_l)
		mat B`i'[`s',5] = r(CI_u)
	}
}


forval i = 1/6{
	clear 
	local j = 10^`i'	
	svmat B`i', names(col)
	ge nobs = `j'
	tempfile temp`i'
	save `temp`i'', replace 
}

clear 
svmat B6, names(col)
	ge nobs = 10000
	forval i = 1/6{
	append using `temp`i''
	}
	
	* Mean stuff * 

collapse (mean) beta sem pval cil ciu, by(nobs)

ge temp = _n

ge trueb = 5 

* FIGURE * 
twoway (scatter beta temp) (scatter sem temp) (rcap cil ciu temp) (connect trueb temp), ///
legend(order(1 "Point Est" 2 "SE" 3 "CI" 4 "True Beta")) scheme(plotplainblind) ///
xlabel(1 "10" 2 "100" 3 "1000" 4 "10000" 5 "100000") xtitle("N(Obs)") 

graph export "figure2.pdf", replace 


* TABLE * 
export delimited using "table2.csv", replace 