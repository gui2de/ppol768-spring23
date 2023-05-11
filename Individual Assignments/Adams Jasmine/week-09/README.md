# Week 9 Assignment

<span style="font-size:20px">Part 1: Three Parameters</span>

I create a dataset to demonstrate how the below controls may bias or de-bias the estimated effect of receiving a credit builder loan on students credit score. Final results displayed in Table 2 and Table 4 indicate the estimated change in credit score for students in the treatment group compared to students in the control group. Despite considerable variance in $\beta$<sub>*treatment*</sub>&nbsp; at lower sample sizes, means of $\beta$<sub>*treatment*</sub>&nbsp; did not notably differ by sample size. 

* The variance in $\beta$<sub>*treatment*</sub>&nbsp; decreases as N gets larger.
* Exluding school effects constitutes omitted variable bias. As does excluding controls for age, female, and credit limit, which exert a positive, negative, and negative bias, repsectfully.
* Excluding parents' credit score does not bias results, as it is unrelated to treatment.
* Incliding the mediator ($x$ = *treatment on treated*) biases results by absorbing the treatment effects.
<hr><br>

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

<span style="font-size:16px"><b>Table 2. Mean Estimated Effect of Treatment.</b></span>
  
| Controls:                    | None   | Age                | Credit Limit       | Parents' Score | All    |
|------------------------------|--------|--------------------|--------------------|----------------|--------|
| Mean $\beta$<sub>*t*</sub> : | 47.679 | 25.103<sup>a</sup> | 54.333<sup>b</sup> | 47.647         | 25.010 |
|                              |        |                    |                    |                |        |

<span style="font-size:13px"><i>Note: Estimates are not disaggregated by sample size because mean effect sizes marginally differ by N.
&nbsp;&nbsp;&nbsp;<sup>a</sup> Positive bias
&nbsp;&nbsp;&nbsp;<sup>b</sup> Negative bias
</i></span><br>

<span style="font-size:16px"><b>Figure 1. Estimated Treatment Effects by Sample Size.</b></span>
<span style="font-size:16px"><i>No Controls vs. Controls</i></span>

![](outputs/graphp1.jpg)

<br>
<br>

<span style="font-size:20px">Part 2: Five Parameters</span>

I build on the same DGB to demonstrate how including an additional confounder and mediator further de-bias and bias the estimated effect of receiving a credit builder loan on students credit score. 

* Again, variance in $\beta$<sub>*treatment*</sub>&nbsp; decreases as sample size increases, though means of $\beta$<sub>*treatment*</sub>&nbsp; are relatively consistent at different sample sizes.
* Exluding controls for female exerts a negative bias.
* Including the mediator ($x$ = *the effect of treatment on treated*) biases results by completely absorbing the treatment effects, which are otherwise meaningful ($\beta$<sub>*t*</sub>&nbsp; = 24.954).
<hr><br>

<span style="font-size:16px"><b>Table 3. Variables and Intended Effects.</b></span>

| Variable                      | Description          | Effect            |
|-------------------------------|----------------------|-------------------|
| $ŷ$                           | Credit Score         | -                 |
| $x$<sub>*treatment*</sub>     | Treatment (0 or 1)   | -                 |
| $x$<sub>*ttreat*</sub>        | Treatment on Treated | $f$(*treatment*)  |
| $x$<sub>*school*</sub>        | School (Strata)      | Treatment and $y$ |
| $x$<sub>*age*</sub>           | Age                  | Treatment and $y$ |
| $x$<sub>*female*</sub>        | Female (0 or 1)      | Treatment and $y$ |
| $x$<sub>*parentscredit*</sub> | Parents credit score | $y$               |
| $x$<sub>*creditlimit*</sub>   | Credit limit         | Treatment         |
<br>

<br>

<span style="font-size:16px"><b>Table 4. Mean Estimated Effect of Treatment.</b></span>

*a) Variable Biases*

| Controls:                    | None   | Age               | Credit Limit      | Parents' Score | Female            | Treated           |
|------------------------------|--------|-------------------|-------------------|----------------|-------------------|-------------------|
| Mean $\beta$<sub>*t*</sub> : | 39.766 | 17.290<sup>a</sup> | 43.593<sup>b</sup> | 39.816          | 47.550<sup>b</sup> | 14.604<sup>c</sup> |

<br>

*b) Specification Biases*

| Controls:                    | None   | All (No Treated)  | All (Treated) |
|------------------------------|--------|-------------------|---------------|
| Mean $\beta$<sub>*t*</sub> : | 39.766 | 24.954            | -0.139        |


<span style="font-size:13px"><i>&nbsp;&nbsp;&nbsp;<sup>a</sup> Positive bias
&nbsp;&nbsp;&nbsp;<sup>b</sup> Negative bias
&nbsp;&nbsp;&nbsp;<sup>c</sup> Mediator bias
</i></span><br><br>

<span style="font-size:16px"><b>Figure 2. Estimated Treatment Effects by Sample Size.</b></span>
<span style="font-size:16px"><i>No Controls vs. Controls (exc. Mediator)</i></span>

![](outputs/graphp2.jpg)

<br>
