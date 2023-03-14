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
***INCOMPLETE***Question 3 --------------------------------------------------
clear

use "${wd}/q3_GPS Data.dta", clear
scatter latitude longitude
rename * one_*
cross using "${wd}/q3_GPS Data.dta"

ssc install geodist
ssc install sepscatter
geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km

cluster kmeans distance_km, k(19) [seg]
***HOW TO READ OPTIONS ON CLUSTER. 
***I want to make an equal n of frequencies of the k 19 cluster based on the latitude and longitude . Then split the frequencies in 6.
/*
cluster kmeans latitude longitude, k(19)
sort _clus_1
sepscatter latitude longitude, separate(_clus_1)
*/

/*
tab _clus_1

 Cluster ID |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        418        3.39        3.39
          2 |        902        7.32       10.71
          3 |        452        3.67       14.38
          4 |        452        3.67       18.05
          5 |        772        6.27       24.32
          6 |        780        6.33       30.65
          7 |        510        4.14       34.79
          8 |        562        4.56       39.35
          9 |        568        4.61       43.96
         10 |        382        3.10       47.06
         11 |        840        6.82       53.88
         12 |        680        5.52       59.39
         13 |        620        5.03       64.43
         14 |        776        6.30       70.72
         15 |        688        5.58       76.31
         16 |        812        6.59       82.90
         17 |        916        7.43       90.33
         18 |        746        6.05       96.39
         19 |        445        3.61      100.00
------------+-----------------------------------
      Total |     12,321      100.00
*/

exit

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

***merge into the final database, here is where I am stuck. Trying to cross crushed the program, it is not merging as the observations are not the same 
clear
use  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_15_saved.dta", clear

use  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_10_saved.dta", clear

merge 1:1 check using  "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q5_15_saved.dta"



