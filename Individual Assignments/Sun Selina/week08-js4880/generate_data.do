global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week08-js4880/"


*create a dataset that randomly contained 10000 observations
set seed 20230402
set obs 10000
gen x = rnormal(100,5)
*save the dataset in the week folder 
save week08, replace

