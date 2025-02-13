
stata.com/manuals/u18.pdf
stata.com/manuals13/psyntax.pdf 


hello

capture program drop normal_dist
program define normal_dist  
	clear
	set obs 100
	gen x = rnormal()
end
	
	capture program drop normal_reg
program define normal_reg, rclass
	syntax, samplesize(integer)
	clear 
	set obs `samplesize'
	gen x1 = rnormal()
	gen randome_num = rnormal()
	egen rank = rank(random_num)
	gen treatment = 0
	replace treatment = 1 if rank>50
	
	gen y = x1 + treatment*runiform()
	
	reg y treatment
	mat results = r(table)
	return scalar beta = results[1,1]
	return scalar pval = results[4,1]
	
end

normal_reg, samplesize(100)

tempfile sims


simulate beta_coef=r(beta) pvalues=r(pval), reps(100) seed(2023) saving(`sims'): normal_reg

use `sims', clear

local style "start(-0.5) barwidth(0.09) width(.1) fc(gray) freq"

tw ///
	(histogram beta, `style' lc(red)) ///
	(histogram beta if pval < 0.05, `style', lc(blue) fc(none)) ///
	, xtit("") legend(on ring(0) post(1) order(2 "p < 0.05") region(lc(none)))