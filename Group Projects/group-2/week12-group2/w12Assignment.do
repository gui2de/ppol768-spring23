********************************************************************************
* PPOL 768: Week 12
* Assignment for Week 12
* Michele Giunti
* April 16th, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/
clear
cd "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Research Design Implementation\week-12-practice\01-data"

/*******************************************************************************
1. Generating the data
*******************************************************************************/

*fixing some labels

import delimited Tunisia-regions.csv, delimiter(",") clear
keep id governorate
tempname lb
local N = c(N)

gen name = "REG"

by name (id), sort: gen label_command_1 = "label define " + name + " " + string(id, "%1.0f") + `" ""' + governorate + `"""' if _n == 1
by name (id): replace label_command_1 = label_command_1[_n-1] + " " + string(id, "%1.0f") + `" ""' + governorate + `"""' if _n > 1
by name (id): keep if _n == _N

gen label_command_2 = "label values " + "region" + " " + name

keep name label_command*
reshape long label_command_, i(name) j(_j)

file open handle using "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Research Design Implementation\week-12-practice\labeler.do", write replace
forvalues i = 1/`=_N' {
 file write handle (label_command[`i']) _n
}
file close handle

clear

*running the data and relabeling
do "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Research Design Implementation\week-12-practice\import_daya_users_survey.do"
drop caseid deviceid devicephonenum username device_info formdef_version key submissiondate starttime endtime

gen id = _n

label define CAT 0 "Normal" 1 "Normal but fast/slow" 2 "Incomplete"
recode id (2 3 4 5 6 7 8 9 10 12 = 0) (14 11 = 1) (1 13 = 2)
label values id CAT

expand 100

gen rando = runiform()
sort rando

gen caseid = _n
drop rando

destring region, replace
do "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Research Design Implementation\week-12-practice\labeler.do"

/*******************************************************************************
2. High Frequency Checks
*******************************************************************************/

*Transform duration to minutes
destring duration, gen(time)
drop duration

gen time_min = time/60


*Check if duration was within one minute of the mean
sum time_min

local tmean = r(mean)

gen tag = 0
replace tag = 1 if time_min > `tmean' + 1 | time_min < `tmean' - 1


*Check if the daya variables were completed or not

foreach v of varlist daya_*{
	replace tag = 2 if missing(`v')
}

*Do the tags match?

tab id tag

/*******************************************************************************
3. Summary Stats
*******************************************************************************/
*overall
preserve

gen count_long = 1 if tag == 1 | tag == 2
gen count_incomplete = 1 if tag == 2
gen count_comp = 1 if tag == 0

keep count_long count_incomplete count_comp

collapse (sum) count_long count_incomplete count_comp

export excel using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-output/highfreqcheck.xlsx", sheet("HFC_overall") replace firstrow(variables)

restore

*By Marital Status

preserve
gen count_long = 1 if tag == 1 | tag == 2
gen count_incomplete = 1 if tag == 2
gen count_comp = 1 if tag == 0

keep count_long count_incomplete count_comp marital_status

collapse (sum) count_long count_incomplete count_comp, by(marital_status)

export excel using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-output/highfreqcheck.xlsx", sheet("HFC_marital") sheetreplace firstrow(variables)

restore

*If they have children

preserve
gen count_long = 1 if tag == 1 | tag == 2
gen count_incomplete = 1 if tag == 2
gen count_comp = 1 if tag == 0

keep count_long count_incomplete count_comp children

collapse (sum) count_long count_incomplete count_comp, by(children)

export excel using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-output/highfreqcheck.xlsx", sheet("HFC_child") sheetreplace firstrow(variables)

restore

*The region is at fault?

preserve
gen count_long = 1 if tag == 1 | tag == 2
gen count_incomplete = 1 if tag == 2
gen count_comp = 1 if tag == 0

keep count_long count_incomplete count_comp region

collapse (sum) count_long count_incomplete count_comp, by(region)

export excel using "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-output/highfreqcheck.xlsx", sheet("HFC_region") sheetreplace firstrow(variables)

restore