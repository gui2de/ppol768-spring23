/*week 5 RDI homework*/

/*setup*/

global wd "C:/Users/Maeve/GitHub/ppol768-spring23/Individual Assignments/Grady Maeve/week-05/01_data"

global q2_CIV_Section_0 "$wd/q2_CIV_Section_0.dta"
global q2_CIV_populationdensity "$wd/q2_CIV_populationdensity.xlsx"
global q3_gpsdata "$wd/q3_GPS_Data.dta"
global q4_Tz_election_2010_raw "$wd/Tz_election_2010_raw.xlsx"
global q4_Tz_election_template "$wd/q4_Tz_election_template.dta"
global q5_Tz_ArcGIS_intersection "$wd/q5_Tz_ArcGIS_intersection"
global q5_Tz_elec_10_clean "$wd/q5_Tz_elec_10_clean"
global q5_Tz_elec_15_clean "$wd/q5_Tz_elec_15_clean"

/*Class exercise*/
use "$store_location", clear

keep in 1
rename * one_*

cross using "$store_location"
	geodist one_gpsLatitude one_gpsLongitude gpsLatitude gpsLongitude, generate(distance_km)
	
	sort distance_km
	
	drop if one_unique_id == unique_id
	
	gen nb_store_500m = 0
	replace nb_store_500m = 1 if distance_km <= 0.5
	bysort one_unique_id: egen total_nb = total(nb_store_500m)
	
	duplicates drop one_unique_id , force
	
	
keep one_unique_id total_nb

/*problem 1*/
use "q1_psle_student_raw.dta", clear

replace s = substr(s, strpos(s, "SUBJECTS"), . )
split s, parse("</TD></TR>")

drop s1


gen i = _n
drop s
reshape long s, i(i) j(j)

drop if s == ""

gen non_obs =  strpos(s, "</BODY>") > 0

drop if non_obs == 1
drop non_obs

split s, parse("</FONT></TD>")

/*getting rid of the html formatting one var at a time*/

	/*cand_no*/
	split s1 , p("CENTER")
	drop s11
	split s12 , p(>)
	drop s1
	drop s12
	drop s121
	rename s122 cand_no

	/*prem_no*/
	split s2 , p("CENTER")
	drop s21
	split s22 , p(>)
	drop s2
	drop s22
	drop s221
	rename s222 prem_no
	
	/*Sex*/
	split s3 , p("CENTER")
	drop s31
	split s32 , p(>)
	drop s3
	drop s32
	drop s321
	rename s322 sex
	
	/*name*/
	split s4 , p("<P>")
	drop s41
	rename s42 cand_name
	drop s4

	/*grades*/
	split s5 , p("LEFT")
	drop s51
	split s52 , p(>)
	drop s5
	drop s52
	drop s521
	split s522 , p("<")
	rename s5221 grades
	drop s5222
	drop s522

/*parsing grades into columns by subject, renaming columns and making contents just the grad as opposed to subject and grade*/

	split grades , p(,)
	
	split grades1 , p(-)
	rename grades12 Kiswahili
	drop grades1
	drop grades11
	
	split grades2 , p(-)
	rename grades22 English
	drop grades2
	drop grades21
	

	split grades3 , p(-)
	rename grades32 Maarifa
	drop grades3
	drop grades31
	
	split grades4 , p(-)
	rename grades42 Hisbati
	drop grades4
	drop grades41
	
	split grades5 , p(-)
	rename grades52 Science
	drop grades5
	drop grades51
	
	split grades6 , p(-)
	rename grades62 Uraia
	drop grades6
	drop grades61
	
	split grades7 , p(-)
	rename grades72 Average_Grade
	drop grades7
	drop grades71
	
	drop grades
	drop i
	drop j
	drop s
	/*i'm sure there was a more elegant way to do this, but this does work!*/

	br

/*question 2*/

use "$q2_CIV_Section_0", clear	
br
	
import excel "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow clear

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
sort NOMCIRCONSCRIPTION
split NOMCIRCONSCRIPTION , p("D'" " ")
rename NOMCIRCONSCRIPTION3 departement
replace departement = NOMCIRCONSCRIPTION4 if departement == ""
drop NOMCIRCONSCRIPTION NOMCIRCONSCRIPTION1  NOMCIRCONSCRIPTION2 NOMCIRCONSCRIPTION4
gen lower_dept = strlower(departement)
replace lower_dept = "arrha" if departement == "ARRAH" // correcting misspelling in this dataset

preserve
	use "$q2_CIV_Section_0",clear
	decode b06_departemen, gen(lower_dept)
	
	tempfile q2_CIV_Section_0_names
	save `q2_CIV_Section_0_names'
restore
	
merge 1:m lower_dept using `q2_CIV_Section_0_names'  
sort _merge // we can see that only one departement did not merge with values from hh dataset 

	
/*problem 3*/ 
/*need to make groups of 6 by nearest neighbors*/


use "$q3_gpsdata", clear

/*finding the distance between all households*/
geonear id latitude longitude using "$q3_gpsdata", neighbors(id latitude longitude) nearcount(111)

reshape long nid km_to_nid, i(id) j(j)

**drop if id == nid
sort id km_to_nid

/*making groups of 6 hh and saving */

gen enumerator_ID = 0


/*foreach v in id {
	preserve
	sort id km_to_nid
	gen i = _n
	drop if i > 6
	tempfile q3_enumeratorgroups
	save "$q3_enumeratorgroups"
	local drop_is nid[i]
	restore
	sort id km_to_nid
	drop if id inlist(`drop_is')
}
*/



	gen nid_a = .
	gen nid_b = .
	gen nid_c = .
	gen nid_d = .
	gen nid_e = .
	gen nid_f = .

	
	
foreach v in id {
	sort id km_to_nid
	replace nid_a = nid[1]
	replace nid_b = nid[2]
	replace nid_c = nid[3]
	replace nid_d = nid[4]
	replace nid_e = nid[5]
	replace nid_f = nid[6]
	preserve
	gen i = _n
	drop if i > 6
	tempfile q3_enumeratorgroups_nid[1]
	save `q3_enumeratorgroups_nid[1]'
	restore
	drop if id == nid_a | id == nid_b | id == nid_c |id == nid_d | id == nid_e | id == nid_f
	}

	//im getting close on this but the loop isn't actually looping, it's only going once at a time and I dont know how to view my local and make sure that things append properly. I've tried a lot of different solutions here but stillno luck. Will have to come back to this another day
	
	
display "`q3_enumeratorgroups'"
use "$q3_enumeratorgroups", clear

/*problem 4*/

import excel "$wd/q4_Tz_election_2010_raw", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring  clear

gen i = _n
drop  if i == 1
drop i

/*filling out empty cells prior to reshaping*/
replace REGION = REGION[_n-1] if REGION == ""
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == ""
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == ""
replace WARD = WARD[_n-1] if WARD == ""
replace SEX = "F" if G == "F"
replace ELECTEDCANDIDATE = "NOT ELECTED" if ELECTEDCANDIDATE == ""

replace POLITICALPARTY = subinstr(POLITICALPARTY, " ", "", .)
replace POLITICALPARTY = subinstr(POLITICALPARTY, "-", "_", .)

/*creating a new geography var that is unique by even if different regions/districts contain wards with the same names*/
gen geography = REGION + "," + DISTRICT + "," + COSTITUENCY+ "," + WARD 

bysort geography: gen cand_no = [_n]

/*creating a candidate count var by ward */
bysort geography: egen cand_max = max(cand_no)

/*creating a ward total var*/
replace TTLVOTES = "999999" if TTLVOTES == "UN OPPOSSED"
destring TTLVOTES, replace
bysort geography: egen ward_ttl = total(TTLVOTES)

drop K ELECTEDCANDIDATE SEX G CANDIDATENAME 

/*since there are some wards in which multiple candidaes ran from a single party we have to combine those observations (by geography AND party) before reshaping*/

duplicates tag geography POLITICALPARTY, gen(duplicates)
tab duplicates // there are four duplicates

/*now i need to find a way to sum the total votes by party for ward that has multiple candidates per party*/

bysort POLITICALPARTY: egen votes = total(TTLVOTES) if duplicates == 1 

replace votes = TTLVOTES if duplicates == 0

drop TTLVOTES cand_no

duplicates drop //getting rid of repeat party since i have now summarized on party 
drop duplicates // getting rid of "duplicate" tag field 


/*reshaping from long to wide*/
reshape wide votes, i(geography) j(POLITICALPARTY) string 

drop geography

use "$q4_Tz_election_template", clear

/*question 5 */ 


	/*first find perfect matches btwn 15 and 10 and save out */
		use "$wd/q5_Tz_elec_10_clean" , clear
		keep region_10 district_10 ward_10
		duplicates drop
		rename (region_10 district_10 ward_10) (region district ward)
		sort region district ward
		gen idvar10 = _n
			
		tempfile clean_10
		save `clean_10'
		
		use "$wd/q5_Tz_elec_15_clean" , clear 
		keep region_15 district_15 ward_15
		duplicates drop
		rename (region_15 district_15 ward_15) (region district ward)
		sort region district ward
		gen idvar15 = _n
				
		
		reclink2 region district ward using `clean_10', idmaster(idvar15) idusing(idvar10) gen(score)
		
		/*saving full merge for later use*/
		tempfile merge_first_10_15
		save "$wd/merge_first_10_15", replace
		
		/*saving only those that had a perfect match*/
		keep if score == 1
		tempfile merge_perfect_10_15
		save "$wd/merge_perfect_10_15", replace
	
	
	/*next fuzzy match the non-perfect matches to the arcgis dataset*/
	
		use "$wd/q5_Tz_ArcGIS_intersection", clear
		keep region_gis_2017 district_gis_2017 ward_gis_2017
		duplicates drop
		rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
		sort region district ward
		gen dist_id = _n

		tempfile gis_15
		save `gis_15'

		
		use "$wd/merge_first_10_15" , clear 
		keep if score != 1
		keep region district ward idvar15
		duplicates drop
		sort region district ward


		/*reclink2 region district ward using `gis_15', idmaster(idvar15) idusing(dist_id) gen(score) ///58 are unmatched on first try*/ 
		
		/*reclink2 region district ward using `gis_15', idmaster(idvar15) idusing(dist_id) gen(score) wmatch(2 3 15) //// 27 are unmatched here */ 
		
		/*reclink2 region district ward using `gis_15', idmaster(idvar15) idusing(dist_id) gen(score) wmatch(1 4 19) npairs(1)/// 21 are unmatched here  */
		
		/*reclink2 region district ward using `gis_15', idmaster(idvar15) idusing(dist_id) gen(score) wmatch(1 1 20) ///12 are unmatched here */
		
		reclink2 region district ward using `gis_15', idmaster(idvar15) idusing(dist_id) gen(score) wmatch(3 5 20) npairs(1)
		
		
		/* nothing i do seems to create better matches for about 70 observations. they're either unpaired or have bad matches that don't make sense when you look at them so i'm going to roll with the matches i hav here */
		
		keep if score >= 0.7199 & _merge == 3
		rename (region district ward Uregion Udistrict Uward) (region_15 district_15 ward_15 region_10 district_10 ward_10)
		keep region_15 district_15 ward_15 region_10 district_10 ward_10
		
		tempfile merge_fuzzy_10_15
		save "$wd/merge_fuzzy_10_15"
		
		/*check to make sure gis 12 matches with clean 10*/
		use "$wd/q5_Tz_ArcGIS_intersection", clear
		keep region_gis_2012 district_gis_2012 ward_gis_2012
		duplicates drop
		rename (region_gis_2012 district_gis_2012 ward_gis_2012) (region district ward)
		sort region district ward
		gen dist_id = _n

		tempfile gis_10
		save `gis_10'
		
		use "$wd/q5_Tz_elec_10_clean" , clear
		keep region_10 district_10 ward_10
		duplicates drop
		rename (region_10 district_10 ward_10) (region district ward)
		sort region district ward
		gen idvar10 = _n
		
		reclink2 region district ward using `gis_10', idmaster(idvar10) idusing(dist_id) gen(score) 
		
		/*these don't seem to match up very well at all (0 perfect matches) so i'm not sure where to go from here. if the 2010 and 2012 don't match up well, then having the 2017:15 match isn't that helpful . I'm really not too sure where to go from here */
		
 


	



