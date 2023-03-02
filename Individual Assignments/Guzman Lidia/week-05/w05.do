***Lidia Guzman Assignment 5
clear 

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

clear

***COMPLETED***Question 1 ----------------------------------------------------

use "${wd}/q1_psle_student_raw.dta", clear

sort schoolcode
split s, parse (">PS")

gen serial = _n

drop s 
drop schoolcode 

reshape long s, i(serial) j(student)

***substring data

split s, parse ("<")

keep s1 s6 s11 s16 s21 

drop if strpos(s6,"BODY TEXT="#000080" LINK="#0000ff" VLINK="#800080" BGCOLOR= "LIGHTBLUE">") > 0

ren (s1 s6 s11 s16 s21) (schoolcode candidate_id sex name subjects)
	compress
	
drop if schoolcode==""

replace candidate_id = subinstr(candidate_id, `"P ALIGN="CENTER">"',"",.)	
replace candidate_id = "PS" + candidate_id
replace sex = subinstr(sex, `"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"',"",.)
compress

split subjects , parse(",")

drop subjects 

foreach var of varlist subject* {
	replace `var' = substr(`var', -1,1)
}


rename subjects1 Kiswahili 

rename subjects2 English

rename subjects3 Maarifa

rename subjects4 Hisabati 

rename subjects5 Science 

rename subjects6 Uraia 

rename subjects7 Average

***COMPLETED***Question 2 -----------------------------------------------------
clear
use "${wd}/q2_CIV_Section_0.dta", clear

labelbook b06_departemen
decode b06_departemen, gen (department)
***
***keep department 

***
sort department

save "${wd}/q2_CIV_Section_0.dta", replace

***import 
clear
import excel "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow allstring

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION

gen department = NOMCIRCONSCRIPTION

replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE","",.)
replace department = subinstr(department, "DEPARTEMENT DU","",.)
replace department = strtrim(department) 
replace department = lower(department)
replace department = "arrha" if department=="arrah"
***prepare for density 
rename DENSITEAUKM pop_density_km2
***keep pop_density_km2


**do merge 
merge 1:m department using "${wd}/q2_CIV_Section_0.dta"

browse if unmatched
drop if _merge==1 
**no survey data for greblandan so ok
order department pop_density_km2, last

exit
***Question 3 --------------------------------------------------
clear

use "${wd}/q3_GPS Data.dta", clear
scatter latitude longitude
rename * one_*
cross using "${wd}/q3_GPS Data.dta"

ssc install geodist
ssc install sepscatter
geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km

sort id distance_km
bys id: gen rank = _n

gen cluster1 = 1 if id==655 & rank<= 6

keep if cluster1 ==1

save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster1.dta" , replace

clear
use "${wd}/q3_GPS Data.dta", clear

rename * one_*
  merge 1:1 one_id using "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster1.dta" , keep(1) nogen
  
  save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster1_clean.dta", replace
  
scatter latitude longitude
cross using "${wd}/q3_GPS Data.dta"
geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km

sort id distance_km
bys id: gen rank = _n

gen cluster2 = 1 if id==id[1] & rank<= 6

keep if cluster2 ==1

save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster2.dta" , replace

clear
use "${wd}/q3_GPS Data.dta", clear

rename * one_*

  merge 1:1 one_id using "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster2.dta" , keep(1) nogen
  
  save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q3_GPS_cluster2_clean.dta", replace

***Here I have created 2 clusters of the 19 I should be creating. Hence I would need to do this process 17 times more, but due to time constraints I wanted to just show these.

***COMPLETED***Question 4 --------------------------------------------
***2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.
clear

import excel "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Class Materials/week-05/03_assignment/01_data/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring clear
 
**loop to fill in the gaps of the variables
 
qui foreach var of varlist * {
	
	cap replace `var' = subinstr(`var',`"""',"",.)
  	
	local theValue = ""
	forv i = 1/`c(N)' {
		
		local nextValue = `var'[`i']
		if ("`nextValue'" == "") | ("`nextValue'" == ".") {
			cap replace `var' = "`theValue'" in `i'
			cap replace `var' = `theValue' in `i'
	    }
		else {
			local theValue = "`nextValue'"
		}
    }
}


***drop nonuseful variables
drop if _n == 1
drop K SEX G

***generate a new variable with location defined and unique id
gen r_d_ward = REGION + " " + DISTRICT + " " + WARD

*the variable in () is used to sort the data within the bysort variable (the unique ward in this case)

destring TTLVOTES,replace ignore("UN OPPOSSED")

collapse (sum) TTLVOTES, by(r_d_ward POLITICALPARTY)

***one political party with two candidates per ward 

bysort r_d_ward (POLITICALPARTY): gen ward_id =_n

***all spaces out 
cap replace POLITICALPARTY = subinstr(POLITICALPARTY," ","",.)

****reshape

drop ward_id
rename TTLVOTES votes
cap replace POLITICALPARTY = subinstr(POLITICALPARTY,"-","",.)

reshape wide votes, i(r_d_ward) j(POLITICALPARTY) string

***INCOMPLETE***Question 5 -----------------------------------------------
***Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided. 


***find changes from 2010 to 2012 
clear
use "${wd}/q5_Tz_elec_10_clean.dta" , clear


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

  ren (region_10 district_10 ward_10) ///
      (region_gis_2012 district_gis_2012 ward_gis_2012)

  duplicates tag region_gis_2012 district_gis_2012 ward_gis_2012 , gen(d)
  replace ward_gis_2012 = ward_gis_2012 + " urban" if urban
  // replace ward_gis_2012 = ward_gis_2012 + " rural" if !urban

    reclink region_gis_2012 district_gis_2012 ward_gis_2012 ///
       using "${wd}/q5_Tz_ArcGIS_intersection.dta" ///
   , idmaster(ward_id_10) idusing(objectid) gen(matchpct) minbigram(0.3)


 ***mark those new districts in 2012
   replace percentage = 0 if percentage ==. 
   gen new_2012 if percentage = 0
   replace new_2012 = 1 if new_2012 ==.

**obs 3,900 , see if there are duplicates that coincide with percentage

gen check = region_gis_2012 + district_gis_2012 + ward_gis_2012
duplicates list check percentage

**all ok save w/o merge as will perform future merge
rename _merge _merge10
save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_10_saved.dta", replace


***find changes from 2015 to 2017

clear
use "${wd}/q5_Tz_elec_15_clean.dta" , clear

gen urban = strpos(district_15,"manispaa")
  replace urban = 1 if strpos(district_15,"jiji")
replace urban = 1 if strpos(district_15,"mji")
  
  replace district_15 = substr(district_15,strpos(district_15," ya ")+4,.) ///
    if strpos(district_15," ya ")
  replace district_15 = substr(district_15,strpos(district_15," la ")+4,.) ///
    if strpos(district_15," la ")
  replace district_15 = substr(district_15,strpos(district_15," wa ")+4,.) ///
    if strpos(district_15," wa ")
  replace district_15 = substr(district_15,strpos(district_15,"mji ")+4,.) ///
    if strpos(district_15,"mji ")
replace district_15 = substr(district_15,strpos(district_15,"ma ")+4,.) ///
    if strpos(district_15,"ma ")
	replace district_15 = substr(district_15,strpos(district_15,"kigoma ")+4,.) ///
    if strpos(district_15,"kigoma ")
	replace district_15 = substr(district_15,strpos(district_15,"mtwara ")+4,.) ///
    if strpos(district_15,"mtwara ")
	replace district_15 = substr(district_15,strpos(district_15,"ra ")+4,.) ///
    if strpos(district_15,"ra ")

	ren (region_15 district_15 ward_15) ///
      (region_gis_2017 district_gis_2017 ward_gis_2017)

  duplicates tag region_gis_2017 district_gis_2017 ward_gis_2017 , gen(d)
  replace ward_gis_2017 = ward_gis_2017 + " urban" if urban
  
  reclink region_gis_2017 district_gis_2017 ward_gis_2017 ///
       using "${wd}/q5_Tz_ArcGIS_intersection.dta" ///
   , idmaster(ward_id_15) idusing(objectid) gen(matchpct) minbigram(0.3)

   
 ***mark those new districts in 2017
   replace percentage = 0 if percentage ==. 
   gen new_2015 if percentage = 0
   replace new_2015 = 1 if new_2015 ==.
   
 ***obs 3,968 , see if there are duplicates that coincide with percentage

gen check = region_gis_2017 + district_gis_2017 + ward_gis_2017
duplicates list check percentage

**all ok save w/o merge as will perform future merge
rename _merge _merge15
save "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_15_saved.dta", replace

***merge into the final database, here is where I am stuck. Trying to cross crushed the program, it is not merging as the observations are not the same. But I do understand the last step is merging. 
clear
use  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_15_saved.dta", clear

use  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_10_saved.dta", clear

merge 1:1 check using  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_15_saved.dta"



