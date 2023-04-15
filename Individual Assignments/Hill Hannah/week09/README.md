# Part 1: De-biasing a parameter estimate using controls


Based on the output of the figures below, I am sure that I was unable to correctly de-bias the parameter estimate as there is really not much of a difference between all of them.

### Figures
![Model_1](https://github.com/gui2de/ppol768-spring23/blob/1dee10f767a713e65773019c20fc7cd42348549e/Individual%20Assignments/Hill%20Hannah/week09/outputs/wk09_model1.png)
![Model_2](https://github.com/gui2de/ppol768-spring23/blob/1dee10f767a713e65773019c20fc7cd42348549e/Individual%20Assignments/Hill%20Hannah/week09/outputs/wk09_model2.png)
![Model_3](https://github.com/gui2de/ppol768-spring23/blob/1dee10f767a713e65773019c20fc7cd42348549e/Individual%20Assignments/Hill%20Hannah/week09/outputs/wk09_model3.png)
![Model_4](https://github.com/gui2de/ppol768-spring23/blob/1dee10f767a713e65773019c20fc7cd42348549e/Individual%20Assignments/Hill%20Hannah/week09/outputs/wk09_model4.png)
![Model_5](https://github.com/gui2de/ppol768-spring23/blob/1dee10f767a713e65773019c20fc7cd42348549e/Individual%20Assignments/Hill%20Hannah/week09/outputs/wk09_model5.png)

### Descriptive Statistics

The table below shows the descriptive statistics for each of the models. There is not much difference between the different biased models, however, there is a significant difference between the base bivariate regression and the other four regressions.

| Stat | Bivariate | Unbiased | First Bias | Second Bias | Third Bias|
| --- | ----- | ------ | ----- | ------ | ---- |
| Mean | 6.951256 | 3.025204 | 3.136162 | 3.023204 | 3.135963 |
| SD | .9179278 | .4301396 | .4589228 | .41324666 | .4432821 |
| SE | .020522 | .0096182 | .0102618 | .0092405 | .0099121 |
| Minimum | 4.302641 | 2.037162 | 2.102715 | 2.016371 | 2.090404 |
| Maximum | 9.630885 | 4.133864 | 4.237675 | 4.13929 | 4.313892 |

# Part 2: Biasing a parameter estimate using controls
Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable.
This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.


When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
Fully describe your results in your README.md file, including figures and tables as appropriate.
