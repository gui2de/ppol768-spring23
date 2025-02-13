*YUQING DANIEL FANG
*PPOL 768
cd "D:\FYQ\Georgetown\PPOL_768\768github\ppol768-spring23\Individual Assignments\Fang Daniel\week04\01_data"
clear 
use "q1_village_pixel.dta" 

*1.
**1a
encode(pixel),gen(pixel1)

gen pixel_consistent = 0 
replace pixel_consistent = 1 if pixel1 != payout 

**1b
bysort village: egen min = min(pixel1) 
bysort village: egen max = max(pixel1)
gen pixel_village = 0 if min == max 
replace pixel_village = 1 if min != max

**1c
gen village_type = 1 if pixel_village == 0 
replace village_type = 2 if pixel_consistent == 0 & pixel_village == 1 
replace village_type = 3 if pixel_consistent == 1 & pixel_village == 1

*ah1152: good job but there's an issue with part c. There is no village in category 2. 
*e.g. OGUDA 'A' should be in category 2 and not 3. 

*2.
global excel_t21 "q2_Pakistan_district_table21.xlsx"
*update the global

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	ds
	foreach var in `r(varlist)'{
		if missing(`var') {
		drop `var'
		}
		}
	ds
	foreach var in `r(varlist)' {
		if regex(`var', "-") {
		split `var', p("-")
		drop `var'
		}
		}
	if c(k) < 13 {
   gen blank_col = ""
		} 
 
	ds
	forvalue j = 2/13 {
		local column: word `j' of `r(varlist)'
		rename `column' column_`j'
		}
 /*create column names*/
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

*ah1152: Your loop wasn't working properly as it was i=1/5. But once I update it to i=1/135 it works fine. Good job.
*3.
use "q3_grant_prop_review_2022.dta" , clear

gen stand_r1_score = (Review1Score - AverageScore)/StandardDeviation
gen stand_r2_score = (Reviewer2Score - AverageScore)/StandardDeviation
gen stand_r3_score = (Reviewer3Score - AverageScore)/StandardDeviation
gen average_stand_score = AverageScore/StandardDeviation
gsort -average_stand_score
gen rank = _n


*ah1152: This is incorrect, the main issue is that the person appearing as reviewer 1 is not always reviewer 1 (one the reviewer is sa1600, and they appear 24 times but sometimes ast reviewer 1, 2 or 3. You have to calculate the standardized score at this unique netid variable)

***Q3-revised

/*create reviewer 1*/
egen stand_r1_score = std(Review1Score)
/*create reviewer 2*/
egen stand_r2_score = std(Reviewer2Score)
/*create reviewer 3*/
egen stand_r3_score = std(Reviewer3Score)
/*averaging score*/
gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3
/*rank data*/
gsort -average_stand_score
gen rank = _n

*4.

**Copy data context from cell in the html and delete everything before "subject", examine the content
use "q4_Tz_student_roster_html.dta", clear

/*view the datasets*/
display s[1]
/*split the data into tables and other contents*/
split s, parse(<TABLE) //s3 is the table 
display s2
keep s3
/*split rows from the data*/
split s3, parse(<TR>)
drop s31 s32 s3
/*reshape data*/
gen row = _n
reshape long s, i(row) j(index) 
/*split rows*/
drop row
split s, parse(<P)
/*find information in each cell*/
gen t_schoolcode = substr(s2, 17, 9)
gen cand_id = substr(s2, 27, 4)
gen prem_number = substr(s3, 17, 11)
gen gender = substr(s4, 17, 1)
split s5, p("</FONT>")
gen name = subinstr(s51,">","", 1)
split s6, p("- ", ",")
gen average = substr(s614, 1, 1)
/*rename columns properly*/
rename s62 Kiswahili
rename s64 English
rename s66 Maarifa
rename s68 Hisabati
rename s610 Science
rename s612 Uraia
drop s*
rename t_schoolcode schoolcode
exit

*ah1152: Your code breaks at "display s2" as s2 variable doesn't exist, please fix this issue. Thanks!