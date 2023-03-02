****** BeverlyAnn Hippolyte ******
****** PPOL 768 : Research & Design Implementation ******
****** Due Date : February 20th, 2023 *******

clear

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data"




***** Question 1 *****

clear // Load dataset
browse // First thing I do, browse the data to get familiar with it 

tempfile newschools

	forvalues i=1/3 {
		use "q1_psle_student_raw.dta", clear
	
		do "wk4q4"
		
		append using `newschools', clear 
		save, replace 
		
		use newschools 
		
	
	}

**** Question 2 ****

We have household survey data and population density data of Côte d'Ivoire. 
Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) 
into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

*tempfile popdens 	/// Generated a tempfile to store the data after I changed 
*save `popdens', replace emptyok
	
	import excel using "q2_CIV_populationdensity.xlsx" 
	
		gen i = _n
	
	** keep if word(DEPARTMENT, 1) I was trying to tell Stata to keep the row if the first word /// is DEPARTMENTE.
	

	*append using `popdens'
	
	*use "popdens"
	
*gen popdens
		
	
*use "popdens"

*This seems like a one to many merge; Should include a column for population density 

***** Question 3 ********

## Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) 
in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. 
Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). 
Note: Your code should still work if I run it on data from another village.

clear 
	
	
* Load dataset 
	use "q3_GPS Data.dta"

	tempfile enum 
	save `enum', replace emptyok

		keep in 1

rename * one_*

	cross using "q3_GPS Data.dta"
	
	geodist one_latitude one_longitude latitude longitude, gen(dist)
	drop if one_numid == numid
	
	sort dist 
	 
	 drop if dist == 0

     keep if dist <= 0.17 
	 
	 append using enum
	 
	 save enum
	 
	drop if numid =  28
	drop if numid == 94
	drop if numid == 95
	drop if numid == 14
	drop if numid == 15
	drop if numid == 1

	use enum, clear
	
	keep in 2
	keep if dist <= 0.22

*save, replace


***** Question 4 *******
## Q4 : 2010 Tanzania Election Data cleaning

/*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. 
You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. 
You can check the following dta file as a template for your output: Tz_elec_template. 
Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*/
*** I'm thinking do i need to set up a tempfile to store the data that i course through after I'm done .

*log using election10

clear 
*Set up a tempfile to store the data within the do file 
tempfile election10
save `election10', replace emptyok


	import excel using "q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring // Importing the xls file 
		replace WARD = WARD[_n-1] if WARD == "" // Given the strucutre of the file, all empty cells were filled up 
		rename (COSTITUENCY)(constituency) // Rename variable constitutency 
		rename (REGION DISTRICT CANDIDATENAME SEX G POLITICALPARTY TTLVOTES ELECTEDCANDIDATE) (region district 			candidatename sex gender politicalparty ttlvotes electedcandidate)
		
		drop K
		
		replace constituency = constituency[_n-1] if constituency == "" 
		replace district = district[_n-1] if district == ""
		
		destring TTLVOTES, ignore ("UNOPPOSED") replace // Unopposed is not relevant to the information we want.
			
			*bysort WARD: egen vote_total = total(TTLVOTES)
			*drop in 1
			
			**** I need to figure out how to drop the duplicate values //
			**** I've tried using the duplicates command but its not working //

			
*use `election10', clear			
			
			
*log close, append

*** Data has alot of missing values; Important variables like WARD has embedded and trailing blanks which I am not sure how to deal with yet 

** The data is at candidate/political level but we want a ward level dataset

***** Question 5 *****


/*
Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It's a trivial task to match wards that weren't divided, but it's impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.  


*/
