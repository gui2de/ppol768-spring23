Week 8 Assignment

Part I

The following describes the result of the simulations in the Week 8 Assignment.
The first simulation consisted of the following  

      * Random dataset generated 10000 observations
      * Written program to randomly simulate the 10000 observations
      * Sample size of the dataset increases by 10 ^ (1,2,3,4)

Part I

|       Sample Size        |    Beta estimate   | Std.error | Conf. Interval |
|          10              |         5.54/6.67  |     1.57  |   2.95 - 10.43 |
|          100             |         3.95       |    0.50   |   2.94 - 4.95  |
|        10000             |         4.01       |    0.04   |   3.94 - 4.10  |

The SEM and confidence intervals get smaller as the sample size gets larger.

Part II

|       Sample Size        |    Beta estimate   | Repetitions |
|          10              |                    |     5       |
|          100             |                    |     50      |
|        10000             |                    |    500      |


I have uploaded a number of histograms generated via Stata which show the change in the beta estimates when:

  (i) Sample size changes
  (ii) Number of simulations change

  To analyze the changes, I made changes to the simulations and the sample sizes from 5 to 500 and from 10 to 1000000.
  In conclusion, as the sample size gets larger in the simulation, the beta estimates are centered around the mean of the sample. Similarly, as the number of simulations increase, the beta estimates are clustered around the mean and the distribution has less variation as opposed to a small sample with less simulations which have more variation.
  In this case we are able to draw a larger sample size because we have not restricted the dataset to a particular seed,
  therefore the program is able to generate larger random samples.
