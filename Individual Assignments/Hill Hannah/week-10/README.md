# Assignment for Week 10
This week's assignment builds off of last week's assignment with same variables and similar program structure.




## Part 1: Calculating required sample sizes and minimum detectable effects
Table 1 illustrates, by model, increasing sample size corresponding to increasing significant power values. In Model 1, the bivariate relationship requires a much smaller sample size than the other two models that incorporate covariates and a confounding variable. The minimum required sample size for Model 1 is n = 594 that renders a power of 8.14 while Model 2's minimum required sample size is exponentially higher at n = 10,197 that renders a power of .80. Lastly, Model 3 (which contains the confounding variable) requires a minimum sample size of n = 1,287 that renders a power of .832.


### Table 1: Calculating Required Sample Sizes
| Sample Size | Model | Significant Power |
|:-----:|:------:|:------:|
|198	|1	|.394|
|297	|1	|.56|
|396	|1	|.662|
|495	|1	|.75|
|**(594)**	|**(1)**	|**(.814)**|
|693	|1	|.854|
|792	|1	|.872|
|891	|1	|.902|
|990	|1	|.9|
|**(10197)**|	**(2)**	|**(.8)**|
|10296|	2	|.798|
|10395|	2	|.804|
|10494|	2	|.828|
|10593|	2	|.814|
|990	|3	|.76|
|1089	|3	|.752|
|1188	|3	|.788|
|**(1287)**	|**(3)**	|**(.832)**|
|1386	|3	|.806|
|1485	|3	|.842|



### Table 2: Finding the Minimum Detectable Effect Size
Below, Table 2 illustrates minimum detectable size of effect for each model's treatment. In Model 1, the minimum detectable effect size is 27 corresponding to a power of .808. As the models increase in complexity and incorporate additional covariates and a confounding variable, the size of the minimum detectable effect size also increases. Model 2 sees a treatment effect size of 30 while Model 3 sees an effect size of 31.


| Size of Treatment Effect| Model | Significant Power |
|:-----:|:------:|:------:|
|25 |	1	|.72 |
|26	|1	|.738|
|**(27)**	|**(1)**	|**(.808)**|
|28	|1	|.804|
|29	|1	|.834|
|30	|1	|.842|
|28	|2	|.75|
|29	|2	|.762|
|**(30)**	|**(2)**	|**(.8)**|
|31	|2	|.82|
|32	|2	|.81|
|28	|3	|.748|
|29	|3	|.778|
|30	|3	|.792|
|**(31)**	|**(3)**	|**(.818)**|
|32	|3	|.792|


## Part 2: Calculating power for DGPs with clustered random errors

1. Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Use a moderately large number of clusters, and also assign treatment at the cluster level.
3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.
4. Calculate "exact" 95% confidence interval estimates using the betas you can use the `collapse` or `mean` command for this, or use something like `lpolyci` to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.
5. Create another DGP in which the random error terms are _only_ determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?
6. Can you get the "analytical" confidence intervals to be correct using the `vce()` option in `regress`?
7. Fully describe your results in your `README.md` file, including figures and tables as appropriate.
