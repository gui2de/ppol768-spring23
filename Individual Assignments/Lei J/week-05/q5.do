clear
cd "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
use q5_Tz_ArcGIS_intersection, clear
rename (region_gis_2017 district_gis_2017 ward_gis_2017 region_gis_2012 district_gis_2012 ward_gis_2012) (region_15 district_15 ward_15 region_10 district_10 ward_10)
gen id1=_n
save gis, replace 
*rename and giving id for reclink later 
use q5_Tz_elec_15_clean.dta, clear
gen id2=_n
reclink region_15 district_15 ward_15 using "gis.dta", idmaster(id2) idusing(id1) gen(matchscore) wmatch(5 10 15)
*reclink 
gen id3=_n 
*give an id for find dups and drop.
duplicates list region_15 district_15 ward_15 total_candidates_15 ward_total_votes_15
list if id3==480 | id3==512 
list if id3==1765 | id3==1930 
list if id3==1747 | id3==1913 
list if id3==1766 | id3==1931 
list if id3==1770 | id3==1905 
list if id3==1748 | id3==1912 
drop if id3==480 
duplicates drop region_15 district_15 ward_15 total_candidates_15 ward_total_votes_15, force
*go through the dup values one by one and decide which ones to drop. 
keep region_15 district_15 ward_15 total_candidates_15 ward_total_votes_15 region_10 district_10 ward_10
gen id1=_n
save vote2015.dta, replace
*tidying up and save
use q5_Tz_elec_10_clean.dta, clear
gen id2=_n
save vote2010.dta, replace

use vote2015.dta,clear
reclink region_10 district_10 ward_10 using "vote2010.dta", idmaster(id1) idusing(id2) gen(matchscore) wmatch(5 10 15)
gen id3=_n 
*pretty move doing the reclink and generate an id for drop dups again 
duplicates list region_15 district_15 ward_15 total_candidates_15 ward_total_votes_15
list if id3==359 | id3==362 
drop if id3==359
keep region_15 district_15 ward_15 total_candidates_15 ward_total_votes_15 region_10 district_10 ward_10 total_candidates_10 ward_total_votes_10
