clear all 

*Working Directory
global wd "/Users/zhouming/Desktop/Graduate/Spring2023/Research Design/week05_assignment/data"

*Datasets
global q1 "$wd/q1_psle_student_raw.dta"
global q2_excel "$wd/q2_CIV_populationdensity.xlsx"
global q2_dta "$wd/q2_CIV_Section_0.dta"
global q3 "$wd/q3_GPS Data.dta"
global q4_template "$wd/q4_Tz_election_template.dta"
global q4 "$wd/q4_Tz_election_2010_raw.xls"
global q5_ArcGIS "$wd/q5_Tz_ArcGIS_intersection.dta"
global q5_2010 "$wd/q5_Tz_elec_10_clean.dta"
global q5_2015 "$wd/q5_Tz_elec_15_clean.dta"
global q1_do "$wd/Q4_do.do"

*Question 1 
clear 
tempfile student_clean 
save `student_clean', replace emptyok

forvalues i = 1/138{
	use "$q1",clear
	keep in `i'
	do "$q1_do"
	append using `student_clean'
	save `student_clean',replace
}

/*codes from week4 assignment
/*split the data into tables and other contents*/
split s, parse(<TABLE) //s3 is the table 
keep s3
/*split rows from the data*/
split s3, parse(<TR>)
drop s31 s32 s3
/*reshape data*/
gen row = _n
reshape long s, i(row) j(index) 
/*split rows*/
drop row
split s, parse(<P)
/*find information in each cell*/
gen t_schoolcode = substr(s2, 17, 9)
gen cand_id = substr(s2, 27, 4)
gen prem_number = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
split s5, p("</FONT>")
gen name = subinstr(s51,">","", 1)
split s6, p("- ", ",")
gen average = substr(s614, 1, 1)
/*rename columns properly*/
rename s62 kiswahili
rename s64 english
rename s66 maarifa
rename s68 hisabati
rename s610 science
rename s612 uraia
drop s*
rename t_schoolcode schoolcode
*/

*Question 2 
/*modified and adjusted dta data*/
use "$q2_dta", clear 
decode b06_departemen, gen(department)
keep department 
duplicates drop
tempfile survey
save `survey'

/*modified and adjusted excel data - generate department variable*/
import excel "$q2_excel",firstrow allstring clear
keep if regex(NOMCIRCONSCRIPTION,"DEPARTEMENT")

gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTMENT DE ","",.)
replace department = subinstr(department, "DEPARTMENT DU ","",.)
replace department = strtrim(department)
replace department = lower(department)

/*merge*/
merge 1:1 department using `survey'
drop _merge

*Question 3
//fail to put clusters together
// trying to pull them out, and put them in an empty sheet
use "$q3",clear

tempfile GPS
save `GPS'

clear

tempfile GPS_clean
save `GPS_clean', replace emptyok

forvalues i = 1/19{
	use `GPS',clear
	creturn list 
	if c(N) >= 6 {
		keep in 1 
		rename latitude latitude_one 
		rename longitude longitude_one 
		rename id id_one 
		cross using `GPS'
		geodist latitude_one longitude_one latitude longitude, gen(distance)
		sort distance 
		keep in 1/6
		gen cluster = `i'
		drop latitude_one longitude_one id_one distance
		append using `GPS_clean'
		save `GPS_clean',replace
		levelsof id, local(id_identified)
		use `GPS',clear
		foreach j in `id_identified'{
			drop if id == `j'
		}
		save `GPS',replace
	}
	else {
		gen cluster = `i'
		append using `GPS_clean'
		save `GPS_clean',replace
	}
}

*Question 4 
import excel "$q4", cellrange(A5:K7927) firstrow allstring clear
drop in 1 
/*replace missing values in the first four columns*/
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""

/*fillin unique combinations of ward and politicalparty*/
fillin WARD POLITICALPARTY 
keep if _fillin == 0 

/*encode and decode variables*/
encode TTLVOTES, gen(votes)
encode POLITICALPARTY, gen(politicalparty)

/*adjust variables with same ward and politicalparty, but with different candidate*/
gen n = _n 
replace votes = votes+581 if n == 5993
drop if n == 5994
replace votes = votes+306 if n == 5995
drop if n == 5996

/*reshape data from long to wide*/
keep WARD REGION DISTRICT COSTITUENCY votes politicalpart
reshape wide votes, i(WARD REGION DISTRICT COSTITUENCY) j(politicalparty)

*Question 5 
//fail to use reclink2 to re-contruct 
//still tyring 

/*use ArcGIS to locate the wards*/
use "$q5_ArcGIS", clear 
keep region_gis_2017 district_gis_2017 ward_gis_2017
rename(region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n 

tempfile gis_15
save `gis_15'

/*rename and gen unique id in 2015*/
use "$q5_2015",clear
keep region_15 district_15 ward_15
duplicates drop 
rename(region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar_15 = _n

/*rename and gen unique id in 2010*/
use "$q5_2010",clear
keep region_10 district_10 ward_10
duplicates drop 
rename(region_10 district_10 ward_10) (region district ward)
sort region district ward
gen idvar_10 = _n

reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score)

gsort - score

merge 1:1 ward_id_15 using "$q5_ArcGIS_edited"
drop _merge
merge 1:1 ward_id_15 using "$q5_2010_edited" 








