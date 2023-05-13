*Week 8 Data Generating Process
/*Develop some data generating process for data X's and for outcome Y.
Write a do-file that creates a fixed population of 10,000 individual observations and generate random X's for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.*/
clear 

	*set seed 65465 // use set seed to make sure it will always create the 	same data set
	*syntax, samplesize(integer)
	set obs 10000 // one option to add fixed population of 10,000 
	gen x=rnormal()
	*gen random_num=rnormal()
	*egen rank =rank(random_num)
	*gen treatment=0
	*replace treatment=1 if rank>50
	
*end


*Capture program drop create
*program define create