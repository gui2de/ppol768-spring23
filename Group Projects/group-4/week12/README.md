# Group #4 Week 12 

Codes for High Frequency Checks to improve data quality.

## Introduction 

### About our dataset
We hypothesize our data as survey questions collected by SurveyCTO. The survey is designed to ask companies about their carbon emission and factors that are associated with the carbon emission like production level, energy efficiency and technology innovations from 2010 to 2016. The 11 states that only implemented single-sector programs is our controlled group and California that only implemented multi-sector program is our treatment group. 

### Potential Problems

* Checking duplicated ids and values: Survey may be filled by the same company multiple times. We can check duplicates using unique user id. Besides the company may fill the same emission value for each year. We have checked duplications for all continuous variables and tabled them in the output. 

* Checking missing variables: Company may leave some questions and numbers blank when they don't have the data. We checked missing blanks for each observation and tagged any observations that have at least one missing value. 

* Checking time-duration for filling out the survey: Companies may fill the survey too quickly. We checked for any observations filled within 5 minutes. 

* Check distribution and outliers: data may be wrongly input or fabricated poorly by the company. For distinct values, we visualized the frequency for each variable and tabled them in the output. For outliers, we tagged any value that is three standard deviations away from the mean and tabled them in the output. 

[Note: DGP is in do.file]

## Authors

Group members:
* Xinyu Zheng
* Ming Zhou
* Jiawei Sun
