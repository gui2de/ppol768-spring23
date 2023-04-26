global wd "/Users/liufan/Desktop/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
global q1 "$wd/q1_psle_student_raw.dta"
global q2 "$wd/q2_CIV_Section_0.dta"
global q3 "$wd/q3_GPS Data.dta"
global q51 "$wd/q5_Tz_elec_10_clean.dta"
global q52 "$wd/q5_Tz_elec_15_clean.dta"
global q53 "$wd/q5_Tz_ArcGIS_intersection.dta"

//Q1: Tanzania Student Data
use "$q1", clear
split s, parse(<TABLE) 
keep s3
split s3, parse(<TR>)
drop s31 s32 s3
gen i = _n
reshape long s, i(i) j(string) 
drop i
split s, parse(<P)
split s5, p("</FONT>")
gen t_schoolcode = substr(s2, 17, 9)
gen cand_id = substr(s2, 27, 4)
gen prem_number = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
gen name = subinstr(s51,">","", 1)
split s6, p("- ", ",")
gen average = substr(s614, 1, 1)
rename s62 Kiswahili
rename s64 English
rename s66 Maarifa
rename s68 Hisabati
rename s610 Science
rename s612 Uraia
drop s*
rename t_schoolcode schoolcode
drop if schoolcode == ""

//Q2: Côte d'Ivoire Population Density
clear
import excel "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow
keep if regexm(NOMCIRCONSCRIPTION, "DEPARTEMENT")
replace NOMCIRCONSCRIPTION = lower(NOMCIRCONSCRIPTION)
encode NOMCIRCONSCRIPTION, gen(b06_departemen)
merge 1:m b06_departemen using "$q2"
keep if _merge == 3
rename (b06_departemen DENSITEAUKM) (department pop_density)
drop NOMCIRCONSCRIPTION SUPERFICIEKM2 POPULATION _merge 
order hh1 hh2 b04_district strate b05_region department b07_souspref b08_commune b09_zd b10_nomvillag b11_quartcpt milieu pop_density

//Q3 : Enumerator Assignment based on GPS

use "$q3", clear
tempfile gps
save `gps'
clear
tempfile GPS
save `GPS', emptyok

forvalues i = 1/19{
	use `gps',clear
	creturn list 
	if c(N) >= 6 {
		keep in 1 
		rename (latitude longitude id) (latitude_1 longitude_1 id_1)
		cross using `gps'
		geodist latitude_1 longitude_1 latitude longitude, gen(distance)
		sort distance 
		keep in 1/6
		gen cluster = `i'
		drop latitude_1 longitude_1 id_1 distance
		append using `GPS'
		save `GPS',replace
		levelsof id, local(ID)
		use `gps',clear
		foreach j in `ID'{
			drop if id == `j'
		}
		save `gps', replace
	}
	else {
		gen cluster = `i'
		append using `GPS'
		save `GPS', replace
	}
}


//Q4: 2010 Tanzania Election Data cleaning
clear
import excel "q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:J7927) firstrow
drop if _n == 1
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""
bysort REGION DISTRICT COSTITUENCY WARD: egen total_candidate = count(CANDIDATENAME)
egen ward_id = group(REGION DISTRICT COSTITUENCY WARD) 
destring TTLVOTES, replace force
bysort ward_id POLITICALPARTY: gen set = _n
keep if set == 1
replace POLITICALPARTY = subinstr(POLITICALPARTY, " ", "", .) 
replace POLITICALPARTY = subinstr(POLITICALPARTY, "-", "_", .) 
drop SEX G CANDIDATENAME ELECTEDCANDIDATE set
reshape wide TTLVOTES, i(ward_id) j(POLITICALPARTY) string
order REGION DISTRICT COSTITUENCY WARD total_candidate, first

//Q5 : Tanzania Election data Merging
use "$q53", clear 
duplicates drop 
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n
tempfile gis_15
save `gis_15'
use "$q51", clear
rename (region_10 district_10 ward_10) (region_15 district_15 ward_15)
merge 1:1 region_15 district_15 ward_15 using "$q52"
drop if _merge == 1
drop _merge
rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar = _n
reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score) 
rename (Uregion Udistrict Uward region district ward) (region_10 district_10 ward_10 region_15 district_15 ward_15)
