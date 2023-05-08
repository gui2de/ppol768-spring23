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

The following graphs are created using the base regression: success_rate treat diversity. In these graphs, the exact confidence interval stays consistent between **1-3**. In the last graph with the largest sample size of 20,400, the analytical confidence intervals get slightly smaller than previous graphs' analytical CIs. Overall, the analytical confidence intervals are smaller than exact confidence intervals in each sample size.

### Graph 1: Base Regression
![Graph_1](https://github.com/gui2de/ppol768-spring23/blob/172090829944ea68a170383e0d19179b747a9e64/Individual%20Assignments/Hill%20Hannah/week-10/outputs/q2p1.png)


### Graph 2: Clustered at the college level
The regression used to create the graphs in Graph 1 was modified to include vce(cluster college) in order to incorporate clustered random errors. Here, we see the opposite finding: analytical CIs become much larger than the exact CIs in each sample size. After clustering, the exact CIs stayed consistent between **1 and 3**.

![Graph_2](https://github.com/gui2de/ppol768-spring23/blob/172090829944ea68a170383e0d19179b747a9e64/Individual%20Assignments/Hill%20Hannah/week-10/outputs/q2p2.png)
