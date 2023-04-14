***Assignment 5
***Daniel Fang

clear 

***Loading assignment data
global wd "D:\FYQ\Georgetown\PPOL_768\768github\ppol768-spring23\Individual Assignments\Fang Daniel\week05\01_data"
global q1 "$wd\q1_psle_student_raw.dta"
global q2 "$wd\q2_CIV_Section_0.dta"
global q2e "$wd\q2_CIV_populationdensity.xlsx"
global q3 "$wd\q3_GPS Data.dta"
global q4 "$wd\q4_Tz_election_2010_raw.xls"
global q51 "$wd\q5_Tz_elec_10_clean.dta"
global q52 "$wd\q5_Tz_elec_15_clean.dta"
global q53 "$wd\q5_Tz_ArcGIS_intersection.dta"

ssc install geodist
***Question 1

***DRAFT
***split s, parse (<TABLE)
***keep s3
***split s3, parse(<TR>)
***drop s31 s32 s3
***gen serial = _n
***reshape long s, i(serial) j(school)
***drop serial
***split s, parse(<P)
***split s5, p("</FONT>")

tempfile data 
save `data', replace emptyok

clear

forvalues i = 1/138 {
	use "$q1", clear

	keep in `i'

	split s , parse(">PS")

	gen serial = _n

	drop s s1

	reshape long s, i(serial) j(student)

	split s, parse("<")

	keep s1 s6 s11 s16 s21

	ren (s1 s6 s11 s16 s21) ///
		(cand prem sex name subjects)

	compress

	replace cand = "PS" + cand
	replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
	replace sex  = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
	replace name = subinstr(name,`"P>"',"",.)
	replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

	compress

	split subjects , parse(",")

	drop subjects

	foreach var of varlist subjects* {
		replace `var' = substr(`var',-1,.)
	}

	format %5s sex subjects*

	rename (subjects*) ///
		(kiswahili english maarifa hisabati science uraia average)

	replace name = proper(name)

	append using `data'
	save `data', replace
}



use `data',  clear

save "${wd}/data_q1.dta"

***Question 2 

***import dta
use "$q2", clear
decode b06_departemen, gen(department)
keep department 
duplicates drop
tempfile survey
save `survey'

***modify excel

import excel using "$q2e", clear firstrow

keep if regexm(NOMCIRCONSCRIPTION, "DEPARTEMENT")

replace NOMCIRCONSCRIPTION = strlower(strtrim(substr(NOMCIRCONSCRIPTION, 15, .)))

drop SUPERFICIEKM2 POPULATION

rename (NOMCIRCONSCRIPTION DENSITEAUKM) (department pop_density)

replace department = "arrha" if department == "arrah" 

tempfile pop_density
save `pop_density'

use "$wd/q2_CIV_Section_0.dta", clear

decode b06_departemen, gen(department)

***perform merge
merge m:1 department using `pop_density'

browse if unmatched
drop if _merge == 1

exit 

***Question 3 
***This question worked if I use codes that are not loop. I failed to resolve

use "$q3",clear

tempfile GPS
save `GPS'


tempfile GPS_limited
save `GPS_limited', replace emptyok

forvalues i = 1/19{
	use `GPS',clear
	creturn list 
	
	if c(N) >= 6 {
		keep in 1 
		rename latitude latitude_1
		rename longitude longitude_1 
		rename id id_1
***There is a way to combine line 145-147 in one line, 	have not figured out how
		cross using `GPS'
		geodist latitude_1 longitude_1 latitude longitude, gen(distance)
		sort distance 
		keep in 1/6
		gen enumerator = `i'
		drop latitude_1 longitude_1 id_1 distance
		
		append using `GPS_limited'
		save `GPS_limited', replace
		levelsof id, local(id_identified)
		use `GPS',clear
		foreach i in `id_identified'{
			drop if id == `i'
		}
		save `GPS',replace
	}
	else {
		gen cluster = `i'
		append using `GPS_limited'
		save `GPS_limited',replace
	}
}


***Question 4 --------------------------------------------

clear
import excel using "$q4", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring clear
 
/*replace missing values*/
drop in 1 
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""
fillin WARD POLITICALPARTY 
keep if _fillin == 0 

/*data manipulations*/ 

/*ENCODING TTLVOTES, POLITICALPARTY*/ 
encode TTLVOTES, gen(votes)
encode POLITICALPARTY, gen(politicalparty)

/*FOR DIFFERENT CANDIDATES, MANIPULATE VOTES*/
gen n = _n 
replace votes = votes+581 if n == 5993
drop if n == 5994
replace votes = votes+306 if n == 5995
drop if n == 5996

/*RESHAPE DATA*/
keep WARD REGION DISTRICT COSTITUENCY votes politicalpart
reshape wide votes, i(WARD REGION DISTRICT COSTITUENCY) j(politicalparty)

***Question 5 WORKING

/*use 2010 data*/
use "$q51",clear
keep region_10 district_10 ward_10
duplicates drop 
rename(region_10 district_10 ward_10) (region district ward)
sort region district ward
gen idvar_10 = _n

/*use 2015 data*/
use "$q52",clear
keep region_15 district_15 ward_15
duplicates drop 
rename(region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar_15 = _n


/*use ARCGIS*/

use "$q53", clear 
keep region_gis_2017 district_gis_2017 ward_gis_2017
rename(region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n 