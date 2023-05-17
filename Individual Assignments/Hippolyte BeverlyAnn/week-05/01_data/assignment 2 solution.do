****** BeverlyAnn Hippolyte ******
****** PPOL 768 : Research & Design Implementation ******
****** Due Date : February 20th, 2023 *******

global wd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data"

***** Question 1 *****
***********************************************************

tempfile newschools // Create a tempfile 


clear // Load dataset


	use "$wd/q1_psle_student_raw.dta", clear
	
	keep in 138

		do "week4" // Using the previous dofile from assignment 4 
		
	save newschools, replace

	use newschools // Open local file 
		
	drop if cand == "PS"
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6 subjects7) (Kiswahili English Maarifa Hisabiti Science Uraia AverageGrade)
  
		replace prem = subinstr(prem, `"BODY TEXT="#000080" LINK="#0000ff" VLINK="#800080" BGCOLOR= "LIGHTBLUE">"', "",.) // This and the next few lines of code substitute the original variable with nothing and returns nothing

		replace sex = subinstr(sex, `"P ALIGN="LEFT"  > PSLE 2021 EXAMINATION RESULTS"', "",.)
	
		replace name = subinstr(name, `"/"', "",.)
		
		save newschools, replace 
	
************************************************************
************************************************************	

**** Question 2 ****

*We have household survey data and population density data of Côte d'Ivoire. ///
*	Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) 
*	into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.


clear

	use "$wd/q2_CIV_Section_0", clear           	// Load dataset containing household data 
	
	decode b06_departemen, generate(deptment) // Decode variable and generate new variable to store decoded version of the variable 
	
	keep deptment
	sort deptment
	
	tempfile popdens // Open tempfile
	
		save `popdens', replace emptyok // Save the local file 
		
		 use `popdens' // Open local file

		import excel "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data/q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow allstring clear  // import excel file 
		
		tempfile density  // Open tempfile 
	
		save `density', replace emptyok

		use `density'
		
	 gen department = word(NOMCIRCONSCRIPTION, 1) 	// Generate new variable department and store the first word in each row of the variable in the syntax
	 keep if department == "DEPARTEMENT"        	// Keep the row if the first word is DEPARTMENT
	 sort department
		replace department = lower(NOMCIRCONSCRIPTION)
		replace department = subinstr(NOMCIRCONSCRIPTION, "DEPARTEMENT DE", "",.)
		replace department = subinstr(NOMCIRCONSCRIPTION, "DEPARTEMENT D", "",.)
		replace department = subinstr(NOMCIRCONSCRIPTION, "DEPARTMENT DU", "",.)
	 
		drop POPULATION								// Drop POPULATION 
		drop SUPERFICIEKM2							// Drop SUPERFICIEKM2 
		rename DENSITEAUKM density 					// Rename DENSITEAUKM 
		

		exit
		
		merge 1:m NOMCIRCONSCRIPTION using density						// Merge the dataset and save the local file 
		use popdens														// Open the local file 
	
		save `popdens'
*******************************************************

***** Question 3 ********

/*## Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) 
in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. 
Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). 
Note: Your code should still work if I run it on data from another village.
*/

clear 	

	tempfile enum 			  	// Generate tempfile to save local file '
	save `enum', replace emptyok
	
	use "$wd/q3_GPS Data.dta" 		// Load the dataset

	tempfile gpsdata
	save `gpsdata', replace
	
	gen i =_n
	order i
	
forvalues i=1/111{
	
			use `gpsdata',clear
	
			keep in 1
		
			rename * one_*				// Rename the column variables; This will help distinguish the variables when we match, and makes matching easier 
		
			cross using "$wd/q3_GPS Data" // With this dataset we create a matrix using the command cross. 
	
			geodist one_latitude one_longitude latitude longitude, gen(distance) // Calculate the distance between
				// the first point and all points in the dataset.
					
			drop if one_id == id // Drop the first distance because it's matched with itself
			
			gen enumerator_id = one_id
			
			drop if distance == 0 
	
			keep in 1/6 // Keep the first  six shortest distances in the variable dist 
			
			append using "gpsdata"
	 
			save `gpsdata'
	}
*** I was able to do the first five houses and assign them to one enumerator but i can't seem to continue onto the next. //
// I've tried several codes but thye aren't working. I referenced the video from class. I did one and it worked so i thought it would work for the others.
*** I would also like to note that I referenced other student's code to improve on mine but this is the best I could do  


***** Question 4 *******
## Q4 : 2010 Tanzania Election Data cleaning

/*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. 
You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. 
You can check the following dta file as a template for your output: Tz_elec_template. 
Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*/

clear 
tempfile election10

	import excel using "q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring // Importing the xls file 
		replace WARD = WARD[_n-1] if WARD == "" // Fill in the name of each ward in the empty cells 
		rename (COSTITUENCY)(constituency) // Rename variable constituency 
		rename (REGION DISTRICT CANDIDATENAME SEX G POLITICALPARTY TTLVOTES ELECTEDCANDIDATE) (region district candidatename sex gender politicalparty ttlvotes electedcandidate) 
					// Rename variables 
		
		drop K // Drop the variable K
		
		drop sex gender electedcandidate candidatename // Drop variables 
		
		gen i = _n // generating i variable
		
		replace constituency = constituency[_n-1] if constituency == "" // Fill in the name of each constituency in the empty cells
		replace district = district[_n-1] if district == "" // Fill in  the name of each district in the empty cells
		replace region  = region[_n-1] if region == "" // Fill in  the name of each district in the empty cells
		destring TTLVOTES, ignore ("UNOPPOSED") replace // Change the TTLVOTES variable from string to numeric
			
			rename WARD ward  // Change the name of the WAARD variable 
			
			order i ward politicalparty ttlvotes  // Changed the order of the variables in the dataset 
			
			reshape wide ward, i(i) j(politicalparty), string // Trying to reshape 
			*bysort WARD: egen vote_total = total(TTLVOTES)
			*drop in 1
	
	
		 // Save local file 

***** Question 5 *****


/*
Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.  


*/
	
	