
# Week 09 Assignement

## Part 1

*Result Graph and Table

![part1_beta](output/part1_line1.png)
![part1_SEM](output/part2_line1.png)

*Table 
*Simulate 500 times, sample sizes use the power of 10, 100, 1000, 10000

| samplesize  | beta1    | beta2     | beta3     | beta4    | beta5     |
|-------------|----------|-----------|-----------|----------|-----------|
| 10          | 4.388988 | 4.398479  | -7.609719 | 4.3728   | -4.92505  |
| 100         | 4.848173 | 4.848722  | -9.716783 | 4.864815 | -7.319871 |
| 1000        | 5.023668 | 5.028888  | -9.278658 | 5.02268  | -6.621612 |
| 10000       | 5.009713 | 5.007886  | -9.223788 | 5.009731 | -6.651827 |
| Total       | 4.817636 | 4.820994  | -8.957237 | 4.817506 | -6.37959  |

### Discussion

I tried to show all the beta estimates in one graph, but due to the large differences in values, beta1, beta2 and beta3 will not display on the graph. Thus, I break the line graph into two. 
I also tried to use histogram to illustrate the frequency of the beta estimates across different regression model and sample size. However, the beta estimates didn't vary significantly across sample size.

* regression 1 is the true regression model: score = 60 + 5*treatment - 2*public - task + study_hour 
* regression 2 omitted _student_ratio_  from the regression. _student_ratio_ is related to _treatment_ but not related to _outcome_. Beta2 is not significantly biased from beta1, which is the true estimator. 
* regression 3 omitted the confounder from the regression. *study_hour* is both related to *outcome* and *treatment*. As we could see from the line graph2, beta3 is significantly biased from the true estimator.
* regression 4 omitted *task* from the regression. *task* is related to the *outcome* but not the *treatment*. Beta4 is also not significantly biased from the true estimator. 
* regression 5 includes only *treatment* and *outcome*. Beta5 is significantly biased from the true estimator.  Beta 5 is the furthest from the true estimator.


## Part 2

*Result Graph and Table

![part2_beta](output/part2_line.png)

*TABLE
| samplesize  | beta1    | beta2    | beta3     | beta4    | beta5    |
|-------------|----------|----------|-----------|----------|----------|
| 5           | 3.091872 | 5.915762 | -.1199359 | .0406781 | .0406781 |
| 25          | 2.99819  | 6.325875 | .2757382  | .040935  | .0409057 |
| 125         | 2.999183 | 5.829864 | .0545769  | .0398053 | .0398139 |
| 625         | 2.996794 | 6.1114   | .0523659  | .0400768 | .0400738 |
| 3125        | 3.001718 | 5.988707 | .0117776  | .0399663 | .0399627 |
| Total       | 3.017552 | 6.034321 | .0549045  | .0402923 | .0402794 |

*Simulate 500 times, sample sizes use the power of 5, 25, 125, 625, 3125

### Discussion
* regression 1 is the true model: score = 60 + 3*channel - public +2*study_hour
* regression 2 omits *channel* from the regression. Although *treatment* is related to *channel*, beta2 is significantly biased from the true estimator. It is upwardly biased from the true estimator because *treatment* and *channel* is positively related and *channel* and *outcome* is also positively related.  
* regression 3 includes both the treatment and the channel. Beta3 is also significantly biased from the true estimator despite that _channel_ is in the regression. 
* Both regression 4 and regression 5 includes collider, which is both related to *outcome* and *treatment*. The beta estimates for both of these regression are significantly biased from true estimator.

