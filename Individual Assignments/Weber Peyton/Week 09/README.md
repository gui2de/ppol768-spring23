# Part One

## Table

| samplesize | beta1     | beta2    | beta3    | beta4    | beta5    |
|------------|-----------|----------|----------|----------|----------|
| 2          | -6.174785 | 1.786596 | 1.786596 | 1.44639  | 1.44639  |
| 4          | -7.1255   | 5.089853 | 4.628936 | 4.915067 | 4.377997 |
| 8          | -6.190635 | 5.258464 | 5.262106 | 4.955775 | 5.017229 |
| 16         | -7.917865 | 3.178329 | 2.867364 | 2.97929  | 2.651316 |
| 32         | -6.181326 | 3.361786 | 3.879577 | 3.365381 | 3.885436 |
| 64         | -7.330035 | 4.171109 | 4.290443 | 4.1868   | 4.30697  |
| 128        | -7.300974 | 4.164581 | 3.917411 | 4.144523 | 3.891028 |
| 256        | -6.864319 | 3.872386 | 3.98822  | 3.875116 | 3.990573 |
| Total      | -6.88568  | 3.860388 | 3.827582 | 3.733543 | 3.695867 |

## Histogram

![Part One Histogram](Outputs/images/part_one_histogram.png) 

The story for part onee is that the missing regressors greatly distort the coeficient estimates for the "treat" variable; however, as the sample size increases in magnitude, the coeficient estimates trend toward the "true" value. 

# Part Two

## Table

| samplesize | beta1     | beta2    | beta3     | beta4    | beta5    |
|------------|-----------|----------|-----------|----------|----------|
| 2          | -8.948811 | 2.11661  | -2.96619  | 2.16415  | 2.197984 |
| 4          | -9.202532 | 1.817322 | -2.908935 | 2.096641 | 2.142497 |
| 8          | -8.806647 | 2.48455  | -2.89927  | 2.52654  | 2.52622  |
| 16         | -8.780182 | 2.601581 | -2.916113 | 2.520466 | 2.48904  |
| 32         | -8.934604 | 2.732219 | -2.92348  | 2.697639 | 2.702785 |
| 64         | -8.812121 | 2.514835 | -2.918005 | 2.438983 | 2.44148  |
| 128        | -8.801578 | 2.443127 | -2.915618 | 2.455932 | 2.457623 |
| 256        | -8.832724 | 2.53049  | -2.914227 | 2.497757 | 2.496994 |
| Total      | -8.8899   | 2.405092 | -2.92023  | 2.424763 | 2.431828 |

## Histogram

![Part Two Histogram](Outputs/images/part_two_histogram.png) 

Like in part one, absent covariates misrepresent the "true" coeficient estimate for "treat." As the sample size increases, the beta coeficient estimates draw closer to the "truth." 

Including colliders in the model is likely to introduce bias in the treatment variable's effect on the outcome. A collider is caused by both the outcome and the treatment, and it therefore should not be controlled for in a regression model; it is likely to generate a spurious relationship between the key, independent variable (x) and the outcome of interest (y), producing bias. 