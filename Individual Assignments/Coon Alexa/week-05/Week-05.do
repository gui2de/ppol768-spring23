clear 
cd "C:/Users/Alexandra/Documents/GitHub/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

*Q1.

clear
tempfile clean_stu
save `clean_stu', emptyok replace

forvalues i=1/138{
use "q1_psle_student_raw.dta" , clear

keep in `i'
clean //call the program created in tz_clean week-05

append using `clean_stu'
save `clean_stu', replace 

}


use `clean_stu'




/*Q2. We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.*/

//import excel extvarlist using filename [, import_excel_options]
//tempfile civ_pop
//import excel using q2_CIV_populationdensity
//replace `civ_pop', emptyok 
//save `civ_pop', clear
import excel q2_CIV_populationdensity, clear //bring in the data set as a 	nonexcel

//where is the CIV_Section_0 dataset?? ASK

drop B
drop C
rename A Department //are all of these departments??? should some of these drop? if so i would use reshape to drop some of them?, drop if =!dep* to drop if not department??
rename D Density_KMSQ 

//trying to drop all of the other items in Department that do not list as dept
keep if strpos(Department,"DEP") //|strpos(jobtitle,"Financial" )
//order Department, alphabetic
//list Department if regexm(Department, "Dep") == 1
//drop if Department==0
//keep if Department=!dep*

//should clean by fixing misspellings and inconsistent spellings if have time

merge 1:m Density_KMSQ using CIV_Section_0.dta //to merge density to CIV_Section_O, haven't run because I can't find the doc???
//merge 1:m varlist using filename [, options]



/*Q3.
We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.*/

use q3_GPS_Data.dta
//19 enumerators and 6 surveys/day
gen enum_number=0
order latitude longitude enum_number id age female
//replace enum_number=(1/19) //tried to make a series of 1-19 but failed

//gsort latitude //confirm that gsort puts all lats and longs together when they are moved
//puts all close latitudes together, but how to ensure longitudes are also close...
/*
to do this I would 
load dataset
set up a tempfile to store the groups in then
set up a loop to 
	first identify the closest 6 households by lat and long// not just one or the other because this could mean you have a slice that is close by latitude but not by longitude and vice versa 
	by cluster
	gen a group_#
	I would move those into the group
	gen numberator_#
	I would assign a numerator to that group 
	I would send the numbers in this group to the tempfile
	I would remove these data points from the data set
	I would end the loop
	I would merge the dataset without the grouped data points //this is so the next loop that runs does not include the points that have already been put in a group
	Allow the loop to run until all data points have been grouped and assigned to a numerator

//need to block together various groups and then remerge them to the list to remove them from the next set of selections, so that each group of 6 is unique and as close as possible 
//make a loop that groups the closest 6
//merge the data found in that loop to the data that is not categorized so that it is not reassigned

