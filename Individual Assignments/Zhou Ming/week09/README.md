# Part One

In part one, we have four independent variables, including treatment, state, activity, and industrial. The treatment variable (a binary variable) is determined by activity, industrial, and include a random effects. Half of observations are in the treatment group. The dependent variable is greenhouse emission. $$ Emission_i= 100 + (-50)*Treatment_i + 3*industrial_i + 3*activity_i + e_s + e_c $$

And we have five regression model. $$ Emission_i= b_0+b_1Treatment $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3activity_i $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3industrial_i$$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3activity_i +b_4industrial_i$$

Table below indicates the beta change in variance and mean by sample size.

| Model | Sample size | Beta Mean | Beta Variance |
|:------|:------------|:---------:|:-------------:|
| 1     | 100         |  -36.444  |   353.9338    |
| 1     | 200         | -36.45667 |   147.8493    |
| 1     | 300         | -36.46076 |   61.93526    |
| 1     | 400         | -36.47055 |   20.25191    |
| 1     | 500         | -36.47896 |       0       |
| 2     | 100         | -36.21103 |   687.3634    |
| 2     | 200         | -36.25216 |   208.7726    |
| 2     | 300         | -36.31179 |   78.76185    |
| 2     | 400         | -36.33672 |   26.88365    |
| 2     | 500         | -36.35232 |       0       |
| 3     | 100         | -36.39751 |   3.47e-12    |
| 3     | 200         | -36.49329 |   1.22e-12    |
| 3     | 300         | -36.56593 |   4.75e-13    |
| 3     | 400         | -36.58658 |    1.76e-1    |
| 3     | 500         | -36.60411 |       0       |
| 4     | 100         | -47.81581 |   3.47e-12    |
| 4     | 200         | -47.69743 |   1.22e-12    |
| 4     | 300         | -47.6823  |   4.75e-13    |
| 4     | 400         | -47.69518 |   1.76e-13    |
| 4     | 500         | -47.69571 |       0       |
| 5     | 100         | -50.71464 |   2455.285    |
| 5     | 200         | -50.48876 |   659.4448    |
| 5     | 300         | -50.50314 |   291.6393    |
| 5     | 400         | -50.51057 |   87.20858    |
| 5     | 500         | -50.50383 |       0       |

As shown in the table and in box graphs(the codes are in the do-file), as samples size increase, the beta would converge to some value in all models. A larger sample size will result in a smaller beta variance. The model five (the one with all covarates and confounding variables) generates the treatment effects closest to the true effect, -50. It demonstrate the point that without controlling for confounding variables (omitted variables), the model is biased.

# Part Two

In part two, based on part one, we add a collider. The treatment variable (a binary variable) is determined by activity, industrial, and include a random effects. Half of observations are in the treatment group. The dependent variable is greenhouse emission. $$ Emission_i= 100 + (-50)*Treatment_i + 3*industrial_i + 3*activity_i + e_s + e_c $$ The collider is a function of emission and treatment. $$ Emission_i= 4*Treatment_i + 3*emission_i  $$

Our models are as follows. $$ Emission_i= b_0+b_1Treatment $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3collider_i $$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3activity_i+b_4collider_i$$ $$ Emission_i= b_0+b_1Treatment_i+b_2state_i+b_3activity_i +b_4industrial_i$$

| Model | Sample size | Beta Mean | Beta Variance |
|:-----:|:------------|:---------:|:-------------:|
|   1   | 100         |  -36.444  |   1.068031    |
|   1   | 200         | -36.45667 |   .4272996    |
|   1   | 300         | -36.46076 |    .179696    |
|   1   | 400         | -36.47055 |   .0605879    |
|   1   | 500         | -36.47896 |       0       |
|   2   | 100         | -36.21103 |   2.103489    |
|   2   | 200         | -36.25216 |   .5168534    |
|   2   | 300         | -36.31179 |   .2284012    |
|   2   | 400         | -36.33672 |   .0740784    |
|   2   | 500         | -36.35232 |       0       |
|   3   | 100         | -1.333329 |   1.59e-11    |
|   3   | 200         | -1.33333  |   4.17e-12    |
|   3   | 300         | -1.33333  |   1.51e-12    |
|   3   | 400         | -1.33333  |   6.64e-13    |
|   3   | 500         | -1.33333  |       0       |
|   4   | 100         | -1.333329 |   1.67e-11    |
|   4   | 200         | -1.333329 |   4.45e-12    |
|   4   | 300         | -1.33333  |   1.63e-12    |
|   4   | 400         | -1.33333  |   7.00e-13    |
|   4   | 500         | -1.33333  |       0       |
|   5   | 100         | -50.71464 |   2.226124    |
|   5   | 200         | -50.48876 |   .5237674    |
|   5   | 300         | -50.50314 |   .2280379    |
|   5   | 400         | -50.51057 |   .0742413    |
|   5   | 500         | -50.50383 |       0       |

As shown in the table and in box graphs(the codes are in the do-file), as samples size increase, the beta would converge to some value in all models. For models without collider, adding more confounding variables would make the estimated beta closer to the true beta, -50. For models with collider, the estimated beta is significantly different from the true beta, even though with a large sample size.

Thus, to explore the effects of variables of our primary interest, controlling for confounding variables is a good choise (it would increase model precision and accuracy). But it does mean we should control as many as factors as possibly. If we control for the collider, the estimated coefficients would be biased, and significantly differ with the true effects.
