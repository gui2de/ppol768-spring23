*C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05

*Last Updated: Feb. 20th, 2023

cd "C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05" 

*_________________________________

*Q1 : Tanzania Student Data
*This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

clear 
*Setting up empty tempfile 
tempfile student_clean 
save `student_clean', replace emptyok

*CHANGE THIS TO 138 EVENTUALLY 
forvalues i=1/138 {
	
	use "q1_psle_student_raw", clear 	
	keep in `i'  ///  Compresses the data 
	
	do "web_scraping_code"
	
	*Add the scraped rows to the tempfile student_clean
	append using `student_clean'
	*Saving so we don't lose any data 
	save `student_clean', replace 
	
}

use `student_clean', clear 
save OUTPUT_Q1, replace



*_________________________________
*Q3 : Enumerator Assignment based on GPS
*We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

clear 
*Visualize the data
use "q3_GPS Data"
scatter latitude longitude
graph export "OUTPUT_Q3_surveyors_scatter.png", replace
graph drop _all 
clear

*Use geodist to calculate shortest distance on spherical surface 
*geodist lat1 lon1 lat2 lon2, generate() 

*High-level / Pseudo-code for this: 
*For Cluster [1:19] 
*	For obs [2:N] 
*		Pick the min(long) point 
*		Calc distance(obs) 
*		Identify the 5/6 observations that have min(dist)
*		Add them into a new dataset (e.g. temp file) [tempfile] 
*		Remove the 6/7 data from the original dataset  
*		Repeat

use "q3_GPS Data", clear 
save "q3_GPS_copy", replace

*Determine if last enumerator will need to have <6 assignments (because total # of locations is not exactly divisible by 6).
global j = mod(_N,6)
global k = ceil(_N/6)

clear 
tempfile clustering
save `clustering', replace emptyok 

*tempfile newGPS 
*save `newGPS', replace emptyok
*use "q3_GPS Data", clear 
*append using `newGPS' 
*save `newGPS', replace emptyok

forvalues i=1/$k {
	*Load dataset 
	use "q3_GPS_copy", clear 
	*use `newGPS', clear
	
	*Pick the min(long) point; and calc. distances 
	sort longitude
	
	egen lon0 = min(longitude) 
	
	gen rowID = _n
    gen lat0 = latitude if rowID == 1 
	carryforward lat0, replace
	order rowID, first
	
	geodist lat0 lon0 latitude longitude, gen(dist)
	sort dist
	gen distID = _n 
	
	*	geodist lat1 lon1 lat2 lon2, generate() 
	*local j=1 
	*foreach var of varlist * {
	*	rename `var' column_`i'
	*}
	
	*Choose 5 shortest distances and add these to new datasets by ID, and cluster to which they're assigned
		preserve 
		
		if `i'<$k | $j==0 {
			*All iterations except the last 
			keep if distID <= 6
		
			*generate clusterID = `i' 
			generate clusterID = `i'
			order clusterID, first
		
			*Add the 6 selections of the cluster to the tempfile
			append using `clustering'
			*Saving so we don't lose any data 
			save `clustering', replace 
			}
		
		else if `i'==$k {
			*The last iteration, for cases where last enumerator has  	
			*fewer assignments 
			
			keep if distID <= $j
		
			*generate clusterID = `i' 
			generate clusterID = `i'
			order clusterID, first
		
			*Add the 6 selections of the cluster to the tempfile
			append using `clustering'
			*Saving so we don't lose any data 
			save `clustering', replace 
			}
			
			
		restore
	
	*Remove these 6 points from original dataset 
	if `i'<$k { 
		drop if distID <= 6 
	}
	else if `i'==$k {
		drop if distID <= $j
	}
	
	drop rowID lon0 lat0 dist distID 
	
	save "q3_GPS_copy", replace
} 


*Load cluster_groups again
use `clustering', clear 
sepscatter latitude longitude, separate(clusterID) legend(pos(3) col(1))
*graph save cluster_scatter_plot.png, replace
graph export "OUTPUT_Q3_surveyors_cluster_scatter.png", replace



*_________________________________
*Q4 : 2010 Tanzania Election Data cleaning
*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

**Question 4
**2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

import excel "q4_Tz_election_2010_raw", clear

drop in 1/4

rename A region
rename B district
rename C constituency
rename D ward
rename E candidate_name
rename F M
rename G F
rename H political_party
rename I ttl_votes
rename J elected_candidates

drop K elected_candidates

drop in 1/2

gen serial = _n

order serial region

replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace constituency = constituency[_n-1] if constituency == ""
replace ward = ward[_n-1] if ward == ""

codebook ward
**gives number of wards = 3113

**if you try to reshape it, not every ward has the same parties, which means that they will not align and we need to use the fillin command.  
**if we see the number of wards, we only see 3113 number of wards whereas this should be 3333 - some ward names are common and are being reused

gen unique_ward = region + "_" + district + "_" + ward

codebook unique_ward
**This code gives correct number of wards = 3333 (for 2010) 

**initially my data showed party or candidate at ward level ______
fillin unique_ward political_party
*fillin unique_ward political_party
**not sure what this is doing

sort unique_ward _fillin
*Sort so parties that actually got votes are at top for each ward 

replace region = region[_n-1] if region == ""
replace district = district[_n-1] if district == ""
replace constituency = constituency[_n-1] if constituency == ""
replace ward = ward[_n-1] if ward == ""

keep unique_ward political_party ttl_votes

sort unique_ward political_party
*Same party order for each unique ward 

bysort unique_ward: gen j=_n

tab j political_party

**ALSO CHECK FOR CANDIDATES IN THE SAME PARTY 20577 20578
*bysort egen total 

*drop duplicates soy you can create a dummy variable = 0 and 1 values, drop one of th duplicates after you have summed them up


reshape wide political_party ttl_votes, i(unique_ward) j(j) 
*save Tz_2010_LegWardData_Wide, replace


**duplicates tag ward, gen(d) [not sure what this does]
*tab d

**bysort
**egen
**reshape 

**we want to reshape party before which we create a j-variable 
*reshape wide political_party, i(ward), j(serial)

*bysort

split unique_ward, parse("_") 
drop unique_ward political_party19 ttl_votes19 political_party20 ttl_votes20
order unique_ward1 unique_ward2 unique_ward3, first

rename unique_ward1 region
rename unique_ward2 district
rename unique_ward3 ward
compress

*Replace missing values (i.e. unopposed elections) with 0 vote values, and substitute an (arbitrary) vote total of 1,000,000 to signify that a specific party won unopposed 
forvalues m=1/18 {
	replace ttl_votes`m' = subinstr(ttl_votes`m', "UN OPPOSSED","1000000", . ) 
	destring ttl_votes`m', replace
	replace ttl_votes`m'=0 if missing(ttl_votes`m')
	drop political_party`m'
}

*Condense party/vote info into 1 column  
rename ttl_votes1 AFP 
rename ttl_votes2 MAENDELEO
rename ttl_votes3 CCM
rename ttl_votes4 CHADEMA
rename ttl_votes5 CHAUSTA 
rename ttl_votes6 CUF
rename ttl_votes7 DP 
rename ttl_votes8 JAHAZI_ASILIA 
rename ttl_votes9 MAKIN
rename ttl_votes10 NCCR_MAGEUZI
rename ttl_votes11 NLD
rename ttl_votes12 NAR 
rename ttl_votes13 SAU 
rename ttl_votes14 TADEA 
rename ttl_votes15 TLP
rename ttl_votes16 UDP 
rename ttl_votes17 UMD 
rename ttl_votes18 UPDP 

save OUTPUT_Q4_2010_Leg_Ward_Election_Data_Wide_Cleaned, replace



*_________________________________
*Q2 : Côte d'Ivoire Population Density
*We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

*Stra Region Departement SousPref(?) Commune Zone de nombrement Village Neighborhood

*APPROACH: WANT TO MERGE THE DEPARTMENT-LEVEL DENSITY DATA FROM IMPORTED EXCEL SHEET ONTO HOUSEHOLD LEVEL DATA
*i.e. merge using imported sheet, 1:Many merge 

clear
import excel q2_CIV_populationdensity, sheet("Population density")
drop in 1

*don't need superficie km^2 (area) nor population 
drop B C

keep if strpos(A,"DEPARTEMENT") 
*Should be 107 departements
split A, parse(" ")

drop A A1 A2
order A3, first

rename A3 department
rename D Population_Density

*Convert upper to lower-case, prior to merge 
ds, has(type string) 
foreach v in `r(varlist)' { 
    replace `v' = lower(`v') 
} 

save departemen_popDens, replace

*MERGE
use q2_CIV_Section_0, clear
decode b06_departemen, generate(department)
merge m:1 department using "departemen_popDens.dta"



*_________________________________
*Q5 : Tanzania Election data Merging
*Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.


*Use reclink2 !!!  

*global wd "C:/Users ... "

*global q5_intersection $wd "" 
*global q5_elec_10 $wd "" 
*global q5_elect_15 $wd "" 

*reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score)
