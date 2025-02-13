

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

*copied the program from last week
* Part 1: De-biasing a parameter estimate using controls * 


cap prog drop reg_N_st
// Define program that takes the sample size as an argument
program define reg_N_st
    syntax, maxn(integer) // nit: N of diff sample sizes 

// Set the seed for reproducibility
set seed 12345 

 * Draw sample size from normal 

// Generate individual-level data
local nit (`maxn')/100

local t = 1 

   forvalues j = 1/5 {
		mat B`j' = J(`nit',3,0)
		mat colnames B`j' = "beta" "sem" "N" 
   }
   
forval size = 100(1000)`maxn'{

clear 

set obs `size'


// Generate a confounder affecting treatment and outcome
gen conf = rnormal(0, 1)

// Create 3 strata based on the value of the confounder

*gen strata = cond(conf < -0.5, 1, cond(conf < 0.5, 2, 3))

gen strata = runiformint(1, 3)

// Generate a variable affecting treatment but not outcome
gen x1 = rbinomial(1, 0.5)


// Generate a binary treatment variable 
gen treat = (rbinomial(1, 0.2) + x1)*2.5*conf

// Generate a continuous y_obs variable
gen y = rnormal(0, 1)


// Generate a variable affecting y_obs but not treatment
gen x2 = rbinomial(1, 0.5)



// Set the true effect of the treatment on the outcome
local beta_treat = 0.5

// Compute the true y_obs for each observation
gen y_true = y +3*strata+ `beta_treat'*treat + 2.5*conf + 0.2*x2

// Add some noise to the outcome
gen noise = rnormal(0, 0.5)
gen y_obs = y_true + noise



    // Run regression models with different combinations of covariates
    forvalues j = 1/5 {
        if `j' == 1 {
            reg y_obs i(2/3)bn.strata treat
        }
        else if `j' == 2 {
            reg y_obs i(2/3)bn.strata treat x1
        }
        else if `j' == 3 {
            reg y_obs i(2/3)bn.strata treat x2
        }
        else if `j' == 4 {
            reg y_obs i(2/3)bn.strata treat conf x2
        }
        else if `j' == 5{
            reg y_obs i(2/3)bn.strata treat conf x1 x2
        }

        // Store regression coefficients in matrix
        matrix B`j'[`t', 1] = _b[treat]
		matrix B`j'[`t', 2] = _se[treat]
		matrix B`j'[`t', 3] = e(N)

		}
		
		local t = `t'+1 
	}

end

reg_N_st, maxn(11000)


* B5 is the right model * 
* 0.5 is the true parameter value * 

forval i = 1/4{
	clear 
	svmat B`i', names(col)
	ge model = `i'
	tempfile temp`i'
	save `temp`i'', replace 
}

clear 
svmat B5, names(col)
ge model = 5 
	forval i = 1/4{
	append using `temp`i''
	}
	
	
collapse (mean) b sem, by(model N)

ge trueb = 0.5 

drop if N == 0 

ge lci = b - 1.96*sem
ge uci = b + 1.96*sem

twoway (connect beta N if model == 1) (rcap lci uci N if model ==1) ///
(connect beta N if model == 2) (rcap lci uci N if model ==2) ///
(connect beta N if model == 3) (rcap lci uci N if model ==3) ///
(connect beta N if model == 4) (rcap lci uci N if model ==4) ///
(connect beta N if model == 5) (rcap lci uci N if model ==5) (connect trueb N, lcol(red)), ///
legend(order(1 "Model 1 Beta" 2 "Model 1 CI" 3 "Model 2 Beta" 4 "Model 2 CI" 5 "Model 3 Beta" 6 "Model 3 CI" 7 "Model 4 Beta" 8 "Model 4 CI" 9 "Model 5 Beta" 10 "Model 5 CI" 11 "True Beta")) scheme(plotplainblind) 

graph export "figure1.pdf", replace 

forval j = 1/5{
	twoway (connect beta N if model == `j') (rcap lci uci N if model ==`j') (connect trueb N, lcol(red)), ///
	legend(order(1 "Model Beta" 2 "Model CI" 3 "True Beta")) title("Model `j'") xlabel(,labsize(vsmall)) ///
	scheme(plotplainblind) name(g`j', replace) ///
	yline(0.5, lcol(red) lp(dash)) 
}

graph combine g1 g2 g3 g4 g5, scheme(plotplainblind)

graph export "figure1merged.pdf", replace 

export delimited "table1.csv", replace 

* Basically as N increases in the right models that control for confounders (4 and 5) the coefficients converge towards true B 

* Part 2: biasing a parameter estimate * 


cap prog drop reg_N_collider
// Define program that takes the sample size as an argument
program define reg_N_collider
    syntax, maxn(integer) // nit: N of diff sample sizes 

// Set the seed for reproducibility
set seed 12345 

 * Draw sample size from normal 

// Generate individual-level data
local nit (`maxn')/100

local t = 1 

   forvalues j = 1/5 {
		mat B`j' = J(`nit',3,0)
		mat colnames B`j' = "beta" "sem" "N" 
   }
   
forval size = 100(1000)`maxn'{

clear 

set obs `size'


// Generate a confounder affecting treatment and outcome
gen conf = rnormal(0, 1)

// Create 3 strata based on the value of the confounder

*gen strata = cond(conf < -0.5, 1, cond(conf < 0.5, 2, 3))

gen strata = runiformint(1, 3)


// Generate a binary treatment variable 
gen treat = (rbinomial(1, 0.2))*2.5*conf


// Generate a channel variable 

gen x1 = rbinomial(1, 0.5) + 0.5*treat 


// Generate a continuous y_obs variable
gen y = rnormal(0, 1)


// Set the true effect of the treatment on the outcome
local beta_treat = 0.5

// Compute the true y_obs for each observation
gen y_true = y + 3*strata + `beta_treat'*treat + 2.5*conf + 0.2*x1

// Generate a collider 
gen x2 = rbinomial(1, 0.5) + 0.45*y_true + 0.45*treat 


// Add some noise to the outcome
gen noise = rnormal(0, 0.5)
gen y_obs = y_true + noise


    // Run regression models with different combinations of covariates
    forvalues j = 1/5 {
        if `j' == 1 {
            reg y_obs i(2/3)bn.strata treat // baseline model
        }
        else if `j' == 2 {
            reg y_obs i(2/3)bn.strata treat x1 // model including channel 
        }
        else if `j' == 3 {
            reg y_obs i(2/3)bn.strata treat x2 // model including collider
        }
        else if `j' == 4 {
            reg y_obs i(2/3)bn.strata treat conf x2 // model including confounder and collider
        }
        else if `j' == 5{
            reg y_obs i(2/3)bn.strata treat conf x1 // model including confounder and treatment and channel 
        }

        // Store regression coefficients in matrix
        matrix B`j'[`t', 1] = _b[treat]
		matrix B`j'[`t', 2] = _se[treat]
		matrix B`j'[`t', 3] = e(N)

		}
		
		local t = `t'+1 
	}

end

reg_N_collider, maxn(11000)


* B5 is the right model * 
* 0.5 is the true parameter value * 

forval i = 1/4{
	clear 
	svmat B`i', names(col)
	ge model = `i'
	tempfile temp`i'
	save `temp`i'', replace 
}

clear 
svmat B5, names(col)
ge model = 5 
	forval i = 1/4{
	append using `temp`i''
	}
	
	
collapse (mean) b sem, by(model N)

ge trueb = 0.5 

drop if N == 0 

ge lci = b - 1.96*sem
ge uci = b + 1.96*sem

twoway (connect beta N if model == 1) (rcap lci uci N if model ==1) ///
(connect beta N if model == 2) (rcap lci uci N if model ==2) ///
(connect beta N if model == 3) (rcap lci uci N if model ==3) ///
(connect beta N if model == 4) (rcap lci uci N if model ==4) ///
(connect beta N if model == 5) (rcap lci uci N if model ==5) (connect trueb N, lcol(red)) , ///
legend(order(1 "Model 1 Beta" 2 "Model 1 CI" 3 "Model 2 Beta" 4 "Model 2 CI" 5 "Model 3 Beta" 6 "Model 3 CI" 7 "Model 4 Beta" 8 "Model 4 CI" 9 "Model 5 Beta" 10 "Model 5 CI" 11 "True Beta")) scheme(plotplainblind) 

graph export "figure2.pdf", replace 

forval j = 1/5{
	twoway (connect beta N if model == `j') (rcap lci uci N if model ==`j') (connect trueb N, lcol(red)), ///
	legend(order(1 "Model Beta" 2 "Model CI" 3 "True Beta")) title("Model `j'") xlabel(,labsize(vsmall)) ///
	scheme(plotplainblind) name(g`j', replace) 
}

graph combine g1 g2 g3 g4 g5, scheme(plotplainblind)

graph export "figure2merged.pdf", replace 

export delimited "table2.csv", replace 
