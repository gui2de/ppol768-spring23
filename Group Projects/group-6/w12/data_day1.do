*Modeling data to test HFC



clear all 
set obs 900
 set seed 1267

gen singleparent= runiform()<.5 //generating single parent households randomly, dummy variable

gen caretime= rnormal(30.5,10) // time spent taking care of children 
gen children_normal= rnormal(3,2) // giving families number of children
gen children=int(children_normal)
drop children_normal

gen household_income= 13090*rnormal(.5,.25) 
gen entrespirit= rnormal() // This assigns a number to the value the person places on being an entrepreneur and having a successful business

gen treatment= 1 if children>0 
replace treatment=0 if children==0

gen household_id= round(900 * runiform()) 
gen enumerator = round(29 * runiform())


replace household_income = 0 if household_income < 0 // had to add to get rid of negative values
replace entrespirit = 0 if entrespirit < 0 
replace children = 0 if children < 0
replace caretime= 0 if children==0 // if 0 children then childcare time will be 0


*DGP, generating y 

		generate entreptime= 10 ///
			- caretime * .5 ///
			+singleparent*rnormal(20,1) ///
			-children*2*rnormal() ///
			+entrespirit*5*rnormal() 
			
replace entreptime = 0 if entreptime < 0
save surveys_day1.dta, replace
