*Resources
*1) www.stata.com/manuals/u18.pdf 
*         /manuals13/psyntax.pdf 
			
*Define programs 
capture program drop hello

program define hello 
display as red "Hey there!"
end
 
 



capture program drop useless_prog 
program define useless_prog
	display as red "This is your 1st Arg: `1'"
	display as red "This is your 2nd Arg: `2'"
	display as red "This is your 3rd Arg: `3'"
end

useless_prog 123 is useless 





 
capture program drop normal_dist 
program define normal_dist 
	clear
	set obs `1'
	gen `2' = rnormal(40,10)
end



capture program drop corr_v2 
program define corr_v2	
	reg `1' `2' 
end

sysuse auto, clear
corr_v2 price mpg	



capture program drop ndist 
program define ndist 
	args num_obs new_var_name random_mean random_sd
	clear 
	set obs `num_obs'
	gen `new_var_name' = rnormal(`random_mean', `random_sd')
end
	
ndist 500 age 22 3



capture program drop normal_reg
program define normal_reg, rclass 
	syntax, samplesize(integer)
	clear 
	set obs `samplesize'
	gen x1 = rnormal() 
	gen random_num = rnormal()
	egen rank = rank(random_num)

	gen treatment=0
	replace treatment=1 if rank>50 

*DGP = Data-Generating Process 
	gen y = x1 + treatment*runiform() 
	reg y treatment 
	mat results = r(table) 
	return scalar beta = results[1,1] 
	return scalar pval = results[4,1]

end

normal_reg, samplesize(100)  
display r(beta)

mat list results




*Simulate_____________
clear
tempfile sims 
simulate beta_coef=r(beta) pvalues=r(pval), reps(100) seed(2023) saving(`sims'): normal_reg, samplesize(100)

use `sims', clear 

local style "start(-0.5) barwidth(0.99) width(0.1) fc(gray) freq" 
tw /// 
	(histogram beta, `style' lc(red) ) ///
	(histogram beta if pval < 0.05 , `style' lc(blue) fc(none) ), xtit("") legend(on ring(0) pos(1F) order(2 "p<0.05") region(lc(none)))