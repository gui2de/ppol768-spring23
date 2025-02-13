# Week 9 - Keegan Brown 


For context on the evaluation below, the following DGP was used:

Activity = school + -3*bmi + 2*urban + 5*athlete + 3*treatment_status
Urban is a binary variable that can only apply to the first school 
athlete is a binary variable that can only exist in urban schools 
bmi is a continous variable with a mean of 25 and SD of 7, with a -5 weight for individuals who are marked as athletes

And treatment status is a fucntion of school strata as shown below: 

treatment_status = (rnormal()+(1/school))>0


As a confounding covariate, urban impacts both the outcome and the liklihood of treatment because urban is only seen at school 1, and has a positive effect on income. 

The strata (school) are different sizes for observations by virtue of the treatement status code (listed above). It is also a function of activity, impacting the outcome. 

We can see by the graph below that as the number of observations increases, the variance decreases. We can also see that the model gets closer the "real" treatment effect beta as the sample size increases. 

![Table 1](output/part1_box.png)



The second simulation shows an identical trend. The variance decreases and the model gets closer to predicting the true value of the treatment effect. Of note, the regression accounting for the collider variable (restinghr) shows reduced variance in estimating the relationship between treatment status and activity. It is also far closer to predicting the true treatment effect across all sample sizes. The channel based model (model 4) shows more bias, but a decresed variance. 

![Table 2](output/part2_box.png)