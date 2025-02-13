For Part 1, I created a random variable x and randomly assigned half the sample size to a treatment variable. The outcome variable y is a function of x with random noise.

A simulation pulled 500 samples of this fixed-population dataset and generated a table of key statistics (betas, p values, standard errors, confidence intervals) at different sample sizes (10, 100, 100, 1000) to illustrate how random noise's impact will vary.

The smaller the sample size, the wider the distribution of estimated betas. With a sample size of 10, the betas are widely dispersed across the true mean and make precise and accurate estimations impossible. At a sample size of 1000, the random draws of the beta are statistically significantly centered on the true value.

As the sample size grows, the SE shrinks closer to zero. Similarly, the confidence interval shrinks and is increasingly centered on the true mean.
