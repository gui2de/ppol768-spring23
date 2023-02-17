*C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-05

*_________________________________

*Q1 : Tanzania Student Data
*This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

clear 
tempfile student_clean 
save `student_clean', replace emptyok


forvalues i=1/10 {
	
	use "q1_student", clear 	
	keep in `i'  ///  Compresses the data 
	
	do "$wk4_q4_cleaning"
	
	append using `student_clean'
	save `student_clean', replace 
	
	
}

use student_clean 

*_________________________________
*Q2 : Côte d'Ivoire Population Density
*We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

*_________________________________
*Q3 : Enumerator Assignment based on GPS
*We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

use "q3_GPS Data"
scatter latitude longitude

*_________________________________
*Q4 : 2010 Tanzania Election Data cleaning
*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.


*_________________________________
*Q5 : Tanzania Election data Merging
*Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.


reclink2 region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score)
