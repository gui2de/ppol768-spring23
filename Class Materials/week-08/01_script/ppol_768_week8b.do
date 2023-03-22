/*
PPOL 768
Week 8 lab
March 16th, 2023


Additional Resources:
https://www.stata.com/manuals/u18.pdf
https://www.stata.com/manuals13/psyntax.pdf
*/



*How to define a program in Stata
capture program drop hello
program define hello
	display as red "Hi there"
end 

capture program drop xyz

program define xyz 
	corr `1' `2' `3'
end


sysuse auto, clear

xyz price mpg weight

capture program drop listargs
program define listargs
display as error "The is the whole argument you typed: `0'"
display as error "The is the whole argument you typed (trimmed): `*'"

display as error "The 1st argument you typed is: `1'"
display as error "The 2nd argument you typed is: `2'"
display as error "The 3rd argument you typed is: `3'"
display as error "The 4th argument you typed is: `4'"
display as error "The 5th argument you typed is: `5'"
display as error "The 6th argument you typed is: `6'"
end  


 
capture program drop abc
program define abc
		args dep_var ind_var1 ind_var2
	display as error "The 1st argument you typed is: `1'"
	display as error "The 1st argument you typed is: `dep_var'"
	display as error "The 2nd argument you typed is: `2'"
	display as error "The 2nd argument you typed is: `ind_var1'"
	display as error "The 3rd argument you typed is: `3'"
	display as error "The 2nd argument you typed is: `ind_var2'"
end  


abc price model mpg

capture program drop normal_dist
program define normal_dist
	clear 
	set obs 100
	gen age = rnormal(45,8)
end 


clear
normal_dist



capture program drop normal_dist
program define normal_dist
	args obs_num varname random_mean random_sd
	clear 
	set obs `obs_num'
	gen `varname' = rnormal(`random_mean',`random_sd')
end 

clear
normal_dist 1000 math_score 65 12


