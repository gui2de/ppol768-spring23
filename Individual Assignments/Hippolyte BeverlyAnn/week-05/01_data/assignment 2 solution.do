****** BeverlyAnn Hippolyte ******
****** PPOL 768 : Research & Design Implementation ******
****** Due Date : February 20th, 2023 *******

clear

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data"

***** Question 1 *****

clear // Load dataset

tempfile newschools // Create a tempfile 
save `newschools', replace emptyok // Save local file 

	use "q1_psle_student_raw.dta", clear
	
		forvalues i=1/3 {
	
		do "wk4q4" // Using the previous dofile from assignment 4 
		
		save `newschools' // save local file 
		
		use newschools // Open local file 
		
	
	}

**** Question 2 ****

*We have household survey data and population density data of Côte d'Ivoire. ///
*	Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) 
*	into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.


	use "q2_CIV_Section_0.dta", clear           	// Load dataset containing household data 
		decode b06_departemen , generate (dept)		// Decode variable and generate new variable to store decoded version of the variable 
		
	tempfile popdens // Generate local file and name it popdens
		save `popdens',replace // Save the local file 
	
** Load excel file 
import excel "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data/q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow allstring clear 

	 gen department = word(NOMCIRCONSCRIPTION, 1) 	// Generate new variable department and store the first word in each row of the variable in the syntax
	 keep if department == "DEPARTEMENT"         	// Keep the row if the first word is DEPARTMENT
	 
		drop POPULATION								// Drop POPULATION variable 
		drop SUPERFICIEKM2							// Drop SUPERFICIEKM2 variable 
		rename DENSITEAUKM density 					// Rename DENSITEAUKM variable 
	 
		merge 1:m dept using `popdens'					// Merge the dataset and save the local file 
		save `popdens', replace								// Save the local file 
 

***** Question 3 ********

/*## Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) 
in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. 
Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). 
Note: Your code should still work if I run it on data from another village.
*/

clear 

	tempfile enum 			  	// Generate tempfile to save local file 
	save `enum', replace emptyok // Save the local file  
	
	use "q3_GPS Data.dta" 		// Load the dataset

	keep in 1					//  Keep the first row  

	rename * one_*				// Rename the column variables; This will help distinguish the variables when we match, and makes matching easier 

	cross using "q3_GPS Data.dta" // With this dataset we create a matrix using the command cross. 
	
	geodist one_latitude one_longitude latitude longitude, gen(dist) // Calculate the distance between the first point and all points in the dataset.
	drop if one_numid == numid // Drop the first distance because it's matched with itself
	
	sort dist // Sort the data in descending order 

     keep dist 1/5 // Keep the first five shortest distances in the variable dist 
	 
	 save `enum' // Save to the the local file
	 
	 // Drop the five points from the orginal dataset 
	 
	save, replace	 // Save over the original dataset
	 
	 // Repeat for each enumerator
	 


***** Question 4 *******
## Q4 : 2010 Tanzania Election Data cleaning

/*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. 
You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. 
You can check the following dta file as a template for your output: Tz_elec_template. 
Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*/

clear 
*Set up a tempfile to store the data 
tempfile election10
save `election10', replace emptyok


	import excel using "q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring // Importing the xls file 
		replace WARD = WARD[_n-1] if WARD == "" // Fill in the name of each ward in the empty cells 
		rename (COSTITUENCY)(constituency) // Rename variable constituency 
		rename (REGION DISTRICT CANDIDATENAME SEX G POLITICALPARTY TTLVOTES ELECTEDCANDIDATE) (region district candidatename sex gender politicalparty ttlvotes electedcandidate) 
					// Rename variables 
		
		drop K // Drop the variable K
		
		replace constituency = constituency[_n-1] if constituency == "" // Fill in the name of each constituency in the empty cells
		replace district = district[_n-1] if district == "" // Fill in  the name of each district in the empty cells
		
		destring TTLVOTES, ignore ("UNOPPOSED") replace // Change the TTLVOTES variable from string to numeric
			
			*bysort WARD: egen vote_total = total(TTLVOTES)
			*drop in 1
	
	
		 // Save local file 

***** Question 5 *****


/*
Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.  


*/
clear 

	tempfile tanz1015  // Create a local file 
		save `tanz1015', replace emptyok
 
	use "q5_Tz_elec_10_clean.dta" // Load 2010 dataset
 
	use "q5_Tz_elec_15_clean.dta" // Load 2015 dataset 
 
	
	
	