### Data Simulation

The data for this study is structured as a panel dataset, where each row represents an observation for a given firm and year. The variables in the dataset include firm-level characteristics such as size and industry, as well as outcomes of interest such as the number of minority hires and wages. In addition, the dataset includes a variable for distance from the firm's location to the nearest Purple Line station, which will be used to examine the impact of proximity to the new transit infrastructure on minority hiring outcomes. Finally, the dataset includes a time variable indicating the year of each observation, which will be used to create the post-treatment variable used in the analysis. The data will be analyzed using a combination of descriptive statistics and regression analysis, in order to assess the impact of the Purple Line on minority hiring outcomes while controlling for other relevant variables. Note that the data visualizations produced in this simulation do not represent actual patterns in data, as all the simulated variables are random and thus do not correlate with other variables despite real-world relationships.

[The ultimate dataset would also use spatial data, e.g., latitude and longitude within the DC metro area, but our technical skills in Stata are not quite there. And the distribution of employment and residence are not random, so a randomized data simulation would not be useful]


[![Age Histogram](https://github.com/gui2de/ppol768-spring23/blob/84cf5a7e4ae3e1e88c322666a4cf8d1412057790/Group%20Projects/group-1/Week%2011/age_histogram.png)](https://github.com/gui2de/ppol768-spring23/blob/week11-group1/Group%20Projects/group-1/Week%2011/age_histogram.png)


### Descriptive Statistics for Distance to Station
|        | Percentiles | Smallest |
|------- | ----------- | -------- |
| 1% | .088285 | .0039988 |
| 5% | .2584286 | .0045272 |
| 10% | .4067165 | .0050676 |
| 50% | 1.008687 | **Largest** |
| 75% | 1.340817 | 2.594731 |
| 90% | 1.619707 | 2.624369 |
| 95% | 1.812213 | 2.625915 |
| 99% | 2.170256 | 2.637214 |


### Descriptive Statistics
| Variable | Observations | Mean | Std. Dev. | Min | Max |
|----------|--------------|------|-----------|----|-----|
| Age | 1,962 | 36.9 | 11.3 | 18 | 57 |
| Distance to Station (miles) | 1,962 | 1.0 | .5 | .004 | 2.64 |
| Salary ($) | 1,962 | 59887.27 | 10522.51 | 25487.51 | 94599.96 |
| Education | 1,962 | 2.0 | .8 | 1 | 3 |
