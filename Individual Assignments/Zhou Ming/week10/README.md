Week10 Ming Zhou

# Part one

## 1 The power of the regression models

Tables below show the power of both biased model and unbiased model.

|     Model      | Sample size |  Power   |
|:--------------:|:-----------:|:--------:|
| unbiased model |     100     | .0666667 |
| unbiased model |     600     | .3033333 |
| unbiased model |    1100     | .5333333 |
| unbiased model |    1600     | .8266667 |
|  biased model  |     100     | .9966667 |
|  biased model  |     600     |    1     |
|  biased model  |    1100     |    1     |
|  biased model  |    1600     |    1     |

# Part two

Table below show the empirical/exact CIs and the analytical ones in an unbiased regression model.The width of the empirical/exact CIs are smaller than analytical ones. And with sample size increasing, the CIs both converge to 0.

| Sample Size | Analytical CIs | Empirical/Exact CIs |
|:-----------:|:--------------:|:-------------------:|
|     100     |    2.590355    |      2.167409       |
|     600     |    1.036603    |       .86953        |
|    1100     |    .7623897    |      .6396518       |
|    1600     |    .6316155    |       .529974       |

Table below show the empirical/exact CIs and the analytical ones in an unbiased regression model with random error terms are only determined at the cluster level. The width of the empirical/exact CIs are smaller than analytical ones. But the differences between analytical ones and empirical ones are smaller. And with sample size increasing, the CIs both converge to 0.

| Sample Size | Analytical CIs | Empirical/Exact CIs |
|:-----------:|:--------------:|:-------------------:|
|     100     |    .832991     |      .6969825       |
|     600     |    .3342147    |      .2803479       |
|    1100     |    .2461906    |      .2065561       |
|    1600     |    .2041379    |      .1712875       |

We can get the "analytical" confidence intervals to be correct using the vce() option in regress.

***reg emission1 treatment industrial activity, vce(cluster)***
