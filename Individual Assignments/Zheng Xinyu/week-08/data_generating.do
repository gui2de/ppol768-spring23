* Week 08 Assignment Xinyu Zheng

cd "C:\Users\zheng\Desktop\research design\ppol768-spring23\Individual Assignments\Zheng Xinyu\week-08"

clear

set seed 20230318

set obs 10000

gen x = rnormal(25, 10)

save "outputs/data.dta", replace







