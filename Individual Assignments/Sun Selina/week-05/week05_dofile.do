global wd"/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-05"

global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_Section_0.dta"
global q3 "$wd/q3_GPS Data.dta"
global q4 "$wd/q4_Tz_election_2010_raw.xls"
global q4_template "$wd/q4_Tz_election_template.dta"

*Q1  using loop 
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

*solving without loop {
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
ssc install geodist

tempfile q3_GPS 
 
 use "$q3"
 
save `q3_GPS'

*save the q3 file in a tempfile and drop id that have already been enumerated in previous loop

*find 5 nearest points and append to the tempfile 
tempfile cluster
	save `cluster', replace emptyok
    use "$q3", clear
	keep in 1
	rename * one_*
	cross using "$q3"
	geodist one_latitude one_longitude latitude longitude, gen(distance)
	sort one_id distance 
	drop if one_id == id
	drop if _n>=6
	gen enumerator = 1
	gen j = _n
	keep one_id id enumerator j
	reshape wide id, i(one_id) j(j)
	rename one_id id 
	append using `cluster'
	save `cluster', replace
	merge 1:1 id using "$q3"
	drop id if id == id1 | id == id2 | id == id3| ///
	id == id4 | id == id5
	*can't move on because the invalid syntax
	use
	
	use `cluster', clear
}

*Q4 unfinished 
use "$q4_template",clear

import excel "$q4", cellrange(A5:J7927) sheet("Sheet1") firstrow case(lower) clear

drop if _n == 1

gen serial = _n
 
drop g sex candidatename 

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

fillin unique_ward politicalparty 
sort unique_ward _fillin

replace region = region[_n-1] if region == ""
replace region = strtrim(region)
replace district = district[_n-1] if district == ""
replace district = strtrim(district)
replace costituency = costituency[_n-1] if costituency== ""
replace costituency = strtrim(costituency)
replace ward = ward[_n-1] if ward== ""
replace ward = strtrim(ward)

keep  unique_ward ttlvotes politicalparty 

sort unique_ward politicalparty

bysort unique_ward: gen j = _n

encode politicalparty, gen (party)

reshape wide ttlvotes, i(unique_ward) j(j)

sort j politicalparty 

bysort ward: egen total_candidate = count(ward)

bysort ward: egen ward_total_votes = sum(ttlvotes)

encode politicalparty, gen(party) 

reshape wide ttlvotes, i(region district costituency unique_ward) j(party) 

bysort ward: egen total_candidate = count(ward)

bysort ward: egen ward_total_votes = sum(ttlvotes)


