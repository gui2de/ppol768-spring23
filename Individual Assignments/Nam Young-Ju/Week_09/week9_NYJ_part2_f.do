
* Part 2-(1~2): Develop some data generating process for data X's and for outcome Y
* Part 2-(3): Create "channel"
* Part 2-(4): Create "collider"

capture program drop normal_reg
program define normal_reg, rclass 
	syntax, samplesize(integer)
	clear

set obs 10 
gen district = _n
expand `samplesize'

	gen bsize = rnormal()
	gen treat = (bsize + district/4 + rnormal()) > 0.6
	gen sales = (1.2)*bsize - district/20 + 1.5*treat + rnormal()
	gen collider = (0.8)*treat + (1.4)*sales + rnormal()
	gen channel = (2.5)*treat + runiform()

	reg sales treat
	return scalar beta1 = _b[treat]
	return scalar N1 = e(N)
	
   	reg sales treat bsize i.district 
	return scalar beta2 = _b[treat]
 		
	reg sales treat bsize channel
	return scalar beta3 = _b[treat]
		
	reg sales treat bsize collider 
	return scalar beta4 = _b[treat]
		
	reg sales treat bsize collider channel  
	return scalar beta5 = _b[treat]
	
end

* Part 2-(5): Run the 5 different regression with different sample sizes!!!

clear
tempfile combined
save `combined', replace emptyok
	tempfile sims

    forvalues j=1/4{
		display as error `j'
	local ss = 10^`j'
	display as error `ss'
	simulate N=r(N1) b1=r(beta1) b2=r(beta2) b3=r(beta3) b4=r(beta4) b5=r(beta5), reps(50) saving(`sims', replace): normal_reg, samplesize(`ss')

	use `sims', clear
	
	append using `combined'
	save `combined',replace
	}

* Visualize

use `combined', clear

graph box b1 b2 b3 b4 b5, over(N) yline(1.5) noout
