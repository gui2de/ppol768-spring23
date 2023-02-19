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
	
	*2  M and F overlap?
	tab SEX G, m // this doesn't show any observations for some reason so next plan
	gen gender_check = 0
	replace gender_check = 1 if SEX == "M" & G == "F" //ideally, no observations would change
	count if gender_check ==1 //count is 0 so now I feel good about combining the columns
	drop gender_check
	
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
	
	reshape wide POLITICALPARTY i(WARD) j(DISTRICT)
	
	/*Data check! I'm going to keep track of one observation in the middle of the dataset before and after I do the above fill-ins of empty cells to make sure my code is working
					240 - DAR ES SALAAM - MANISPAA YA ILALA - ILALA - JANGWANI ... and my code works! I can proceed*/

*Time to sort the data so I can get a better idea of how to transform it
*sort WARD POLITICALPARTY 

*Going to use fillin so that I have a row for every political party in every ward (even if no votes went to that political party)
fillin DISTRICT WARD POLITICALPARTY

*Ok but now we need to repopulate empty cells  for region, district, and costistuency again
*bysort WARD: egen region = mode(REGION)
*bysort WARD: replace REGION = region if missing(REGION) 

*bysort WARD: egen district = mode(DISTRICT)
*bysort WARD: replace DISTRICT = district if missing(DISTRICT) 

*Now we can reshape our data to the wide format

reshape wide POLITICALPARTY i(WARD) j(DISTRICT)
	
/**********************************************************************************

					Question 5: Tanzania Election data Merging
						
***********************************************************************************/
