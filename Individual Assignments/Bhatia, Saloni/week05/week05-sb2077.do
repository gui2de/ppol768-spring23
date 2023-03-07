cd "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/"


**Question 1 
**This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

use "q1_psle_student_raw.dta"

keep in 1 

do "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Individual Assignments/Bhatia, Saloni/week05/Q1_Q05_webscraping.do"

clear 
*Setting up empty tempfile 
tempfile student_clean 
save `student_clean', replace emptyok

forvalues i=1/16 {
    
    use "q1_psle_student_raw", clear     
    keep in `i'  ///  Compresses the data 
    
    do "Q1_Q05_webscraping"
    
    *Add the scraped rows to the tempfile student_clean
    append using `student_clean'
    *Saving so we don't lose any data 
    save `student_clean', replace 
    }

use `student_clean', clear


**Question 2 
**We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

use "q2_CIV_Section_0.dta", clear 

import excel "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow clear

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION

tempfile survey 
save `survey'

gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE ","",.)
replace department = subinstr(department, "DEPARTEMENT DU ","",.)
replace department = strtrim(department)
replace department = lower(department)

merge 1:1 department using `survey'

exit


**Question 3
**We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

tempfile cluster_group
save "`cluster_group'", replace emptyok

use "q3_GPS Data.dta", clear 

**forvalues i=1/10 {

*scatter latitude longitude

use "q3_GPS Data.dta"

keep in 1

rename * one_*

cross using "q3_GPS Data.dta"

geodist one_latitude one_longitude latitude longitude, generate(distance_km) 

drop if one_id==id

sort distance 

list one_id id distance_km

drop if _n>6

keep id 
gen enumerator = 1 

merge 1:1 id using "q3_GPS Data.dta"

append using `cluster_group'
save `cluster_group', replace 

}

use `cluster_group', clear

**How to shift a few select values to a nn empty dataset 

**shift the 6 households that are in one cluster to an empty dataset or a temp file 
**remove these 6 households in one cluster from the existing dataset 

**create a new column for enumerator id - there are 19 in number 

**kmeans cannot be used because the number across clusters are not consistent 

**Question 4
**2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

import excel "q4_Tz_election_2010_raw", clear

drop in 1/4

rename A region 
rename B district 
rename C constituency 
rename D ward 
rename E candidate_name 
rename F M
rename G F
rename H political_party 
rename I ttl_votes
rename J elected_candidates 

drop K elected_candidates

drop in 1/2

gen serial = _n

order serial region 

replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace constituency = constituency[_n-1] if constituency == ""
replace ward = ward[_n-1] if ward == ""

codebook ward 
**gives number of wards = 3111

**if you try to reshape it, not every ward has the same parties, which means that they will not align and we need to use the fillin command.  
**if we see the number of wards, we only see 3113 number of wards whereas this should be 3333 - some ward names are common and are being reused 

gen unique_ward = region + "_" + district + "_" + ward 

codebook unique_ward
**gives number of wards = 3333

**we want to reshape party before which we create a j-variable 
**reshape wide political_party, i(i), j(j)

**initially my data showed party or candidate at ward level ______
fillin unique_ward political_party 
**not sure what this is doing 

sort unique_ward _fillin 

replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace constituency = constituency[_n-1] if constituency == ""
replace ward = ward[_n-1] if ward == ""

keep unique_ward political_party ttl_votes 

sort unique_ward political_party 
bysort unique_ward: gen j=_n

tab j political_party

reshape wide political_party ttl_votes, i(unique_ward) j(j) 

save Tz_2010_LegWardData_Wide


**ALSO CHECK FOR CANDIDATES IN THE SAME PARTY 20577 20578
bysort egen total drop duplicates soy you can create a dummy variable = 0 and 1 values, drop one of th duplicates after you have summed them up

reshape wide j = 


**duplicates tag ward, gen(d) [not sure what this does]
tab d

**bysort 
**egen 
**reshape 

**Question 5
**Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were division 
