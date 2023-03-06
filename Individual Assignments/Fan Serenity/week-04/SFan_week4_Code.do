*PPOL 768 - Week 4, STATA Assignment 
*Serenity Fan
*RE-SUBMISSION 
*LAST UPDATED: MARCH 6TH, 2023



*______________________________
* ## Q1 : Crop Insurance in Kenya

*You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

*1a)	Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (`pixel_consistent`), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)  

*Each HH: Village name, HH id, pixel, payout status 

*global excel_t21 "C:/Users/ah1152/Documents/PPOL_768/Week_4/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
*update the global

use q1_village_pixel, clear

*a) 
sort pixel
by pixel: egen pixel_min = min(payout)
by pixel: egen pixel_max = max(payout)

gen pixel_consistent = .
replace pixel_consistent = 0 if pixel_min == pixel_max

*LOGIC: Within each pixel / pixel ID, all HH's should have the same payout, either 0 or 1. This code calculates the min and max value of payout within each pixel. The min and max of payout within each pixel must be the same; if they are different, then we know that at least one of the HH's within a pixel has a different payout. 


*______________________________
*1b)	Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (`pixel_village`), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.  

sort village

*bysort village: list pixel
*replace pixel_village = 0 if pixel[_n] == pixel[_n+1]
*replace pixel_village = 0 if pixel[_n] == pixel[_n-1]

ssc install unique
unique pixel, by(village) gen(n_pixels)

by village: egen sum_n_pixels = sum(n_pixels)
gen pixel_village = 0
by village: replace pixel_village = 1 if sum_n_pixels>1

*LOGIC: We use the 'unique' user-created function in Stata to generate the categorical variable 'n_pixels', which tells us the number of unique strings (ie. 'pixels') in each village. Only those villages which are in multiple pixels (e.g. at a boundary between 2) will have a value for this of 2. Then, we use 'sum' to replicate this value for all HH's within such villages. All HH's in such villages will have a value of 1 for pixel_village. 


*______________________________
*1c)	For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:  
*I.	Villages that are entirely in a particular pixel. (==1)  
*II.	Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)  
*III.	Villages that are in different pixels AND have different payout status (==3)  
*These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.  

gen village_status = 0 

*Villages located entirely within precisely 1 pixel (1)  
replace village_status = 1 if pixel_village==0

*Villages spilling into multiple pixels with SAME (2) vs. DIFFERENT (3) payout status 
unique payout, by(village) gen(n_payouts)
by village: egen sum_n_payouts = sum(n_payouts)

replace village_status = 2 if pixel_village==1 & sum_n_payouts==1
replace village_status = 3 if pixel_village==1 & sum_n_payouts>1
order village_status, last

tab village_status
*Using tab here shows that our 3 categories are indeed mutually exclusive and exhaustive, i.e. every observation has a village_status number, and their count adds up to 958, which is the same number of total observations in the dataset 

list hhid if village_status==2
*This creates the list of villages (by hhid) that span multiple pixels but have the same payout status. We can see that 50 HH's fall under this classification.  

save Q1_output, replace



*______________________________
* ## Q2 : National ID's in Pakistan

*We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

*The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly

*How to align columns on stata?
*Start writing code for first 10 as 135 loop code  takes time 


global excel_t21 "C:\Users\kevin\Github\ppol768-spring23\Individual Assignments\Fan Serenity\week-04\q2_Pakistan_district_table21.xlsx"

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/1 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import 
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21

	gen district=`i' //to keep track of the sheet we imported the data from
	*order district, first 
	*Move 'table' to 1st column
		
	*destring _all, replace
	*destring B C D E F G H I J K L M N O P Q R S T U V W X Y Z, replace
	
	*Delete empty cells at each observation 
	foreach var of varlist * {
		if missing(`var') {
			drop `var'
		}
	}
	
	*Standardize variable names 
	local i=1 
	foreach var of varlist * {
		rename `var' column_`i' 
		local i = `i' + 1
}
	
	*foreach var of varlist _all {
*		if missing(`var') drop `var' 
*	}
	
	append using `table21', force //adding the rows to the tempfile
	*drop table21 B D F H J L N P R T V X Z
	save `table21', replace //saving the tempfile so that we don't lose any data

}
*load the tempfile

use `table21', clear
compress
*sort district

drop column_1

*Rename variables to their actual names 
rename column_2 Total_Pop_A
rename column_3 CNI_Card_Obt_A
rename column_4 CNI_Card_NotObt_A
rename column_5 Total_Pop_M
rename column_6 CNI_Card_Obt_M 
rename column_7 CNI_Card_NotObt_M 
rename column_8 Total_Pop_F
rename column_9 CNI_Card_Obt_F 
rename column_10 CNI_Card_NotObt_F
rename column_11 Total_Pop_T 
rename column_12 CNI_Card_Obt_T
rename column_13 CNI_Card_NotObt_T

sort column_14
rename column_14 District 
order District, first
*Re-order (as observations were appended in reverse order), and drop sheet #

*Save results 
save Q2_output, replace

*fix column width issue so that it's easy to eyeball the data
*format %10s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y Z 



*_________________________
* ## Q3 : Faculty Funding Proposals

*I KNOW THIS IS NOT THE RIGHT ANSWER; WE NEED TO DETERMINE STATISTICS FOR STANDARDIZED SCORES ON THE BASIS OF INDIVIDUAL REVIEWERES, RATHER THAN THEIR AGGREGATED SCORES IN GROUPS OF 3. I WILL ATTEMPT A CORRECT SOLUTION IN TIME. 

*Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)


use "q3_grant_prop_review_2022", clear

rename Rewiewer1 Reviewer1
rename Review1Score Reviewscore1 
rename Reviewer2Score Reviewscore2 
rename Reviewer3Score Reviewscore3


reshape long Reviewer Reviewscore, i(proposal_id) j(Reviewer_number) 
compress 
sort Reviewer

bysort Reviewer: egen norm_score = std(Reviewscore)

reshape wide Reviewer Reviewscore norm_score, i(proposal_id) j(Reviewer_number)

*Standardized by trios  
rename norm_score1 stand_r1_score 
rename norm_score2 stand_r2_score 
rename norm_score3 stand_r3_score

egen average_stand_score = rowmean(stand_r1_score stand_r2_score stand_r3_score)
egen rev_rank = rank(-average_stand_score)

sort rev_rank

keep in 1/50

save Q3_output, replace



*_________________________
*## Q4 : Student Data from Tanzania

*Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from [Tanzania's government website](https://onlinesys.necta.go.tz/results/2021/psle/results/shl_ps0101114.htm). Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

use q4_Tz_student_roster_html, clear

split s, parse(">PS") 
*Splits up the code in the string 's', 'parsing' (aka) dividing the string by using >PS as the 'divider' between sections

gen serial = _n
*Serial can be anything, as we only have 1 row, so don't need to worry about it's identifier  
	drop s 
	*Don't need this extra HTML bit 

reshape long s ///  
	, i(serial) j(student)
	*Reshape so that rows become columns

split s, parse("<")
	*Split up each student's string further
	keep s1 s6 s11 s16 s21
	*We only need a few of these sections, with student/grade info; don't need all the HTML font specifications 
	drop in 1 
	*Don't need 1st row 
	
	rename (s1 s6 s11 s16 s21) /// 
		(cand prem sex name subjects)
		*Rename columns 
		
		compress 
		
	*Remove/replace miscellanous characters 
	replace cand = "PS" + cand 
		*Put "PS" in front of candidate numbers 
	replace prem = subinstr(prem, `"P ALIGN="CENTER">"' ,"", . )
	replace sex = subinstr(sex, `"P ALIGN="CENTER">"' ,"", . )
	replace name = subinstr(name, "P>" ,"", . )
	replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"' ,"", . )
	*Note: . at the end denotes all instance of the text to be subbed out 

	split subjects, parse(",")
	drop subjects
	*Split subjects up into constituent subjects, divided by "," ; then drop combined subj. string
	
	foreach var of varlist subjects* {
		replace `var' = substr(`var', -1, 1 )  
		*Get only the last character, i.e. the grade, using substring, i.e. extract the 'substring' that is only the last character within each subject string 
	}
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6 subjects7) /// 
		(Kiswahili English Maarifa Hisabati Science Uraia Average_Grade)
		
		compress


save Q4_output, replace