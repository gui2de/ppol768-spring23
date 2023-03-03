global wd"/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-05"

global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_Section_0.dta"
global q3 "$wd/q3_GPS Data.dta"
global q4 "$wd/q4_Tz_election_2010_raw.xls"
global q4_template "$wd/q4_Tz_election_template.dta"
global q5 "$wd/q5_Tz_ArcGIS_intersection.dta"
global q5_10 "$wd/q5_Tz_elec_10_clean.dta"
global q5_15 "$wd/q5_Tz_elec_15_clean.dta"

*Q1  I use two ways to solve this problem. The major difference is whether to use loop. 
{
clear
tempfile student_cleaned
save `student_cleaned', replace emptyok

forvalues i=1/138 {
	use "$q1", clear
	display as error "This is loop number `i'"
	keep in `i'
	replace s = substr(s, strpos(s, "SUBJECT"), .)
*split each line 
split s, parse("</TD></TR>") 
drop s s1
*serial indicate different schools 
gen serial = _n
reshape long s, i(serial) j(stud_obs)
split s, parse("><P")
drop s 

gen cand_No = substr(s2,17,14)
gen prem_No = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
replace schoolcode = substr(schoolcode, 5, 9)

split s5, parse("</FONT>")
drop s52
gen name = substr(s51,2,.)

split s6, parse("-" ",")
rename s62 Kiswahili
rename s64 English 
rename s66 Maarifica 
rename s68 Hisabati 
rename s610 Science 
rename s612 Uraia 
gen average =substr(s614, -8, 1)

order s*
drop s1-s614

drop if missing(cand_No)

append using `student_cleaned'
save `student_cleaned', replace
}

use `student_cleaned', clear
exit
}

*Q1 solving without loop 
{
use "$q1", clear
replace s = substr(s, strpos(s, "SUBJECT"), .)
*split each line 
split s, parse("</TD></TR>") 
drop s s1
*serial indicate different schools 
gen serial = _n
reshape long s, i(serial) j(stud_obs)
split s, parse("><P")
drop s 

gen cand_No = substr(s2,17,14)
gen prem_No = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
replace schoolcode = substr(schoolcode, 5, 9)

split s5, parse("</FONT>")
drop s52
gen name = substr(s51,2,.)

split s6, parse("-" ",")
rename s62 Kiswahili
rename s64 English 
rename s66 Maarifica 
rename s68 Hisabati 
rename s610 Science 
rename s612 Uraia 
gen average =substr(s614, -8, 1)

order s*
drop s1-s614

drop if missing(cand_No)
}

*Q2
{
global pop "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-05/q2_CIV_populationdensity.xlsx"
*update the global
clear

*explore b06_department variable 
use "$q2", clear
decode b06*, gen(department)

*why we need duplicates drop?

tempfile department_level
save `department_level'

import excel "$pop", sheet("Population density") firstrow case(lower) clear allstring

rename densiteaukm pop_density

keep if strpos(nomcirconscription, "DEPARTEMENT") == 1 
sort nomcirconscription

gen department = nomcirconscription
replace department = subinstr(department, "DEPARTEMENT D'", "", .) 
replace department = subinstr(department, "DEPARTEMENT DE", "",.)
replace department = subinstr(department, "DEPARTEMENT DU", "",.)
*remove blanks in the variable
replace department = trim(department)
replace department = strlower(department)
replace department = "arrha" if department=="arrah"


keep department pop_density

merge 1:m department using `department_level'
drop if _merge==1
order department pop_density, last
}

*Q3
{
*save the q3 file in a tempfile, to merge later with the enumerated tempfile so that locations that have been enumerated would be removed.
*our original dataset would be stay intacted 
ssc install geodist

tempfile q3_GPS 
 
 use "$q3"
 
save `q3_GPS'

*find 5 nearest points, starting from the first location///
*should append the tempfile after the loop otherwise 
forvalues i = 1/19 {
tempfile cluster`i'
	keep in 1
	rename * one_*
	cross using `q3_GPS'
	geodist one_latitude one_longitude latitude longitude, gen(distance)
	sort one_id distance 
	drop if one_id == id
	drop if _n>=6
	gen enumerator = `i'
	gen j = _n
	keep one_id id enumerator j
	reshape wide id, i(one_id) j(j)
	rename one_id id 
	save `cluster`i'', replace
	merge 1:1 id using `q3_GPS'
	
	drop if id == id1[1] | id == id2[1] | id == id3[1] | ///
	id == id4[1] | id == id5[1]
	drop if enumerator != .
	drop _merge id1 id2 id3 id4 id5 enumerator 
	save `cluster`i'', replace
}
}


*Q4 Finished 
{
use "$q4_template",clear

import excel "$q4", cellrange(A5:J7927) sheet("Sheet1") firstrow case(lower) clear

drop if _n == 1
gen serial = _n
drop g sex

*fillin region, district constituency and ward
replace region = region[_n-1] if region == ""
replace region = strtrim(region)
replace district = district[_n-1] if district == ""
replace district = strtrim(district)
replace costituency = costituency[_n-1] if costituency== ""
replace costituency = strtrim(costituency)
replace ward = ward[_n-1] if ward== ""
replace ward = strtrim(ward)
replace ttlvotes = "0" if ttlvotes == "UN OPPOSSED"
destring ttlvotes, replace

gen unique_ward = region + "_" + district + "_" + ward
*count candidate in each ward
bysort unique_ward: egen total_candidate = count(unique_ward)
drop candidatename

fillin unique_ward politicalparty 

sort unique_ward _fillin

replace region = region[_n-1] if region == ""
replace region = strtrim(region)
replace district = district[_n-1] if district == ""
replace district = strtrim(district)
replace costituency = costituency[_n-1] if costituency== ""
replace costituency = strtrim(costituency)
rename costituency constituency
replace ward = ward[_n-1] if ward== ""
replace ward = strtrim(ward)
replace total_candidate = total_candidate[_n-1] if total_candidate == .

keep unique_ward ttlvotes politicalparty total_candidate constituency 

sort unique_ward politicalparty

bysort unique_ward: gen j = _n

tab j politicalparty
*detect and combine duplicates 
duplicates list politicalparty unique_ward
collapse (sum) ttlvotes, by(unique_ward politicalparty ///
total_candidate constituency)

*check again for duplicates
duplicates list politicalparty unique_ward

*split the wards
split unique_ward, parse("_")
rename(unique_ward1 unique_ward2 unique_ward3)(region district ward)
replace region = lower(region)
replace district = lower(district)
drop unique_ward

*count total votes in wards
bysort ward: egen total_votes_wards = sum(ttlvotes)

*remove spaces in politicalparty
replace politicalparty = subinstr(politicalparty, " - ", "_", .)
replace politicalparty = subinstr(politicalparty, "-", "_", .)
replace politicalparty = subinstr(politicalparty, " ", "_", .)
*reshape
reshape wide ttlvotes, i(region district ward constituency) j(politicalparty) string
*order the table
order ttlvotes*, last
order constituency, after(ward)
}

*Q5 Stuck in the same place as in Question 3
{
*install recklins2
net from http://www.stata-journal.com/software/sj15-3
net install dm0082.pkg, replace
net get dm0082.pkg, replace

*processing data
use "$q5",clear
keep region_gis_2017 district_gis_2017 ward_gis_2017
duplicates drop
rename(region_gis_2017 district_gis_2017 ward_gis_2017) ///
(region district ward)
sort region district ward
gen dist_id = _n
tempfile gis
save `gis'

*2010
use "$q5_10", clear
keep region_10 district_10 ward_10 ward_id_10
duplicates drop
rename (region_10 district_10 ward_10) (region district ward)
sort region district ward	   
tempfile 2010_clean
save `2010_clean'

*2015
use "$q5_15", clear
keep region_15 district_15 ward_15 ward_id_15
duplicates drop
rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
tempfile 2015_clean
save `2015_clean'

*reclink 2010 to 2015 data 
use `2015_clean', clear
reclink2 region district ward using `2010_clean', ///
idmaster(ward_id_15) idusing(ward_id_10) gen(score) 

gsort -score

keep region_10
*fuzzy matching 
reclink2 region district ward using `gis_15', ///
idmaster(idvar) idusing(dist_id) gen(score) 

gsort -score

drop if score < 0.9701 | score == .

rename (region district ward Uregion Udistrict Uward) ///
(region_15 district_15 ward_15 region_10 district_10 ward_10)

drop score ward_id_10 _merge

*store the matched ward id in new tempfiles 10to15 and remove those wards from 2015 data
*use the same strategy to fuzzy match the rest of the 2015 wards with 
*`gis' tempfile, and drop those with low score.
*append the matched wards ids to 10to15 tempfile
*sort the 10to15 tempfile and drop duplicates ward ids to get the list
}

*I got stuck in removing the matched ids from 2015_clean and store the ids in a new tempfile that will also append further match results.
*I guess this is similar to question 3 where we ought to remove the marked ids from original file and re-mark them. Meanwhile the marked results will be appended and stored in a new file.
*I tried to creat mulitiple new tempfiles. But I am confused with when to save the new results/ids in the tempfile and when to recall orginial table to remove the ones that have been matched/marked.






