

capture program drop powersimu

program powersimu, rclass

// DEFINE THE INPUT PARAMETERS AND THEIR DEFAULT VALUES
   syntax, n(integer) debias(integer)	      /// sample size for each dosage group
	b1(real)             ///  b1 under the alternative
	[ alpha(real 0.05)   ///  alpha level     ///  fixed dosage level 3
	]

// GENERATE THE RANDOM DATA AND TEST THE NULL HYPOTHESIS
   clear
   set obs `n'
   
 ** DGP **
 
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



// Compute the true y_obs for each observation
gen y_true = y + `b1'*treat + 2.5*conf + 0.2*x2

// Add some noise to the outcome
gen noise = rnormal(0, 0.5)
gen y_obs = y_true + noise

// reg 
if `debias'==0{ // no debiasing controls 
	reg y_obs x1 x2 treat 
}
if `debias'==1{
reg y_obs x1 x2 conf treat 
}
// RETURN RESULTS
   mat a=r(table)
   local p1=el(a,rownumb(a,"pvalue"),colnumb(a,"treat"))
   return scalar pvalue = `p1'
   return scalar reject = (`p1'<`alpha') 
end


* With debiasing controls,  fixed the beta to 0.5
power powersimu, debias(1) reps(50) n(10(10)100) b1(0.5) table graph(xdimension(N) yline(0.8) title("With Debiasing Controls") name(g1, replace) scheme(plotplainblind)) alpha(0.05) 

* Withput debiasing controls, fixed the beta to 0.5
power powersimu, debias(0) reps(50) n(10(10)100) b1(0.5) table graph(xdimension(N) yline(0.8) title("Without Debiasing Controls") name(g2, replace) scheme(plotplainblind)) alpha(0.05) 

graph combine g1 g2, cols(2) graphregion(color(white))

graph export "figure1_power.pdf", replace 


 
* With debiasing controls, fixed the n to 50
power powersimu, debias(1) reps(50) n(50) b1(0(0.05)0.5) table graph(xdimension(b1) yline(0.8) title("With Debiasing Controls", size(small)) name(g1, replace) scheme(plotplainblind)) alpha(0.05) 

* Without debiasing controls, fixed the n to 50
power powersimu, debias(0) reps(50) n(50) b1(0(0.05)0.5) table graph(xdimension(b1) yline(0.8) title("Without Debiasing Controls",size(small)) name(g2, replace) scheme(plotplainblind)) alpha(0.05) 


graph combine g1 g2, cols(2) graphregion(color(white))

graph export "figure1_power_effectsize.pdf", replace 