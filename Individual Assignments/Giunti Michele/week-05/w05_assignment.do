********************************************************************************
* PPOL 768: Week 5
* Assignment for Week 5
* Michele Giunti
* Feb 9th, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/

/*******************************************************************************
1. Tanzania Student Data
*******************************************************************************/
clear
use "01_data/q1_psle_student_raw.dta"

foreach v of varlist schoolcode{
	replace s = substr(s,strpos(s,"SUBJECT"),.)
split s, parse("</TD></TR>")
gen i = _n
drop s


reshape long s, i(i) j(j)

*Remove HTML and separate relevant information
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")

*Drop Missing
foreach var of varlist *{
    capture assert missing(`var')
    if !_rc {
        drop `var'
    }
}
}

drop if missing(s5)

drop i j s

gen id = 0
replace id = 1 if !missing(s50)
replace id = 2 if !missing(s51)

egen name = concat(s21 s22 s23 s24 s25), punct(" ")

ds s21-s51
local variables `r(varlist)'
local nvars : word count `variables'
macro list _variables _nvars

forvalues vnf = 2(1)`nvars' {
    local vnt = `vnf' - 1
    local from : word `vnf' of `variables'
    local to   : word `vnt' of `variables'
    quietly replace `to' = `from' if id==1 | id == 2
}

forvalues vnf = 2(1)`nvars' {
    local vnt = `vnf' - 1
    local from : word `vnf' of `variables'
    local to   : word `vnt' of `variables'
    quietly replace `to' = `from' if id==2
}

foreach var of varlist *{
	replace `var' = subinstr(`var', ",","",.)
}

drop schoolcode s1 s2 s3 s7 s8 s12 s13 s17 s19 s21 s22 s23 s24 s25 s26 s27 s28 s29 s31 s32 s34 s35 s37 s38 s40 s41 s43 s44 s46 s47 s48 s50 s51 id

rename s5 id
rename s10 prem_number
rename s15 gender
rename s30 kiswahili
rename s33 english
rename s36 maarifa
rename s39 hisabati
rename s42 science
rename s45 uraia
rename s49 average

split id, parse("-")
drop id
rename id1 schoolcode
rename id2 cand_id

order schoolcode cand_id

/*******************************************************************************
2. Côte d'Ivoire Population Density
*******************************************************************************/
clear

global excel_d "01_data/q2_CIV_populationdensity.xlsx"

tempfile department
save `department', replace emptyok

import excel "$excel_d", sheet("Population density") firstrow case(lower) clear
keep if regex(nomcirconscription, "DEPARTEMENT" )==1
replace nomcirconscription = subinstr(nomcirconscription, "DEPARTEMENT", "", .)
replace nomcirconscription = subinstr(nomcirconscription, "DE", "", .)
replace nomcirconscription = subinstr(nomcirconscription, "DU", "", .)
replace nomcirconscription = subinstr(nomcirconscription, "D'", "", .)
replace nomcirconscription = subinstr(nomcirconscription, " ", "", .)
replace nomcirconscription = strlower(nomcirconscription)
drop if strpos(nomcirconscription ,"gbeleban")
sort nomcirconscription
encode nomcirconscription, gen(b06_departemen)

save `department', replace

clear
use "01_data/q2_CIV_Section_0.dta"
decode b06_departemen, gen(dep)
label drop b06_departemen
sort dep
drop b06_departemen
encode dep, gen(b06_departemen)
order b06_departemen, after(b05_region)

merge m:m b06_departemen using "`department'"
drop nomcirconscription dep

/*******************************************************************************
3. Enumerator Assignment based on GPS
*******************************************************************************/
clear
tempfile main

use "01_data/q3_GPS Data.dta"

ssc install geodist

save `main'

forvalues i = 1/19 {
tempfile t`i'
sort latitude
keep in 1
rename * one_*
cross using `main'
geodist one_latitude one_longitude latitude longitude, gen(distance_km)
sort distance_km
drop if one_id == id
drop if _n>5
gen shape = _n
gen enumerator = `i'
keep one_id id shape enumerator
reshape wide id, i(one_id) j(shape)
rename one_id id
save `t`i'', replace
if enumerator == 19 {
	continue, break
}
merge 1:1 id using `main'

drop if id == id1[1] | id == id2[1] | id == id3[1] | id == id4[1] | id == id5[1]
drop if !missing(enumerator)
drop _merge
drop id1 id2 id3 id4 id5 enumerator
save `main', replace
}

clear
tempfile boi
save `boi', replace emptyok
forvalues i = 1/19 {
    append using `t`i''
    save `"`boi'"', replace
}



/*******************************************************************************
4. 2010 Tanzania Election Data cleaning
*******************************************************************************/
clear
global excel_t "01_data/q4_Tz_election_2010_raw"

tempfile t2010
save `t2010', replace emptyok

import excel "$excel_t", sheet("Sheet1") cellrange(A5:K7927) firstrow
rename *, lower
drop k

foreach v of varlist region district costituency ward {
	replace `v' = `v'[_n-1] if missing(`v')
	replace `v' = strlower(`v')
}

replace costituency = strupper(costituency)

egen tag = tag(ward candidatename) 
egen ndistinct = total(tag), by(ward)
rename ndistinct total_candidates
order total_candidates, after(ward)

drop tag candidatename sex g electedcandidate
drop if total_candidates == 0


sort ward
by ward: gen ward_id = 1 if _n==1
replace ward_id = sum(ward_id)
replace ward_id = . if missing(ward)


replace politicalparty = subinstr(politicalparty, " ", "", .)
replace politicalparty = subinstr(politicalparty, "-", "_", .)


gen id = _n
reshape wide ttlvotes, i(id) j(politicalparty) string

encode ttlvotesAFP, gen(votes_AFP)
encode ttlvotesAPPT_MAENDELEO, gen(votes_APPT_MAENDELEO)
encode ttlvotesCCM, gen(votes_CCM)
encode ttlvotesCHADEMA, gen(votes_CHADEMA)
encode ttlvotesCHAUSTA, gen(votes_CHAUSTA)
encode ttlvotesDP, gen(votes_DP)
encode ttlvotesJAHAZIASILIA, gen(votes_JAHAZIASILIA)
encode ttlvotesMAKIN, gen(votes_MAKIN)
encode ttlvotesNCCR_MAGEUZI, gen(votes_NCCR_MAGEUZI)
encode ttlvotesNRA, gen(votes_NRA)
encode ttlvotesSAU, gen(votes_SAU)
encode ttlvotesTADEA, gen(votes_TADEA)
encode ttlvotesTLP, gen(votes_TLP)
encode ttlvotesUDP, gen(votes_UDP)
encode ttlvotesUMD, gen(votes_UMD)
encode ttlvotesUPDP, gen(votes_UPDP)

drop ttlvotesAFP ttlvotesAPPT_MAENDELEO ttlvotesCCM ttlvotesCHADEMA ttlvotesCHAUSTA ttlvotesCUF ttlvotesDP ttlvotesJAHAZIASILIA ttlvotesNCCR_MAGEUZI ttlvotesNLD ttlvotesNRA ttlvotesSAU ttlvotesTADEA ttlvotesTLP ttlvotesUDP ttlvotesUMD ttlvotesUPDP ttlvotesMAKIN

local yikes votes_AFP votes_APPT_MAENDELEO votes_CCM votes_CHADEMA votes_CHAUSTA votes_DP votes_JAHAZIASILIA votes_MAKIN votes_NCCR_MAGEUZI votes_NRA votes_SAU votes_TADEA votes_TLP votes_UDP votes_UMD votes_UPDP
collapse (sum) `yikes', by (region district costituency ward total_candidates ward_id)

egen ward_total_votes = rowtotal(`yikes')
order ward_total_votes, after(total_candidates)

foreach j in *{
	rename * *_10
}

foreach i in votes_AFP votes_APPT_MAENDELEO votes_CCM votes_CHADEMA votes_CHAUSTA votes_DP votes_JAHAZIASILIA votes_MAKIN votes_NCCR_MAGEUZI votes_NRA votes_SAU votes_TADEA votes_TLP votes_UDP votes_UMD votes_UPDP{
	replace `i' = . if `i' == 0
}

save `t2010', replace

/*******************************************************************************
5. Tanzania Election data Merging
*******************************************************************************/

use "01_data/q5_Tz_ArcGIS_intersection.dta", clear 

keep region_gis_2017 district_gis_2017 ward_gis_2017
duplicates drop 
rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
sort region district ward
gen dist_id = _n

tempfile gis_15
save `gis_15'


use "01_data/q5_Tz_elec_15_clean", clear 
keep region_15 district_15 ward_15
duplicates drop
rename (region_15 district_15 ward_15) (region district ward)
sort region district ward
gen idvar = _n


reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score) 
tempfile match
save `match'

clear
use "01_data/q5_Tz_elec_10_clean"
tempfile elec2010
sort ward_10
rename (region_10 district_10 ward_10) (Uregion Udistrict Uward)
save `elec2010'

clear
use "01_data/q5_Tz_elec_15_clean"
tempfile elec2015
sort ward_15
rename (region_15 district_15 ward_15) (region district ward)
save `elec2015'


use `match'
sort ward
rename _merge mergematch
merge m:m ward using `elec2015'
sort ward
rename _merge merge2015
merge m:m Uward using `elec2010'
rename _merge merge2010

duplicates drop region Uregion district Udistrict ward Uward, force
keep if merge2010 != 2

*This is honestly the best I can do here. I am not sure if I did what the assignment asked me to do
*If you have any comments please let me know!
