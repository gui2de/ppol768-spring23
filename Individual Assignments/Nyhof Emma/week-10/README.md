# Week 10: Power

## **PART 1**
I find that the minimum sample size to get 80% power with this data is 255. The minimum treatment effect to get 80% power is smaller without controls than with controls

#### Finding minimum sample size to get 80% power
![image](https://user-images.githubusercontent.com/122739454/230805176-16954ffa-ce3e-4ba4-b469-803a04792fdf.png)

#### Minimum treatment effect without controls
![image](https://user-images.githubusercontent.com/122739454/230805197-4fd84195-770b-4023-a0ce-714bd71cf89d.png)

#### Minimum treatment effect with controls
![image](https://user-images.githubusercontent.com/122739454/230805232-7a6fbca9-3fc3-4282-b5c0-18206a57d564.png)


## **PART 2**
The clearest pattern I'm seeing here is that, unsurprisingly, the variation in confidence intervals decreases as sample size increases. I'm not sure if I'm doing something wrong, but I'm seeing very little other variation/patterns based on differences in where the random error terms are determined, and using the VCE options doesn't seem to change things either

### Some portion of random error at strata level
#### "Exact" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231271063-455a2483-3556-47f2-8017-5bf5d24d2ac8.png)

#### "Analytical" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231271276-d9aa38a1-1758-4a4b-8c2c-f049c06dd731.png)

#### Graphical results
(Note: pay attention to y-axis range here - could not for the life of me figure out how to keep the y-axis consistent across all 4 graphs wtihout them warping)
![week-10-graphs-part2](https://user-images.githubusercontent.com/122739454/235535465-ef2ae66a-a10f-4b5a-a939-5de9ce586551.PNG)

### Random error term ONLY at cluster level

#### *With Controls*
#### "Exact" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231272160-fbc63e77-6317-4d66-8b79-fefccccd3856.png)

#### "Analytic" confidenc intervals
![image](https://user-images.githubusercontent.com/122739454/231272271-34805ace-9a5a-406c-931e-244578a27053.png)

#### Graphical results
![week-10-graphs-p2-with controls](https://user-images.githubusercontent.com/122739454/235540381-bf7867ff-3b85-4fe8-83c9-9c7dd49e5539.PNG)


#### *With Controls and VCE Option*
#### "Exact" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231272478-4e70edde-f115-4b4b-8b3c-8f8d8d8a8984.png)

#### "Analytic" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231272570-e7aa59cf-fb33-4519-8ec4-19555e1c31bd.png)


#### *Without Controls*
#### "Exact" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231271520-067ad8a6-2c59-469b-9c9c-bfde8ff6e596.png)

#### "Analytical" confidence intervals
![image](https://user-images.githubusercontent.com/122739454/231271611-1362e905-1c09-4880-a85c-e303df3d8bd2.png)
