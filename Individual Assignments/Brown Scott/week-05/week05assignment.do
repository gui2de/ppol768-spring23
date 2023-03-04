*Working Directory
global wd "D:/2021-2023, Georgetown University/2023 - Spring/Research Design & Implementation/ScottsRepo/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

*Datasets
global q1_psle_student_raw "$wd/q1_psle_student_raw.dta"

global q2_CIV_populationdensity "$wd/q2_CIV_populationdensity.xlsx"

global q2_CIV_Section_0 "$wd/q2_CIV_Section_0.dta"

global q3_GPS_data "$wd/q3_GPS Data.dta"

global q4_Tz_election_2010_raw "$wd/q4_Tz_election_2010_raw.xls"

global q4_Tz_election_template "$wd/q4_Tz_election_template.dta"

global q5_Tz_ArcGIS_intersection "$wd/q5_Tz_ArcGIS_intersection.dta"

global q5_q5_Tz_elec_10_clean "$wd/q5_Tz_elec_10_clean.dta"

global q5_q5_Tz_elec_15_clean "$wd/q5_Tz_elec_15_clean.dta"

***********************************************
*Q1: Tanzania Student Data
/* This builds on Q4 of week 4 assignment. 
We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.
*/
***********************************************
use "$q1_psle_student_raw", clear

sort schoolcode
split s, parse(">PS")

* Reshape data and drop missing rows
gen serial = _n
order serial, before(s)
drop s
drop schoolcode 
reshape long s, i(serial) j(student)

drop if s==""  //drop empty rows
drop if regex(s, "NATIONAL EXAMINATIONS COUNCIL OF TANZANIA")

* Create and rename correct columns
split s, parse("<")
keep s1 s6 s11 s16 s21
rename (s1 s6 s11 s16 s21) (cand prem sex name subjects)

* Eliminate html code // 8791 changes made for each
replace cand = "PS" + cand
replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
format %15s prem 
replace sex = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
format %5s sex 
replace name = subinstr(name,`"P>"',"",.)
replace name = proper(name)
replace subjects = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

* Split and rename subjects
split subjects, parse(",")
rename subjects1 kiswahili
rename subjects2 english
rename subjects3 maarifa
rename subjects4 hisabati
rename subjects5 science
rename subjects6 uraia
rename subjects7 average
drop subjects
 
* Remove html code; keep letter grades. NOTE: some students have missing grades marked by X in the original data source.
foreach var of varlist kiswahili english maarifa hisabati science uraia average {
	replace `var' = substr(`var', -1,.)
} 

* Check for errors and duplicates
duplicates list cand // Zero duplicates
duplicates list prem // Zero duplicates
duplicates list name // Two duplicates: "NEEMA JAMES MOLLEL" and "UPENDO JACKSON MOLLEL" appear in two classes. Not same classes or numbers, so it shouldn't be an issue.

***********************************************
*Q2: Côte d'Ivoire Population Density
/* We have household survey data and population density data of Côte d'Ivoire. 
Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.
*/
***********************************************
* Prepare CIV data with "department" variable
use "$q2_CIV_Section_0", clear
decode b06_departemen, gen(department)
replace department = "arrah" if department=="arrha"

duplicates drop
sort department

tempfile civ
save `civ'

* Prepare density data with "department" variable
import excel "$wd/q2_CIV_populationdensity", sheet("Population density") firstrow allstring clear

* Keep only department-level data
keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT") 
sort NOMCIRCONSCRIPTION
gen department = NOMCIRCONSCRIPTION

* Trim and correct department names
replace department = subinstr(department,"DEPARTEMENT DE","",.)
replace department = subinstr(department,"DEPARTEMENT DU","",.)
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = strtrim(department)
replace department = lower(department)

* Rename variables
rename DENSITEAUKM pop_density_km2
rename SUPERFICIEKM2 area_km2
rename POPULATION population

duplicates drop // no duplicates

* Merge datasets
merge 1:m department using `civ'
drop if _merge==1 //Gbeleban data only in master
order NOMCIRCONSCRIPTION hh1 hh2 
sort NOMCIRCONSCRIPTION hh1 hh2 
duplicates drop // 0 duplicates

***********************************************
*Q3: Enumerator Assignment based on GPS
/* We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.
*/
***********************************************
/* Still working on this Q; will do more after Monday Feb 20

use "$q3_GPS_data", clear
sort id
*/


***********************************************
*Q4: 2010 Tanzania Election Data cleaning
/* 2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. 
You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.
*/
***********************************************
* Import and drop blank rows and columns
import excel "$wd/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange (A5:K7927) firstrow allstring clear // first four rows unneeded

drop if _n==1 // blank row
drop K // blank column

* Rename vars and values with correct lowercase
rename *, lower
//rename * "*_10" //"invalid" names for Stata
rename costituency constituency
rename candidatename candidate
rename politicalparty party
foreach v of varlist region-electedcandidate{
	replace `v' = lower(`v')
}
replace ttlvotes = "" if ttlvotes=="un oppossed"

* Gen new binary var for unopposed candidate
gen unopposed = 0
replace unopposed = 1 if ttlvotes=="un oppossed" // 599 changes

* Convert votes to num; remove strings
replace ttlvotes = "" if ttlvotes=="un oppossed" //599 changes
destring ttlvotes, replace

* Collapse M and F columns in to one sex column
count if sex!="m" // 7356 males; 565 blanks
count if g!="f" // 556 female; 7365 blanks
list if g=="" & sex=="" // 9 missing obs for sex; accounts for discrepancy in count of m and f. Original data source does not have the sex for these 9 obs.
replace sex = "F" if g=="f" // 556 changes
drop g

* Fill in blank cells that were previously merged cells in the original data source
foreach v of varlist region-ward{
	replace `v' = `v'[_n-1] if `v'==""
}

gen r_d_ward = region + district + ward 

/* Still working on this section and related Q below; will do more after Monday Feb 20
fillin r_d_ward party
sort r_d_ward party
bysort r_d_ward: gen j=_n-1encode r_d_ward, gen(i)
*/

***********************************************
*Q5: Tanzania Election data Merging
/* Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. 
This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.
*/
***********************************************