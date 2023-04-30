Week 10 - Keegan Brown

For reference, the DGP for the first graph is as follows: 

School is a uniform variable with values 1-3
urban is a binary variable that only applies to school 1 
student athlete is a binary variable that only applies to 10% of the urban school. This is one of my confounding variables. 
bmi is normally distributed continuous variable with a mean of 25 and a SD of 7, with a -5 hard coded in for all student athletes.
Gym access is a binary variable that is uniformly distributed as a function of treatment status. If treatment status =1 it is possible for gym access to equal 1. Gym access will impact outcome for activity but will not impact the treatment. 

treatment status is dictated by the following formula (rnormal()+(1/school))>0. This means that school impacts the treatment but not the outcome. 

gen activity = 1.25*treatment_status + 2*urban + 5*student_athlete + 3*gym_access + -.5*bmi^2+ .1*scholarship + rnormal(0,1) 

![Figure 1](outputs/part1_line.png")

As we can see from the graph above, as sample size increases the MDE rapidly decreases. This aligns with the underlying mathematical concepts, where increased sample size decreases the variance and allows for our confidence intervals to be narrowed. With narrowed CI's the potentaial for type 2 errors decrease. 

When we switch to evaluating the MDE for a sample size of 1500, we can see that the most precise model is the one with all variables accounted for. The models with the covariates #3, #4, require more effect to be detected. This aligns with our expectation that a covariate would introduce some bias and increase variance. See graph below. 

![Figure 2](outputs/part1_bar.png")


![Figure 3](outputs/part2_A.png")


![Figure 4](outputs/part2_B.png")



I cannot get the charts above to appear correctly, but as clusters appear the sample size required to get the same MDE increases. This is because clusters have some group similarity that need to be accounted for. This is typically accounted for with an Intra-cluster correlation coefficent. 
