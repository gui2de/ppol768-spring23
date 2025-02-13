# Week 10 Assignment 
## Daniel Fang

## Part 1


In this assignment, I made a simulaton that explores bias in parameter estimates when controlling for confounding variables in a regression analysis. The simulation is based on a data generating process that includes a school-level variable, a confounding variable, and several covariates, including a treatment variable. The outcome variable is a score that is a function of the treatment variable, confounding variable, covariates, and random error terms.


As shown in the following table and the line graph generated from the simulation, as samples size increase, the CIs for both the biased and the unbiased model converge to 0.

samplesize |  beta_b~s  beta_u~s  pv~_bias  pv~nbias  sig_bias  sig_un~s
-----------+------------------------------------------------------------
         1 | -6.192041  4.987896  .0246186  .0951727      .926       .73
         2 | -6.332589   4.88729  .0029947  .0385465       .99      .892
         4 | -6.239778  4.964988  .0001757   .006718      .998      .978
         8 | -6.321542  5.002093  1.73e-14  .0001108         1         1
        16 | -6.255576  4.967335         0  4.94e-12         1         1
        32 | -6.331969  4.999689         0  3.15e-33         1         1
        64 | -6.326482  4.985631         0         0         1         1
       128 | -6.330445  4.985039         0         0         1         1
       256 | -6.335084  4.967908         0         0         1         1
-----------+------------------------------------------------------------
     Total | -6.296167  4.971986  .0030733  .0155583  .9904444  .9555556

treat_effect |  beta_b~s  beta_u~s  pv~_bias  pv~nbias  sig_bias  sig_un~s
-------------+------------------------------------------------------------
          .5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
           1 | -6.192041  4.987896  .0246186  .0951727      .926       .73
         1.5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
           2 | -6.192041  4.987896  .0246186  .0951727      .926       .73
         2.5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
           3 | -6.192041  4.987896  .0246186  .0951727      .926       .73
         3.5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
           4 | -6.192041  4.987896  .0246186  .0951727      .926       .73
         4.5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
           5 | -6.192041  4.987896  .0246186  .0951727      .926       .73
-------------+------------------------------------------------------------
       Total | -6.192041  4.987896  .0246186  .0951727      .926       .73



# Part 2

In part two, based on part one, instead of having strata groups contributing to the main effect, I create some portion of the random error term at the strata level (now, they are clusters, rather than strata). Below is the result, as well as the plots indicating the "empirical/exact" CIs against the "analytical" . 



samplesize |     Beta1  CI_le~e1  CI_le~t1   CI_vce1     Beta2  CI_le~e2  CI_le~t2   CI_vce2
-----------+--------------------------------------------------------------------------------
         2 |   1.11456  1.502612  1.579557  1.498017  1.276355  .9091176  .8809287   .904812
         4 |  4.119092  1.273852   1.19087  1.179742  4.227045  .7092126  .5502229  .5473271
         8 |  5.278352  1.041328  1.144358  1.141361   5.12093  .5927213  .6278704  .6412726
        16 |  4.775968  1.033431  1.143934    1.1492  4.524274  .5940044  .6757985   .675341
        32 |  4.999121  1.043287  .9950748  .9804865  5.122715  .5917942  .5527764  .5463527
        64 |  5.833827  .9935349  .8202457   .847175  6.215607  .5568032  .3827679   .402749
       128 |  4.524047  1.044918  1.080444  1.039509  4.367496   .582119  .6074861  .5928711
       256 |  4.903279  .9544541  .9543728  .9893864  4.871056  .5257778  .5648307  .5769139
-----------+--------------------------------------------------------------------------------
     Total |  4.443531  1.110927  1.113607   1.10311  4.465685  .6326938  .6053352  .6109549


![Part 2 Line Graph 1](outputs/Graph1.png)


![Part 2 Line Graph 2](outputs/Graph2.png)

As shown from the visualizations, exact/empirical CIs will converge to the analytical CI as the sample size increases