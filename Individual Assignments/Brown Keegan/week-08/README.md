Keegan Brown
Week 8 Assignment 

## Part 1

![Part1 Graph](outputs/part1_bar.png)

| n     | betas  | ses    | lower  | upper  | interval |
|-------|--------|--------|--------|--------|----------|
| 10    | 1.0015 | 0.1036 | 0.7627 | 1.2403 | 0.4776   |
| 100   | 0.9977 | 0.0294 | 0.9394 | 1.0561 | 0.1166   |
| 1000  | 0.9984 | 0.0092 | 0.9804 | 1.0164 | 0.0360   |
| 10000 | 0.9982 | 0.0029 | 0.9925 | 1.0039 | 0.0114   |

Based on the histogram and the table above, we can see that as we inrease sample size our beta tends to move to the population mean, which in this case is 1. We can also see that our variance decreases signficiantly. This suggests that as sample size increases the dispersion of values decreases. The interval also decreases, confirming that estimates are closer to the true population mean when large samples are drawn. 

## Part 2 

![Part2 Graph](outputs/part2_graph.png)


| samplesize | betas  | se     | lower   | upper   |
|------------|--------|--------|---------|---------|
| 4          | 0.9922 | 2.1711 | -8.3491 | 10.3336 |
| 8          | 0.9848 | 1.2424 | -2.0552 | 4.0248  |
| 10         | 1.0084 | 1.0598 | -1.4356 | 3.4524  |
| 16         | 1.0078 | 0.8135 | -0.7370 | 2.7527  |
| 32         | 0.9675 | 0.5503 | -0.1564 | 2.0914  |
| 64         | 1.0147 | 0.3780 | 0.2591  | 1.7703  |
| 100        | 0.9945 | 0.3028 | 0.3937  | 1.5953  |
| 128        | 0.9937 | 0.2673 | 0.4648  | 1.5226  |
| 256        | 1.0067 | 0.1885 | 0.6355  | 1.3778  |
| 512        | 0.9963 | 0.1324 | 0.7362  | 1.2565  |
| 1000       | 1.0084 | 0.0948 | 0.8223  | 1.1945  |
| 1024       | 1.0000 | 0.0939 | 0.8157  | 1.1842  |
| 2048       | 0.9972 | 0.0663 | 0.8672  | 1.1273  |
| 4096       | 0.9980 | 0.0469 | 0.9060  | 1.0900  |
| 8192       | 1.0001 | 0.0331 | 0.9352  | 1.0651  |
| 10000      | 1.0006 | 0.0300 | 0.9417  | 1.0594  |
| 16384      | 1.0001 | 0.0234 | 0.9541  | 1.0460  |
| 32768      | 0.9980 | 0.0166 | 0.9655  | 1.0305  |
| 65536      | 0.9997 | 0.0117 | 0.9767  | 1.0227  |
| 100000     | 0.9993 | 0.0095 | 0.9807  | 1.0179  |
| 131072     | 0.9999 | 0.0083 | 0.9836  | 1.0161  |
| 262144     | 0.9997 | 0.0059 | 0.9882  | 1.0112  |
| 524288     | 0.9999 | 0.0041 | 0.9918  | 1.0080  |
| 1000000    | 1.0001 | 0.0030 | 0.9942  | 1.0060  |
| 1048576    | 0.9998 | 0.0029 | 0.9941  | 1.0056  |
| 2097152    | 1.0001 | 0.0021 | 0.9960  | 1.0041  |

From our graph, we can see that the true expected value of the betas is not changing, but our confiecne intervals around those values begin to grow smaller with increased sample size. We can also see that our variance - through our standard errors - decrease as the number of iterations increases. Estimates show les bias as the number of draws increases. 
					