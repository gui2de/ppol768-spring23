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
replace NOMCIRCONSCRIPTION = lower(NOMCIRCONSCRIPTION)
encode NOMCIRCONSCRIPTION, gen(b05_region)
merge m:m b05_region using "$q2"
keep if _merge == 3
drop NOMCIRCONSCRIPTION SUPERFICIEKM2 POPULATION _merge
order hh1 hh2 b04_district strate b05_region b06_departemen b07_souspref b08_commune b09_zd b10_nomvillag b11_quartcpt milieu DENSITEAUKM

//Q3 : Enumerator Assignment based on GPS
*In order to make up for the problem that k-means cannot limit the coarse size, I choose to keep only n=5 or n=6 clusters and keep looping commands. I'm not sure if it's possible with a loop but so far I've had no success. Compared with geodist, the advantage of cluster is that it can find the minimum distance of all points at the same time and classify them*
use "$q3", clear
gen enu_id = 0
cluster kmeans latitude longitude, k(19) start(kr(1234))
tab _clus_1
replace enu_id = 1 if _clus_1 == 11
replace enu_id = 2 if _clus_1 == 15
replace enu_id = 3 if _clus_1 == 18
cluster kmeans latitude longitude if enu_id == 0, k(16) start(kr(1234))
tab _clus_2
replace enu_id = 4 if _clus_2 == 15
cluster kmeans latitude longitude if enu_id == 0, k(15) start(r(1234))
tab _clus_3
replace enu_id = 5 if _clus_3 == 13
cluster kmeans latitude longitude if enu_id == 0, k(14) start(pr(1234))
tab _clus_4
replace enu_id = 6 if _clus_4 == 3
replace enu_id = 7 if _clus_4 == 10
cluster kmeans latitude longitude if enu_id == 0, k(12) start(kr(1234))
tab _clus_5
replace enu_id = 8 if _clus_5 == 12
cluster kmeans latitude longitude if enu_id == 0, k(11) start(r(1234))
tab _clus_6
replace enu_id = 9 if _clus_6 == 4
cluster kmeans latitude longitude if enu_id == 0, k(10) start(kr(1234))
tab _clus_7
replace enu_id = 10 if _clus_7 == 9
cluster kmeans latitude longitude if enu_id == 0, k(9) start(kr(1234))
tab _clus_8
replace enu_id = 11 if _clus_8 == 6
cluster kmeans latitude longitude if enu_id == 0, k(8) start(pr(1234))
tab _clus_9
replace enu_id = 12 if _clus_9 == 6
cluster kmeans latitude longitude if enu_id == 0, k(7) start(r(1234))
tab _clus_10
replace enu_id = 13 if _clus_10 == 6
cluster kmeans latitude longitude if enu_id == 0, k(6) start(kr(123))
tab _clus_11
replace enu_id = 14 if _clus_11 == 1
replace enu_id = 15 if _clus_11 == 4
cluster kmeans latitude longitude if enu_id == 0, k(4) start(kr(1234))
tab _clus_12
replace enu_id = 16 if _clus_12 == 2
replace enu_id = 17 if _clus_12 == 3
cluster kmeans latitude longitude if enu_id == 0, k(3) start(kr(1234))
tab _clus_13
replace enu_id = 18 if _clus_13 == 2
cluster kmeans latitude longitude if enu_id == 0, k(2) start(kr(1234))
tab _clus_14
replace enu_id = 18 if _clus_14 == 2
replace enu_id = 19 if _clus_14 == 1
drop _clus_1 _clus_2 _clus_3 _clus_4 _clus_5 _clus_6 _clus_7 _clus_8 _clus_9 _clus_10 _clus_11 _clus_12 _clus_13 _clus_14

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
