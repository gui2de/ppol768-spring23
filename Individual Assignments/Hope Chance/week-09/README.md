# Assignment for Week 09

## Setup

As usual, create a branch from `instructions` at the indicated commit. Name the new branch `week09-yourNetID`. Create a folder called `week-09` inside your `Individual Assignments` folder. Create a `README.md` file inside that folder, and an `outputs` folder there as well. You will create one or more do-files; have them create outputs corresponding to the assignment below (in the `outputs` folder); then write a summary of your results in the `README.md` folder including figures and tables as you now know how to do. When you are done, create a pull request targeting the `main` branch and request a reviewer.

## Part 1: De-biasing a parameter estimate using controls

1. Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable and treatment effect. Like last week, you should strongly consider "simulating" data along the lines of your group project.
2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.
3. Make sure that at least one of the continuous covariates also affects both the outcome and the likelihood of receiving treatment (a "confounder"). Make sure that another one of the covariates affects the outcome but not the treatment. Make sure that another one affects the treatment but not the outcome. (What do these do?)
4. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type `h fvvarlist` for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a `program` like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N? Can you visually compare these to the "true" parameter value?
6. Fully describe your results in your `README.md` file, including figures and tables as appropriate.

## Part 2: Biasing a parameter estimate using controls

1. Develop some data generating process for data X’s and for outcome Y, with some (potentially multi-armed) treatment variable.
2. This DGP should include strata groups and continuous covariates, as well as random noise. Make sure that the strata groups affect the outcome Y and are of different sizes, and make the probability that an individual unit receives treatment vary across strata groups. You will want to create the strata groups first, then use a command like `expand` or `merge` to add them to an individual-level data set.
3. When creating the outcome, make sure there is an intermediate variable that is a function of treatment. Have this variable determine Y in the true DGP, not the treatment variable itself. (This is a "channel".)
4. In addition, create a second independent variable that is a function of both Y and the treatment variable. (This is a "collider".)
5. Construct at least five different regression models with combinations of these covariates and strata fixed effects. (Type `h fvvarlist` for information on using fixed effects in regression.) Run these regressions at different sample sizes, using a `program` like last week. Collect as many regression runs as you think you need for each, and produce figures and tables comparing the biasedness and convergence of the models as N grows. Can you produce a figure showing the mean and variance of beta for different regression models, as a function of N?
6. Fully describe your results in your `README.md` file, including figures and tables as appropriate.
