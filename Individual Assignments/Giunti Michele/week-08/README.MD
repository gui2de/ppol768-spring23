# Part 1: Sampling noise in a fixed population

![Tabstat of The First Simulation](img/table1sim1.png)

![Beta Variation Simulation 1](img/betadeviationpart1.png)

![Variance Difference Simulation 1](img/SEMpart1.png)

![Confidence Interval Difference Simulation 1](img/CIBetapart1.png)

### Comment

We can see that the betas tend to center to the mean as we increase the sample size, and the variance tends to become smaller.

This can also be seen from the change in the standard deviation of the Upper and Lower limits of the Confidence Intervals and the Betas.

# Part 2: Sampling noise in an infinite superpopulation

## 300 Iterations
![Tabstat of the Second Simulation (300)](img/table2sim2a-1.png)

![Deviation of the Beta Coefficient (300)](img/betadeviationpart2-300.png)

![Beta Distribution (300)](img/facetbetapart2-300.png)

![Means Change (300)](img/CIBetapart2-300.png)

## 500 Iterations
![Tabstat of the Second Simulation (500)](img/table2sim2b-1.png)

![Deviation of the Beta Coefficient (500)](img/betadeviationpart2-500.png)

![Beta Distribution 500)](img/facetbetapart2-500.png)

![Means Change (500)](img/CIBetapart2-500.png)

## 800 Iterations
![Tabstat of the Second Simulation (800)](img/table2sim2c-1.png)

![Deviation of the Beta Coefficient (800)](img/betadeviationpart2-800.png)

![Beta Distribution (800)](img/facetbetapart2-800.png)

![Means Change (800)](img/CIBetapart2-800.png)

### Comment

It seems that past the original 10000 sample size, increasing the N does not matter as much, as the betas come to stabilize and assume the same values.

This can be seen also for the Standard Deviation of the Confidence Interval and the Betas.

# Part 2.5: Comparisons

![Beta Comparison](img/BetaDifference.png)

![Variance Comparison](img/VarianceDifference.png)

![CI Comparison](img/CIDifference.png)

### Comment

We see that what we assumed before was true:

The sample size past 10000 does not matter as much, since the betas of our relationship don't vary as much once we go past that number.
