cd "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-05\03_assignment\01_data"

/* Q1 : Tanzania Student Data */
/* This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools. */


use "q1_psle_student_raw.dta", clear

tempfile school138
save `school138', replace emptyok

forvalues k=1/138 {
	use "q1_psle_student_raw", clear 	
	keep in `k'
	* loop function is used to append 138 cleaned dataset
split s, parse(">PS")
gen serial = _n
drop s
reshape long s, i(serial) j(student)
split s, parse("<")
keep s1 s6 s11 s16 s21
drop in 1
ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)

replace cand = "PS" + cand	
replace prem = subinstr(prem, `"P ALIGN="CENTER">"',"",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

compress

  split subjects, parse(",")
  drop subjects
  
  foreach var of varlist subjects* {
    replace `var' = substr(`var',-1,.)
  }
format %5s sex subjects* 
rename subjects1 Kiswahili
rename subjects2 English
rename subjects3 Maarifa
rename subjects4 Hisabati
rename subjects5 Science
rename subjects6 Uraia
rename subjects7 Average_Grade
    * above codes are same with Q4 commands of week 4 assignment
	append using `school138' 
	save `school138', replace
	* appended corresponding as 'forvalues' command
}

drop s schoolcode
    * drop useless variables 's' and 'schoolcode'
    

/* Q2 : Côte d'Ivoire Population Density
We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset. */

use "q2_CIV_Section_0.dta", clear
decode b06_departemen, gen(department)
      * change b06_departemen from Numeric to String variable

tempfile CIV_data
save `CIV_data'

import excel "q2_CIV_populationdensity.xlsx", clear firstrow

gen depart = regexm(NOMCIRCONSCRIPTION, "DEPARTEMENT")
      * Find DEPARTMENTs
drop if depart == 0
      * Leave only DEPARTMENTs
drop SUPERFICIEKM2 POPULATION depart
rename (NOMCIRCONSCRIPTION DENSITEAUKM) (department density)
replace department = substr(department, 15, .)
      * Get rid of unnecesary expression such as 'DEPARTMENT DE'
replace department = lower(department)

forvalues i=1/108{
	local dept_name =  department[`i']
	display "__`dept_name'__"
	}
      * Find leading blanks  	
replace department = strtrim(department)
replace department = "arrha" if department == "arrah"
	  * Found naming error
tempfile CIV_density
save `CIV_density'

merge 1:m department using `CIV_data'

drop if _merge == 1
      * Department "gbeleban" is not in excel
	  
drop _merge

 * Thanks to Ali's help and Zheng's comment, I could make it.

/* Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village. */
ssc install geodist

use "q3_GPS Data.dta"

tempfile main_data
save `main_data'

clear

tempfile temp_data
save `temp_data', emptyok

forvalues x = 1/19 {
	    use `main_data', clear
	     	
		keep in 1

		rename * one_*

		cross using `main_data'
		
		geodist one_latitude one_longitude latitude longitude, gen(distance_km)

		sort distance_km

		drop if one_id == id
		
		keep in 1/6

		gen enumerator = `x'

		drop one_*
		
		append using `main_data'
		save `temp_data', replace

		foreach x in enumerator {
			drop if enumerator != .
		}

		drop distance_km enumerator
		
		save `main_data', replace
	}
* I've tried to remove assigned households by using 'foreach' command. But if I do not drop 'disnance_km' and 'enumerator', they show error message 'vlariables already defined'. 


/* Q4 : 2010 Tanzania Election Data cleaning
2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset. */

use "q4_Tz_election_template.dta", clear

import excel "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-05\03_assignment\01_data\q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange (A5:K7927) firstrow allstring clear

drop K
drop if _n == 1

replace SEX = "F" if G == "F"
drop G

replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""

gen unique_ward = REGION + "_" + DISTRICT + "_" + WARD
egen unique_ward_id = group(REGION DISTRICT WARD)
bysort unique_ward_id: egen candidates = count(CANDIDATENAME)

fillin unique_ward POLITICALPARTY

sort unique_ward POLITICALPARTY
order unique_ward POLITICALPARTY

keep unique_ward POLITICALPARTY TTLVOTES candidates

bysort unique_ward: gen j=_n
encode unique_ward, gen (i)

reshape wide POLITICALPARTY TTLVOTES candidates, i(i) j(j)

rename candidates3 total_candidates

replace TTLVOTES3 = "0" if TTLVOTES3 == "UN OPPOSSED"
destring TTLVOTES*, replace

rename (TTLVOTES1 TTLVOTES2 TTLVOTES3 TTLVOTES4 TTLVOTES5 TTLVOTES6 TTLVOTES7 TTLVOTES8 TTLVOTES9 TTLVOTES10 TTLVOTES11 TTLVOTES12 TTLVOTES13 TTLVOTES14 TTLVOTES15 TTLVOTES16 TTLVOTES17 TTLVOTES18) (AFP APPT_MAENDELEO CCM CHADEMA CHAUSTA CUF DP JAHAZI_ASILIA MAKIN NCCR_MAGEUZI NLD NRA SAU TADEA TLP UDP UMD UPDP)

drop i POLITICALPARTY* TTLVOTES* candidates*

egen total_vote = rowtotal(AFP APPT_MAENDELEO CCM CHADEMA CHAUSTA CUF DP JAHAZI_ASILIA MAKIN NCCR_MAGEUZI NLD NRA SAU TADEA TLP UDP UMD UPDP), missing

order unique_ward total_vote total_candidates

clear


/* Q5 : Tanzania Election data Merging
Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided. */

use "q5_Tz_ArcGIS_intersection.dta", clear
use "q5_Tz_elec_10_clean.dta", clear
use "q5_Tz_elec_15_clean.dta", clear

* I could not figure it out how to start with it. Will work on it.