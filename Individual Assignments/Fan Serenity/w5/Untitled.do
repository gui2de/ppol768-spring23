********************************************************************************
* PPOL 768: Week 5
* Handling datasets in Stata
* Ali Hamza
* Feb 14th, 2023
********************************************************************************
clear 
set seed 1
set more off
********************************************************************************


*Working Directory
global wd "C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\w5"

*Datasets
global tz_elec_15_raw "$wd/Tanzania_election_2015_raw.dta"
global tz_elec_15_clean "$wd/Tz_elec_15_clean.dta"
global tz_elec_10_clean "$wd/Tz_elec_10_clean.dta"
global tz_15_10_gis "$wd/Tz_GIS_2015_2010_intersection.dta"

global store_location "$wd/store_location_bufferzone.dta"

global kenya_baseline "$wd/kenya_education_baseline.dta"
global kenya_endline  "$wd/kenya_education_endline.dta"



/********************************************************************************
*Stata Cheat Sheets
********************************************************************************

https://www.stata.com/bookstore/statacheatsheets.pdf


********************************************************************************/





********************************************************************************
*Merge
********************************************************************************

*Merge 1:1 example Baseline/endline

use "$kenya_baseline",clear
merge 1:1 pseudo_idvar using "$kenya_endline"



use "$kenya_endline",clear
merge 1:1 pseudo_idvar using "$kenya_baseline"

*Is this the same?
 

 
 
********************************************************************************
*cf (comparing datasets) 
*USE FOR DEBUGGING PURPOSES
********************************************************************************
use "$tz_elec_10_clean", clear

*replace ward name where ward_id ==77
replace ward_10 = "WASHINGTON DC" if ward_id_10==77
tempfile edited_data
save `edited_data'

use "$tz_elec_10_clean", clear

cf _all using `edited_data' 


 

********************************************************************************
*Fillin
********************************************************************************
*"FILLS IN" ALL POSSIBLE COMBINATIONS of sex, race, age_group, etc. 
webuse fillin1, clear
list
fillin sex race age_group
list

********************************************************************************
*Joinby Vs Cross
********************************************************************************

*Difference between Joinby and Cross

clear

// CREATE "MASTER" DATA SET
set obs 6
gen int id = ceil(_n/3)
gen x = round(runiform()*10,1)
list, clean
tempfile master
save `master'

// CREATE "USING" DATA SET
clear
set obs 6
gen int id = ceil(_n/3)
gen y = round(runiform()*10,1)
list, clean
tempfile using
save `using'


*Use Cross
use `master', clear
rename id id_master
cross using `using'
count
assert `r(N)' == 36
list, clean


**Use Joinby 
use `master', clear
joinby id using `using'
count
assert `r(N)' == 18
list, clean


*example: Buffer Zone Calculations: calculate the number of stores within 500 meters of each store? 
use "$store_location", clear
*in class demo

********************************************************************************
*cf (comparing datasets)
********************************************************************************
use "$tz_elec_10_clean", clear

*replace ward name where ward_id ==77
replace ward_10 = "WASHINGTON DC" if ward_id_10==77
tempfile edited_data
save `edited_data'

use "$tz_elec_10_clean", clear

cf _all using `edited_data' 

 
********************************************************************************
*Reclink2 (assignment)
********************************************************************************


use "$tz_15_10_gis", clear 

keep region_gis_2017 district_gis_2017 ward_gis_2017
duplicates drop 
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n

tempfile gis_15
save `gis_15'


use "$tz_elec_15_clean", clear 
keep region_15 district_15 ward_15
duplicates drop
rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar = _n


reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score) 
 
******************************************************************************** 
*IN class Demos:

*example Tanzania 2015 election
use "$tz_elec_15_raw", clear
*in class demo?
 
 

 
*ASSIGNMENT WEEK 5 NOTES 
* 1. Run the data cleaning code from week 4, for each school_ID 
* 2. 
* 3. Cluster analysis? Travelling Salesman question? 
*
* NB: 3 of the questions can be done using the tools we already learned from first 2 weeks 
*
