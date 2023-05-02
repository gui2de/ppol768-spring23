*******************************************************************************
*** PPOL 768-01
*** Student: Gustavo Murillo Velazquez
*** Week 05 Assignment
*******************************************************************************

** Setting A Global Working Directory
clear
global wd "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-05"

** Setting Global Datasets

global PSLE "$wd/q1_psle_student_raw.dta"
global CIV "$wd/q2_CIV_Section_0"
global CIV2 "$wd/q2_CIV_populationdensity.xlsx"
global GPS "$wd/q3_GPS Data.dta"
global TZQ4 "$wd/q4_Tz_election_2010_raw.xls"
global TZQ5 "$wd/q5_Tz_ArcGIS_intersection.dta"
global TZ10 "$wd/q5_Tz_elec_10_clean.dta"
global TZ15 "$wd/q5_Tz_elec_15_clean.dta"

************************** Question 1 ****************************************

clear
tempfile student_clean
save `student_clean', replace emptyok

forvalues i=1/10 {
	use "$PSLE", clear
	
	display as error "This is loop number `i'"
	keep in `i'
	do "$Q4_Code" // My own do file from Q4 from assignment 04
	
	append using `student_clean'
	save `student_clean', replace
}

use `student_clean', replace emptyok
exit

************************** Question 2 ****************************************
use "$CIV", clear

** unstring and keepign the only variable we're interested in
decode b06_departemen, gen(department)

tempfile svy_data
save `svy_data'
import excel "$CIV2", sheet("Population density") firstrow clear

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT" )
sort NOMCIRCONSCRIPTION

** Generating a new department variable to eliminate unnecessary text and to be matched when merging
gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE","",.)
replace department = subinstr(department, "DEPARTEMENT DU","",.)
replace department = strtrim(department)
replace department = lower(department)
replace department = "arrha" if department=="arrah"

rename DENSITEAUKM pop_density_km2
keep pop_density_km2 department

merge 1:1 department using `svy_data'
drop if _merge==1 // There is no survey data for this observation
order department pop_density_km2 


************************** Question 3 ****************************************
use "$GPS", clear
keep in 1
rename * one_*
cross using "$GPS"

help geodist
geodist one_latitude one_longitude  latitude longitude, generate(distance)
sort distance
drop if one_id == id

682, 749, 748, 669, 668
gen 

use `master', clear
rename id id_master
cross using `using'
count
assert `r(N)' == 36
list, clean

*Append new 6 


** IDEA
gen serial = _n
keep first 5 _n

gen nb_store_500m = 0
replace nb_store_500m = | if distance_km<=0.5
bysort one_unique_id: egen total_nb = total(nb_store_500m)
duplicates drop one_unique_id


************************** Question 4 ****************************************
clear
import excel "/Users/gustavomurillovelazquez/Documents/GitHub/ppol768-spring23/Individual Assignments/Murillo Gustavo/week-05/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring

*Dropping first observation which contains no useful information
drop in 1
gen serial = _n

*Filling the empty values for REGION, DISTRICT, COSTITUENCY, and WARD
replace REGION = REGION[_n-1] if REGION ==""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT ==""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY ==""
replace WARD = WARD[_n-1] if WARD ==""

*Generating a new variable where we can distinguish all the existing wards.
gen unique_ward = REGION + " " + DISTRICT + " " + WARD

fillin unique_ward POLITICALPARTY
sort unique_ward _fillin

*Filling the empty values for REGION, DISTRICT, COSTITUENCY, and WARD for new observations created through fillin
replace REGION = REGION[_n-1] if REGION ==""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT ==""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY ==""
replace WARD = WARD[_n-1] if WARD ==""

keep unique_ward POLITICALPARTY TTLVOTES
sort unique_ward POLITICALPARTY
*bysort unique_ward: gen j=_n

*Using real function to convert TTLVOTES (stored as a string variable) to a numeric variable.
gen numTTLVOTES = real(TTLVOTES)

***Since there are is a case where one political party has two candidates in one ward, we need to add them.
bysort POLITICALPARTY unique_ward: egen TTLPVOTES = total(numTTLVOTES)

*Identify duplicates parties within a ward
duplicates tag POLITICALPARTY unique_ward, gen(dups) 

*generate a serial within the duplicate cases, we can use this to drop one observation
bysort POLITICALPARTY unique_ward: gen duplicate_serial = _n

drop if dups==1 & duplicate_serial==2 

sort unique_ward POLITICALPARTY

*generate j variable
bysort unique_ward (POLITICALPARTY): gen j=_n

************************** Question 5 ****************************************

use "$TZQ5", clear

** Keeping relevant variables and renaming vbariables
keep region_gis_2017 district_gis_2017 ward_gis_2017
rename region_gis_2017 region
rename district_gis_2017 district
rename ward_gis_2017 ward


** sorting variables to generate an identifier
sort region district ward
generate disid = _n

**creating a tempfile
tempfile gis_15
save `gis_15'

use "$TZ10", clear

** Repeting same process with the new data
tempfile 2010data
keep region_10 district_10 ward_10
duplicates drop
rename region_10 region
rename district_10 distrct
rename ward_10 ward 
** sorting variables to generate an identifier
sort region district ward
gen idvar = _n 
save `2010data'


use "$TZ15", clear

** Repeting same process with the new data
tempfile 2015data
keep region_15 district_15 ward_15
duplicates drop
rename region_15 region
rename district_15 distrct
rename ward_15 ward 
** sorting variables to generate an identifier
sort region district ward
gen idvar = _n 
save `2015data'

** I got confused here on how to merge using tempfiles but this is what I came up with 

use gis_15
merge m:m region district ward using 2010data
keep if merge == 3
save merge1

use merge1
merge m:m region district ward using 2015data
keep if merge == 3
save mergefinal

