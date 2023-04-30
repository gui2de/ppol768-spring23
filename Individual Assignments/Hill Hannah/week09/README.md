# Part 1: De-biasing a parameter estimate using controls

Below, we see that the Beta estimate for Model 1 ("Beta1") outlined in red stands out from the rest of the models' estimates. Model 1, a bivariate model, is downwardly biased. The other models (2-5) which include multivariate controls and fixed effects, concentrate around 0. One exception is Beta4, which has a higher peak than the other models with an upwards bias.

### Graph
![Graph](https://github.com/gui2de/ppol768-spring23/blob/6d75b8b9b691baaf20b5d94604c468fa89cbb93c/Individual%20Assignments/Hill%20Hannah/week09/outputs/use_wk9_q1.png)


### Descriptive Statistics

The table below shows the descriptive statistics for each of the models. Again, we see that Model 1, the bivariate regression, has substantially different values than the rest of the models that incorporate more variables and fixed effects. 

| Stat | Beta1 | Beta2 | Beta3 | Beta4 | Beta5|
| --- | ----- | ------ | ----- | ------ | ---- |
| Mean | -11.85955 | .0637742 | .0933259 | .0017102 | .0428582 |
| SD | 3.47035 | 3.161506 | 3.029504 | 3.190822 | 2.93994 |
| Minimum |  -27.84032 | -45.26399 | -45.26399 | -53.10278 | -53.10278 |
| Maximum | 10.35675 | 17.53874 | 17.53874 | 15.53005 | 15.42391 |

# Part 2: Biasing a parameter estimate using controls
Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable.
This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like expand or merge to add them to an individual-level data set.


When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type h fvvarlist for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a program like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
Fully describe your results in your README.md file, including figures and tables as appropriate.
