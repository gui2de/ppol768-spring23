********************************************************************************
* PPOL 768: Week 4
* Exploring and manipulating data in Stata
* Ali Hamza
* Feb 9th, 2023
********************************************************************************

/*
Topics:


1 Introduction to STATA: directories, import/export datasets in different 
  formats, basic commands to explore datasets, annotation, data cleaning, labels

2 Basic Data Manipulation: generating new variables, if/if else statements, 
  and/or conditions, preserve/restore 
  
3 Missing values, locals, globals, egen, duplicates/isid, loops, string 
functions, and describing data with tab, table
  */
  
set more off
clear


********************************************************************************
*Globals: Working directory + Datasets
********************************************************************************


*Define a global for the working directory
global wd "C:/Users/ah1152/Documents/PPOL_768/Week_4/02_data"
*NOTE: Change ^^^THIS^^^

*Datasets
global insurance "$wd/car_insurance"
global project_e "$wd/project_e"
global project_educ "$wd/project_educ.dta"
global baseline "$wd/project_educ_baseline.dta"
global endline "$wd/project_educ_endline.dta"
global project_u "$wd/project_u.dta"
global project_treg "$wd/project_treg.dta" 

	
********************************************************************************
*Loops: Recap + Examples
********************************************************************************


*Example 3 (calculating duration for each insurance plan
use "$insurance", clear
gen	policy_duration1 = expirydate1 - startdate1
gen	policy_duration2 = expirydate2 - startdate2
gen	policy_duration3 = expirydate3 - startdate3
gen	policy_duration4 = expirydate4 - startdate4
gen	policy_duration5 = expirydate5 - startdate5

/*
	"RULE OF THREE" (code duplication)
"You are allowed to copy and paste the code once, but that when the same code is 
replicated three times, it should be extracted into a new procedure.

Duplication in programming is almost always in indication of poorly designed 
code or poor coding habits. Duplication is a bad practice because it makes code 
harder to maintain." 
*/

*We can use forvalues loop to generate these 5 variables
use "$insurance", clear
*How to create policy_duration1-5 through a loop?




* Additional Example
gen	policy_gap1 = startdate2 - expirydate1 
gen	policy_gap2 = startdate3 - expirydate2 
gen	policy_gap3 = startdate4 - expirydate3 
gen	policy_gap4 = startdate5 - expirydate4 

**How to create policy_gap1-4 through a loop?


********************************************************************************
*Locals: Recap + Advanced Functions
********************************************************************************


*1. Using locals for all the files in a particular folder
local list : dir "$wd" files "*"

display as error `list'
*You can then loop through it
foreach file in `list' {

display as error "`file'"
	}

*2. Using list options in locals

local names Ali Hamza Beatrice Leydier Benjamin Daniels Ali Hamza

*unique Option
local unique_names: list uniq names

display "`unique_names'"


*Duplicate Option
local duplicate_names: list dups names

display "`duplicate_names'"

*Word option

forvalues i=1/8 {
	local single_name: word `i' of `names'
	display as error "`single_name'"
}


/*
c-class values:
they are designed to provide one all-encompassing way to access system parameters
and settings, including system directories, system limits etc
*/

*Example
creturn list

*Objective: You should be able to run my do file without changing a single line 
*			of code

*Solution: You can do this using c(username) & if/else statements:

*example: 
*Ali Hamza 1 (Windows)
if c(username)=="ah1152" {
	global wd "C:/Users/ah1152/Documents/PPOL_768/Week_4/02_data"
}

* Ali Hamza 2 (MacOS)
else if c(username)=="Zambeel" {
	global wd "/Users/Zambeel/Downloads/PPOL_768/Week_4/02_data"
}

* Beatrice Leydier
else if c(username)=="Pytha" {
	global wd "C:/Users/Pytha/Box Drive/PPOL_768/Week_4/02_data"
}

else {
	display as error "Please define global wd before running this do file"
}

 


*Display options  (Note: Run this once you are comfortable with string functions mentioned at the end of this do file)
local date: display %tdCCYY.NN.DD date(c(current_date),"DMY")
local date: subinstr local date "." "", all
local time: display %tchham Clock(c(current_time),"hms")
local time: subinstr local time " " "", all
*defining log names using date and time 
local log_name "location_of_the_log_file/projectXYZ_`date'_`time'_`c(username)'.smcl"

display as error "`log_name'"





********************************************************************************
*15. Indexing: Referring to observations, keeping, and dropping obs :
********************************************************************************

* _n refers to the number of the row 
use "$insurance", clear
gen obsnum=_n 
lab var obsnum "Observation number" 
order obsnum, first 


* writing _n refers to observations 
list if _n<50 //will browse the first 49 observations 

*dropping and keeping 
drop if _n>1000 
keep if _n<=100 //will keep the first 100 observatiosn 

*you can refer to certain values of variables in certain observations 

use "$insurance", clear

sort reg_marks
gen duplicate_reg=0
replace duplicate_reg=1 if  reg_marks[_n]==reg_marks[_n+1]
replace duplicate_reg=1 if  reg_marks[_n]==reg_marks[_n-1]


********************************************************************************
*16. recode, destring, encode, decode
********************************************************************************
use "$project_educ", clear

/*
Recode: 
It changes the values of numeric variables according to the rules specified. 
*/

*we have a dummy variable for male but we want to include a dummy variable female
*in our regression model. Using recode option

gen female=male
recode female (1=0) (0=1) 
tab male female

/*detring
It converts variables in varlist from string to numeric
*/

*age is a string vartiable 
destring(age), replace


gen female2 = female 
label define fgender 1 "Female" 0 "Male" //gender is the name of the value label
label values female2 "fgender" //here the variable is called female. 

decode female2, gen(gender)
encode gender, gen(female3)
 

********************************************************************************
* 17. Datasets commands: merge, append, reshape, cf 
********************************************************************************

/*
*merge
 merge joins corresponding observations from the dataset currently in memory 
 (called the master dataset) with those from filename.dta (called the using 
 dataset), matching on one or more key variables.  merge can perform match
 merges (one-to-one, one-to-many, many-to-one, and many-to-many), which are 
 often called 'joins' by database people.
 */




use "$baseline", clear

merge 1:1 student_id using "$endline"
 
*look at m:1, 1:m & m:m option

/*
Append:
append appends Stata-format datasets stored on disk to the end of the dataset 
in memory. 
*/

use "$baseline", clear

append using "$endline"
sort student_id

bysort student_id: egen baseline_score = max(total_M_B)
bysort student_id: egen endline_score = max(total_M_E)

drop total*

 
/*
reshape
It converts data from wide to long form and vice versa.
*/
/*
*wide to long
webuse reshape1, clear //Webuse is a command to use Stata datasets that are not available locally, must be connected to the internet.
reshape long inc ue, i(id) j(year)


*long to wide
reshape wide inc ue, i(id) j(year)
*/ 

 
********************************************************************************
*19. Preserve/Restore. tempfiles
********************************************************************************
use "$baseline", clear

preserve 
	use "$endline", clear
	drop in 1/50 //drop first 50 observations of the data

	tempfile endline_minus50 //define tempfile name
	save `endline_minus50' //save tempfile
restore

merge 1:1 student_id using `endline_minus50' //merge using the tempfile

 
********************************************************************************
*20. String functions
********************************************************************************
/*
*split (very important)

*substr
					 substr("abcdef",2,3) = "bcd"
                     substr("abcdef",-3,2) = "de"
                     substr("abcdef",2,.) = "bcdef"
                     substr("abcdef",-3,.) = "def"
                     substr("abcdef",2,0) = ""
                     substr("abcdef",15,2) = ""

*subinstr
					 subinstr("this is the day","is","X",1) = "thX is the day"
                     subinstr("this is the hour","is","X",2) = "thX X the hour"
                     subinstr("this is this","is","X",.) = "thX X thX"


*strpos 
					 strpos("this","is") = 3
					 
*strlen 
					 strlen("ab") = 2



*/



/*
regexm(s,re)
performs a match of a regular expression and evaluates to 1 if regular 
expression re is satisfied by the ASCII string s; otherwise, 0
*/


*Example1:

use "$project_u", clear

*correct answer is 7:25 am for mq10

gen mq10_new =""
replace mq10_new = "7:25am" if regexm(mq10,"7:25")
replace mq10_new = "7:25am" if regexm(mq10,"7hrs")
replace mq10_new = "7:25am" if regexm(mq10,"7.25") | regexm(mq10,"725")
replace mq10_new = "" if regexm(mq10,"pm")
replace mq10_new = "" if regexm(mq10,"p.m")


tab mq10 if mq10_new !="" //See if we can clean it further?
  
*Example2:
use "$project_treg", clear

*registration number for vehicles registered in Tanzania should look like:
* regnum = T123ABC
gen correct_regnum = regexm(regnum,"^T[0-9][0-9][0-9][A-Z][A-Z][A-Z]$")
*You can use ChatGPT to create regex expressions by 