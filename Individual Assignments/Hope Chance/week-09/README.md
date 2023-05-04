**Chance Hope**

**Week 9**

**Pt. 1**

![w9pt1comp](C:\Users\maxis\Desktop\ppol768backup\week-09\outputs\w9pt1comp.png)

Beta1= No controls

Beta2= Age

Beta3= Income

Beta4= Income Age

Beta5= Income Age Grade

|             |             |             |                |                    |                          |
| ----------- | ----------- | ----------- | -------------- | ------------------ | ------------------------ |
| Sample Size | No Controls | Control Age | Control Income | Control Income Age | Control Income Age Grade |
|             |             |             |                |                    |                          |
| 600         | 3.510278    | 3.475523    | 3.467907       | 3.431584           | 3.438079                 |
| 1200        | 3.533896    | 3.53015     | 3.513627       | 3.50967            | 3.50463                  |
| 1800        | 3.420855    | 3.461207    | 3.446934       | 3.483956           | 3.487409                 |
| 2400        | 3.532659    | 3.530975    | 3.517745       | 3.516196           | 3.517613                 |
| Average     | 3.499       | 3.499       | 3.487          | 3.485              | 3.487                    |

Income and age positively bias the estimated effect of treatment. Controlling for age alone did not meaningfully change the estimated relationship between treatment and scores. In contrast, income seems to have positively biased the effects of treatment because when we control for income, the estimated effect of treatment decreases. Including grade in the model does not change the estimated effect of treatment. As shown by the above figure and table, the variance of the treatment effects decreases as N increases for all regressions. 

**Pt. 2**

![w9p2](C:\Users\maxis\Desktop\ppol768backup\week-09\outputs\w9p2.png)

Beta1= No Controls

Beta2= Mediator

Beta3= Collider

Beta 4= Income Age Grade Collider

Beta 5= Income Age Grade Mediator Collider 

|             |             |                  |                  |                                   |                                            |
| ----------- | ----------- | ---------------- | ---------------- | --------------------------------- | ------------------------------------------ |
| Sample Size | No Controls | Control Mediator | Control Collider | Control Income Age Grade Collider | Control Income Age Grade Mediator Collider |
|             |             |                  |                  |                                   |                                            |
| 600         | 7.049212    | -.0342679        | 7.071693         | 7.045085                          | .239462                                    |
| 1200        | 6.936135    | -.0757799        | 6.946807         | 6.941475                          | -.137651                                   |
| 1800        | 7.02274     | -.066709         | 7.011865         | 7.034243                          | .0267048                                   |
| 2400        | 6.96629     | .0247645         | 6.973732         | 7.013182                          | .0281894                                   |
| Average     | 6.994       | -0.038           | 7.001            | 7.008                             | 0.039                                      |

Controlling for the collider variable did not appear to change the observed treatment effect. Controlling for the mediator reduces the observed effect of the treatment. The mediator absorbs the effect of treatment so that treatment is no longer correlated with Y. As shown by the above figure and table, the variance of the treatment effects decreases as N increases for all regressions. 