# Results - Week 08
Finalized code, files, and figures for Assignment 08.

## Question 1 - Sampling Noise in a Fixed Population

The figure below illustrates that as the sample size increases in greater magnitude, the histogram concentrates around the mean and becomes much more narrow. Essentially, this means that as sample sizes increase, a random sample from the population is more likely to be in proximity to the true mean.

![Beta_Graph](https://github.com/gui2de/ppol768-spring23/blob/e419748e7b46dc0e77f06e0e5cffd11aefd66f6b/Individual%20Assignments/Hill%20Hannah/week-08/outputs/wk08_q1beta.png)

In the table below, the standard error decreases exponentially as the sample size increases. The lower bound and upper bound values represent the 25th & 75th percentiles of the data. These values also decrease exponentialy as the sample size increases indicating a more narrow distribution.


### Table of Beta Coefficients:
| Sample Size | Beta Coefficient | SE | Lower Bound | Upper Bound|
|------------|-------------|----|--------|-------|
| 10 | .9180499 | .2413039 | 1.046967 | 1.04694 |
| 100 | .970479 | .0199844 | .3054613 | .3026856 |
| 1000 | .0929588 | .0022879 | .092936 |.0917521 |
| 10000 | .032614 | .0002057 | .0325673 | .032985 |
| **Total** | .1441394 | .2104117 | .6252996 | .6047957 |

## Question 2 - Sampling Noise in an Infinite Superpopulation

The program I built in Stata creates random samples from infinite populations. In the first question, the population was fixed to 10,000 at the maximum. Here in the figure below, we see that the distribution also becomes much more narrow.

![Beta_Graph2](https://github.com/gui2de/ppol768-spring23/blob/50a664800385a51f76628c60cd5cb0a0a72f7f61/Individual%20Assignments/Hill%20Hannah/week-08/outputs/wk08_q2beta.png)

In the table below, the standard error again decreases substantially as the sample size increases exponentially. The values for the 25th and 75th percentile again shrink as the sample size continues to increase.

### Table of Beta Coefficients:
| Sample Size | Beta Coefficient | SE | Lower Bound | Upper Bound|
|------------|-------------|----|--------|-------|
| 4 | 1.697616 | .8773211 | 3.901797 | 4.077197 |
| 8 | 1.079292 | .3071342 | 1.305808 | 1.265725 |
| 10 | .8897903 | .2361932 | .9611148 | 1.04795 |
| 16 | .6927022 | .1499769 | .7945453 | .8297659 |
| 32 | .518067 | .0709505 | .5295215 | .5390885 |
| 64 | .3648855 | .0313197 | .3656524 | .3775632 |
| 100 | .2983231 | .0211691 | .3029103 | .3064287 |
| 128 | .222664 | .0176853 | .2351122 | .222987 |
| 256 | .1747535 | .0083893 | .1792725 | .1809037 |
| 512 | .1262079 | .0040964 | .1275072 | .127105 |
| 1000 | .0946949 | .0021097 | .094779 | .0941375 |
| 1024 | .0907416 | .0018429 | .0897542 | .0889752 |
| 2048 | .0722548 | .0010493 | .0729389 | .0720545 |
| 4096 | .0446908 | .0004742 | .0444417 | .0444161 |
| 8192 | .0327343 | .0002635 | .032357 | .032963 |
| 10000 | .032614 | .002057 | .0325673 | .032985 |
| 16384 | .0232844 | .0001324 | .0232622 | .0231792 |
| 32768 | .0145462 | .0000682 | .0145235 | .0145676 |
| 65536 | .0115606 | .0000328 | .0115695 | .0115736 |
| 131072  | .0076668 | .0000156 | .0076599 | .007679 |
| 262144 | .0061269 | 8.56e-06 | .0061315 | .0061263 |
| 524288 | .0041362 | 3.63e-06 | .0041419 | .0041351 |
| 1048576 | .0029618 | 1.95e-06 | .0029614 | .0029622 |
| 2097152 | .0019396 | 9.24e-07 | .0019407 | .0019385 |
| **Total** | .0567152 | .226919 | .4418451 | .4333361 |

### Comparison Table : Fixed vs. Infinite Superpopulation

The table below compares the data on distribution between the fixed population (10,000) and the infinite superpopulation. With the understanding that as the sample size increases and the random samples drawn begin to center more around the mean, I expepcted the IQR to considerably smaller for the simulations running a high amount of iterations and vice versa for simulations with a lower number of iterations.
| Population | Sample Size | Beta Coefficient | SE | Lower Bound | Upper Bound|
| --------- |------------|-------------|----|--------|-------|
| Fixed | 10 | .9180499 | .2413039 | 1.046967 | 1.04694 |
| Infinite | 10 | .8897903 | .2361932 | .9611148 | 1.04795 |
| Fixed | 100 | .970479 | .0199844 | .3054613 | .3026856 |
| Infinite | 100 | .2983231 | .0211691 | .3029103 | .3064287 |
| Fixed | 1000 | .0929588 | .0022879 | .092936 |.0917521 |
| Infinite | 1000 | .0946949 | .0021097 | .094779 | .0941375 |
| Fixed | 10000 | .032614 | .0002057 | .0325673 | .032985 |
| Infinite | 10000 | .032614 | .002057 | .0325673 | .032985 |
