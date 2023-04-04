# Part one

Biased Model: Score = beta0 + beta1 * treat + error
Unbiased Model: Score = beta0 + beta1 * treat + beta2 * urban + beta3 * teach_exp + beta4 * mother_educ + error

![Graph1] (Part1a.png)

From the table above, the "minimum sample size" required to achieve 80% power for the regression model with and without the unbiased control is 2.

![Graph2] (Part1b.png)

As can be seen from the figure above, when the number of fixed samples is 2, the "minimum detectable effect size" we found is 4.5 (its value should be between 4 and 4.5), that is, at this size, no matter whether the unbiased control is used or not , the regression model can obtain 80% power
