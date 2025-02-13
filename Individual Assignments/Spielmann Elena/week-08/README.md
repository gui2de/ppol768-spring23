
# Week 8 Assignment

#Elena Spielmann

## Part 1:


![Graph of Betas by Sample Size](img/beta_graph_1.png)


These graphs depict the relationship between the accuracy of beta estimates and the sample size. With a sample size of 10, the estimates for beta are more variable, have a higher standard error, and larger confidence intervals compared to a sample size of 10,000. Additionally, the graph shows how the estimates of beta converge to the real value of 1.5 as the sample size increases. The estimate is closest to the real value when the sample size is 10,000, out of all the other sample sizes.

![Graph of Betas Against Real Value](img/beta_ss_graph.png)

As the sample size increases and the estimates for betas become more accurate, we also observe a reduction in the standard error and the confidence interval. This is because the accuracy of the estimates improves with larger sample sizes. This is demonstrated in the table below, where the standard error and confidence interval decrease as the sample size increases.


## Sampling noise in a fixed population

| Sample Size |   Beta   |    SE     |
|:-----------:|:-------:|:--------:|
|      10     | 1.532619| 0.6957142|
|     100     | 1.498962| 0.1997243|
|    1000     | 1.504217| 0.0629871|
|   10000     |  1.501159| 0.0197896|

## Part 2:


Similarly, we can see the correlation between the accuracy of the betas and sample size in this section. As the sample size increases, the precision of the beta estimate also increases. This relationship is shown in the table below.

## Sampling noise in an infinite superpopulation

| samplesize |   beta   |    se     |
|:----------:|:--------:|:--------:|
|     10     | 1.503429 | 0.6971501|
|     100    | 1.505169 | 0.2032561|
|     1000   | 1.498118 | 0.0632277|
|    10000   | 1.497663 | 0.0200122|
|   100000   | 1.500172 | 0.0063257|
|  1000000   | 1.500107 | 0.0020001|



##Comparison of the two processes with 500 repetitions:

| Sample size_Super Population |   Beta1   |    SE1     | Sample size_Fixed Population |   Beta2   |    SE2     |
|:----------------------------:|:---------:|:----------:|:---------------------------:|:---------:|:----------:|
|              10              |  1.502522 |  0.6978596 |               10            | 1.533906  | 0.6981993  |
|             100              |  1.507246 |  0.2015349 |               100           | 1.494756  | 0.2012687  |
|             1000             |  1.500221 |  0.0631075 |               1000          | 1.505837  | 0.0633429  |
|            10000             |  1.496702 |  0.0199948 |              10000          | 1.501987  | 0.0199217  |
|            100000            |  1.500236 | 0.0063209  |               -             |    -      |     -      |
|           1000000            |  1.500099 |     0.002  |               -             |    -      |     -      |


The above table presents a comparison between the simulation results using a super population and a fixed population. The estimated beta for the same sample size is different for both population types. This discrepancy arises due to the fact that the super population takes into account any potential population that could exist. As a result, the estimates for beta are even more precise than those obtained using a fixed population.  
