*week05 Xinyu Zheng

global wd "C:/Users/zheng/Desktop/research design/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

********************************************************************************
*Q1
********************************************************************************
clear

tempfile psle
save `psle', emptyok

forvalues i = 1/138 {
	use "$wd/q1_psle_student_raw.dta", clear

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

	append using `psle'
	save `psle', replace
}

********************************************************************************
* Q2
********************************************************************************
import excel using "$wd/q2_CIV_populationdensity.xlsx", clear firstrow

keep if regexm(NOMCIRCONSCRIPTION, "DEPARTEMENT")

replace NOMCIRCONSCRIPTION = strlower(strtrim(substr(NOMCIRCONSCRIPTION, 15, .)))

drop SUPERFICIEKM2 POPULATION

rename (NOMCIRCONSCRIPTION DENSITEAUKM) (department pop_density)

replace department = "arrha" if department == "arrah" 

tempfile pop_density
save `pop_density'

use "$wd/q2_CIV_Section_0.dta", clear

decode b06_departemen, gen(department)

merge m:1 department using `pop_density'

drop if _merge == 1

********************************************************************************
*Q3
********************************************************************************
use "$wd/q3_GPS Data.dta", clear

tempfile gps
save `gps'

clear

tempfile assigned
save `assigned', emptyok

forvalues x = 1/19 {
	use `gps', clear

	creturn list

	if c(N) >= 6 {
		keep in 1

		rename * *_1

		cross using `gps'

		geodist latitude_1 longitude_1 latitude longitude, gen(distance)

		sort distance

		keep in 1/6

		gen enumerator = `x'

		drop *_1 distance

		append using `assigned'
		save `assigned', replace

		levelsof id, local(id_assigned)

		use `gps', clear

		foreach i in `id_assigned'{
			drop if id == `i'
		}

		save `gps', replace
	}

	else {
		gen enumerator = `x'

		append using `assigned'
		save `assigned', replace
	}
}

use `assigned', clear

sepscatter latitude longitude, separate(enumerator) legend(row(2)) 

********************************************************************************
* Q4
********************************************************************************
import excel using "$wd/q4_Tz_election_2010_raw.xls", clear

drop in 1/6

drop F G J K

rename (A B C D E H I) (region district constituency ward candidate party vote) 

* fill the blanks
foreach v in region district constituency ward {
	replace `v' = `v'[_n-1] if `v' == ""
}

* calculate the number of candidate
bysort region district constituency ward: egen number_cand = count(candidate)

* prepare for reshape
egen ward_id = group(region district constituency ward)

** find duplicated parties in one ward
duplicates tag ward_id party, gen(duplicates)

br if duplicates != 0

** gengerate total vote by party and drop duplicates
destring vote, replace ignore("UN OPPSSED")

bysort ward_id party: egen party_vote = total(vote), missing

drop candidate vote duplicates

duplicates drop

replace party = subinstr(party, " - ", "_", .)
replace party = subinstr(party, "-", "_", .)
replace party = subinstr(party, " ", "_", .)

* reshape
reshape wide party_vote, i(ward_id) j(party) string

ds, has(type string)
foreach v in `r(varlist)' {
	replace `v' = strlower(`v')
}

egen total_vote = rowtotal(party_vote*), missing

order party_vote*, last

********************************************************************************
* Q5
********************************************************************************
clear

tempfile 2015_2010
save `2015_2010', emptyok

* process 2015 data
use "$wd/q5_Tz_elec_15_clean.dta", clear

rename (region_15 district_15 ward_15) (region district ward)

tempfile 2015
save `2015'

* process 2010 data
use "$wd/q5_Tz_elec_10_clean.dta", clear

drop total_candidates_10 ward_total_votes_10

rename (region_10 district_10 ward_10) (region district ward)

tempfile 2010
save `2010'

* fussy merge 2015 and 2010 data
use `2015', clear

reclink2 region district ward using `2010', idmaster(ward_id_15) idusing(ward_id_10) gen(score)

gsort -score

drop if score < 0.97 | score == .

rename (Uregion Udistrict Uward region district ward) (region_10 district_10 ward_10 region_15 district_15 ward_15)

order *_10, last

drop score ward_id_10 _merge

levelsof ward_id_15, local(ward_id_15)

append using `2015_2010'
save `2015_2010', replace

* delete merged data
use `2015', clear

foreach id in `ward_id_15' {
	drop if ward_id_15 == `id'
}

save `2015', replace
*save "C:/Users/zheng/Desktop/research design/2015_left.dta"

* merge left 2015 data with intersection data
use "$wd/q5_Tz_ArcGIS_intersection.dta", clear

rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)

tempfile intersection
save `intersection'

use `2015', clear

*use "C:/Users/zheng/Desktop/research design/2015_left.dta", clear

reclink2 region district ward using `intersection', idmaster(ward_id_15) idusing(objectid) gen(score)

gsort -score

drop if score < 0.6667 | score == . // delete unmatched

drop if objectid == 2318 // delete the unmatched duplicated ward_id_15

drop U* score objectid fid_gis_2017 fid_gis_2012 area percentage _merge

rename (region district ward region_gis_2012 district_gis_2012 ward_gis_2012) (region_15 district_15 ward_15 region district ward)

reclink2 region district ward using `2010', idmaster(ward_id_15) idusing(ward_id_10) gen(score)

gsort -score

drop if score < 0.6363 | score == .

drop region district ward score ward_id_10 _merge

rename U* (region_10 district_10 ward_10)

levelsof ward_id_15, local(ward_id_15)

append using `2015_2010'
save `2015_2010', replace

* delete merged data
use `2015', clear

foreach id in `ward_id_15' {
	drop if ward_id_15 == `id'
}

rename (region district ward) (region_15 district_15 ward_15)

append using `2015_2010'
save `2015_2010', replace

sort ward_id_15

duplicates drop

