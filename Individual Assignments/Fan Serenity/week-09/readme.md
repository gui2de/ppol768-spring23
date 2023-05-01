# Week 09: Multi-level Simulation Assignment

PPOL 768: Serenity Fan 
Last Updated: May 1st, 2023 

## Part 1: De-biasing a Parameter using Controls 

Applying the model to the policy problem of our group project, manual scavenging in India, I define a multi-level model with variables and levels i, j, k such that:  

* Y = Income 
* X1 = Treatment: Number of days spent attending employment training, mentorship, and services  
* X2 = Years of education (continuous covariate #1)
* X3 = Years to date spent working in manual scavenging field (continuous covariate #2)
* X4 = Door-to-door transit time to city centre (continuous covariate #2)
* X5 = Gender (indicator variable)

* i = District level (75 districts in UP)
* j = Village-level (panchiyat) or municipality 
* k = Household-level 

I run 5 different regression models, where: 
* Model 1: Base binary, Y and treatment 
* Model 2: Add village indicators 
* Model 3: Add confounder: years worked in manual scavenging, affecting both the outcome and the likelihood of receiving treatment 
* Model 4: Add covariate (door-to-door transit time) that affects outcome but not treatment
* Model 5: Add covariate (years of education) that also affects outcome but not treatment 

The graphs below show the distribution of the betas and their biasedness/convergence, for each of the five models above, respectively:

![part1_beta1_hist](part1_reg_1_over_N)
![part1_box1](part1_boxplot_1)

![part1_beta2_hist](part1_reg_2_over_N)
![part1_box2](part1_boxplot_2)

![part1_beta3_hist](part1_reg_3_over_N)
![part1_box3](part1_boxplot_3)

![part1_beta4_hist](part1_reg_4_over_N)
![part1_box4](part1_boxplot_4)

![part1_beta5_hist](part1_reg_5_over_N)
![part1_box5](part1_boxplot_5)


## Part 2: Biasing a Parameter using Controls 

