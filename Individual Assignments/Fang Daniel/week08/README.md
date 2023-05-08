# Week08 Assignment
## Daniel Fang

## Part 1:

| Sample size |  SE   | CI (Lower) | CI (Upper) |
|:------------|:-----:|:----------:|:----------:|
| 10          |   0   |     0      |     0      |
| 100         | 0.047 |   0.927    |   1.113    |
| 1000        | 0.026 |   0.928    |   1.031    |
| 10000       | 0.010 |   0.992    |   1.031    |

| Sample size | Beta variance |
|:------------|:-------------:|
| 10          |       0       |
| 100         |   0.0038735   |
| 1000        |   0.0008315   |
| 10000       |   0.0019327   |

Based on my simulation results in part 1, the relationship between sample size and confidence interval (CI) can be expressed as follows: a larger sample size leads to a tighter confidence interval with a smaller margin of error (ME), whereas a smaller sample size leads to a wider confidence interval with a larger margin of error. As the sample size (N) increases, the standard error of the mean (SEM) decreases and the confidence intervals become narrower. This can be observed in the first table, which indicates the change in SEM and confidence intervals with varying sample sizes.

As for the relationship between sample sizes and variance, the second table indicates that with a larger sample size, the variance of estimated beta (estimated parameters) is getting relatively smaller.

## Part 2:

In part two, the program is built first and the data set is created within the program, with the argument setting the number of observations in the data set. This allows for the sample size to be set without any limits. Furthermore, since the randomly distributed variable (x) is created first and then the sample size is set, the distribution of x in the new sample is closer to a random distribution. In contrast, in part one, the sample size was set before the creation of x, which may have resulted in a less random distribution of x in the sample. Due to the difference in the distributions of x in the two parts, the sizes of the SEM and confidence intervals may differ by orders of magnitude.

The following table shows the SEM, confidence intervals and the beta variance for varying sample sizes in part two:

| Sample size |   SE   | CI (Lower) | CI (Upper) |
|:------------|:------:|:----------:|:----------:|
| 10          | 0.395  |   0.802    |   2.622    |
| 100         | 0.060  |   0.926    |   1.164    |
| 1000        | 0.014  |   0.968    |   1.023    |
| 10000       | 0.002  |   0.994    |   1.002    |
| 100000      | 0.0002 |   0.999    |   1.000    |
| 1000000     | 0.0001 |   1.000    |   1.000    |

| Sample size | Beta variance |
|:------------|:-------------:|
| 10          |   0.1263214   |
| 100         |   0.0035254   |
| 1000        |   0.0001876   |
| 10000       |   3.73e-06    |
| 100000      |   3.65e-08    |
| 1000000     |   6.65e-08    |
| 10000000    |   8.26e-10    |

### Histograms
To further demonstrate the relationships described above, the user can also refer to the histogram created in the Stata do file.