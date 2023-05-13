#Assignment 10

#Elena Spielmann

# Part 1

Based on our study, we are testing the effect of a digital nudge on physical activity levels of the students across multiple universities within the state of NY (SUNY and CUNY respectively). These universities are located in urban, suburban and rural areas of the state. For the sake of simplicity, we will just be looking at urban and rural areas. We are also looking at different majors students have. We will also investigate if students parents played sports growing up and at what level and what the quality of fitness centers are available on respective campuses.

Below are the unbiased and biased mathematical models:

Biased Model: Score = beta0 + beta1 * treat + u_i + u_ij + e_ijk
Unbiased Model: Score = beta0 + beta1 * treat + beta2 * urban + beta3 * campus_gym + beta4 * par_sport + u_i + u_ij + e_ijk

The three random errors represent the random errors of the three strata levels of the university, major, and students, respectively.

Summary statistics: Mean
Group variable: samplesize

samplesize |  beta_b~s  beta_u~s  pv~_bias  pv~nbias  sig_bias  sig_un~s
-----------+------------------------------------------------------------
         1 | -5.944516   5.24843  .0246101  .0716641       .92      .798
         2 | -6.243408  4.949035    .00654  .0378067      .988      .896
         4 | -6.378697   4.96171   .000013   .010296         1      .978
         8 | -6.351979  4.922304  1.47e-16  3.26e-06         1         1
        16 | -6.261646  5.041893         0  2.26e-15         1         1
        32 | -6.319302  4.953678         0  1.20e-33         1         1
        64 | -6.330768  5.021444         0         0         1         1
       128 | -6.323818  5.009031         0         0         1         1
       256 | -6.340385  4.990581         0         0         1         1
-----------+------------------------------------------------------------
     Total | -6.277169  5.010901  .0034296  .0132169  .9897778  .9635556

The table above shows the power of a regression model at different "treat_effect" values, with and without an unbiased control group. The "minimum sample size" required to achieve 80% power for both cases is 2. However, since stratification is used in the model, the actual sample size (obs) is the product of the number of strata (10) and the number of observations per stratum, which varies from 15 to 27.

Therefore, the actual sample size ranges from 2 * 10 * 15 = 300 to 2 * 10 * 27 = 540. This means that in order to achieve 80% power in the actual regression analysis, a minimum sample size of 300 to 540 is needed, depending on the number of observations per stratum. Since this range is somewhat wide, we can approximate it by taking the lower end, which is 300, as the minimum sample size needed to achieve the target power.


Summary statistics: Mean
Group variable: treat_effect

treat_effect |  beta_b~s  beta_u~s  pv~_bias  pv~nbias  sig_bias  sig_un~s
-------------+------------------------------------------------------------
          .5 | -10.38152  .8114295  .0005804  .2913038      .984       .34
           1 | -9.888516   1.30443  .0014913  .2751365      .976      .378
         1.5 | -9.395516   1.79743  .0033174   .250965      .974      .414
           2 | -8.902516   2.29043  .0060249  .2203466       .97      .476
         2.5 | -8.409516   2.78343  .0086378  .1882734      .966       .53
           3 | -7.916516   3.27643  .0111793  .1590019      .962      .572
         3.5 | -7.423516   3.76943  .0123847  .1349668      .954      .616
           4 | -6.930516   4.26243  .0144321  .1102932      .944      .674
         4.5 | -6.437516   4.75543  .0180258  .0883091      .942      .752
           5 | -5.944516   5.24843  .0246101  .0716641       .92      .798
-------------+------------------------------------------------------------
       Total | -8.163016   3.02993  .0100684   .179026     .9592      .555


As can be seen from the figure above, when the number of fixed samples is 2, the "minimum detectable effect size" we found is 4.5 (its value should be between 4 and 4.5), that is, at this size, no matter whether the unbiased control is used or not , the regression model can obtain 80% power

The "minimum detectable effect size" refers to the smallest difference between the treatment and control groups that can be detected with a certain level of statistical power. In this case, the target power is 80%, and the minimum detectable effect size is determined by the sample size and other parameters used in the regression model.

From the figure above, it can be seen that when the number of fixed samples is 2, the minimum detectable effect size is 4.5, which means that the regression model can detect a treatment effect of at least 4.5 units with 80% power. This result is obtained by considering the power of the regression model under different treatment effect sizes and using a certain significance level (e.g., 5%). This result holds regardless of whether the unbiased control is used or not.

This information can be useful for planning future studies, as it provides guidance on the minimum sample size and effect size required to achieve a certain level of statistical power. In our case, the literature confirms a sample size between 300-450, so this is a promising result.

# Part 2

Below are the data generating processes for the second part of the assignment.

DGP1: Score = beta0 + beta1 * treat + beta2 * urban + u_i + u_ij

DGP2 (DGP1 without indvidual random error): Score = beta0 + beta1 * treat + beta2 * urban + u_i

u_i is the random error at the cluster level, and u_ij is the random error at the individual level

Summary statistics: Mean
Group variable: samplesize

samplesize |     Beta1  CI_le~e1  CI_le~t1   CI_vce1     Beta2  CI_le~e2  CI_le~t2   CI_vce2
-----------+--------------------------------------------------------------------------------
         2 |  1.853952  1.326569  1.337148  1.328514  1.285295  .6511134  .6419786  .6529307
         4 |  1.447561  1.163022  1.140625  1.109735  1.113066  .6523334  .6004215  .6271769
         8 |  4.677709  1.121514  1.071924  1.038697   4.61743  .6259227  .4953837  .4691973
        16 |  5.164856  1.044482  1.128887  1.105498  5.128615  .5713358  .6687572  .6581795
        32 |  5.513799  .9959794   .904335  .9066045  5.104743  .5353583  .4874261  .5038543
        64 |   5.05094  1.036037  1.015718  1.009118  4.681059  .5733855  .6840422  .6670131
       128 |  4.696642  .9955073  1.000518  .9679891  4.868092  .5424771  .5086278  .5117897
       256 |  4.613169  .9972789  .9754261  .9652206  4.135818  .5461698  .4228923  .4236104
-----------+--------------------------------------------------------------------------------
     Total |  4.127329  1.085049  1.071823  1.053922  3.866765   .587262  .5636912   .564219

![CI vs SS 1](part2agraph.png)
![CI vs SS 2](part2bgraph.png)

Based off the above table and two figures, we can draw the following conclusions which answer the questions in part 2.

1. As the number of samples increases, the estimated or analytical confidence interval (CI) will gradually converge to the empirical or exact CI. This is because with more samples, the estimate of the population parameter becomes more precise, and the standard error of the estimate decreases. As the standard error decreases, the width of the CI also decreases, and the CI becomes more accurate. The empirical or exact CI is the CI that would be obtained if the entire population were sampled, and is considered the "gold standard" for comparison with estimated or analytical CIs.

2. If the random error term is only determined at the cluster level (such as in a clustered or multilevel design), then the convergence of the estimated or analytical CI to the empirical or exact CI will decrease as the sample size increases. This is because in a clustered design, the within-cluster correlation increases the standard error of the estimate, and makes the CI wider than it would be if there were no clustering. As the sample size increases, the effect of the within-cluster correlation decreases, and the estimated or analytical CI will become more accurate. However, because the within-cluster correlation has a persistent effect on the CI, the convergence to the empirical or exact CI will be slower than in a non-clustered design.

3. The vce() option in the regress command in Stata can help "correct" the analytical confidence interval. The VCE stands for variance-covariance estimator, and the option allows the user to specify a different method for estimating the standard errors and covariances of the regression coefficients than the default method. Using a more appropriate VCE can lead to more accurate standard errors and CIs. From the figure, it can be seen that using the vce() option leads to estimated or analytical CIs that are closer to the empirical or exact CIs, especially when the sample size is small. This is because the vce() option takes into account the within-group correlation, which can have a larger impact on the CI when the sample size is small.
