/*Marlyn Bruno 
PPOL 768 
Week 5 Assignment*/


*Working Directory
global wd "/Users/marlyn/GitHub/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

*Datasets
global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_Section_0.dta"
global q2_excel "$wd/q2_CIV_populationdensity.xlsx"
global q3_GPS "$wd/q3_GPS Data.dta"
global q4 "$wd/q4_Tz_election_template.dta"
global q4_excel "$wd/q4_Tz_election_2010_raw.xls"
global q5_GIS "$wd/q5_Tz_ArcGIS_intersection.dta"
global q5_10 "$wd/q5_Tz_elec_10_clean.dta"
global q5_15 "$wd/q5_Tz_elec_15_clean.dta"

/**********************************************************************************

						Question 1: Tanzania Student Data
						
***********************************************************************************/

*Load in dataset
use "$q1", clear

*Establish temporary dataset where all student-level data will be stored
tempfile student_clean 
save `student_clean', replace emptyok //says that empty dataset is ok

*Building up my dataset with a loop because without it, STATA breaks down and creates a wonky dataset
forvalues i = 1/138 {
	use "$q1", clear
	display as error "This is loop number `i'"
	keep in `i'
	do "/Users/marlyn/GitHub/ppol768-spring23/Individual Assignments/Bruno Marlyn/week-05/w04_q4"
	
	append using `student_clean'
	save `student_clean', replace //overwrite the same dataset
}

*Check dataset to make sure it works
use `student_clean', clear

*Exit
exit


/**********************************************************************************

					Question 2: Côte d'Ivoire Population Density
						
***********************************************************************************/

*First taking a peek at the data to see how it's set up
use "$q2", clear
br //looking specifically at the department name column since that's what we will be using to eventually merge

*To make sure that datasets can be merged, I have to decode the variable in "q2" that has departments because it's currently coded as a numeric variable instead of string
decode b06_departemen, gen(department)

*Save as tempfile 
tempfile survey
save `survey'

*Importing the Excel sheet data 
import excel "$q2_excel", sheet("Population density") firstrow allstring clear

/*I wanted to make sure that before anything, there aren't any mispellings of "DEPARTEMENT" 
gen check = ""
replace check = "department" if regexm(NOMCIRCONSCRIPTION,"DEPARTEMENT")//this helps me eyeball the data better as I stroll and check for mispellings
drop check //didn't find any errors so now I can drop this variable and proceed safely that my code will capture all departments*/

*I want to keep only the department-level population density numbers. 
keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")

*To be able to merge with the main dataset, I have to make sure the department names are lowercase and also that they just have the name of the Department, not any iteration of "Departemente de." 
gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT DU", "", .)
replace department = subinstr(department, "DEPARTEMENT D' ", "", .)
replace department = subinstr(department, "DEPARTEMENT DE ", "", .)
replace department = subinstr(department, "DEPARTEMENT D'", "", .)
replace department = lower(department) // change all to lowercase
replace department = "arrha" if department == "arrah" 

*Checking variable now - 108 unique values and shows "leading blanks" warning
codebook department

*Trim string variable so any leading blanks are resolved
replace department = strtrim(department) // now warning is gone
sort department

*Keep only relevant variables
rename DENSITEAUKM pop_density 
keep pop_density department

*Merge one pop_density stat to many survey responses
merge 1:m department using `survey' //wth is happening here

*One observation doesn't have survey data
drop if _merge != 3

*Arrah is actually the correct spelling
replace department = "arrah" if department == "arrha" 

*Fix some order issues
order pop_density, last

*Drop merged variable now that we've merged and handled all conflicts
drop _merge

/**********************************************************************************

					Question 3: Enumerator Assignment based on GPS
						
***********************************************************************************/

use "$q3_GPS", clear

*I ran out of time, unfortunately, but I will revisit this problem later this week!

/**********************************************************************************

					Question 4: 2010 Tanzania Election Data cleaning
						
***********************************************************************************/

use "$q4", clear

*Browsing and exploring
br

*Import Excel
import excel "$q4_excel", cellrange(A5:K7927) firstrow allstring clear

*From browsing the data, I can tell I need to 1. delete the first row which is not an observation and delete variable K, which is all missing values (based on the codebook), 2. see if there are observations marked for both M and F, 3. merge the gender columns, and 4. populate the empty cells for region, district, costituency, and ward (so we can safely sort or transform data)

	*1. Delete the first row and column K
	drop if _n == 1
	drop K
	gen serial = _n //helps me track original order of observations

	
	*2  M and F overlap?
	tab SEX G, m // can see that one that one value has a trailing blank issue. Also see 9 candidates have unknown gender
	replace SEX = "M" if SEX == "M " //fixing that one value
	
	*3. Combine sex columns
	gen gender = ""
	replace gender = "M" if SEX == "M"
	replace gender = "F" if G == "F"
	tab gender
	drop SEX G //no reason to keep these two old sex variables 
	
	*4. Populate the empty cells for region, district, costituency, and ward
	gen region = REGION
	replace region = region[_n-1] if region == "" 
	gen district = DISTRICT
	replace district = district[_n-1] if district == ""
	gen costituency = COSTITUENCY
	replace costituency = costituency[_n-1] if costituency == ""
	gen ward = WARD 
	replace ward = ward[_n-1] if ward == ""
	
	order region district costituency ward, before(CANDIDATENAME)
	drop REGION DISTRICT COSTITUENCY WARD
	
*Before using the fillin command, I should create a unique ward ID since some wards have the same names though they're in different districts or regions
gen unique_ward = region + "_" + district + "_" + ward	

*Going to use fillin so that I have a row for every political party in every ward (even if no votes went to that political party)
fillin unique_ward POLITICALPARTY	

*Now, I have to populate the empty cells that were created after using fillin to create a row for every political party for each ward
sort unique_ward _fillin //sorting so that the original names of the region, district, costistuency, and ward appear first in every unique ward

replace region = region[_n-1] if region == "" 
replace district = district[_n-1] if district == ""
replace costituency = costituency[_n-1] if costituency == ""
replace ward = ward[_n-1] if ward == ""

*Before reshaping, we have to a generate "j" value, which will be used to keep track of every political party. 
sort unique_ward POLITICALPARTY
bysort unique_ward: gen j = _n

tab j POLITICALPARTY // we can now see that there are ONLY TWO instances where there are two candidates within the same political party. Both cases happen within the LINDI_WILAYA YA LIWALE_NANGANDO unique ward. There are two CCM and two CUF candidates in this ward. 20,578 and 20,577 == 1,812 votes

*Sum votes in instances where there are multiple candidates within the same party
gen totalvotes = real(TTLVOTES) //to be able to sum up votes, I have to change the vote variable first from string to real numeric
sort unique_ward POLITICALPARTY //make sure dataset is in right order
bysort unique_ward POLITICALPARTY: egen votes = total(totalvotes) //summing up values for multi-candidate parties 
drop totalvotes //dropping the old variable for total votes 

bysort unique_ward j: gen mult_cand = 0
replace mult_cand = 1 if POLITICALPARTY[_n] == POLITICALPARTY[_n + 1] //flags which observations have two candidtes for a party
drop if mult_cand == 1 //dropping 2 duplicates now

tab j POLITICALPARTY //checking to see if issue of multiple candidates is resolved and it is

*I have to recreate my j variable now that I've resolved the multiple candidates issue
drop j
sort unique_ward POLITICALPARTY
bysort unique_ward: gen j = _n

*Create my "i" so that I can reshape data
encode unique_ward, gen(i) //create a unique number identifier for each unique ward so that I can reshape data 

*Reshape data
encode POLITICALPARTY, gen(party) //need to encode political party variable for reshape to be able to run
drop CANDIDATENAME TTLVOTES ELECTEDCANDIDATE serial gender _fillin POLITICALPARTY j//have to drop to be able to reshape
reshape wide votes, i(i) j(party) 

*Clean data even more
drop mult_cand unique_ward //no longer need this now that they're extraneous 
order region district costituency ward, before(i)

egen total_ward_votes = rowtotal(votes*) //calculate total votes for each ward
order total_ward_votes, after(i) //place new total votes variable at start

rename votes1 votes_afp
rename votes2 votes_appt
rename votes3 votes_ccm
rename votes4 votes_chadema
rename votes5 votes_chausta
rename votes6 votes_cuf
rename votes7 votes_dp
rename votes8 votes_jahazi_asilia
rename votes9 votes_makin
rename votes10 votes_nccr_mageuzi
rename votes11 votes_nld
rename votes12 votes_nra
rename votes13 votes_sau
rename votes14 votes_tadea
rename votes15 votes_tlp
rename votes16 votes_tdp
rename votes17 votes_umd
rename votes18 votes_updp
rename i wardID
	
/**********************************************************************************

					Question 5: Tanzania Election data Merging
						
***********************************************************************************/

*I ran out of time, unfortunately, but I will revisit this problem later this week! 
