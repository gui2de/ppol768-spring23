
*						      							  				       *	 
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 04 						       *
*						       February 11, 2023							   *
*							     04wk-ja.txt.do								   *
*						      							   					   *
*																			   *
* 							   - Program Setup -							   *
*																			   *
	clear
	version 17             	    // Version no. for backward compatibility
	set more off                // Disable partitioned output
	clear all                   // Start with a clean slate
	set linesize 80             // Line size limit for readability
	* macro drop _all           // clear all macros
	* capture log close         // Close existing log files
	* log using "04wk-ja.txt",     text replace // Open log file 
	* Project file location     // $rd/w04-ja/w04-ja.stpr
	
	global wd      "/Users/jasmineadams/Dropbox/R Stata"
	global rd      "/Users/jasmineadams/Dropbox/R Stata/repositories/Rsrch-Dsgn"
	global w4q1    "$rd/w04-ja/q1_village_pixel.dta"	
	global w4q2p   "$rd/w04-ja/q2_Pakistan_district_table21.pdf"
	global w4q2e   "$rd/w04-ja/q2_Pakistan_district_table21.xlsx"	
	global w4q3    "$rd/w04-ja/q3_grant_prop_review_2022.dta"	
	global w4q4    "$rd/w04-ja/q4_Tz_student_roster_html.dta"	
	
	cd "$wd"
* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *

*				       -- Q1 : Crop Insurance in Kenya -- 
   	
/*
	
	Confirm whether the payout variable is consistent within pixels
	Create `pixel_consistent` = 1 for pixels with inconsistent payouts
*/ 
	use "$w4q1"
	
	tab pixel payout 				// Compare payout between pixes
	gen pixel_consistent = 0		// All pixels are conistent
	
/*

	Create `pixel_village` = 1 for villages spanning more than 1 pixel
*/	
	encode pixel, gen(npixel)	     // Numerical values for each pixel
	tab npixel, nolab			     // Check variable was encoded successfully
	
	bysort village: egen pmin = min(npixel)
	bysort village: egen pmax = max(npixel)
	gen pixel_village = 0
	replace pixel_village = 1 if pmin != pmax

	drop pmin pmax
/*	
	
	Divide households into three categories:
		1. Villages contained in one pixel  w/ same payout
		2. Villages across different pixels w/ same payout (list hhids)
		3. Villages across different pixels w/ different payouts
*/
	    gen cat3 = 1 if pixel_village== 0 & pixel_consistent== 0  // 1
	replace cat3 = 2 if pixel_village== 1 & pixel_consistent== 0  // 2
	replace cat3 = 3 if pixel_village== 1 & pixel_consistent== 1  // 3
	
	list hhid if cat3 == 2										 // hhid list
		
	clear
* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *

		
*					  -- Q2 : National IDs in Pakistan --

 					    *----  Hint .do on Githib ----*
						
	   // github.com/gui2de/ppol768-spring23/blob/main/Class%20Materials/
	   // week-04/03_assignment/hint_q2.do
/*

	Pakistan_district_table21.xslx has 135 tables (1 for each district)  
		- Import data from the first row of each table ("18 and above...")
		- Append one row for each district by looping through each sheet
		- Align the columns correctly
*/
	
	* Setting up an empty tempfile
	
	clear
	
	tempfile table21   
	save `table21', replace emptyok
	
	 			    // Looping through excel sheets (1-135) //
				 	    			   ******
	local columns B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC 
	
   forvalues i = 1/135 {
	import excel "$w4q2e", sheet("Table `i'") firstrow clear allstring 
	
	display as error `i' 							    // Display sheet number
	keep if regex(TABLE21PAKISTANICITIZEN1,"18 AND")==1 // Denote row cell
	replace TABLE21PAKISTANICITIZEN1 = "`i'"			// Create row id
	keep in 1 										    // Keep row one only
	drop if _n > 135								    // Prevent overlooping
	rename TABLE21PAKISTANICITIZEN1 sheet 				// Rename row id
		append using `table21' 							// Add row to tempfile
		save `table21', replace 						// Save tempfile
	}
	use `table21', clear								// Load tempfile

	
						// Fixing misaligned columns //

	format %15s ///
	sheet B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC 
	
	foreach x in `columns' {
		replace `x' = "0" if inlist(`x', "-")
			}
	
	destring(*), replace
	
	tab AC if AC !=.
	drop AC
	
	save "$rd/w04-ja/temp.dta", replace
	use "$rd/w04-ja/temp.dta", clear
	
	sort sheet
	list sheet B C D if B ==. 
	
	replace B = C if B ==. 
	replace C =. if B == C
	replace B = D if B ==. 
	replace D =. if B == D
	replace B = E if B ==. 
	replace E =. if B == E
	
	replace C = D if C ==. 
	replace D =. if C == D
	replace C = E if C ==.
	replace E =. if C == E
	replace C = F if C ==.
	replace F =. if C == F
	
	replace D = E if D ==. 
	replace E =. if D == E
	replace D = F if D ==.
	replace F =. if D == F
	replace D = G if D ==.
	replace G =. if D == G
	replace D = H if D ==.
	replace H =. if D == H
	replace D = I if D ==.
	replace I =. if D == I
	
	replace E = F if E ==.
	replace F =. if E == F
	replace E = G if E ==.
	replace G =. if E == G
	replace E = H if E ==.
	replace H =. if E == H
	replace E = I if E ==.
	replace I =. if E == I
	replace E = J if E ==.
	replace J =. if E == J
	replace E = K if E ==.
	replace K =. if E == K
	list B C D E F G
	
	* So on and so forth. Could create a forvalues loop if I renamed all the
	* columns to col1, col2, col3, etc.but this is the pattern^

	clear
*					  -- Q3 : Faculty Funding Proposal --
		
/*
	Students scored 128 proposals (24 each) between 1 and 5  
	Normalize the score with respect to each reviewer 
	Add columns: 
			1) stand_r1_score 
			2) stand_r2_score 
			3) stand_r3_score 
			4) average_stand_score 
			5) rank (highest score =>1, lowest => 128)
*/
	
	use "$w4q3", clear
	
	* --Data cleaning-- *
	
	rename Rewiewer1 Reviewer1
	rename Reviewer2Score Review2Score
	rename Reviewer3Score Review3Score
	
	sort Reviewer1
	encode Reviewer1, gen (reviewer1)
	sort Reviewer2
	encode Reviewer2, gen (reviewer2)
	sort Reviewer3
	encode Reviewer3, gen (reviewer3)
	
	drop PIName Department Reviewer1 Reviewer2 Reviewer3
	
	save "$rd/w04-ja/q3copy.dta"
	global q3 "$rd/w04-ja/q3copy.dta"
	
	* --Creating dataset with only one var for reviewers and scores-- *
	
	sort reviewer1
	keep proposal_id Review1Score AverageScore StandardDeviation reviewer1
	rename Review1Score rscore
	rename reviewer1 reviewer
	gen year = 1
	save "$rd/w04-ja/r1.dta"
	global r1 "$rd/w04-ja/r1.dta"
	use "$q3", clear
	
	sort reviewer2
	keep proposal_id Review2Score AverageScore StandardDeviation reviewer2
	rename Review2Score rscore
	rename reviewer2 reviewer
	gen year = 2
	save "$rd/w04-ja/r2.dta"
	global r2 "$rd/w04-ja/r2.dta"
	use "$q3", clear
	
	sort reviewer3
	keep proposal_id Review3Score AverageScore StandardDeviation reviewer3
	rename Review3Score rscore
	rename reviewer3 reviewer
	gen year = 3
	save "$rd/w04-ja/r3.dta"
	global r3 "$rd/w04-ja/r3.dta"
	use "$r1", clear
	append using "$r2"
	append using "$r3"

	bysort reviewer: egen count1 = count(year) if year == 1
	bysort reviewer: egen count2 = count(year) if year == 2
	bysort reviewer: egen count3 = count(year) if year == 3
	bysort reviewer: egen mean1 = total(rscore/count1)
	bysort reviewer: egen mean2 = total(rscore/count2) 
	bysort reviewer: egen mean3 = total(rscore/count3)
	bysort reviewer: egen meant = total(rscore/24) 

	bysort reviewer: egen sd1 = sd(rscore) if year == 1
	bysort reviewer: egen sd2 = sd(rscore) if year == 2
	bysort reviewer: egen sd3 = sd(rscore) if year == 3
	bysort reviewer: egen sdt = sd(rscore) 
	
	gen stand_r1_score = (rscore - mean1) / sd1
	gen stand_r2_score = (rscore - mean2) / sd2
	gen stand_r3_score = (rscore - mean3) / sd3
	gen average_stand_score = (rscore - meant) / sdt
	
	bysort year: egen rank = rank(AverageScore)


*			    	 -- Q4 : Student Data from Tanzania --
/*
	Create a student level dataset with the following variables: 

		schoolcode		name		 hisabati
		cand_id 		kiswahili	 science
		gender 			english		 uraia
		prem_number		maarifa		 average 
*/

	use "$w4q4", clear
	
	split s, parse(">PS")
	
	gen id = _n
	order id, first
	drop s
	
	reshape long s, i(id) j(student)
	split s, parse("<")
	
	keep s1 s6 s11 s16 s21
	drop in 1
	
	ren (s1 s6 s11 s16 s21) (cand_id prem_number sex names subjects)
	compress

	replace cand = "PS" + cand_id
	replace prem = subinstr(prem, "P ALIGN="CENTER">","",.) 
	
	local vari cand_id prem_number sex names subjects
	foreach x in `vari' {
		replace `x' = subinstr(`x', `"""',  "", .)
			}
	
	gen candid = _n
	drop cand_id
	rename candid cand_id
	order cand_id, first
	
	replace prem_number = subinstr(prem, "CENTER>", "", .)
	destring prem_number, replace 
	format %12.0f prem_number
	
	replace sex = subinstr(sex, "P ALIGN=CENTER>", "", .)
	encode sex, gen(nsex)
	drop sex
	rename nsex sex
	
	replace names = subinstr(names, "P>", "", .)
	
	replace subjects = subinstr(subjects, "P ALIGN=LEFT>", "", .)
	gen kiswahili = substr(subjects,13,1)
	gen english = substr(subjects, 26,1)
	gen maarifa = substr(subjects, 39,1)
	gen hisabati = substr(subjects,53,1)
	gen science = substr(subjects,66,1)
	gen uraia = substr(subjects,77,1)
	gen average = substr(subjects,-1,1)
	drop subjects




