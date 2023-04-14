
*using stata commands for power calculations

*individual level randomization
*sample size needed to detect MDE of 50 points when mean is 500 and sd is 100 and power is 80%
power twomeans 500 550, sd(100)  power(0.8)

power twomeans 0 0.5  //this should give us exactly the same result


*you can generate a table as well if you want to know the sample size at different MDEs
power twomeans 0 0.1(0.05)0.8, table  

 

*cluster design 
power twomeans 0,  sd(1) k1(100) k2(100) m(10) m2(10) power(0.8) graph


forvalues i=5(5)40 {
power twomeans 0,  sd(1) k1(100) k2(100) m1(`i') m2(`i') power(0.8) table

}
