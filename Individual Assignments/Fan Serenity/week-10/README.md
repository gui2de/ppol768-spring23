# Week 10 - Power Calculations Assignment 
Author: Serenity Fan (kaf121)
Last Updated: April 30th, 2023

* Fix part 1(a), i.e. update tables and pros accordingly, as adjusted code to get confounder right* 

## Part 1 (a): Calculating required sample sizes and minimum detectable effects 

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

In general, for all models, power values are low (close to 0) for small values of N, and increase monotonically, converging to 1 for larger values of N. The minimum sample size is lowest for Model 1 at N of approximately 1100, the base binary regression case. It ranges from 1600 to 2300 households in Models 2-4, in which village indicators, a confounder, 

### Regression 1: Power Calculations (Base Binary)
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

   
### Regression 2: Power Calculations (Add Village Indicators, as village affects treatment due to randomization at village level)
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

### Regression 3: Power Calculations (Add confounder affecting both outcome and likelihood of receiving treatment, years worked in manual scavenging)
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

### Regression 4: Power Calculations (Add covariate affecting outcome but not treatment, transit time)
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

### Regression 5: Power Calculations (Add (another) covariate affecting outcome but not treatment, years of education)
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






## Part 1 (b): MDE Calculations at Power=0.8 

### Regression 1: MDE Calculations (Base Binary)
                  |       Mean   Std. err.     [95% conf. interval]
------------------+------------------------------------------------
c.sig1@treat_size |
             100  |       .334   .0211135      .2926092    .3753908
             123  |       .316   .0208124      .2751995    .3568005
             152  |       .376   .0216838      .3334911    .4185089
             187  |        .43   .0221626      .3865525    .4734475
             230  |       .498   .0223829      .4541207    .5418793
             283  |       .544   .0222962      .5002906    .5877094
             348  |       .644   .0214347      .6019795    .6860205
             429  |        .78   .0185442       .743646     .816354
             528  |       .848    .016072      .8164926    .8795074
             650  |       .912    .012682      .8871382    .9368618
             800  |       .976   .0068514      .9625685    .9894315
-------------------------------------------------------------------

### Regression 2: MDE Calculations (Add Village Indicators, as village affects treatment due to randomization at village level)

               |       Mean   Std. err.     [95% conf. interval]
------------------+------------------------------------------------
c.sig2@treat_size |
             100  |       .318   .0208476      .2771305    .3588695
             123  |       .334   .0211135      .2926092    .3753908
             152  |       .366   .0215643      .3237255    .4082745
             187  |       .432   .0221751       .388528     .475472
             230  |       .462   .0223183      .4182472    .5057528
             283  |       .582     .02208      .5387144    .6252856
             348  |        .64   .0214878      .5978755    .6821245
             429  |       .772   .0187813      .7351812    .8088188
             528  |       .862   .0154398      .8317318    .8922682
             650  |       .924   .0118629      .9007439    .9472561
             800  |       .974   .0071239      .9600344    .9879656

### Regression 3: MDE Calculations (Add confounder affecting both outcome and likelihood of receiving treatment, years worked in manual scavenging)

                 |       Mean   Std. err.     [95% conf. interval]
------------------+------------------------------------------------
c.sig3@treat_size |
             100  |       .096   .0131877      .0701469    .1218531
             123  |        .07   .0114219      .0476085    .0923915
             152  |       .108   .0138945      .0807612    .1352388
             187  |        .12   .0145473      .0914816    .1485184
             230  |        .17   .0168156      .1370347    .2029653
             283  |       .224    .018664      .1874112    .2605888
             348  |       .282   .0201436      .2425106    .3214894
             429  |       .416   .0220649       .372744     .459256
             528  |       .568   .0221751       .524528     .611472
             650  |        .72      .0201      .6805961    .7594039
             800  |       .894   .0137807      .8669844    .9210156


### Regression 4: MDE Calculations (Add covariate affecting outcome but not treatment, transit time)

                |       Mean   Std. err.     [95% conf. interval]
------------------+------------------------------------------------
c.sig4@treat_size |
             100  |       .098   .0133096      .0719079    .1240921
             123  |       .076   .0118629      .0527439    .0992561
             152  |         .1   .0134298      .0736722    .1263278
             187  |       .128   .0149559      .0986805    .1573195
             230  |       .158    .016328      .1259906    .1900094
             283  |       .218   .0184834      .1817653    .2542347
             348  |       .292   .0203544      .2520974    .3319026
             429  |       .424    .022123      .3806302    .4673698
             528  |        .57   .0221626      .5265525    .6134475
             650  |       .734   .0197806      .6952223    .7727777
             800  |         .9   .0134298      .8736722    .9263278

### Regression 5: MDE Calculations (Add (another) covariate affecting outcome but not treatment, years of education)
                  |       Mean   Std. err.     [95% conf. interval]
------------------+------------------------------------------------
c.sig5@treat_size |
             100  |       .104   .0136653      .0772105    .1307895
             123  |       .088    .012682      .0631382    .1128618
             152  |       .106   .0137807      .0789844    .1330156
             187  |       .146   .0158072      .1150116    .1769884
             230  |       .188   .0174907      .1537114    .2222886
             283  |        .22   .0185442       .183646     .256354
             348  |       .318   .0208476      .2771305    .3588695
             429  |       .484   .0223716      .4401428    .5278572
             528  |        .62   .0217289      .5774028    .6625972
             650  |       .768   .0188962       .730956     .805044
             800  |       .926   .0117185      .9030272    .9489728
