## Week 10 Assignment 

### Part 1: Calculating required sample sizes and minimum detectable effects

#### Data Dictionary
_state_: US state (strata for this assignment)

_salary_: individual's salary (hourly $ wage)

_daca_: treatment dummy set equal to 1 when individuals have DACA; 0 otherwise

_corr_x_noenglish_: percentage of time at home spent speaking another language besides English. Related to an individual having DACA but not related to salary (in this flawed hypothetical)

_corr_y_healthcare_: individual out-of-pocket health care expenses. Related to salary but not DACA (in this flawed hypothetical)

_conf_school_: years of schooling. Related to both DACA status and salary.

#### Discussion

I set DACA to have an effect of 0.5. I simulated different sample sizes from 20 to 220 (this is in thousands). Around 180K is when ~80% of randomly-drawn samples produce effect estimates that are statistically significant (p < 0.05). I simulated this various times with different effect sizes besides 0.3 and found that the smaller a true effect is, the larger the sample size is needed to be powered at the 0.8 level.

 *Percent of samples that have stat. sig. effect estimates:*
| Sample Size | No Controls | Controls |
|-------------|-------------|----------|
| 20          | .996        | .156     |
| 60          | 1           | .368     |
| 100         | 1           | .542     |
| 140         | 1           | .690     |
| 180         | 1           | .830     |
| 220         | 1           | .886     |

To play around with MDE, I set the sample size to 180. I simulated different treatment effect sizes from 0.1 to 0.55. Around 0.3 is when ~80% of randomly-drawn samples produce effect estimates that are statistically significant (p < 0.05). This would be the MDE at a sample size of 180K. In contrast, the sample size of 180 is so large that it would produce stat. significant estimates for the DACA effect 100% of the time for a simple bivariate regression without controls.

 *Percent of samples that have stat. sig. effect estimates:*
| Effect Size | No Controls | Controls |
|-------------|-------------|----------|
| .10         | 1           | .148     |
| .15         | 1           | .28      |
| .20         | 1           | .416     |
| .25         | 1           | .62      |
| .30         | 1           | .772     |
| .35         | 1           | .898     |
| .40         | 1           | .974     |
| .45         | 1           | .992     |
| .50         | 1           | .996     |
| .55         | 1           | .998     |


### Part 2: Calculating power for DGPs with clustered random errors

I sadly did not have the time to give this section the attention (and office hours!) it requires. For context: I moved onto the Week 13 assignment before completing this assignment because my brain needed a break from STATA. 