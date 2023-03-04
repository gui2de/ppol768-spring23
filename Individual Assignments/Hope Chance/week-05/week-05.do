* PPOL 768: Week 5
*Chance Hope 

*Working Directory
global wd "C:\Users\maxis\Desktop\ppol768-spring23\Individual Assignments\Hope Chance\week-05"

*Datasets
global psle_student "$wd/q1_psle_student_raw.dta"
global tz_elec_15_raw "$wd/Tanzania_election_2015_raw.dta"
global tz_elec_15_clean "$wd/Tz_elec_15_clean.dta"
global tz_elec_10_clean "$wd/Tz_elec_10_clean.dta"
global tz_15_10_gis "$wd/Tz_GIS_2015_2010_intersection.dta"
global q2_CIV "$wd/q2_CIV_populationdensity.xlsx"
global CIV_S0 "$wd/q2_CIV_Section_0.dta"
global GPS "$wd/q3_GPS Data.dta"
global tz_electdata "$wd/q4_Tz_election_2010_raw.xls"

*Q1
clear
tempfile student_clean
save `student_clean', replace emptyok

forvalues i=1/138 {
 use "$psle_student", clear
 display as error "This is loop number `i'"
 keep in `i'
	split s, parse(">PS")
	
	gen id = _n
	order id, first
	drop s
	
	reshape long s, i(id) j(student)
	split s, parse("<")
	
	keep s1 s6 s11 s16 s21
	drop in 1
	
	ren (s1 s6 s11 s16 s21) (cand_id prem_number sex names subjects)
	compress 

	append using `student_clean'
	save `student_clean', replace
}
 use `student_clean'
 	replace cand = "PS" + cand_id
	replace prem = subinstr(prem, "P ALIGN="CENTER">","",.)
	replace prem = subinstr(prem, `"""',  "", .)
	replace prem = subinstr(prem, "CENTER>" ,"",.)
	
	replace sex = subinstr(sex, "P ALIGN="CENTER">","",.)
	replace sex = subinstr(sex, `"""',  "", .)
	replace sex = subinstr(sex, "CENTER>" ,"",.)
	
	replace names = subinstr(names, "P>" ,"",.)
	
	replace subj = subinstr(subj, "P ALIGN="LEFT">","",.)
	replace subj = subinstr(subj, `"""',  "", .)
	replace subj = subinstr(subj, "LEFT>" ,"",.)
	
	generate Kiswahili = substr(subj, 13,1)
	generate English = substr(subj, 26,1)
	generate maarifa = substr(subj, 39,1) 
	generate hisabati = substr(subj,53,1) 
	generate science = substr(subj, 66,1) 
	generate uraia = substr(subj, 77,1) 
	generate average = substr(subj, -1,1)
 clear
 
*Q2
clear
tempfile CIV_merge
save `CIV_merge', replace emptyok
import excel "$q2_CIV", sheet("Population density") firstrow case(lower) clear

keep if regex(nomcirconscription, "DEPARTEMENT" )==1
gen departement1 = lower(substr(nomcirconscription, 16,.))
encode departement1, gen(departement)
drop nomcirconscription

append using `CIV_merge' 
save `CIV_merge', replace 

use "$CIV_S0", clear
rename b06_departemen departement
merge m:1 departement using `CIV_merge'
drop if _merge == 2


*Q3
* visiualize data before answering question: graph twoway scatter latitude longitude

clear
tempfile groups
save `groups', emptyok

forvalues i = 1/19 {
	use "$GPS", clear
	sort longitude
	gen enumerator = `i'
	gen rownumber = _n 
	gen alreadygrouped = (`i'*6)-6
	drop if rownumber <= alreadygrouped
	
	rename (latitude longitude) (latitude1 longitude1)
	drop id age female rownumber alreadygrouped
	keep in 1
	
	cross using "$GPS"
	sort longitude
	gen rownumber = _n 
	gen alreadygrouped = (`i'*6)-6
	drop if rownumber <= alreadygrouped

	geodist latitude1 longitude1 latitude longitude, gen(distance)
	sort distance
	replace rownumber = _n
	keep if rownumber <= 6
	drop alreadygrouped rownumber
	append using `groups'
	save `groups', replace	
}

*Q4
import excel "$tz_electdata", sheet("Sheet1") cellrange(A5:J7927) firstrow case(lower) clear
drop in 1
drop g elected sex
carryforward *, replace 
replace ttlvotes = "." if ttlvotes == "UN OPPOSSED"
destring(ttlvotes), replace

bysort ward region district: egen candidates = count(candidatename)
bysort ward region district: egen votes = total(ttlvotes) 
egen id = group(ward region district)
encode(politicalparty), gen(party)
duplicates drop id party, force

tab politicalparty
replace politicalparty = subinstr(politicalparty, " ", "",.)
replace politicalparty = subinstr(politicalparty, "-", "_",.)
replace politicalparty = subinstr(politicalparty, "JAHAZIASILIA", "JAHAZI_ASILIA",.)

rename (ttlvotes votes) (votes totalvotes)
drop candidatename party
reshape wide votes, i(id) j(politicalparty) string


*Q5




 