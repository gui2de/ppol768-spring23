****** BeverlyAnn Hippolyte ******
****** PPOL 768 : Research & Design Implementation ******
****** Due Date : February 20th, 2023 *******

clear

cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-05/01_data"

use q1_psle_student_raw.dta, clear


***** Question 1 *****

/*
use q4_Tz_student_roster_html.dta , clear 

browse // First thing I do, browse the data to get familiar with it 

	split s, parse(">PS") // Split the string using ">PS" as the indicator of where we would like to begin the split.

	gen serial = _n       // this helps us generate a unique identifier when we reshape the data 
		drop s
	
	reshape long ///
		s , i(serial) j(student)

	split s , parse ("<")		// Split the string again using the indicator "<"
		keep s1 s6 s11 s16 s21 // Keep the columns that are relevant to the table
		drop in 1              // 
	
	rename (s1 s6 s11 s16 s21) (cand prem sex name subjects) // renamed each column
	
	compress 					// shortened the length of some of the string by reducing the number of characters; specficially prem and sex
	
	replace cand = "PS" + cand // cand is numeric so adding PS helps display the unique candidate number for each student 
	replace prem = subinstr(prem, `"P ALIGN="CENTER">"', "",.) // This and the next few lines of code substitute the original variable with nothing and returns nothing
	replace sex = subinstr(sex, `"P ALIGN="CENTER">"', "",.)   // This helps clean the data in the table and removing unnecessary characters in the columns and rows 
	replace name = subinstr(name, `"P>"', "",.)
	replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"', "",.)

	split subject , parse(",") // we split the variable "subject" into each individual subject; 
							//	the comma is the character used to identify where to in the string we should split
	
	foreach var in varlist subject* {  // for each variable in the list of subjects 
		replace `'"var " = substr(`'var', -1, .)
	}
	
	compress
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6) (Kiswahili English Maarifa Hisabiti Uraia AverageGrade)
	rename (Uraia AverageGrade subjects7) (Science Uraia AverageGrade)
	
*/

/*
**** Question 2 ****

We have household survey data and population density data of Côte d'Ivoire. 
Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) 
into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.


*/




/* 

***** Question 3 ********

## Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. 
You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) 
in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. 
Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). 
Note: Your code should still work if I run it on data from another village.

*/


***** Question 4 *******
## Q4 : 2010 Tanzania Election Data cleaning

/*2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. 
You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. 
You can check the following dta file as a template for your output: Tz_elec_template. 
Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.

*/
	import excel using "q4_Tz_election_2010_raw.xls", firstrow allstring // Importing the xls file 

*** So far the data imported appears to have many misaligned and misplaced data 
	