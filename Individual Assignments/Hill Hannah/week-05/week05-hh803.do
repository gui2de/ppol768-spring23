// Hannah Hill //
// February 20, 2023 //
// Week 05 //

*******************************************************************************
** 1):  Tanzania Student Data                                                **
*******************************************************************************
//This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

use "q1_psle_student_raw.dta", clear

gen str_pos = strpos(s, "SUBJECT")
replace s = substr(s, strpos(s, "SUBJECT"), . )
split s, parse("</TD></TR>")

//reshape data to expand unique observations into rows/
gen i = _n
drop s
reshape long s, i(i) j(j)

//parse variables to create columns//
split s, parse("</FONT></TD>")
drop s
drop str_pos


//delete rows without data//
keep if j >= 2
keep if j <= 17

//parse through html variable by variable//

	//cand_id//
	split s1 , p("CENTER")
	drop s11
	split s12 , p(>)
	drop s1
	drop s12
	drop s121
	rename s122 cand_id

	//prem_number//
	split s2 , p("CENTER")
	drop s21
	split s22 , p(>)
	drop s2
	drop s22
	drop s221
	rename s222 prem_number
	
	//gender//
	split s3 , p("CENTER")
	drop s31
	split s32 , p(>)
	drop s3
	drop s32
	drop s321
	rename s322 gender
	
	//name//
	split s4 , p("<P>")
	drop s41
	rename s42 name
	drop s4

	//grades//
	split s5 , p("LEFT")
	drop s51
	split s52 , p(>)
	drop s5
	drop s52
	drop s521
	split s522 , p("<")
	rename s5221 grades
	drop s5222
	drop s522

// split grades //

	split grades , p(,)
	
	split grades1 , p(-)
	rename grades12 Kiswahili
	drop grades1
	drop grades11
	
	split grades2 , p(-)
	rename grades22 English
	drop grades2
	drop grades21
	

	split grades3 , p(-)
	rename grades32 Maarifa
	drop grades3
	drop grades31
	
	split grades4 , p(-)
	rename grades42 Hisbati
	drop grades4
	drop grades41
	
	split grades5 , p(-)
	rename grades52 Science
	drop grades5
	drop grades51
	
	split grades6 , p(-)
	rename grades62 Uraia
	drop grades6
	drop grades61
	
	split grades7 , p(-)
	rename grades72 Average_Grade
	drop grades7
	drop grades71
	
// finish dropping unecessary columns //
	drop grades
	drop i
	drop j

// drop schoolcode for easier generated clean schoolcode in next code chunk //
drop schoolcode
	
// split cand_id into school code and actual cand_id //
	split cand_id , p(-)
	rename cand_id1 schoolcode
	drop cand_id
	rename cand_id2 cand_id
	
// drop blank observations but unsure of how to drop blank string obs //
drop if 
// REVISIT


*******************************************************************************
** 2):  Cote d'Ivoire Population Density                                     **
*******************************************************************************
//We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

// load in both data files
use "q2_CIV_Section_0.dta", clear

decode b06_departemen, gen(department)
keep department
duplicates drop
sort department

tempfile survey
save `survey'


import excel using "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow allstring

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION
gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'", "",.)
replace department = subinstr(department, "DEPARTEMENT DE", "",.)
replace department = subinstr(department, "DEPARTEMENT DU", "",.)
replace department = strtrim(department)
replace department = lower(department)
replace department = "arrha" if department == "arrah"

rename DENSITEAUKM pop_density_km2
keep pop_density_km2 department

exit
// merge the two datafiles
merge 1:m department using `survey'
drop if _merge==1
order department pop_density_km2, last

// save
save "merged_CIV_data.dta", replace


*******************************************************************************
** 3): Enumerator Assignment based on GPS                                    **
*******************************************************************************
//We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

// calculate distance between all observations
// then, based off that column, assign enum 1-19?

// load necessary packages
ssc install spmap
ssc install geocode

// gen geonear
geonear id latitude longitude using "q3_GPS Data.dta", n(id1 latitude1 longitude1) ignoreself nearcount(6)

// egen enum1-19 based off nearcount(6) groupings???


// from office hours
use "q3_GPS", clear
scatter latitude longitude
sepscatter latitude longitude, separate(_clus_1)
cluster kmeans latitude longitude, k(19)
exit

*******************************************************************************
** 4):  2010 Tanzania Election Data cleaning                                 **
*******************************************************************************
//2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*1. delete first row and column k
drop if _n == 1
drop K

*2. M and F overlap
tab SEX G, m
gen sex_check = 0
replace sex_check = 1 if SEX == "M" & G == "F"
count if sex_check == 1
drop sex_check

*3. Combine sex columns 
gen gender = ""
replace gender = "M" if SEX == "M"
replace gender = "F" if G == "F"
tab gender
drop SEX G

*4. population cells for region, district, constituency, wards
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace CONSTITUENCY = CONSTITUENCY[_n-1] if CONSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""
gen i = _n

egen unique_ward_id = group(REGION DISTRICT WARD)

gen unique_ward = REGION + "_" + DISTRICT + "_" + WARD

fillin unique_ward POLITICALPARTY

sort unique_ward _fillin
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace CONSTITUENCY = CONSTITUENCY[_n-1] if CONSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""


keep unique_ward POLITICALPARTY TTLVOTES

sort unique_ward POLITICALPARTY
bysort unique_ward: gen j = _n
reshape wide POLITICALPARTY i(WARD) j(DISTRICT)



/// other trial

drop if _n == 1
drop K
gen serial = _n


gen ward = WARD
order ward, after(WARD)
replace ward = ward[_n-1] if ward== ""

gen constituency = CONSTITUENCY
replace constituency = constituency[_n-1] if constituency==""

gen district = DISTRICT
replace district = district[_n-1] if district == ""

gen region = REGION
replace region = region[_n-1] if region == ""

rename POLITICALPARTY party
rename TTLVOTES votes

drop WARD DISTRICT CONSTITUENCY REGION ELECTEDCANDIDATE SEX G CANDIDATENAME

gen r_d_ward = region + district + ward

fillin r_d_ward party
sort r_d_ward party
order r_d_ward party
exit
bysort r_d_ward: gen j = _n
encode r_d_ward, gen (i)

drop serial
reshape wide party votes, i(i) j(j)

order region district constituency
*******************************************************************************
** 5):  Tanzania Election Data merging                                       **
*******************************************************************************
//Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.

// NEED TO REVISIT AND SPEND MORE TIME ON

keep region_gis_2017 district_gis_2017 ward_gis_2017
duplicates drop
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n

tempfile gis_15
save `gis_15'
///////////////////////////


keep region_15 district_15 ward_15
duplicates drop
rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar = _n

reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score)
///////

