*Elena Spielmann
*PPOL 768
*Week 05 STATA Assignment 02

*Working Directory
global wd "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation\week-05-materials"

/*
Q1 : Tanzania Student Data
This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

*/

* To solve this, we need to update the code used in question 4 from assignment 1 to can handle 138 cells instead of just one. We will take one string, run the code, and if code works we will have a student level data set. Then we will run cleaning code and then append to previous data set. We will then run a loop for the rest. 

use "q1_psle_student_raw", clear

*We only want to use the tables we are interested in
sort schoolcode
split s, parse(">PS")

* Reshape data
gen serial = _n
order serial, before(s)
drop s
drop schoolcode
reshape long s, i(serial) j(student)

	/*Always a good idea to drop empty rows before doing any further analysis, makes your code more efficient.
	*/
	drop if s==""  //drop empty rows
	
	/*"drop in 1" line is being used to drop the first row of the first school that contains 
	header data. But you need to drop this for every school. 
	*/

drop if regex(s, "NATIONAL EXAMINATIONS COUNCIL OF TANZANIA")
	
split s, parse("<")
keep s1 s6 s11 s16 s21
rename (s1 s6 s11 s16 s21) (cand prem sex name subjects)

*****I'm not sure if this is right

*Finally we need to finish cleaning our dataset.

compress

replace cand = "PS" + cand
replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
replace sex  = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name,`"P>"',"",.)
replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

compress

split subjects , parse(",")

  foreach var of varlist subjects* {
    replace `var' = substr(`var',-1,.)
  }
  
format %5s sex subjects* 
replace name = proper(name)

******************************************************************


/*
Q2 : Côte d'Ivoire Population Density
We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

*/

*To solve this, we need to extract department level data from an excel spreadsheet. These are in light grey. We will then need to merge the extracted data with the original data set and clean the data accordingly. We will need to convert the extracted data to string variables and convert from all uppercase. To do this sucessfully, there must be cleaning done to both data sets beofre the merge. 

use "q2_CIV_Section_0", clear

*First import the excel and convert to string. This can be done via "point click method" and then copying the code below, or just through writing the code. Need to convert to string here.

import excel "q2_CIV_populationdensity", sheet("Population density") firstrow allstring

*Now we keep and sort by ourvariable of interest and are interested in the observations associated with "DEPARTEMENT"

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION

*we need to get rid of part of the department data (this is french so there are d' and de etc that we don't need)

gen department = NOMCIRCONSCRIPTION
*helpful to look at syntax for subinstr: subinstr("this is this", "is", "X",.) = "thX X thX"
replace department = subinstr(department, "DEPARTEMENT D'", "",.)
replace department = subinstr(department, "DEPARTEMENT DE", "",.)
replace department = subinstr(department, "DEPARTEMENT DU", "",.)
replace department = "arraha" if department=="arrah"

rename DENSITEAUKM pop_density_km2//* this is column we want to keep */
keep pop_density_km2 department

codebook department

*leading blank means there is a space at the beginnnig which is an issue. Use google to see how to fix then help strtrim which gets rid of leading and trailing blanks

replace department = strtrim(department)

codebook department /* the issue is solved */

replace department = lower(department)

tempfile survey
save `survey' /* this doesnt work for me. */

save "q2_CIV_populationdensity1"

exit
merge 1:m department using "q2_CIV_populationdensity1"

*Copy and paste the first 20 NOMCIRCONSCRIPTION in a separate .do/place. Then we load the survey data and see our desired data in b06.

codebook b06_departemen

*when comparing the datasets we see that the unque values are similar (appx 107 compared to 108)

labelbook b06_departemen

*THey are in ascending order and we can see that the departments generally seem to match but are not in exact alphabetical order. 

*The issue is that the orginal data set is numeric with a label on it. To fix this, we need to convert to string.

decode b06_departemen, gen(department)

keep department

duplicates drop

sort department

*This is ideally what we want, but now we need to do the same level of cleaning to the other data set.

***Once all the cleaning is complete, we can check if we are ready to merge

merge 1:1 department using "q2_CIV_populationdensity1"

drop if _merge==1
order department pop_density_km2, last 

*106 matched, can fix two of three unmatched because it doesn't exist in survey data.
 

/*
Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

*/

*To solve this, take the left-most observation and put it into an empty data set. Then cross it with the original data set with a function that can calculate all the distances from the original point to each separate point. You can then identify which of the points have the shortest distance from the original point and then call it cluster 1. You then have to remove those 6 points from the original data set. Then you go to the next nearest observation and repeat the process. Once complete, append the previously empty data set to the clustered data set. To check the results of your work, create a scatter plot depicting the latitude and longidtude based on the cluseters. . 

use "q3_GPS Data", clear

ssc inst sepscatter

scatter latitude longidtude

use "store_location", clear

keep in 1

rename *one_*

cross using "store_location" 

geodist_one gps /* struggling to make this work */

sort dist_km

drop if one_unique_id==unique_id

gen nb_store_500m = 0
replace nb_store_500m = 1 if distance

sepscatter latitude longidtude, separate(_clus1) 

*create a clustered graph so enumerators know where to go. then number each cluster

*dont use k means because there needs to be 6 stores per person. 


/*

Q4 : 2010 Tanzania Election Data cleaning
2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*/


*First four rows need to be gone.... can import via click and point and choose rows as well as import as string. 

import excel "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation
> \week-05-materials\q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) allstring

*browse and compare to desired data set set-up. We need to "drag and drop" the respectvie districts, constituencies, wards etc. to fill the blanks below them (but with code). Need a separate column for political party.

drop if _n == 1
drop K
gen serial = _n  /* this preseves the inital row numbers */

replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace CONSTITUENCY = CONSTITUENCY[_n-1] if CONSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""
gen i = _n
egen unique_ward_id = group(REGION DISTRICT WARD)
*This gives us a numeric id and gets the correct number of groups

gen unique_ward = REGION + "_" + DISTRICT + "_" + WARD

duplicates tag WARD, gen(d)

exit

fillin unique_ward POLITICALPARTY

sort unique_ward _fillin

keep unique_ward POLITICALPARTY TTLVOTES

sort unique_ward POLITICALPARTY
bysort unique_ward: gen j=_n

tab j POLITICALPARTY

*investigate anomalies which are two canidadtes from the same political party

br if j=4 & POLITICALPARTY == "CCM"

exit 

*The final thing we need to do is reshape from long to wide
reshape wide POLITICALPARTY i(unique_ward) j(_n) 


/*

Q5 : Tanzania Election data Merging
Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.

*/

use "tz_15_10_gis", clear

*First we need to figure out how we will match these datasets. We will save region, district and ward as a temp file.

keep region_gis_2017 district_gis_2017 ward_gis_2017
duplicates drop
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward_gis_2017
gen dist_id = _n

tempfile gis_15
save `gis_15'

*We are doing this separately first because the data is very noisy.

use "tz_elec_15_clean", clear
keep region_15 district_15 ward_15
duplicates drop
rename (region_15 district_15 ward_15)(region district ward)
sort region district ward
gen idvar = _n

*we need to use reclink as a "fuzzy match up".  reclink uses record linkage methods to match observations between two datasets where no perfect key fields exist -- essentially a fuzzy merge. reclink allows for user-defined matching and non-matching weights for each variable and employs a bigram string comparator to assess imperfect string matches.

*We need to see how alike and different the strings between the two data sets

gsort -score
reclink2 region district ward using `gis_15' idmaster(idvar) idusing(dist_id) gen(score)

*if the score is 1, then it is a perfect match. Less than that, the worse match it is. 

*To finish solving this, we would compare data from 2010 to 2015 dataset and see which are the matching wards. The remaining unmatched wards could be compared to the intersection dataset to tell what the original parent ward is. 

exit


