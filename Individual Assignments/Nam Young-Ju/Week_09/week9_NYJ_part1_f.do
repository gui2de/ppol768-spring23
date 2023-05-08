
* Part 1-(1~3): Develop some data generating process for data X's and for outcome Y
* Part 1-(3): Create "bsize" as counfounder!
* Part 1-(4): Run the 5 different regression with different sample sizes!!!

capture program drop normal_reg
program define normal_reg, rclass 
	syntax, samplesize(integer)
	clear

set obs 10 
gen district = _n
expand `samplesize'

	gen bsize = rnormal()
	gen tourist_influx = rnormal()
	gen export = rnormal()
	gen treat = (bsize + tourist_influx + district/4 + rnormal()) > 0.6
	gen sales = (1.2)*bsize + export - district/20 + 1.5*treat + rnormal()

	reg sales treat
	return scalar beta1 = _b[treat]
	return scalar N1 = e(N)
	
   	reg sales treat bsize
	return scalar beta2 = _b[treat]
 		
	reg sales treat bsize i.district
	return scalar beta3 = _b[treat]
		
	reg sales treat i.district tourist_influx 
	return scalar beta4 = _b[treat]
		
	reg sales treat i.district tourist_influx export  
	return scalar beta5 = _b[treat]
	
end
 

* Part 1-(4): Simulate program by running 500 times with different N

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
