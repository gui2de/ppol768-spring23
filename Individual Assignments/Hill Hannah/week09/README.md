# Part 1: De-biasing a parameter estimate using controls

Below, we see that the Beta estimate for Model 1 ("Beta1") outlined in red stands out from the rest of the models' estimates. Model 1, a bivariate model, is downwardly biased. The other models (2-5) which include multivariate controls and fixed effects, concentrate around 0. One exception is Beta4, which has a higher peak than the other models with an upwards bias.

### Graph
![Graph](https://github.com/gui2de/ppol768-spring23/blob/6d75b8b9b691baaf20b5d94604c468fa89cbb93c/Individual%20Assignments/Hill%20Hannah/week09/outputs/use_wk9_q1.png)


### Descriptive Statistics

The table below shows the descriptive statistics for each of the models. Again, we see that Model 1, the bivariate regression, has substantially different values than the rest of the models that incorporate more variables and fixed effects. 

| Stat | Beta1 | Beta2 | Beta3 | Beta4 | Beta5|
| --- | ----- | ------ | ----- | ------ | ---- |
| Mean | -11.85955 | .0637742 | .0933259 | .0017102 | .0428582 |
| SD | 3.47035 | 3.161506 | 3.029504 | 3.190822 | 2.93994 |
| Minimum |  -27.84032 | -45.26399 | -45.26399 | -53.10278 | -53.10278 |
| Maximum | 10.35675 | 17.53874 | 17.53874 | 15.53005 | 15.42391 |

# Part 2: Biasing a parameter estimate using controls
Introducing more controls (with the addition of one related to the treatment) shows a larger difference between models than the in the first part. This graph shows that there is much more variation between models 1, 2, and 3-5. Model 1, the bivariate regression, produces consistent negative estimates. Model 2, the multivariate regression with no fixed effects or the inclusion of the control related to the treatment, is concentrated around zero. However, models 3-5 are almost identical to each other and it is hard to distinguish where those three models vary.

### Graph
![Graph](https://github.com/gui2de/ppol768-spring23/blob/c39d9a99a788b245bba2f241333a4e770a4c8985/Individual%20Assignments/Hill%20Hannah/week09/outputs/use_wk9_q2.png)


### Descriptive Statistics
The descriptive statistics table below shows again how closely the beta estimates are across models 3-5. The difference in beta estimates is quite stark between the bivariate regression model and the multivariate model.


| Stat | Beta1 | Beta2 | Beta3 | Beta4 | Beta5|
| --- | ----- | ------ | ----- | ------ | ---- |
|Mean	|-11.78717|	-.0121736|	-1.427405|	-1.421238	|-1.416551|
|SD	|3.505125|	2.974457	|.3300313|	.4066494|	.4102723|
|Min	|-27.71192	|-15.02476	|-3.340859|	-7.164005	|-7.164005|
|Max	|5.475519	|12.92577|	.0513222|	1.444167|	1.444167|
					

