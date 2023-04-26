****** BeverlyAnn Hippolyte ******
****** Course : Research and Design Implementation ******
****** Due Date : February 13th 2023 ******

*** Define global working directory 
	if c(username) == "beverlyannhippolyte" {
	cd "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-04"
}

**** Load dataset 
	use "q1_village_pixel.dta", clear 

**** Browse/Familiarize with data
	codebook 

**** Q1 (a). Verify : Is the payout variable consistent within each pixel 
		bysort pixel: egen pixel_min = min(payout)
		bysort pixel: egen pixel_max = max(payout)
		
		gen pixel_consistent = 0
		replace pixel_consistent = 1 if pixel_min == pixel_max
		
		count if pixel_consistent == 1 
		
		count if pixel_consistent !=1
		
**** By observing the minimum and maximum values from the output 
///  the payout variable for each pixel is consistent 


**** Q1 (b). Identifying the villages that are in more than one  pixel
	sort village pixel
	 by village (pixel), sort: gen pixel_village = pixel[1] != pixel[_N] 
        list pixel village if pixel_village
		
	
**** Q1 (c) Place the villages into three exhaustive and exclusive categories 
*** foreach village[_n] if pixel_village == 0 replace village == 1 
	sort pixel_village payout
	gen diffpix_pay = 0
	replace diffpix_pay = 1 if pixel_village = pixel_village[1] != payout[_N]
*	replace diffpix_pay == 2 if pixel_village = pixel_village
*	replace diffpix_pay == 3 if 
	
*	by village (pixel_village), sort: gen diffpix_pay = 1 if pixel_village[1] = payout[_N] 
*	by village (pixel_village), sort: gen diffpix_pay == 2 if pixel_village[1] != payout[_N] 
*	by village (pixel_village), sort: gen diffpix_pay == 1 if pixel_village[1] = payout[_N] 
	
        list pixel village if diffpix_pay
		
save,replace 

**** Question 2
**** Load hint dodfile 

global excel_t21 "/Users/beverlyannhippolyte/GitHub/RDI/ppol768-spring23/Individual Assignments/Hippolyte BeverlyAnn/week-04/q2_Pakistan_district_table21.xlsx"
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
	
	keep table21 B C D E F G H I J K L M  table // Usingthe keep command, we keep the columns that are important
	order table table21 B C D E F G H I J K L M // Changing the order of the tables putting the loop numbers first
	gsort table // the table was in descending order so I changed it to ascending order using this code 

	destring, replace ignore (".") // used destring to convert the string variables into numeric variable
	destring M, replace ignore(-) // changed "- "into a non-numeric value to destring the variable M

	mdesc B C D E F G H I J K L M // This helped me verify the number of missing values for each variable in the 15 columns
	 

/*	
This is where i got stuck with aligning the columns in the dataset 
I realized i could run a code that allows me to delete cells adjacent to each other
I could tell stata *	drop if (C == . & D = .) and it would delete missing value cells 
but that was not efficient because it would be tedious to write code for all these columns
I also attempted to count the number of missing values in each column and 
I thought maybe  I could write a code to delete all the missing values using drop if " ....."
I'm going to continue trying to figure out how i could complete this task. 
	
*	(count if B == .)
	
*/
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

save,replace

****************************** Question 3 *********************
Eng
use q3_grant_prop_review_2022.dta, clear 

egen zreviewscore1 = std(Review1Score) // Generated new variables and stored the std.dev for each score 
egen zreviewscore2 = std(Reviewer2Score)
egen zreviewscore3 = std(Reviewer3Score)

egen avg_zscore = rowmean(zreviewscore1 zreviewscore2 zreviewscore3) // Calculated avg score of the std. scores

rename ( zreviewscore2 zreviewscore3 ) (stand_r2_score stand_r3_score) // Used rename to align names of variables with assignment instructions
rename (avg_zscore) (average_stand_score) // Did the same for avg. z scores.

range rank 1 128 // Generated a numeric variable using the rank command (=>1 lowest, >=128 highest)

save,replace

*****Question 4 *****

**** Set up log file 


log using TZstudent.log

*clear
*tempfile tzstudent // tempfile to store output
*save `tzstudent', replace emptyok

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
		replace var = substr(`var', -1, .)
	}
	
	compress
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6) (Kiswahili English Maarifa Hisabiti Uraia AverageGrade)
	rename (Uraia AverageGrade subjects7) (Science Uraia AverageGrade)
	
log close, append
