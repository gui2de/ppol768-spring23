/*******************************************************************************

Week 12 Assignment 
Group 6 


*******************************************************************************/

clear 
use "/Users/diana/Desktop/Github/ppol768-spring23/Group Projects/group-6/w12/surveys_day1.dta"

global dashboard "/Users/diana/Desktop/Github/ppol768-spring23/Group Projects/group-6/w12/HFC.xlsx"



gen abnormal_children_amount= children>=5
gen abnormal_caretime= abnormal_children_amount & caretime <=20
replace abnormal_caretime=. if abnormal_caretime==0 // had to do this because if left as a dummy then the graph of errors by enumerator did not work

gen abnormality = 1 if children>=5 & caretime <= 20
replace abnormality = 0 if abnormality == .

list household_id enumerator if abnormal_caretime


graph bar (count) abnormal_caretime, over(enumerator)
sepscatter children caretime, separate(abnormality)


export excel household_id caretime children enumerator abnormality using "$dashboard" if abnormality == 1, sheet("hfc") sheetreplace firstrow(variables)
