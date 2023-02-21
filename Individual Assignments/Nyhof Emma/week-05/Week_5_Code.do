clear all
********************************************************************************
*                                  Q1                                          *
********************************************************************************
cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-05"

use q1_psle_student_raw.dta
tempfile raw
save `raw'

clear
tempfile all
save `all', emptyok

forvalues i = 1/138 {

	use `raw'
	keep in `i'
	
	split s, p("SUBJECTS")
	drop s1

	split s2, p("</TR>")
	drop s s2 s21  // s218

	gen serial = _n
	reshape long s, i(serial) j(j)

	split s, p(">")

	keep schoolcode s5 s10 s15 s20 s25

	forvalues j = 5(5)25 {
		split s`j', p("</FONT")
		drop s`j'
	}

	split s251, p(",")
	drop s251

	forvalues j = 11/17 {
		replace s25`j' = substr(s25`j', -1, .)
	}

	rename s51 cand_id
	rename s101 prem_number
	rename s151 gender
	rename s201 name
	rename s2511 kiswahili_grade
	rename s2512 english_grade
	rename s2513 maarifa_grade
	rename s2514 hisabati_grade
	rename s2515 science_grade
	rename s2516 uraia_grade
	rename s2517 avg_grade
	
	append using `all'
	
	save `all', replace
	clear
	
}
use `all'
drop if cand_id == ""
save week4_q1_data_cleaned.dta, replace
clear

********************************************************************************
*                                    Q2                                        *
********************************************************************************
clear
* We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

import excel "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-05\q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow clear

gen original_order = _n
rename NOMCIRCONSCRIPTION location

*gen district =  (substr(location, 1, 8) == "DISTRICT")
*gen region = (substr(location, 1, 6) == "REGION")
gen departement = (substr(location, 1, 11) == "DEPARTEMENT")
*gen city = (district == 0 & region == 0 & departement == 0)

keep if departement == 1
drop departement

split location
split location2, p(')

gen departement_string = location3
replace departement_string = location22 if departement_string == ""
drop location*
tempfile pop_density
save `pop_density'

use q2_CIV_Section_0.dta, clear
decode b06_departemen, gen(departement_string)
replace departement_string = upper(departement_string)
* when I first ran these were mismatched, assuming one is a mispelling - according to Google Arrah looks to be the correct spelling
replace departement_string = "ARRAH" if departement_string == "ARRHA"


merge m:1 departement_string using `pop_density'
keep if _merge == 3
drop _merge


********************************************************************************
*                                    Q3                                        *
********************************************************************************

* We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.


********************************************************************************
*                                    Q4                                        *
********************************************************************************

*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.
import excel "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-05\q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow clear

gen serial = _n

*1. Delete the first row and column K
drop if _n == 1
drop K

*2 Combine sex columns
gen gender = ""
replace gender = "M" if SEX == "M"
replace gender = "F" if G == "F"
drop SEX G

*Populate the empty cells for region, district
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""

gen unique_ward = REGION + "_" + DISTRICT + "_" + WARD 

replace POLITICALPARTY = "APPT_MAENDELEO" if POLITICALPARTY == "APPT - MAENDELEO"
replace POLITICALPARTY = "JAHAZI_ASILIA" if POLITICALPARTY == "JAHAZI ASILIA"
replace POLITICALPARTY = "NCCR_MAGEUZI" if POLITICALPARTY == "NCCR-MAGEUZI"

replace TTLVOTES = "" if TTLVOTES == "UN OPPOSSED"
destring TTLVOTES, replace

duplicates tag unique_ward POLITICALPARTY, gen(dup)

bysort unique_ward POLITICALPARTY: egen ttlvotesdup = total(TTLVOTES) if dup !=0
replace TTLVOTES = ttlvotesdup if dup !=0
duplicates drop unique_ward POLITICALPARTY, force

rename TTLVOTES TTLVOTES_

keep REGION DISTRICT COSTITUENCY WARD TTLVOTES_ unique_ward POLITICALPARTY

*reshape wide REGION DISTRICT COSTITUENCY WARD TTLVOTES, i(unique_ward) j(POLITICALPARTY) string

reshape wide TTLVOTES_, i(REGION DISTRICT COSTITUENCY WARD) j(POLITICALPARTY) string

********************************************************************************
*                                    Q5                                        *
********************************************************************************

* Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.


use "q5_Tz_ArcGIS_intersection.dta", clear
gen serial = _n
duplicates tag region_gis_2012 district_gis_2012 ward_gis_2012, gen(split)
*gen same_name = .
*replace same_name = (ward_gis_2012 == ward_gis_2017) if split == 1
*sort region_gis_2012 district_gis_2012 ward_gis_2012 same_name
*gen ward_2015 = ward_gis_2017[_n-1] if same_name == 1
*drop if split == 1 & same_name == 0
keep region* district* ward* split  // same_name
rename (region_gis_2012 district_gis_2012 ward_gis_2012) (region_10 district_10 ward_10)
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region_15 district_15 ward_15)

tempfile gis
save `gis'

use "q5_Tz_elec_15_clean.dta", clear
split district_15 // was going to try to 

use "q5_Tz_elec_10_clean.dta", clear


keep region_gis_2012 district_gis_2012 ward_gis_2012 split same_name
rename (region_gis_2012 district_gis_2012 ward_gis_2012) (region district ward)
duplicates drop region district ward, force
gen gis_2012_id = _n

tempfile gis_2012
save `gis_2012'
clear

use `gis_all'
keep region_gis_2017 district_gis_2017 ward_gis_2017 split same_name
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
duplicates drop region district ward, force
gen gis_2017_id = _n

* Can't seem to figure out how to install this command
reclink2 region district ward using `gis_2012', idmaster(gis_2017_id) idusing(gis_2012_id) gen(score) 
