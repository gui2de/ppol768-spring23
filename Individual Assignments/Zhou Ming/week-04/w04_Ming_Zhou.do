
********************************************************************
* PPOL 768: Week 4
* Exploring and manipulating data in Stata
* Feb 7th, 2023
********************************************************************
cd "/Users/zhouming/Desktop/Graduate/Spring2023/Research Design/Assignment03"

*Q1: Crop Insurance in Kenya
use "q1_village_pixel.dta", clear
*(a)
/*change pixel to numeric variable*/
encode(pixel),gen(pixel1)
/*generate pixel_consistent variable*/
gen pixel_consistent = 0 
replace pixel_consistent = 1 if pixel1 != payout 
*(b)
bysort village: egen min = min(pixel1) 
bysort village: egen max = max(pixel1)
gen pixel_village = 0 if min == max 
replace pixel_village = 1 if min != max
*(c)
gen village_cate = 1 if pixel_village == 0 
replace village_cate = 2 if pixel_consistent == 0 & pixel_village == 1 
replace village_cate = 3 if pixel_consistent == 1 & pixel_village == 1

*Q2: National IDs in Pakistan
clear all 
global excel_t21 "/Users/zhouming/Desktop/Graduate/Spring2023/Research Design/Assignment03/q2_Pakistan_district_table21.xlsx"
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
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	/* drop missing columns*/
	ds
	foreach var in `r(varlist)'{
		if missing(`var') {
			drop `var'
		}
	}
	/*"_" indiscates a blank cell*/
	ds
	foreach var in `r(varlist)' {
	 if regex(`var', "-") {
	 	split `var', p("-")
		drop `var'
	 }
	}
	/*generate columns when the missing columns are at the tail of the table*/
	creturn list
	if c(k) < 13 {
	  gen blank_col = ""
	} 
	/*create column names*/
	ds
	forvalue j = 2/13 {
	    local column: word `j' of `r(varlist)'
		rename `column' column_`j'
	}
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 `r(varlist)'

/*rename the columns*/
rename column_2 total_pop
rename column_3 total_obtained
rename column_4 total_not_obtained
rename column_5 male_pop
rename column_6 male_obtained
rename column_7 male_not_obtained
rename column_8 female_pop
rename column_9 female_obtained
rename column_10 female_not_obtained
rename column_11 trans_pop
rename column_12 trans_obtained
rename column_13 trans_not_obtained

*Q3: Faculty Funding Proposals
use "q3_grant_prop_review_2022.dta", clear
/*create standardized score reviewer 1*/
egen stand_r1_score = std(Review1Score)
/*create standardized score reviewer 2*/
egen stand_r2_score = std(Reviewer2Score)
/*create standardized score reviewer 3*/
egen stand_r3_score = std(Reviewer3Score)
/*get average score*/
gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3
/*sort data and get rank*/
gsort -average_stand_score
gen rank = _n

*Q4: 
use "q4_Tz_student_roster_html.dta",clear
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
rename s62 kiswahili
rename s64 english
rename s66 maarifa
rename s68 hisabati
rename s610 science
rename s612 uraia
drop s*
rename t_schoolcode schoolcode





