
# Week 9 Assignment

#Elena Spielmann
# Week 9 Assignment

### Data Code Book

_city_: US city in New York(strata for this assignment)

_heart_rate_: individual's heart rate (beats per minute)

_nudge_: treatment dummy set equal to 1 when individuals receive a nudge; 0 otherwise

_age_: individual's age in years. Related ability to interact with technology but not related to heart rate (in this hypothetical)

_gym_membership_: months of gym membership. Related to heart rate but not nudge (in this  hypothetical)

_education_: level of education in years. Related to both nudge status and heart rate.

### Regression Models

*Bivariate*: A simple bivariate regression of heart rate on nudge status.

*City + Confounder*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects and level of education (confounder).

*Biased Model 1*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, level of education (confounder), and age (related to nudge status, not heart rate).

*Biased Model 2*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, level of education (confounder), and gym membership(related to heart rate, not nudge status).

*Biased Model 3*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, level of education (confounder), age and gym membership.

Discussion
![Combination Graph Part 1](p1_comb.png)

After accounting for city fixed effects and a confounding variable, the range of Beta estimates was significantly reduced compared to the simple bivariate model. As the sample size increased, the estimates converged around the true nudge effect of 2 (indicated by the green line) in both the unbiased and biased models. However, the biased models were less precise in their estimates than the unbiased models.

**Table 1**


Summary statistics: Mean SD semean Min Max
     for variables: bivar unbias bias1 bias2 bias3

             |   e(Mean)      e(SD)  e(semean)     e(Min)     e(Max)
-------------+-------------------------------------------------------
       bivar |  8.943715   1.054968    .038522   6.041209   13.89576
      unbias |   4.00221   .1297604   .0047382     3.4501   4.782087
       bias1 |   4.00221   .1297604   .0047382     3.4501   4.782087
       bias2 | -1.333333   5.28e-08   1.93e-09  -1.333333  -1.333333
       bias3 | -1.333333   5.28e-08   1.93e-09  -1.333333  -1.333333


Table 1 shows that, the mean of the Beta estimates fluctuated across all sample sizes for both the unbiased and biased models. The standard error of the mean was smaller across all models, except for the bivariate model, where it was larger. Biased Model 2&3 had the smallest standard error of the mean.

## Part 2: Biasing a parameter estimate using controls

### Data Code Book

All variables from Part 1 are also applicable for Part 2. The following are additional variables:

_channel_stepcount_: A continuous variable measuring an individuals daily step count.

_collider_social_: A continuous variable measuring an individual's social support either in person or through social media to exercise in some capacity.

### Regression Models
*Bivariate*: A simple bivariate regression of heart rate on nudge status.

*City + Confounder*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects and age (confounder).

*Biased Model 1*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, age (confounder), and step count (a channel).

*Biased Model 2*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, age (confounder), and social support(a collider).

*Biased Model 3*: A multivariate regression of heart rate on nudge status, controlling for city fixed effects, age (confounder), step count (a channel), and social support (a collider).

*Discussion*
![Combination Graph Part 1](p2_comb.png)

The first two models in Part 2 use the same variables as the Bivariate and City + Confounder models in Part 1, but neither accurately reflect the true nudge effect of 2. This is because the outcome variable, heart rate, is influenced by the channel variable, step count, which is in turn influenced by the nudge itself (2 * nudge). Therefore, in the "City + Confounder" model, which should be unbiased, the estimated effect of nudge becomes inflated since it is essentially being considered multiple times during the outcome variable generation process (nudge effect + channel = 2nudge + 2nudge = 4*nudge). Biased Model 1 controls for the channel variable (step count), yet the Beta estimates produced remain upwardly biased. However, the most significant change occurs in Biased Models 2 & 3, which control for the collider variable, social support The effects change completely, and the estimated Beta stays a constant negative value. This demonstrates why colliders should be excluded from models entirely. Despite my expectation that the City + Confounder model would be unbiased, I was surprised to see that all Beta estimates in all models were biased. This is because the channel was included in the DGP for the outcome variable.
