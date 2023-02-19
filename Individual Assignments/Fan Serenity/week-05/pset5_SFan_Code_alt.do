*C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05

cd "C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05" 

*_________________________________

*Q1 : Tanzania Student Data
*This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

clear 
*Setting up empty tempfile 
tempfile student_clean 
save `student_clean', replace emptyok

forvalues i=1/1 {
	
	use "q1_psle_student_raw", clear 	
	keep in `i'  ///  Compresses the data 
	
	do "web_scraping_code"
	
	*Add the scraped rows to the tempfile student_clean
	append using `student_clean'
	*Saving so we don't lose any data 
	save `student_clean', replace 
	
}

use `student_clean', clear 



*_________________________________
*Q2 : Côte d'Ivoire Population Density
*We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

clear 





*_________________________________
*Q3 : Enumerator Assignment based on GPS
*We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

*Visualize the data
use "q3_GPS Data"
scatter latitude longitude
graph export "surveyors_scatter.png", replace
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
graph export "surveyors_cluster_scatter.png", replace

*_________________________________
*Q4 : 2010 Tanzania Election Data cleaning
*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.


*_________________________________
*Q5 : Tanzania Election data Merging
*Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.

*Use reclink2 !!!  

*global wd "C:/Users ... "

*global q5_intersection $wd "" 
*global q5_elec_10 $wd "" 
*global q5_elect_15 $wd "" 



*reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score)
