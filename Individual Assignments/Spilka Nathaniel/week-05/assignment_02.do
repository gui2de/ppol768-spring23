*******************************************************************************
** clean workspace, set dir, load data, quick view of data
*******************************************************************************
* nate spilka
* 2023-03-24

* clean workspace 
cls
clear all

* set dir
cd "/Users/nathanielhugospilka/Documents/research_methods_2023/research_design/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/"

*******************************************************************************
** Q1 : Tanzania Student Data (part 2)
*******************************************************************************

* clear workspace and create the tempfile
cls
clear
tempfile tmp
save `tmp', replace emptyok


forvalues i = 1/138 {
	use q1_psle_student_raw.dta, clear
		
	* keeping each iteration
	keep in `i'
	
	* q4 from Assignment 1
		* parse out students columnwise
		split s, parse(">PS")

		* generate another value to reshape by
		generate val = _n

		* drop before reshaping
		drop s schoolcode

		* flip the participant columns to become rows
		reshape long s, i(val) j(student)

		* Disaggregate cells further
		split s, parse("<")

		* remove the first row/header
		drop in 1 

		* rename variables 
		rename s1 cand_id
		rename s6 prem_number
		rename s11 gender
		rename s16 name
		rename s21 grade

		* only keep relevant variables
		keep cand_id prem_number gender name grade 

		* more cleaning
		replace prem_number = subinstr(prem_number, `"P ALIGN="CENTER">"', "", .)
		replace gender = subinstr(gender, `"P ALIGN="CENTER">"', "", .)
		replace name = subinstr(name, "P>", "", .)
		replace grade = subinstr(grade, `"P ALIGN="LEFT">"', "", .)

		* parsing out the different classes
		split grade, parse(",")

		* taking the last string value (-1) of the cells (i.e., the grade)
		foreach var of varlist grade* {
			replace `var' = substr(`var', -1, 1)
		}

		* renmae the subjects
		rename (grade1 grade2 grade3 grade4 grade5 grade6 grade7) ///
		(kiswahili english maarifa hisabati science uraia average)

		* this is no longer needed
		drop grade 
	
	* adding to each iteration
	append using `tmp'
	save `tmp', replace
} 

*******************************************************************************
** Q2 : Côte d'Ivoire Population Density
*******************************************************************************

* clear workspace and load data
cls
clear

import excel using "q2_CIV_populationdensity.xlsx"

* there is no CIV_Section_O.dta in 01_data

*******************************************************************************
** Q3 : Enumerator Assignment based on GPS
*******************************************************************************

* clear workspace and load data
cls
use q3_GPS_Data.dta, clear

* working with only the i'th row
// keep in 1/2

* to differentiate between lon/lats we're relabeling the originals								 
rename * first_*

* mashing the data to a single row - this is now a new matrix
cross using q3_GPS_Data.dta

* calculate the distance between the row we're on and every other row
geodist first_latitude first_longitude latitude longitude, generate(distance)

* remove situations where we're calculating the distance with itself
drop if first_id == id

* we only need one row for each ID
duplicates drop first_id, force

*******************************************************************************

* clear workspace and load data
cls
use q3_GPS_Data.dta, clear

cluster kmedians latitude longitude, k(19)
exit

sort _clus_1

*******************************************************************************
** Q4 : 2010 Tanzania Election Data cleaning
*******************************************************************************

* clean workspace
cls
clear

* load in data
import excel using "q4_Tz_election_2010_raw.xls", cellrange(A5:k7927) firstrow 

* we want the dataset to look like this:
// use q4_Tz_election_template.dta, clear

* make all variable names lowercase
rename *, lower

* here are the original row numbers just in case 
generate orig_row_nums = _n

* remove the first row
drop if _n == 1

* remove unneeded rows
drop k sex g


* filling in blank space with the appropriate values
replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace costituency = costituency[_n-1] if costituency == ""
replace ward = ward[_n-1] if ward == ""

* avoid duplicates 
generate id = region + "_" + district + "_" + costituency + "_" + ward
generate i = _n

encode politicalparty, gen(party)
encode id, gen(id_i)
exit

reshape wide ttlvotes, i(id_i) j(party)


*******************************************************************************
** Q5 : Tanzania Election data Merging
*******************************************************************************

* clear workspace
cls

* load in data (starting off with 2010)
use q5_Tz_elec_10_clean.dta, clear 

* remove duplicates
duplicates drop

rename (region_10 district_10 ward_10) (region district ward)
sort region district ward
keep region district ward
generate id = _n

tempfile tz_10
save `tz_10'

***********************************

* load in data (2015)
use q5_Tz_elec_15_clean.dta, clear 

* remove duplicates
duplicates drop

rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
keep region district ward
generate id = _n
 
reclink region district ward using `tz_10', idmaster(id) idusing(dist_id) gen(score)
exit




