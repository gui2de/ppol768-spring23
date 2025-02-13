# Week 09 Assignment 
## Daniel Fang

## Part 1

In this assignment, I made a simulaton that explores bias in parameter estimates when controlling for confounding variables in a regression analysis. The simulation is based on a data generating process that includes a school-level variable, a confounding variable, and several covariates, including a treatment variable. The outcome variable is a score that is a function of the treatment variable, confounding variable, covariates, and random error terms.

The simulation saves the results in a dta file named simulation_results.dta in the working directory. The file contains the following columns:

sample_size: the sample size used in the simulation.
beta1: the estimated treatment effect when the model includes only the treatment variable.
beta2: the estimated treatment effect when the model includes the treatment variable and additional covariates (urban, years of faculty experience, mother's education).
beta3: the estimated treatment effect when the model includes the treatment variable, additional covariates, and a confounding variable (c).
beta4: the estimated treatment effect when the model includes the treatment variable, additional covariates, and school fixed effects.
beta5: the estimated treatment effect when the model includes the treatment variable, additional covariates, and school and classroom fixed effects.

### Findings

As shown in the following table and the line graph generated from the simulation, as samples size increase, the beta would converge to some value in all models. A larger sample size will result in a smaller beta variance. 

|samplesize |   beta1  |   beta2  |   beta3  |   beta4  |   beta5  |
|:----------|:---------|:---------|:---------|:---------|:---------|
|         2 | -4.690646|  5.515604|  5.515536|  3.609921|  3.647691|
|         4 | -4.258713|  5.836529|  5.862241|  6.136644|  6.257674|
|         8 | -7.188596|  5.379711|  4.256903|  5.366421|  4.159163|
|        16 | -5.990525|  4.783673|  4.392635|  4.585372|  4.132096|
|        32 | -6.796387|  5.188379|  5.362726|  5.207388|  5.397692|
|        64 | -6.433371|  4.344003|  4.924297|  4.348243|  4.926929|
|       128 | -6.519008|  4.867979|  5.148422|  4.921265|  5.205618|
|       256 | -6.698785|  4.879347|  4.750026|  4.871841|  4.742855|


![Part1 Line Graph](outputs/part1.png)


# Part 2

In part two, based on part one, we add a collider, which, according to definition, is a variable that is affected by both treatment and outcome.


|samplesize |     beta1 |    beta2 |    beta3  |  beta4   |   beta5  |
|:--------- |:----------|:---------|:----------|:---------|:---------|
|         2 | -7.004296 | 2.799126 |-2.954797  |2.79919   |-.1647684 |
|         4 | -6.577161 | 3.616373 |-2.956766  |3.628645  |4.054646  |
|         8 | -9.923226 | 1.725568 |-2.878554  |.7333176  |.9852172  |
|        16 | -8.143732 | 2.128747 |-2.880272  |1.676882  |1.431225  |
|        32 | -9.359378 | 2.43473  |-2.89901   |2.612908  |2.653395  |
|        64 | -9.010195 | 1.879616 |-2.923849  |2.463463  |2.466607  |
|       128 | -8.916148 | 2.414814 |-2.922263  |2.734034  |2.78197   |
|       256 | -9.282635 | 2.236676 |-2.907643  |2.096793  |2.092279  |

![Part2 Line Graph](outputs/part2.png)

As shown from the visualizationsTherefore, models that include colliders may produce biased estimates. Including the collider in the regression, or including both channel and collider in the regression, will bias the treatment coefficient estimate.