WEEK 9

Part 1:

Note that from the model, the "true" parameter value is marked at 5, because we have designed the treatment to have an effect of 5 units.

Table showing the mean and variance of beta for different regression models, as a function of N:

 mean treat_*, over(samplesize)

Mean estimation                                           Number of obs = 2,000

-------------------------------------------------------------------------------
                              |       Mean   Std. err.     [95% conf. interval]
------------------------------+------------------------------------------------
        c.treat_fe@samplesize |
                          40  |  -10.15074   .4538822     -11.04087   -9.260607
                         400  |  -9.585519   .1368175     -9.853839     -9.3172
                        4000  |  -9.437226   .0452426     -9.525953   -9.348498
                       40000  |  -9.473398   .0133876     -9.499654   -9.447143
                              |
      c.treat_conf@samplesize |
                          40  |   5.867544   .3520863      5.177049    6.558038
                         400  |    6.09849    .111977      5.878887    6.318094
                        4000  |   6.227329   .0373234      6.154132    6.300526
                       40000  |    6.20765   .0111892      6.185706    6.229594
                              |
   c.treat_fe_conf@samplesize |
                          40  |   4.624792   .4277855       3.78584    5.463744
                         400  |   4.851813   .1283095      4.600179    5.103448
                        4000  |   5.022026   .0438916      4.935948    5.108104
                       40000  |   5.001909   .0123975      4.977596    5.026222
                              |
c.treat_conf_covar@samplesize |
                          40  |   6.045534   .3734453      5.313151    6.777916
                         400  |   6.291458   .1124198      6.070986    6.511931
                        4000  |   6.476202   .0358526       6.40589    6.546514
                       40000  |    6.45272   .0109192      6.431306    6.474134
                              |
 c.treat_fe_convar@samplesize |
                          40  |  -13.45106   .4718026     -14.37634   -12.52579
                         400  |  -12.82648   .1392364     -13.09954   -12.55341
                        4000  |  -12.69185    .046407     -12.78286   -12.60084
                       40000  |  -12.71433   .0132153     -12.74025   -12.68841
                              |
  c.treat_complete@samplesize |
                          40  |   4.329101   .4774011      3.392845    5.265356
                         400  |   4.806571   .1348354      4.542139    5.071004
                        4000  |   5.019561   .0435786      4.934096    5.105025
                       40000  |   5.000734   .0121339      4.976937     5.02453
-------------------------------------------------------------------------------

These findings are then ploted on a boxplot below: 

![Mean and Variance of Beta vs "true" parameter value](img/biasbox.png "Mean and Variance of Beta vs true parameter value")

Where the x axis represents N and the Y-axis the Variance of Beta, and where outliers have been eliminated.

And where: 

m1 = reg y treatment

treat_fe = reg y treatment i.strata

treat_conf = reg y treatment  cov_xy 

treat_fe_conf = reg y treatment i.strata cov_xy

treat_conf_covar = reg y treatment cov_xy cov_x cov_y

treat_fe_convar = reg y treatment i.strata cov_x cov_y

treat_complete = reg y treatment i.strata cov_xy cov_x cov_y

From the table we can see the c.treat_fe and c.treat_fe_convar regardless of their N are the most biased regressions as their mean is far from the "true" parameter value of 5. Instead, the ones that converge the most to the "true" parameter value are c.treat_complet and c.treat_fe_conf when they reach N = 40,000. We can see that as N grows in most regression models, the means of the regressions converge to 5, meaning the higher N the more likely to reach the "true" treatment effect. c.treat_conf is the exception, but since the model does not include covariates nor strata, it seems plausible to become more biased as N increases.

As on the table above, we see the yellow, red, and green figures, being the m1, c.treat_fe and c.treat_fe_convar models correspondingly, are further away from the "true" parameter value of 5,  meaning they are the most biased models. 

Where it seems again, c.treat_complete in purple, is the most accurate model, the box is in the line of the "true" parameter, as it includes the confounder and the covariates variables. i.e. is the most complete model. 

Part 2: 

Note again that from the model, the "true" parameter value is marked at 5, because we have designed the treatment to have an effect of 5 units.

Table showing the mean and variance of beta for different regression models, as a function of N:

Mean estimation                              Number of obs = 2,000

------------------------------------------------------------------
                 |       Mean   Std. err.     [95% conf. interval]
-----------------+------------------------------------------------
 c.r1@samplesize |
             40  |   3.523298   .3762221       2.78547    4.261127
            400  |   3.067383   .1240771      2.824049    3.310717
           4000  |   3.251146   .0387966       3.17506    3.327232
          40000  |   3.217989   .0126358      3.193208     3.24277
                 |
 c.r2@samplesize |
             40  |  -.9964758   .0156375     -1.027143   -.9658084
            400  |  -1.005712   .0049238     -1.015369    -.996056
           4000  |  -.9937662   .0016713      -.997044   -.9904884
          40000  |  -.9957471   .0005054     -.9967383   -.9947559
                 |
 c.r3@samplesize |
             40  |    .034781   .5109798     -.9673277     1.03689
            400  |  -.0334101   .1494473     -.3264988    .2596786
           4000  |   .1852367   .0488457      .0894428    .2810305
          40000  |   .1355786   .0145473      .1070491    .1641082
                 |
 c.r4@samplesize |
             40  |   14.94575   .3933326      14.17437    15.71714
            400  |   14.92114   .1209591      14.68392    15.15836
           4000  |   15.07455   .0390545      14.99796    15.15114
          40000  |   15.05764   .0118335      15.03443    15.08085
                 |
 c.r5@samplesize |
             40  |   17.21272   .4207111      16.38764     18.0378
            400  |   17.81773   .1250311      17.57252    18.06293
           4000  |   17.81311   .0412821      17.73215    17.89407
          40000  |   17.79662   .0123504       17.7724    17.82084
                 |
 c.r6@samplesize |
             40  |   16.00583   .4674773      15.08904    16.92262
            400  |   16.75092   .1346329      16.48688    17.01495
           4000  |   16.81293   .0443703      16.72591    16.89995
          40000  |   16.79624   .0130162      16.77071    16.82177
                 |
 c.r7@samplesize |
             40  |  -.9426927   .0216641     -.9851792   -.9002062
            400  |  -.9755876   .0059329      -.987223   -.9639523
           4000  |  -.9646193   .0020767      -.968692   -.9605466
          40000  |  -.9647527   .0006425     -.9660126   -.9634927
                 |
 c.r8@samplesize |
             40  |   7.716298   .3301041      7.068914    8.363682
            400  |   7.395836   .1146477      7.170995    7.620678
           4000  |   7.462345   .0352165       7.39328     7.53141
          40000  |   7.442843   .0115597      7.420173    7.465513
                 |
 c.r9@samplesize |
             40  |  -.9879559   .0229548     -1.032974    -.942938
            400  |  -1.029734   .0060647     -1.041627    -1.01784
           4000  |   -1.01839   .0020091     -1.022331    -1.01445
          40000  |  -1.018712   .0006241     -1.019936   -1.017488
                 |
c.r10@samplesize |
             40  |  -.9480859   .0254572     -.9980113   -.8981605
            400  |  -.9985431     .00644     -1.011173   -.9859132
           4000  |  -.9853216   .0022621     -.9897579   -.9808852
          40000  |  -.9853474   .0006965     -.9867133   -.9839816
------------------------------------------------------------------


These findings are then ploted on a boxplot below: 

![Mean and Variance of Beta vs "true" parameter value for part 2](img/biasbox2.png "Mean and Variance of Beta vs true parameter value")

Where the x axis represents N and the Y-axis the Variance of Beta, and where outliers have been eliminated.

where: 

r1 = reg y treatment
r2 = reg y treatment z coll
r3 = reg y treatment z i.strata
r4 = reg y treatment z cov_xy 
r5 = reg y treatment i.strata cov_xy
r6 = reg y treatment i.strata z cov_xy
r7 = reg y treatment i.strata z coll cov_xy
r8 = reg y treatment cov_xy cov_x cov_y
r9 = reg y treatment i.strata z coll cov_x cov_y 
r10 = reg y treatment i.strata z coll cov_xy cov_x cov_y

This time none of the regression models truly converge to the "true" parameter, however it seems r8 is the closest. This regression includes the confounder but not the collider nor strata. Since the purpose of the excersise was to bias a parameter, these results match the expectation. In Part 2, as opposed to part 1, it appears, as N grows, the regressions become more biased, and their means move away from the true parameter. r2 and r3 have different jumps in the means with changes in N, and this might be caused by the fact that their models do not include neither confounders nor covariate effects. 




