# Week 10 - Power Calculations Assignment 
Author: Serenity Fan (kaf121)
Last Updated: April 30th, 2023

## Part 1: Calculating required sample sizes and minimum detectable effects 

[
Construct unbiased regression models to estimate the treatment parameter, and run these regressions at various sample sizes.

Calculate the "power" of these regression models, defined as "the proportion of regressions in which p<0.05 for the treatment effect". Based on this definition, find the "minimum sample size" required to obtain 80% power for regression models with and without the non-biasing controls.

![Beta_FixedPop_Graph](beta_graph_fixed.png)  
] 

I employ the same Data Generating Process (DGP) as from the W9 assignment, as applied to the simulation of a cluster RCT rehabilitation program for manual scavengers, subjected to an exogenous mechanization of their (sanitation) labor. The dependent variable is income (in INR, i.e. rupees), while the independent variables are the treatment (an employment matching & certification program), years of education, years spent working in manual scavenging, door-to-door transit time (from household to city centre), and an indicator variable for gender (female=1, male=0). Randomization occurs at the panchiyat (village) / municipality level, i.e. we work with the Uttar Pradesh government to decide, within our 3 pilot districts of Budaon, Shahjahanpur, and Farrukhabad, which villages receive mechanized de-sludging machines. For the purpose of this code, we vary and iterate the number of districts as 1, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64 (in half-unit-exponential increments) - noting that in reality, UP contains 75 districts. Each district in turn is assumed to contain 10 villages/municipalities, of which each village/municipality contains 10 households, such that N increments as N = 100, 200, 300, 400, 600, 800, ... , 6400. 

I calculate 5 different regressions of increasing complexity: 
* Model 1 (Base binary): 
income = Beta_0 + Beta_1 * treatment
* Model 2 (Add village indicators): 
income = Beta_0 + Beta_1 * treatment + Beta_2 * village_1 + ... + Beta_j * village_j, where j is the number of villages, and hence there will be j village indicators. 
* Model 3 (Add confounder, years worked in manual scavenging): 
income = Beta_0 + Beta_1 * treatment + Beta_2 * village + ... + Beta_j * village_j + scav 
* Multivariate (Add covariate, transit time): 
income = Beta_0 + Beta_1 * treatment + Beta_2 * village + ... + Beta_j * village_j + scav + transit_time
* Multivariate (Add covariate, years of education): 
income = Beta_0 + Beta_1 * treatment + Beta_2 * village + ... + Beta_j * village_j + scav + transit_time + educ

Results of the power calculations corresponding to each regression are shown in the tables below. The 'minimum sample size' required to attain the power criterion of 0.8 (80%) is found as follows: 

* Model 1: Approximately N=1100 households (Power=0.788)
* Model 2: Ranging between N=[1600, 2300] households, i.e. Power=[0.700, 0.852]
* Model 3: Ranging between N=[1600, 2300] households, i.e. Power=[0.710, 0.854]
* Model 4: Ranging between N=[1600, 2300] households, i.e. Power=[0.722, 0.864]
* Model 5: Approximately N=1600 households, i.e. Power=0.788 

In general, for all models, power values are low (close to 0) for small values of N, and increase monotonically, converging to 1 for larger values of N. 

### Regression 1: Power Calculations 
|   N    | Power |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|--------|-------|------------|---------------|---------------|
|        |       |            |               |               |
|  100   |  .212 |  .018297   |  .1761312     |  .2478688     |
|  200   |  .31  |  .020704   |  .2694126     |  .3505874     |
|  300   |  .348 |  .0213237  |  .3061978     |  .3898022     |
|  400   |  .462 |  .0223183  |  .418248      |  .505752      |
|  600   |  .62  |  .0217289  |  .5774036     |  .6625964     |
|  800   |  .706 |  .0203951  |  .6660183     |  .7459817     |
|  1100  |  .788 |   .018297  |  .7521312     |  .8238688     |
|  1600  |  .876 |  .0147541  |  .8470767     |  .9049233     |
|  2300  |  .962 |  .0085591  |  .945221      |  .978779      |
|  3200  |  .984 |   .005617  |  .9729886     |  .9950114     |
|  4500  |  .988 |  .0048744  |  .9784445     |  .9975555     | 
|  6400  |     1 |         0  |         .     |         .     | 

   
### Regression 2: Power Calculations 
|   N    | Power |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|--------|-------|------------|---------------|---------------|
|        |       |            |               |               |
|  100   |  .084 |  .0124176  |  .0596571     |  .1083429     |
|  200   |  .154 |  .0161583  |  .122324      |  .185676      |
|  300   |  .212 |  .018297   |  .1761312     |  .2478688     |
|  400   |  .268 |  .0198277  |  .2291306     |  .3068694     | 
|  600   |  .366 |  .0215643  |  .3237263     |  .4082737     |
|  800   |  .454 |  .0222881  |  .4103072     |  .4976928     |
|  1100  |  .604 |  .0218935  |  .5610808     |  .6469192     |
|  1600  |  .7   |  .0205144  |  .6597843     |  .7402157     |
|  2300  |  .852 |  .0158965  |  .8208372     |  .8831628     |
|  3200  |  .942 |  .0104638  |  .9214872     |  .9625128     |
|  4500  |  .976 |  .0068514  |  .9625688     |  .9894312     |
|  6400  |  .99  |  .0044542  |  .9812682     |  .9987318     |


### Regression 3: Power Calculations 
|   N    | Power |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|--------|-------|------------|---------------|---------------|
|        |       |            |               |               | 
|  100   |  .08  |  .0121448  |  .0561919     |  .1038081     |
|  200   |  .152 |  .016072   |  .1204931     |  .1835069     |
|  300   |  .222 |  .0186044  |  .1855287     |  .2584713     | 
|  400   |  .27  |  .0198744  |  .2310391     |  .3089609     | 
|  600   |  .382 |  .0217508  |  .3393606     |  .4246394     | 
|  800   |  .474 |  .0223528  |  .4301805     |  .5178195     |
|  1100  |  .614 |  .0217935  |  .5712768     |  .6567232     | 
|  1600  |  .71  |  .0203132  |  .6701789     |  .7498211     |
|  2300  |  .854 |  .0158072  |  .8230122     |  .8849878     |
|  3200  |  .942 |  .0104638  |  .9214872     |  .9625128     |
|  4500  |  .976 |  .0068514  |  .9625688     |  .9894312     |
|  6400  |  .992 |  .003988   |  .9841822     |  .9998178     | 

### Regression 4: Power Calculations 
|   N    | Power |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|--------|-------|------------|---------------|---------------|
|        |       |            |               |               | 
|  100   |  .088 |  .012682   |  .0631387     |  .1128613     | 
|  200   |  .16  |  .0164115  |  .1278275     |  .1921725     |
|  300   |  .228 |  .0187813  |  .1911819     |  .2648181     |
|  400   |  .268 |  .0198277  |  .2291306     |  .3068694     |
|  600   |  .386 |  .0217935  |  .3432768     |  .4287232     | 
|  800   |  .478 |  .0223614  |  .4341636     |  .5218364     |
|  1100  |  .608 |  .0218547  |  .565157      |  .650843      |
|  1600  |  .722 |  .0200558  |  .6826834     |  .7613166     |
|  2300  |  .864 |  .0153453  |  .8339176     |  .8940824     | 
|  3200  |  .952 |  .0095695  |  .9332404     |  .9707596     |
|  4500  |  .976 |  .0068514  |  .9625688     |  .9894312     |
|  6400  |  .994 |  .0034572  |  .9872227     | 1.000777      |

### Regression 5: Power Calculations 
|   N    | Power |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|--------|-------|------------|---------------|---------------|
|        |       |            |               |               | 
|   100  |  .104 |  .0136653  |  .077211      |  .130789      |
|   200  |  .152 |  .016072   |  .1204931     |  .1835069     | 
|   300  |  .254 |  .0194866  |  .2157993     |  .2922007     |
|   400  |  .314 |  .0207767  |  .2732702     |  .3547298     |
|   600  |  .428 |  .0221498  |  .3845784     |  .4714216     |
|   800  |  .53  |  .0223427  |  .4862002     |  .5737998     |
|   1100 |  .674 |  .020984   |  .6328638     |  .7151362     |
|   1600 |  .788 |  .018297   |  .7521312     |  .8238688     |
|   2300 |  .894 |  .0137807  |  .8669849     |  .9210151     |
|   3200 |  .962 |  .0085591  |  .945221      |  .978779      |
|   4500 |  .978 |  .0065664  |  .9651274     |  .9908726     |
|   6400 |     1 |         0  |         .               .



