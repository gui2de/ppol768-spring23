# Part One

A larger sample size will result in a tighter confidence interval with a smaller margin of error. A smaller sample size will result in a wider confidence interval with a larger margin of error. As N gets larger, the size of SEM will decrease and confidence intervals will become tighter. Table below indicates the change in se and confidence intervals by sample size.

| Sample size |  SE   | CI (Lower) | CI (Upper) |
|:------------|:-----:|:----------:|:----------:|
| 10          |   0   |     0      |     0      |
| 100         | 0.047 |   0.927    |   1.113    |
| 1000        | 0.026 |   0.928    |   1.031    |
| 10000       | 0.010 |   0.992    |   1.031    |

Table below also indicates that with a larger sample size, the variance of estimated beta (estimated parameters) is getting relatively smaller.

| Sample size | Beta variance |
|:------------|:-------------:|
| 10          |       0       |
| 100         |   0.0038735   |
| 1000        |   0.0008315   |
| 10000       |   0.0019327   |

# Part Two

In part one, we firstly create the data set with one random distributed variable and then build the program using observations randomly picked in that data set. In this case, we can only set the sample size which is less than or equal to the number of observations (which is 10000 in this data set) in the original data.

But in part two, we build the program first and create data set in the program with the argument setting the number of observations in the data set. By creating data in program, we are able to set the size of sample with no limits.

Also because in part one we set the random distributed variable (x) first and then set the sample size, the distribution of x in the new sample may not be perfectly randomly distributed. But in part two, we set the number of observations first and then create the randomly distributed variable (x), making the distribution of x in the sample closer to random distribution. Because of the difference in the distributions of x in two parts, the sizes of the SEM and confidence intervals might be difference at the powers of ten than in two parts.

Table below shows the se and confidence intervals in part two.

| Sample size |   SE   | CI (Lower) | CI (Upper) |
|:------------|:------:|:----------:|:----------:|
| 10          | 0.395  |   0.802    |   2.622    |
| 100         | 0.060  |   0.926    |   1.164    |
| 1000        | 0.014  |   0.968    |   1.023    |
| 10000       | 0.002  |   0.994    |   1.002    |
| 100000      | 0.0002 |   0.999    |   1.000    |
| 1000000     | 0.0001 |   1.000    |   1.000    |

Table below shows the variance of estimated beta in part two, and the variance of estimated beta in two parts.

| Sample size | Beta variance |
|:------------|:-------------:|
| 10          |   0.1263214   |
| 100         |   0.0035254   |
| 1000        |   0.0001876   |
| 10000       |   3.73e-06    |
| 100000      |   3.65e-08    |
| 1000000     |   6.65e-08    |
| 10000000    |   8.26e-10    |

| Sample size | Var(beta) in Part One | Var(beta) in Part Two |
|:------------|:---------------------:|:---------------------:|
| 10          |       0.1263214       |           0           |
| 100         |       0.0035254       |       0.0038735       |
| 1000        |       0.0001876       |       0.0008315       |
| 10000       |       3.73e-06        |       0.0019327       |
| 100000      |       3.65e-08        |                       |
| 1000000     |       6.65e-08        |                       |
| 10000000    |       8.26e-10        |                       |

If we increase/decrease the number of repetitions, the results would change. As the number of repetitions gets larger, the estimated beta would converge to the "true beta".