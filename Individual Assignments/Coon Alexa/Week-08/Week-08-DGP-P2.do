*Week 8 Data Generating Process
/*Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().*/
clear 

	set seed 65465 
	//syntax, samplesize(integer)
	set obs 10000 // one option to add fixed population of 10,000 
	gen x=rnormal()
	gen y= 5+1.5*x+2*rnormal() 
	gen random_num=rnormal()
	egen rank =rank(random_num)
	gen treatment=0
	replace treatment=1 if rank>50

	//notes from class March 16 and 23
	
*end


*Capture program drop create
*program define create