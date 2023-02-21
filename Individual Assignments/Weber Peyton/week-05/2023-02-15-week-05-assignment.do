*PPOL 768-01, SS2023 
*Author: Peyton Weber
*Week 5 Assignment Do-File 

clear all
set more off
global wd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
*Reviewer to update this command to reflect the reviewer's working directory. 
cd "$wd"

*Question 1:

use "$wd/q1_psle_student_raw.dta"
*Loading in the dataset. 

*foreach i of varlist _all {
	
*I receive an error message that s is an ambiguous abbreviation when I try to run my week 4, question 4 code in a loop. 
*The code below works (even though it's not a loop), but it takes a long time to run. 

gen str_pos = strpos(s, "SUBJECTS")
replace s = substr(s,strpos(s,"SUBJECTS"),.)
split s, p("</TD></TR>")
gen i = _n
drop s
reshape long s, i(i) j(j)
*Parsing through HTML code and reshaping the data from wide to long. 

split s, parse("</FONT></TD>")
drop s str_pos
split s1 , p("CENTER")
drop s11
split s12 , p(>)
drop s1 s12 s121
rename s122 candidate_num
*Creating the candidate number column by splitting and parsing through HTML code. 

split s2 , p("CENTER")
drop s21
split s22 , p(>)
drop s2 s22 s221
rename s222 prem_num
*Creating the school identifier column by splitting and parsing through HTML code. 

split s3 , p("CENTER")
drop s31
split s32 , p(>)
drop s3 s32 s321
rename s322 gender
*Creating the student gender column by splitting and parsing through HTML code. 

split s4 , p("<P>")
drop s41
rename s42 candidate_name
drop s4
*Creating the student name column by splitting and parsing through HTML code. 

split s5 , p("LEFT")
drop s51
split s52 , p(>)
drop s5 s52 s521
split s522 , p("<")
rename s5221 grades
drop s5222 s522
*Creating the student grades column by splitting and parsing through HTML code. 

split grades , p(,)
	
split grades1 , p(-)
rename grades12 Kiswahili
drop grades1 grades11
*Creating the Kiswahili language column by splitting and parsing through HTML code. 
	
split grades2 , p(-)
rename grades22 English
drop grades2 grades21
*Creating the English language column by splitting and parsing through HTML code. 
	
split grades3 , p(-)
rename grades32 Maarifa
drop grades3 grades31
*Creating the Maarifa language column by splitting and parsing through HTML code. 
	
split grades4 , p(-)
rename grades42 Hisbati
drop grades4 grades41
*Creating the Hisbati language column by splitting and parsing through HTML code. 
	
split grades5 , p(-)
rename grades52 Science
drop grades5 grades51
*Creating the Science column by splitting and parsing through HTML code. 
	
split grades6 , p(-)
rename grades62 Uraia
drop grades6 grades61
*Creating the Uraia column by splitting and parsing through HTML code. 
	
split grades7 , p(-)
rename grades72 Avg_Grade
drop grades7 grades71
*Creating the average grades column by splitting and parsing through HTML code. 

drop grades i j 
*Dropping columns no longer needed that were created from reshaping the data. 

keep if prem_num != ""
*Dropping missing observations. 
*}

br

*Question 2: 

global survey_data "$wd/q2_CIV_populationdensity.xlsx" 

use "$wd/q2_CIV_Section_0.dta", clear 

decode b06_departemen, generate(department)
*Changing department variable from an integer to new string variable. 

tempfile survey
save `survey'
*Temporarily saving this dataset with department name info to be merged with excel survey data later on. 

import excel "$survey_data", sheet("Population density") firstrow clear
*Loading in the dataset on population density. 

drop SUPERFICIEKM2 POPULATION
*Dropping extraneous information. 

keep if regex(NOMCIRCONSCRIPTION, "DEPARTEMENT")
*The above command ensures that we are only keeping department-level data. 

sort NOMCIRCONSCRIPTION

gen department = NOMCIRCONSCRIPTION
replace department = subinstr(department, "DEPARTEMENT D'","",.)
replace department = subinstr(department, "DEPARTEMENT DE ","",.)
replace department = subinstr(department, "DEPARTEMENT DU ","",.)
*The above commands are extracting the actual department names into a new variable that will hopefully match the department names in the other dataset saved in a tempfile. 

codebook department 
*There are leading blanks! 
replace department = strtrim(department)
codebook department 
*No more leading blanks. 
replace department = lower(department) 
*Making sure all the department names are in lowercase in preparation for merge. 
replace department = "arrha" if department == "arrah" 
*Standardizing department names in preparation for merge. 

rename DENSITEAUKM pop_density 
keep pop_density department 
*Keeping essential variables in preparation to merge. 

merge 1:m department using `survey'
*Merging the two datasets after cleaning/preparing. 
drop if _merge==1
*Dropping the one observation that was unable to be merged. No population density data for this observation. 

order department pop_density, last
*This command allows us to view the population density for each department to the very far right of the browsw window. 

*Question 3:
use "$wd/q3_GPS Data.dta", clear

ssc install egenmore
egen clock = mlabvpos(latitude longitude)
*Creating a new "clock" variable that assigns a time that corresponds to the households' positions using the latitude and longitude information. 
sort clock 
br
scatter longitude latitude, mlab(id) mlabvpos(clock) title("Placeholder")
*Visualizing the position of the households to be surveyed. 
ssc install seq
*Preparing right commands to assign numerators to various household placements. 
seq enumID, f(1) t(19) b(6)
*Creating a new variable, Enumerator ID, to assign households to all 19 enumerators in groups of approximately six. 
drop age female
*Dropping variables no longer needed. 
br
*Visually checking enumerator IDs have been assigned correctly. 
tab clock enumID
*Verifying that enumerators have been assigned (almost) equal numbers of households. 
list id if enumID == 1 
*If an enumerator is assigned id = 1, the household IDs they are responsible for are listed. 

*Question 4: 

import excel "$wd/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow allstring clear
*Loading in the dataset. 
*The important data doesn't start until line five in the original spreadsheet. Always a good idea to import everything as strings, per Ali's advice in office hours. 

drop if _n == 1 
*The first row is blank. 
drop K 
*K is an empty column. 
generate serial = _n
*Generating a serial variable so that I can always revert back to the original order. 

replace REGION = REGION[_n-1] if REGION == "" 
*Bringing down region since missing region values did not transfer when imported from Excel file. 
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == "" 
*Bringing down district since missing district values did not transfer when imported from Excel file. 
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == "" 
*Bringing down constituency since missing constituency values did not transfer when imported from Excel file.  
replace WARD = WARD[_n-1] if WARD == "" 
*Bringing down ward since missing ward values did not transfer when imported from Excel file. 
replace POLITICALPARTY = subinstr(POLITICALPARTY, " ", "", .)
replace POLITICALPARTY = subinstr(POLITICALPARTY, "-", "_", .)

*Not every ward has the same party, which would cause issues if we tried to reshape the data as-is. Need to use the fillin command. 

codebook WARD
*There are only 3,113 wards, but we know there should be 3,333. It must be the case that some ward names are common and are being reused in districts. 
gen unique_ward = REGION + DISTRICT + WARD
*Could have also used the following command, but it would have created a numeric variable: egen unique_ward = group(REGION DISTRICT WARD) 

codebook unique_ward
*We now see that there are the expected 3,333 unique ward values, as expected. 

*I need to use fillin comand before reshaping the data, because not every ward has the same parties. 

fillin unique_ward POLITICALPARTY
sort unique_ward _fillin
*Need to fill in missing values again after creating unique ward variable. 

replace REGION = REGION[_n-1] if REGION == "" 
*Bringing down region since creating unique ward variable generated missing cells. 
replace DISTRICT = DISTRICT[_n-1] if DISTRICT == "" 
*Bringing down district since creating unique ward variable generated missing cells.
replace COSTITUENCY = COSTITUENCY[_n-1] if COSTITUENCY == "" 
*Bringing down constituency since creating unique ward variable generated missing cells. 
replace WARD = WARD[_n-1] if WARD == "" 
*Bringing down ward since creating unique ward variable generated missing cells.

keep unique_ward POLITICALPARTY TTLVOTES
*Dropping extra variables we are not interested in. 
sort unique_ward POLITICALPARTY
bysort unique_ward: gen j=_n 
*Creating a "j" for each unique ward with all 18 parties, even if there was not a candidate represented for that party in a given unique ward. 
tab j POLITICALPARTY
*There is an issue to resolve before we reshape. CCM is not always j = 2. This is also an issue for other wards. 
br if j==4 & POLITICALPARTY == "CCM" 
br
*In some wards, there are two or more candidates for one political party! 
*I got stuck here trying to fix this problem!

encode unique_ward, gen(i) 
*Preparing the unique_ward variable to reshape the data. 
reshape wide POLITICALPARTY TTLVOTES, i(i) j(j)

*Question 5: 
clear
use "$wd/q5_Tz_ArcGIS_intersection.dta"
*Loading in the GIS dataset. 

keep region_gis_2017 district_gis_2017 ward_gis_2017
*Dropping any unwanted variables. 
duplicates drop

rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region district ward)
*Renaming variables in the hopes that we will be able to merge 2017 GIS information with 2015 information. 

sort region district ward 
gen dist_id = _n 
*Creating a serial variable so that I can always revert back to original order.
 
tempfile gis_15
save `gis_15'
*Saving modified GIS dataset in preparation for fuzzy matching. 

use "$wd/q5_Tz_elec_15_clean.dta", clear
*Loading in the 2015 dataset. 

keep region_15 district_15 ward_15
duplicates drop
*Trimming dataset to maintain only important information. 

rename (region_15 district_15 ward_15) (region district ward)
*Renaming to maximize matching success with reclink command/fuzzy matching. 

sort region district ward
gen idvar = _n 
*Creating a serial variable so that I can always revert back to original order.

reclink region district ward using `gis_15', idmaster(idvar) idusing(dist_id) gen(score) 
*Utilizing "fuzzy matching" to use a proxy merge method when observations names are not exactly the same. 
gsort -score
*I'm stuck on this last question, but I believe I need to use the newly-created "score" variable and drop observations that are below a particular percentage matched. 
