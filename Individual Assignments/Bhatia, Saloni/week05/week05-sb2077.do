**Week05 - Saloni Bhatia**

cd "/Users/salonibhatia/Desktop/Github/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/"

**Question 1 - This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

use "q1_psle_student_raw.dta", clear

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

**Question 2 - We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

**We import the excel from which we want to extract department-level density data 
import excel "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow clear

**The column with department names is called NOMCIRCONSCRIPTION, out if which we filter out rows with department information 
keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION

**We create a new variable department that matches the department data from the .dta file 
gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE ","",.)
replace department = subinstr(department, "DEPARTEMENT DU ","",.)
replace department = strtrim(department)
replace department = lower(department)

**We save the cleaned file as a .dta file 
save "CIV_populationdensity.dta", replace

**We use the IV_Section_O.dta file to merge with the cleaned file and change the varaible b06_departemen to match with the department varaible in the CIV_populationdensity.dta file
use q2_CIV_Section_0, clear
decode b06_departemen, generate(department)

**After running the merge command once - there were 12,827 matched observation. We find that most of the unmatched observations are due to the varying spellings of Arrha/Arrha, which we change using the following command:  
replace department = subinstr(department, "arrha","arrah",.)

**This result matches 12,899 observations
merge m:1 department using "CIV_populationdensity.dta"

keep department DENSITEAUKM

**Question 3 - We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

**The code worked for enumerator 1 and 2 but not for all 111

**Code for enumerator 1
tempfile cluster_group
save "`cluster_group'", replace emptyok

use "q3_GPS Data.dta", clear

**we visualize the coordinates that we want to create clusters for 
scatter latitude longitude

keep in 1

rename * one_*

cross using "q3_GPS Data.dta"

geodist one_latitude one_longitude latitude longitude, generate(distance_km) 

sort distance_km 

list one_id id distance_km

drop if _n>6
keep id distance_km
gen enumerator = 1 

merge 1:1 id using "q3_GPS Data.dta"

sepscatter latitude longitude, sep(_merge)

save `cluster_group', replace 

drop _merge

**Code for enumerator 2

tempfile cluster_group
save "`cluster_group'"

drop in 1/6

keep in 1

rename * two_*

cross using "q3_GPS Data.dta"

geodist two_latitude two_longitude latitude longitude, generate(distance_km) 

sort distance_km 

list two_id id distance_km

drop if _n>6
keep id distance_km
gen enumerator = 2 

merge 1:1 id using "q3_GPS Data.dta"

sepscatter latitude longitude, sep(_merge)

append using "`cluster_group'"
save "`cluster_group'", replace 

drop _merge

**Code for 111 values 
clear all 

forvalues i=1/19 {
	
tempfile cluster_group
save "`cluster_group'"

use "q3_GPS Data.dta", clear

**we visualize the coordinates that we want to create clusters for 
scatter latitude longitude

keep in 1

rename * "`i'_"*

cross using "q3_GPS Data.dta"

geodist "`i'_latitude" "`i'_longitude" latitude longitude, generate(distance_km) 

sort distance_km 

list "`i'_id" id distance_km

drop if _n>6
keep id distance_km
gen enumerator = `i'

merge 1:1 id using "q3_GPS Data.dta"

sepscatter latitude longitude, sep(_merge)

append using "`cluster_group'"
save `cluster_group', replace 

drop _merge
}

**Question 4 - 2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.
clear all

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
**gives number of wards = 3111, however, we know that this number should have been 3333

**if we try to reshape it, not every ward has the same parties, which means that they will not align and we need to use the fillin command.  
**if we see the number of wards, we only see 3113 number of wards whereas this should be 3333 - some ward names are common and are being reused. So we generate a unique_ward column 

gen unique_ward = region + "_" + district + "_" + ward 

**gives number of wards = 3333
codebook unique_ward

**initially my data showed party or candidate at ward level ______
fillin unique_ward political_party 

sort unique_ward _fillin 

replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace constituency = constituency[_n-1] if constituency == ""
replace ward = ward[_n-1] if ward == ""

keep unique_ward political_party ttl_votes 

sort unique_ward political_party 
bysort unique_ward: gen j=_n

tab j political_party
**we find that there are two candidates from the same party and need to fix that 

*bysort egen and total 
*drop one of the duplicates 
*dummy varaible duplicates tag political party 
*drop duplicates after summing them up 

reshape wide political_party ttl_votes, i(unique_ward) j(j) 
**There are some additional columnss political_party19 ttl_votes19 political_party20 ttl_votes20 which also have some additional values. Eyeablling the data, there are some cells with UMD, UPDP - not sure 

drop political_party1 political_party2 political_party3 political_party4 political_party5 political_party6 political_party7 political_party8 political_party9 political_party10 political_party11 political_party12 political_party13 political_party14 political_party15 political_party16 political_party17 political_party18 

rename ttl_votes1 AFP
rename ttl_votes2 APPT_MAENDELEO
rename ttl_votes3 CCM
rename ttl_votes4 CHADEMA
rename ttl_votes5 CHAUSTA
rename ttl_votes6 CUF
rename ttl_votes7 DP
rename ttl_votes8 JAHAZI_ASILIA
rename ttl_votes9 MAKIN
rename ttl_votes10 NCCR_MAGEUZI
rename ttl_votes11 NLD
rename ttl_votes12 NRA
rename ttl_votes13 SAU
rename ttl_votes14 TADEA
rename ttl_votes15 TLP
rename ttl_votes16 UDP
rename ttl_votes17 UMD
rename ttl_votes18 UPDP

save Tz_2010_LegWardData_Wide, replace 

**I got stuck after this point and could not delete duplicate values and reshape long. I would like to learn how to solve for the two candidates in the same party problem. 

**Question 5 - Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were division 

**The answer to this question was done with the help of Ben. I do not completely understand the code and would like to clarify 

use "q5_Tz_elec_10_clean.dta" , clear

  gen urban = strpos(district_10,"manispaa")
  replace urban = 1 if strpos(district_10,"jiji")

  replace district_10 = substr(district_10,strpos(district_10," ya ")+4,.) ///
    if strpos(district_10," ya ")
  replace district_10 = substr(district_10,strpos(district_10," la ")+4,.) ///
    if strpos(district_10," la ")
  replace district_10 = substr(district_10,strpos(district_10," wa ")+4,.) ///
    if strpos(district_10," wa ")
  replace district_10 = substr(district_10,strpos(district_10," wara ")+6,.) ///
    if strpos(district_10," wara ")

  rename (region_10 district_10 ward_10) ///
      (region_gis_2012 district_gis_2012 ward_gis_2012)

  duplicates tag region_gis_2012 district_gis_2012 ward_gis_2012 , gen(d)
  replace ward_gis_2012 = ward_gis_2012 + " urban" if urban
  // replace ward_gis_2012 = ward_gis_2012 + " rural" if !urban
  
**ssc install reclink
  
  reclink region_gis_2012 district_gis_2012 ward_gis_2012 using "q5_Tz_ArcGIS_intersection.dta", idmaster(ward_id_10) idusing(objectid) gen(matchpct) minbigram(0.3)
