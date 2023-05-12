# Week 10 Assignment

<span style="font-size:20px">Part 1. Minimum Sample Sizes and Detectable Effects</span>

Simulated results indicate that a sample size of $n$ = 60 is required to detect treatment effects when excluding controls, in this case due to positive omitted variable bias. However, both power calculations and simulated results confirm that a larger sample of $n$ ≈ 130 is required when including proper controls. The minimum amount by which a credit score can change is 5pts, whuch would require a substantially larger sample size to detect $n$ ≈ 1800.

<br>

<span style="font-size:16px"><b>Table 1. Variables and Intended Effects.</b></span>

| Variable                      | Description          | Effect on           |
|-------------------------------|----------------------|-------------------|
| $ŷ$                           | Credit Score         | -                 |
| $x$<sub>*treatment*</sub>     | Treatment (0 or 1)   | -                 |
| $x$<sub>*school*</sub>        | School (Strata)      | Treatment and $y$ |
| $x$<sub>*age*</sub>           | Age                  | Treatment and $y$ |
| $x$<sub>*parentscredit*</sub> | Parents credit score | $y$               |
| $x$<sub>*creditlimit*</sub>   | Credit limit         | Treatment         |
<br>

<span style="font-size:16px"><b>Figure 1a. Sample size when $\beta$<sub>*treatment*</sub>&nbsp; = 20 Score Points.</b></span>
<span style="font-size:16px"><i>Predicted Change in Credit Score = 20pts.</i></span>

![](outputs/g1.png)

<br>

<span style="font-size:16px"><b>Figure 1b. Effect Size when $n$ = 130.</b>

![](outputs/g2.png)
<br>

<span style="font-size:16px"><b>Figure 1c. Sample size when $\beta$<sub>*treatment*</sub>&nbsp; = 5 Score Points.</b>
<span style="font-size:16px"><i>Minimum Change in Credit Score</i></span>

![](outputs/graphp1c.jpg)
<br>

<br>
<hr>
<br>

<span style="font-size:20px">Part 2. CIs with Clustered Random Errors</span>

I create 5 clusters within 6 strata (schools) at the student level and assign treatment and outcomes effects by cluster. Analytic and exact  confidence intervals follow distinct patters as sample size increases. 
* Analytic intervals behave conventionally without random effects by exponentiall decreasing as sample size increases. 
* Exact statistic always follow a more uniform distribution
* Analytics results resemble an even smoother uniform distribution when controlling for random effects.  
<br>

<span style="font-size:16px"><b>Figure 2a.</b>

![](outputs/g4.png)

<span style="font-size:16px"><b>Figure 2b.</b>

![](outputs/g5.png)

<br>

<span style="font-size:16px"><b>Figure 2c.</b>

![](outputs/graphp2e.jpg)
<br> 