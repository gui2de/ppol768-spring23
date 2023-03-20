# Results - Week 08
Initial code, files, and results for assignment 08.

## Question 1 - Sampling Noise in a Fixed Population
Develop some data generating process for data X’s and for outcome Y.
Write a do-file that creates a fixed population of 10,000 individual observations and generate random X’s for them (use set seed to make sure it will always create the same data set). Save this data set in your week-08 folder.
Write a do-file defining a program that: (a) loads this data; (b) randomly samples a subset whose sample size is an argument to the program; (c) create the Y's from the X's with a true relationship an an error source; (d) performs a regression of Y on one X; and (e) returns the N, beta, SEM, p-value, and confidence intervals into r().
Using the simulate command, run your program 500 times each at sample sizes N = 10, 100, 1,000, and 10,000. Load the resulting data set of 2,000 regression results into Stata.
Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
Fully describe your results in your README.md file, including figures and tables as appropriate.

## Question 2 - Sampling Noise in an Infinite Superpopulation
Write a do-file defining a program that: (a) randomly creates a data set whose sample size is an argument to the program following your DGP from Part 1 including a true relationship an an error source; (b) performs a regression of Y on one X; and (c) returns the N, beta, SEM, p-value, and confidence intervals into r().
Using the simulate command, run your program 500 times each at sample sizes corresponding to the first twenty powers of two (ie, 4, 8, 16 ...); as well as at N = 10, 100, 1,000, 10,000, 100,000, and 1,000,000. Load the resulting data set of 13,000 regression results into Stata.
Create at least one figure and at least one table showing the variation in your beta estimates depending on the sample size, and characterize the size of the SEM and confidence intervals as N gets larger.
Fully describe your results in your README.md file, including figures and tables as appropriate.
In particular, take care to discuss the reasons why you are able to draw a larger sample size than in Part 1, and why the sizes of the SEM and confidence intervals might be different at the powers of ten than in Part 1. Can you visualize Part 1 and Part 2 together meaningfully, and create a comparison table?
Do these results change if you increase or decrease the number of repetitions (from 500)?
