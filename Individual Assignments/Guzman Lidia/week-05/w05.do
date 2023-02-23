***Lidia Guzman Assignment 5
clear 

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05"

clear

***INCOMPLETE RESHAPE&TEMPFILE ***Question 1 -------------------------------------

use "${wd}/q1_psle_student_raw.dta", clear

split s, parse (">PS")

gen serial = _n

order serial 
drop s1


reshape long s schoolcode, i(serial) j(school)

drop s
drop s1

tempfile data 
save `data', replace emptyok

cd "$data"

local varlist "$data"
foreach var of varlist * {
  local varlist "`varlist' `var'"
  collapse alldata = `varlist'
}

****I want to put all variables in one long list (where I am stuck because many have the same school, but I think this code is the closest), eliminate duplicates, and substractstrings to get te final variables 

use `data',  clear

save "${wd}/data_q1.dta"

***COMPLETED***Question 2 -----------------------------------------------------
clear
use "${wd}/q2_CIV_Section_0.dta", clear

labelbook b06_departemen
decode b06_departemen, gen (department)
***
***keep department 

***
sort department

save "${wd}/q2_CIV_Section_0.dta", replace

***import 
clear
import excel "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow allstring

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION

gen department = NOMCIRCONSCRIPTION

replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE","",.)
replace department = subinstr(department, "DEPARTEMENT DU","",.)
replace department = strtrim(department) 
replace department = lower(department)
replace department = "arrha" if department=="arrah"
***prepare for density 
rename DENSITEAUKM pop_density_km2
***keep pop_density_km2


**do merge 
merge 1:m department using "${wd}/q2_CIV_Section_0.dta"

browse if unmatched
drop if _merge==1 
**no survey data for greblandan so ok
order department pop_density_km2, last

exit
***COMPLETE***Question 3 --------------------------------------------------
clear

use "${wd}/q3_GPS Data.dta", clear
scatter latitude longitude
rename * one_*
cross using "${wd}/q3_GPS Data.dta"

ssc install geodist
ssc install sepscatter
geodist one_latitude one_longitude latitude longitude, generate (distance_km)
sort distance_km

cluster kmeans distance_km, k(19) [seg]
***HOW TO READ OPTIONS ON CLUSTER. 
***I want to make an equal n of frequencies of the k 19 cluster based on the latitude and longitude . Then split the frequencies in 6.
/*
cluster kmeans latitude longitude, k(19)
sort _clus_1
sepscatter latitude longitude, separate(_clus_1)
*/

/*
tab _clus_1

 Cluster ID |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        418        3.39        3.39
          2 |        902        7.32       10.71
          3 |        452        3.67       14.38
          4 |        452        3.67       18.05
          5 |        772        6.27       24.32
          6 |        780        6.33       30.65
          7 |        510        4.14       34.79
          8 |        562        4.56       39.35
          9 |        568        4.61       43.96
         10 |        382        3.10       47.06
         11 |        840        6.82       53.88
         12 |        680        5.52       59.39
         13 |        620        5.03       64.43
         14 |        776        6.30       70.72
         15 |        688        5.58       76.31
         16 |        812        6.59       82.90
         17 |        916        7.43       90.33
         18 |        746        6.05       96.39
         19 |        445        3.61      100.00
------------+-----------------------------------
      Total |     12,321      100.00
*/

exit


***INCOMPLETE RESHAPE***Question 4 --------------------------------------------
clear
import excel "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-05/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring clear
 
***cap prog drop infill
***prog def infill

 *** syntax anything
 
qui foreach var of varlist* {
  	
	local theValue = ""
	forv i = 1/`c(N)' {
		
		local nextValue = `var'[`i']
		if ("`nextValue'" == "") | ("`nextValue'" == ".") {
			cap replace `var' = "`theValue'" in `i'
			cap replace `var' = `theValue' in `i'
	    }
		else {
			local theValue = "`nextValue'"
		}
    }
}
end


drop if _n == 1
drop ELECTEDCANDIDATE K SEX G
gen r_d_ward = REGION + DISTRICT + WARD
bysort r_d_ward: gen ward_id =_n

******Missing the last step, I DO NOT KNOW HOW TO RESHAPE THIS

reshape long POLITICALPARTY TTLVOTES, i()


***INCOMPLETE***Question 5 -----------------------------------
***DontunderstandQ, why use gib
clear
use "${wd}/q5_Tz_elec_10_clean.dta", clear

keep region_10 district_10 ward_10
duplicates drop
rename (region_10 district_10 ward_10) (region district ward)

sort region district ward
gen dist_id = _n

save "${wd}/q5_10_saved.dta", replace

clear 
use "${wd}/q5_Tz_elec_15_clean.dta", clear

keep region_15 district_15 ward_15
duplicates drop
rename (region_15 district_15 ward_15) (region district ward)

sort region district ward
gen idvar = _n

save "${wd}/q5_15_saved.dta", replace


clear 
use "${wd}/q5_Tz_ArcGIS_intersection.dta", clear
destring percentage, replace
keep percentage if >=95


ssc install reclink
reclink region district ward using "${wd}/q5_10_saved.dta", idmaster(idvar) ///
idusing(dist_id) gen(score) 


exit
codebook




