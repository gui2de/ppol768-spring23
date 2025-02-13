## **PART 1**

The accuracy of the estimates seem to improve with sample size (getting closer to the true parameter of 7), though already once the sample size reaches 100 the improvement seems to be negligible. The SEM, p-values, and size of confidence intervals decrease with the increase in sample size.


![image](https://user-images.githubusercontent.com/122739454/235385053-f5a0053e-a5d3-43a4-92ff-58a4c2ea34f4.png)

![week-08-graph1](https://user-images.githubusercontent.com/122739454/235385021-cde16e6d-e154-48a1-91ff-5f44cfd99d79.PNG)



## **PART 2**

The overall pattern of results when using an infinite superpopulation are very similar to the results when using the fixed population. In general, variability around the true parameter of 7 decreases as sample size increases. 

![week-08-graph2](https://user-images.githubusercontent.com/122739454/235387879-f37c53c7-3c2a-4240-95f9-aa65087e7121.PNG)

![image](https://user-images.githubusercontent.com/122739454/235387796-74b84331-19ac-4174-b70b-7e01c21b0739.png)

### Comparison

While results are fairly similar when comparing the same sample sizes in the fixed versus infinite superpopulation, there appears to be slightly less variation in the beta estimates when using the infitie superpopulation. This can be observed in the smaller standard deviations for beta, slightly smaller p-values, and smaller ranges in the beta and SEM. This is because instead of sampling from a fixed population that could already potentially have some type of bias, we are essentially sampling from the entire "universe" of options, which, when done repeatedly, results in a less biased sample. 

![image](https://user-images.githubusercontent.com/122739454/235387959-91e9a3d8-a9ad-42ab-8064-f709df0db7b3.png)

### What happens when increasing/decreasing repetitions

Changing the number of repetitions seems to make a fairly negligible difference, especially as sample size increases. With small sample sizes (4, 128), the mean beta is closer to the true parameter with the higher number of repetitions, but there is also more variability than with the lower number of repetitions (larger range in beta values)

![image](https://user-images.githubusercontent.com/122739454/235393262-98d73166-a31e-427b-8df5-85bdcac4bb16.png)
