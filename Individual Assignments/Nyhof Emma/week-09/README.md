## **PART 1**

In general, the variance of the beta estimates decreases as sample size increases, and p-value and error decrease as well. While all estimates at the largest sample sizes were relatively close to the true parameter value (100), the model that included the covariate that affects the treatment but not the outcome was the furthest off. The model that most closely predicted the true parameter value was the one that included both the confounder (hoursworked) and the covariate that affected the outcome but not the treatment (age), but excluded the covariate that affected the treatment but not the outcome (unemployed). 

### Regressions
1: wkly_inc treatment

2: wkly_inc treatment i.state

3: wkly_inc treatment i.state hoursworked

4: wkly_inc treatment i.state unemployed

5: wkly_inc treatment i.state hoursworked age

### Figures
**Histogram of regression 1 betas at sample size N = 50 & N = 50000:**

![reg1_part1](https://user-images.githubusercontent.com/122739454/228043237-67ac8564-e84b-480b-8240-c50634131d32.png)

**Histogram of regression 5 betas at sample size N = 50 & N = 50000:**

![reg5_part1](https://user-images.githubusercontent.com/122739454/228043686-bf25b613-dca6-4863-b3e2-78dab97d88e0.png)

### Tables
**Regression 1: wkly_inc treatment**

![image](https://user-images.githubusercontent.com/122739454/228048853-41ec6d9d-e338-4427-ad98-edf688720e84.png)

**Regression 2: wkly_inc treatment i.state**

![image](https://user-images.githubusercontent.com/122739454/228048885-125b35c5-85d1-4aa6-8efd-feaa7ea0e64f.png)

**Regression 3: wkly_inc treatment i.state hoursworked**

![image](https://user-images.githubusercontent.com/122739454/228049095-ed6e15d7-b0ea-4753-a99f-7f5360d4a820.png)

**Regression 4: wkly_inc treatment i.state unemployed**

![image](https://user-images.githubusercontent.com/122739454/228049133-71699c0b-ad66-4830-b174-c4bf99ce3ac3.png)

**Regression 5: wkly_inc treatment i.state hoursworked age**

![image](https://user-images.githubusercontent.com/122739454/228048805-cd85f5bf-34a8-44ae-a9ee-eda3779c55a4.png)


## **PART 2**
Again, the variance of the beta estimates decreases as sample size increases. In this case, estimates are very far off from the true value (100) unless the channel variable is included. 

### Regressions
1: wkly_inc treatment

2: wkly_inc treatment i.state

3: wkly_inc treatment i.state channel

4: wkly_inc treatment i.state collider

5: wkly_inc treatment i.state channel collider

### Figures
**Histogram of regression 1 betas at sample size N = 50 & N = 50000:**

![reg1_part2](https://user-images.githubusercontent.com/122739454/228046725-b0c46694-1045-4a53-9853-a84f0a3063be.png)

**Histogram of regression 3 betas at sample size N = 50 & N = 50000:**

![reg3_part2](https://user-images.githubusercontent.com/122739454/228046959-3a988b85-e769-42bc-b712-e6e0a355aab6.png)

**Histogram of regression 4 betas at sample size N = 50 & N = 50000:**

![reg4_part2](https://user-images.githubusercontent.com/122739454/228046993-2128f2f1-5b74-46ed-ba09-1d40620188c6.png)

### Tables

**Regression 1: wkly_inc treatment**

![image](https://user-images.githubusercontent.com/122739454/228041696-85130833-0ef5-4dc3-8c89-c68af0a52958.png)

**Regression 2: wkly_inc treatment i.state**

![image](https://user-images.githubusercontent.com/122739454/228042062-a445b5e7-398c-4c98-b074-bd5751436798.png)

**Regression 3: wkly_inc treatment i.state channel**

![image](https://user-images.githubusercontent.com/122739454/228042479-955d188f-12c1-4961-a69d-3fb090d9ff2f.png)

**Regression 4: wkly_inc treatment i.state collider**

![image](https://user-images.githubusercontent.com/122739454/228042804-f9dea03a-771b-4a20-838b-75907f824cdd.png)

**Regression 5: wkly_inc treatment i.state channel collider**

![image](https://user-images.githubusercontent.com/122739454/228042877-52bb79b6-f54e-4c10-a678-d8ddd6438cc9.png)
