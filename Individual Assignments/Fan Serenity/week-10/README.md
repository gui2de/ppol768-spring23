# Week 10 - Power Calculations Assignment 
Author: Serenity Fan (kaf121)
Last Updated: May 1st, 2023

* Fix part 1(a), i.e. update tables and pros accordingly, as adjusted code to get confounder right* 

## Part 1 (a): Calculating required sample sizes and minimum detectable effects 

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

* Model 1: Approximately N=800 households (Power=0.77)
* Model 2: Ranging between N=[800, 1100] households, i.e. Power=[0.736, 0.86]
* Model 3: Approximately N=2300 households (Power=0.804)
* Model 4: Approximately N=2300 households (Power=0.832)
* Model 5: Approximately N=[1600, 2300] households, i.e. Power=[0.772, 0.864] 

In general, for all models, power values are low (close to 0) for small values of N, and increase monotonically, converging to 1 for larger values of N. The minimum sample size is lowest for Model 1 at N of approximately 800, the base binary regression case. The most notably increase in minimum sample size required to attain power of 0.8 occurs in model 3, which requires a factor of ~2-3 times increase in sample size compared to previous models. This can be explained by the inclusion of the confounder in model 3, scav (number of years worked in the manual scavenging field), which affects both the probability of treatment, and the outcome (income).

### Regression 1: Power Calculations (Base Binary)
|     N       |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|-------------|------------|------------|---------------|---------------|
|             |            |            |               |               |
|        100  |        .23 |  .0188391  |    .1930687   | .2669313      |
|        200  |       .284 |  .0201867  |    .2444268   | .3235732      |
|        300  |       .414 |  .0220495  |    .3707751   | .4572249      | 
|        400  |       .508 |  .0223802  |    .4641267   | .5518733      |
|        600  |        .68 |  .0208823  |    .6390631   | .7209369      |
|        800  |        .77 |  .0188391  |    .7330687   | .8069313      |
|       1100  |       .858 |  .0156256  |    .8273681   | .8886319      | 
|       1600  |       .964 |  .0083395  |    .9476516   | .9803484      |
|       2300  |       .972 |  .0073852  |    .9575224   | .9864776      |
|       3200  |       .984 |   .005617  |    .9729886   | .9950114      |
|       4500  |       .996 |  .0028256  |    .9904608   | 1.001539      |
|       6400  |       .998 |      .002  |    .9940793   | 1.001921      | 
 

   
### Regression 2: Power Calculations (Add Village Indicators, as village affects treatment due to randomization at village level)
|       N     |       Mean |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|-------------|------------|------------|---------------|---------------|
|             |            |            |               |               |
|        100  |       .186 |  .0174188  |    .1518529   | .2201471      |
|        200  |       .252 |  .0194357  |     .213899   | .290101       |
|        300  |       .374 |  .0216607  |    .3315372   | .4164628      |
|        400  |       .494 |  .0223815  |    .4501243   | .5378757      |
|        600  |       .644 |  .0214347  |    .6019803   | .6860197      |
|        800  |       .736 |  .0197329  |    .6973165   | .7746835      |
|       1100  |        .86 |  .0155333  |    .8295492   | .8904508      |
|       1600  |        .95 |  .0097566  |    .9308736   | .9691264      |
|       2300  |       .976 |  .0068514  |    .9625688   | .9894312      |
|       3200  |       .986 |  .0052596  |    .9756893   | .9963107      |
|       4500  |       .994 |  .0034572  |    .9872227   | 1.000777      |
|       6400  |       .996 |  .0028256  |    .9904608   | 1.001539      |


### Regression 3: Power Calculations (Add confounder affecting both outcome and likelihood of receiving treatment, years worked in manual scavenging)
|      N      |       Mean |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|-------------|------------|------------|---------------|---------------|
|             |            |            |               |               |
|        100  |       .098 |  .0133096  |    .0719083   | .1240917      |
|        200  |       .142 |  .0156256  |    .1113681   | .1726319      |
|        300  |       .192 |  .0176322  |    .1574346   | .2265654      |
|        400  |       .266 |  .0197806  |     .227223   |  .304777      |
|        600  |       .348 |  .0213237  |    .3061978   | .3898022      |
|        800  |       .436 |   .022199  |    .3924821   | .4795179      |
|       1100  |       .572 |  .0221498  |    .5285784   | .6154216      |
|       1600  |       .696 |  .0205916  |     .655633   |  .736367      |
|       2300  |       .804 |  .0177708  |    .7691629   | .8388371      |
|       3200  |       .904 |  .0131877  |    .8781473   | .9298527      |
|       4500  |       .968 |  .0078788  |    .9525546   | .9834454      |
|       6400  |       .992 |   .003988  |    .9841822   | .9998178      |


### Regression 4: Power Calculations (Add covariate affecting outcome but not treatment, transit time)
|      N      |       Mean |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|-------------|------------|------------|---------------|---------------|
|             |            |            |               |               |
|        100  |       .098 |  .0133096  |    .0719083   | .1240917      |
|        200  |       .146 |  .0158072  |    .1150122   | .1769878      |
|        300  |       .184 |  .0173462  |    .1499953   | .2180047      |
|        400  |       .278 |  .0200558  |    .2386834   | .3173166      |
|        600  |       .358 |  .0214614  |    .3159279   | .4000721      |
|        800  |       .426 |  .0221366  |    .3826044   | .4693956      |
|       1100  |       .588 |  .0220337  |    .5448061   | .6311939      |
|       1600  |       .714 |  .0202293  |    .6743432   | .7536568      |
|       2300  |       .832 |  .0167366  |    .7991903   | .8648097      |
|       3200  |       .922 |   .012005  |    .8984659   | .9455341      |
|       4500  |       .974 |  .0071239  |    .9600347   | .9879653      |
|       6400  |        .99 |  .0044542  |    .9812682   | .9987318      |

### Regression 5: Power Calculations (Add (another) covariate affecting outcome but not treatment, years of education)
|      N      |       Mean |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|-------------|------------|------------|---------------|---------------|
|             |            |            |               |               |
|        100  |       .104 |  .0136653  |    .077211    | .130789       |
|        200  |       .168 |  .0167366  |    .1351903   | .2008097      | 
|        300  |       .208 |  .0181695  |    .1723812   | .2436188      | 
|        400  |        .31 |   .020704  |    .2694126   | .3505874      | 
|        600  |       .376 |  .0216838  |    .3334919   | .4185081      | 
|        800  |       .498 |  .0223829  |    .4541215   | .5418785      | 
|       1100  |       .654 |   .021295  |    .6122542   | .6957458      | 
|       1600  |       .772 |  .0187813  |    .7351819   | .8088181      | 
|       2300  |       .864 |  .0153453  |    .8339176   | .8940824      | 
|       3200  |       .942 |  .0104638  |    .9214872   | .9625128      | 
|       4500  |       .984 |   .005617  |    .9729886   | .9950114      | 
|       6400  |       .992 |   .003988  |    .9841822   | .9998178      | 



## Part 1 (b): MDE Calculations at Power=0.8 

The following tables show calculations to determine the minimum detectable effect (MDE), when the number of observations N is set at 1000 households. This value was chosen from inspection of the data in the previous part of Part 1 above. Then, rather than setting the size of the treatment (for treated households) as being a (random) normal distribution with mean 500 and standard deviation 100, the treatment size is set as a (random) normal distribution with mean 100 (and standard deviation 20), multiplied by a treatment scale factor ranging from 1 to 8 (varying quadratically between these minimum and maximum values). Multiplying these together produces the Treatment Effect Size, measured in INR. By running the power calculations for each treatment size (for a given regression model), we can determine the MDE for an arbitrary target power value, such as 0.8. 

In summary, the MDE's for each regression model are: 
* Model 1: Approximately 429 INR (Power=0.78) 
* Model 2: Between (429-528) INR (Power=[0.772, 0.862])
* Model 3: Between (650-800) INR (Power=[0.72, 0.894])
* Model 4: Between (650-800) INR (Power=[0.734, 0.9])
* Model 5: Approximately 650 INR (Power=0.768)

To contextualize the substantive significance of these MDE values, consider that a typical manual scavenger may make on the order of ~10,000 INR (~120 USD) per month in wages; this is reflected in the DGP equation, which has an intercept of 10,000 INR, i.e. for a male 'manual scavenger' with 0 years of education, 0 years of manual scavenging experience, and 0 transit time. In this respect, the smallest treatment effect size we can detect at a reasonable power, in proportional terms, ranges from 4% to 8% of the dependent variable in question (income). If our employment matching and certification program boosts incomes by less than this proportion, then we will not be able to detect this change with suitable power. 

### Regression 1: MDE Calculations (Base Binary)
|Treatment Effect  |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|Size (INR)        |            |            |               |               |
|------------------|------------|------------|---------------|---------------|
|                  |            |            |               |               |
|             100  |       .334 |  .0211135  |    .2926092   | .3753908      |
|             123  |       .316 |  .0208124  |    .2751995   | .3568005      |
|             152  |       .376 |  .0216838  |    .3334911   | .4185089      |
|             187  |        .43 |  .0221626  |    .3865525   | .4734475      |
|             230  |       .498 |  .0223829  |    .4541207   | .5418793      |
|             283  |       .544 |  .0222962  |    .5002906   | .5877094      |
|             348  |       .644 |  .0214347  |    .6019795   | .6860205      |
|             429  |        .78 |  .0185442  |     .743646   |  .816354      |
|             528  |       .848 |   .016072  |    .8164926   | .8795074      |
|             650  |       .912 |   .012682  |    .8871382   | .9368618      |
|             800  |       .976 |  .0068514  |    .9625685   | .9894315      |

### Regression 2: MDE Calculations (Add Village Indicators, as village affects treatment due to randomization at village level)

|Treatment Effect  |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|Size (INR)        |            |            |               |               |
|------------------|------------|------------|---------------|---------------|
|                  |            |            |               |               |
|             100  |       .318 |  .0208476  |    .2771305   | .3588695      |
|             123  |       .334 |  .0211135  |    .2926092   | .3753908      |
|             152  |       .366 |  .0215643  |    .3237255   | .4082745      |
|             187  |       .432 |  .0221751  |     .388528   |  .475472      |
|             230  |       .462 |  .0223183  |    .4182472   | .5057528      |
|             283  |       .582 |    .02208  |    .5387144   | .6252856      |
|             348  |        .64 |  .0214878  |    .5978755   | .6821245      |
|             429  |       .772 |  .0187813  |    .7351812   | .8088188      |
|             528  |       .862 |  .0154398  |    .8317318   | .8922682      |
|             650  |       .924 |  .0118629  |    .9007439   | .9472561      |
|             800  |       .974 |  .0071239  |    .9600344   | .9879656      |

### Regression 3: MDE Calculations (Add confounder affecting both outcome and likelihood of receiving treatment, years worked in manual scavenging)

|Treatment Effect  |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|Size (INR)        |            |            |               |               |
|------------------|------------|------------|---------------|---------------|
|                  |            |            |               |               |
|             100  |       .096 |  .0131877  |    .0701469   | .1218531      |
|             123  |        .07 |  .0114219  |    .0476085   | .0923915      |
|             152  |       .108 |  .0138945  |    .0807612   | .1352388      |
|             187  |        .12 |  .0145473  |    .0914816   | .1485184      |
|             230  |        .17 |  .0168156  |    .1370347   | .2029653      |
|             283  |       .224 |   .018664  |    .1874112   | .2605888      |
|             348  |       .282 |  .0201436  |    .2425106   | .3214894      |
|             429  |       .416 |  .0220649  |     .372744   |  .459256      |
|             528  |       .568 |  .0221751  |     .524528   |  .611472      |
|             650  |        .72 |     .0201  |    .6805961   | .7594039      |
|             800  |       .894 |  .0137807  |    .8669844   | .9210156      |


### Regression 4: MDE Calculations (Add covariate affecting outcome but not treatment, transit time)

|Treatment Effect  |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper |
|Size (INR)        |            |            |               |               |
|------------------|------------|------------|---------------|---------------|
|                  |            |            |               |               |
|             100  |       .098 |  .0133096  |    .0719079   | .1240921      |
|             123  |       .076 |  .0118629  |    .0527439   | .0992561      |
|             152  |         .1 |  .0134298  |    .0736722   | .1263278      |
|             187  |       .128 |  .0149559  |    .0986805   | .1573195      |
|             230  |       .158 |   .016328  |    .1259906   | .1900094      |
|             283  |       .218 |  .0184834  |    .1817653   | .2542347      |
|             348  |       .292 |  .0203544  |    .2520974   | .3319026      |
|             429  |       .424 |   .022123  |    .3806302   | .4673698      |
|             528  |        .57 |  .0221626  |    .5265525   | .6134475      |
|             650  |       .734 |  .0197806  |    .6952223   | .7727777      |
|             800  |         .9 |  .0134298  |    .8736722   | .9263278      |

### Regression 5: MDE Calculations (Add (another) covariate affecting outcome but not treatment, years of education)
|Treatment Effect  |    Mean    |  Std. err. | 95% CI, Lower | 95% CI, Upper|
|Size (INR)        |            |            |               |               |
|------------------|------------|------------|---------------|---------------|
|                  |            |            |               |               |
|             100  |       .104 |  .0136653  |    .0772105   | .1307895      |
|             123  |       .088 |   .012682  |    .0631382   | .1128618      |
|             152  |       .106 |  .0137807  |    .0789844   | .1330156      |
|             187  |       .146 |  .0158072  |    .1150116   | .1769884      |
|             230  |       .188 |  .0174907  |    .1537114   | .2222886      |
|             283  |        .22 |  .0185442  |     .183646   |  .256354      |
|             348  |       .318 |  .0208476  |    .2771305   | .3588695      |
|             429  |       .484 |  .0223716  |    .4401428   | .5278572      |
|             528  |        .62 |  .0217289  |    .5774028   | .6625972      |
|             650  |       .768 |  .0188962  |     .730956   |  .805044      |
|             800  |       .926 |  .0117185  |    .9030272   | .9489728      |
