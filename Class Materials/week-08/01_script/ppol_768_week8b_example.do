// Example do-file for programming session

// Define the program
cap prog drop normaldistro
prog def normaldistro , rclass // Allow returning values to memory

syntax, samplesize(integer)


  clear
  set obs `samplesize'
  local treat_num = `samplesize'/2
  gen x1 = rnormal() // Arbitrary covariate
  gen rand = rnormal()  // 50-50 treatment
    egen rank = rank(rand)
    gen treatment = rank <= `treat_num'

  // DGP
  gen y = x1 + treatment*runiform() // Heterogeneous, positive effect

  reg y treatment
  mat a = r(table)
    return scalar beta = a[1,1]
    return scalar pval = a[4,1]
end

// Use the program in simulate, for samplesize 10, 100, 1000, 10,000
clear
tempfile combined
save `combined', replace emptyok

forvalues i=1/4{
	local samplesize= 10^`i'
	tempfile sims
	simulate beta=r(beta) pval=r(pval) ///
	  , reps(500) seed(725485) saving(`sims') ///
	  : normaldistro, samplesize(`samplesize') 

	use `sims' , clear
	gen samplesize=`samplesize'
	append using `combined'
	save `combined', replace

}
 
use `combined', clear



*histogram to show distribution of betas by samplesize
histogram beta, by(samplesize)

*generating a histogram of betas for samplesize=100
keep if samplesize==100
local style "start(-0.5)  barwidth(0.09) width(.1) fc(gray) freq"
tw ///
  (histogram beta , `style' lc(red) ) ///
  (histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ) ///
, xtit("") legend(on ring(0) pos(1) order(2 "p < 0.05") region(lc(none)))




