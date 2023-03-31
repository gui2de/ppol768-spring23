Week 8 Assignment

NB: The figures in the outputs folder have been organized in the following order as per the assignment

  All of the histograms generated for Part 1 are named part1sampleN

  All of the histograms generated for Part 2, with variation in the number of simulations are labelled

  sampleNrep5 and samplesizeN (the histograms labelled sameplsizeN reflect simulations that were done 500 times at varying sample sizes as seen in the table in Part 12 below.)
Part I

The following describes the result of the simulations in the Week 8 Assignment.
The first simulation consisted of the following  

      * Random dataset generated 10000 observations
      * Written program to randomly simulate the 10000 observations
      * Sample size of the dataset increases by 10 ^ (1,2,3,4)

|       Sample Size        |    Beta estimate   | Std.error|  Conf.Interval |
|          10              |         4.43       |    1.61  |   0.71 - 8.15  |
|          100             |         4.38       |    0.47  |   3.44 - 5.32  |
|         1000             |         4.09       |   0.16   |   3.78 - 4.412 |
|        10000             |         4.01       |    0.04  |   3.91 - 4.10  |

The beta, SEM and confidence intervals get smaller as the sample size gets larger. The larger sample size means that estimates that we're getting are getting closer and closer to the  population.
In the file the following images represent the information in the table above.
In the following order of histograms part1sample10.png, part1sample100.png, part1sample1000 and partsample10000.png.

Part II

|       Sample Size        |    Beta estimate   | Repetitions | Std. error | Conf. Interval |
|          10              |       9.57         |     500     |   1.57     | 5.94 - 13.19   |
|          100             |       7.18         |     500     |   0.57     |  6.04 - 8.33   |
|          1000            |       6.99         |     500     |   0.18     |  6.62 - 7.36   |
|          10000           |       6.89         |     500     |   0.05     |  6.78 - 7.01   |
|          100000          |       6.97         |     500     |   0.01     |  6.94 - 7.01   |
|          1000000         |       7.00         |     500     |   0.00     |  6.99 - 7.01   |

|       Sample Size        |    Beta estimate   | Reps      | Std. error | Conf. Interval |
|          10              |       9.57         |     5     |   1.57     | 5.94 - 13.19   |
|          100             |       7.18         |     5     |   0.57     |  6.04 - 8.33   |
|          1000            |       6.99         |     5     |   0.18     |  6.62 - 7.36   |
|          10000           |       6.89         |     5     |   0.05     |  6.78 - 7.01   |
|          100000          |       6.97         |     5     |    0.01    |  6.94 - 7.01   |
|          1000000         |       7.00         |     5     |   0.00     |  6.99 - 7.01   |




I have uploaded a number of histograms generated via Stata which show the change in the beta estimates when:

  (i) Sample size changes
  (ii) Number of simulations change

  To analyze these differences, I made changes to the simulations and the sample sizes from 5 to 500 and from 10 to 1000000.
  In conclusion, as the sample size gets larger in the simulation, the beta estimates are centered around the mean of the sample. Similarly, as the number of simulations increase, the beta estimates are clustered around the mean and the distribution has less variation as opposed to a smaller sample with less simulations which have more variation.
  In this case we are able to draw a larger sample size because we have not restricted the dataset to a particular seed,
  therefore the program is able to generate larger random samples as opposed to Part I which limits the dataset to the same data every time we run the simulation, at different sample sizes up to 10,000.
