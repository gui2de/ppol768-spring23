# Assignment for Week 10

## Setup 

As usual, create a branch from `instructions` at the indicated commit. Name the new branch `week10-yourNetID`. Create a folder called `week-10` inside your `Individual Assignments` folder. Create a `README.md` file inside that folder, and an `outputs` folder there as well. You will create one or more do-files; have them create outputs corresponding to the assignment below (in the `outputs` folder); then write a summary of your results in the `README.md` folder including figures and tables as you now know how to do. When you are done, create a pull request targeting the `main` branch and request a reviewer.

## Part 1: Calculating required sample sizes and minimum detectable effects

1. Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.
3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome.
4. Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.
5. Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.
6. Now, choose a sample size. Go back to the DGP and allow the size of the treatment effect to vary. With the sample size fixed, find the "minimum detectable effect size" at which you can obtain 80% power for regression models with and without the non-biasing controls.
7. Fully describe your results in your `README.md` file, including figures and tables as appropriate.

## Part 2: Calculating power for DGPs with clustered random errors

1. Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
2. Instead of having strata groups contributing to the main effect, create some portion of the random error term at the strata level (now, they are clusters, rather than strata).
3. Take the means and 95% confidence interval estimates (or, equivalently, their widths) from many regressions at various sample sizes in an unbiased regression.
4. Calculate "exact" 95% confidence interval estimates using the betas you can use the `collapse` or `mean` command for this, or use something like `lpolyci` to get 95% CIs graphically. Plot the "empirical/exact" CIs against the "analytical" ones (the ones obtained from the regression). Discuss any differences.
5. Create another DGP in which the random error terms are _only_ determined at the cluster level. Repeat the previous step here. What happens to the convergence of the "exact" CIs?
6. Can you get the "analytical" confidence intervals to be correct using the `vce()` option in `regress`?
7. Fully describe your results in your `README.md` file, including figures and tables as appropriate.
