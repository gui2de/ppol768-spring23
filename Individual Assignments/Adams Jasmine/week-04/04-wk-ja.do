	 
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 04 						       *
*						   Updated: February 24, 2023						   *
*							      04-wk-ja.do								   *
*						      							   					   *
* 							   - Program Setup -							   *
	clear
	version 17             	    // Version no. for backward compatibility
	set more off                // Disable partitioned output
	clear all                   // Start with a clean slate
	set linesize 120            // Line size limit for readability
	* macro drop _all           // clear all macros
	* capture log close         // Close existing log files
	* log using "04wk-ja.txt",     text replace // Open log file 
	* Project file location     // $rd/w04-ja/w04-ja.stpr
	
	global main    "/Users/jasmineadams/Dropbox/R Stata"
	global rd      "$main/repositories/Rsrch-Dsgn"
	global wd4	   "$rd/w04-ja"
	global w4q1    "$wd4/q1_village_pixel.dta"	
	global w4q2p   "$wd4/q2_Pakistan_district_table21.pdf"
	global w4q2e   "$wd4/q2_Pakistan_district_table21.xlsx"	
	global w4q3    "$wd4/q3_grant_prop_review_2022.dta"	
	global w4q4    "$wd4/q4_Tz_student_roster_html.dta"	
	cd 			   "$wd4"
	
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
	encode  pixel, gen(npixel)	     		 
	bysort  village: egen pmin = min(npixel)
	bysort  village: egen pmax = max(npixel)
	gen 	pixel_village = pmin != pmax
	drop 	pmin pmax
/*	
	Divide households into three categories:
		1. Villages contained in one pixel  w/ same payout
		2. Villages across different pixels w/ same payout (list hhids)
		3. Villages across different pixels w/ different payouts
*/
	gen 	categories = 1 											 
	replace categories = 2 if pixel_vill == 1 & pixel_cons == 0 
	sort 	hhid
	list 	hhid if categ == 2										 

	
	
*					  -- Q2 : National IDs in Pakistan --

//   --  Hint .do on Githib --					
	   // github.com/gui2de/ppol768-spring23/blob/main/Class%20Materials/
	   // week-04/03_assignment/hint_q2.do
/*
	Pakistan_district_table21.xslx has 135 tables (1 for each district)  
		- Import data from the first row of each table ("18 and above...")
		- Append one row for each district by looping through each sheet
		- Align the columns correctly
*/
	clear
	
	tempfile table21   
	save `table21', replace emptyok
			  
	qui forvalues i = 1/135 {
		import excel "$w4q2e", sheet("Table `i'") firstrow clear allstring 
		display as error `i' 							    
		keep if regex(TABLE21PAKISTANICITIZEN1,"18 AND")==1 
		replace TABLE21PAKISTANICITIZEN1 = "`i'"			
		keep in 1 							
		rename TABLE21PAKISTANICITIZEN1 sheet 				
		append using `table21' 							
		save `table21', replace 					
	}
		
	use 	  `table21', clear							
	compress								    // Adjust column width 
	save 	  "$rd/w04-ja/temp.dta", replace
	use  	  "$rd/w04-ja/temp.dta", clear
	
	egen    col = concat(*), p(|)             	// Create long string sep by | 
	replace col = subinstr(col, " ", "", .) 
	replace col = subinstr(col, "-", "|.|", .)  // Let - = 1 cell w/ miss value
	
	forvalues i = 1/8 {
	  replace col = subinstr(col,"||","|",.)    // Iteratively remove || groups   											
	}
	keep  	col
	split 	col, parse("|")						// Put values into even columns
	drop  	col							        // Drop long string when done

	forvalues i = 1/13 {
	   replace col`i' = "." if col`i' == " " 	// Find and correct any spaces
	   destring col`i', replace					// Convert values to numeric
	}
	rename 	col1 sheet
	sort 	sheet


*					 -- Q3 : Faculty Funding Proposal --		
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
	
	drop	PIName Department					  // Data cleaning
	rename 	proposal_id    		proposal
	rename 	AverageScore   		avg
	rename 	StandardDeviation 	stdv
	rename 	Rewiewer1 	  		reviewer1		  // "Reviewer" was misspelled
	rename 	Review1Score   		score1
	rename 	Reviewer2Score		score2
	rename	Reviewer3Score 		score3
	label 	variable reviewer1  "Reviewer 1"	  // Misspelled again here
	rename  *, lower
	
	reshape long score reviewer,    			  /// All 3 rounds in 1 column
			i(proposal) j(round)  
	bysort  reviewer: egen rmean =total(scor/_N)
	bysort  reviewer: egen rstdv =sd(score)
	gen 	stand_r	 = (score - rmean)/rstdv 	  // Standardized scores
	drop    rmean rst							  // using reviewer avg & st.d
	replace proposal = propos + .2 if round == 2  // Creating unique id that
	replace proposal = propos + .3 if round == 3  // reps proposals & rounds
	
	reshape	wide review score stand_r, 			  /// Convert back to wide form
			i(proposal) j(round)
	replace proposal = round(proposal, 1)		  // Remove unique identifiers
	
	forvalues i = 1/3 {
		gsort proposal -reviewer`i'			      // Place var at the top then 
		carryforward *`i', replace				  // fill in missing vals below 
		}
		
	duplicates drop
	
	rename	stand_r* stand_r*_score
	gen		average_stand_score = (stand_r1 + stand_r2 + stand_r3)/3
	egen	rank = rank(-average_stand_score)
	sort 	rank
	
*			    	 -- Q4 : Student Data from Tanzania --
/*
	     Create a student level dataset with the following variables: 

					schoolcode		name		 hisabati
					cand_id 		kiswahili	 science
					gender 			english		 uraia
					prem_number		maarifa		 average 
*/ 

	use "$w4q4", clear
	
	split 	s, parse(">PS")			 // Separating the string of html by ">PS"
	gen   	id = _n
	order 	id, first
	drop  	s
	
	reshape long s, i(id) j(student) // Reshaping the data 
	split   s, parse("<")			 // Separating the string further by "<"
	keep    s1 s6 s11 s16 s21		 // Keeping sections containing variables 
	drop    in 1					 // Removing irrelevant 1st row								
	ren     (s1 s6 s11 s16 s21)      /// Renaming the variables accordingly
			(cand_id prem_number   	 ///	 									   
			sex names subjects) 			 
	
	compress		 
	gen		schoolcode = substr(cand,1,9)  // Create schoolode from cand_id
	order   schoolcode, first
	replace cand = "PS" + cand_id
	
	local   vari cand_id prem_number ///
			sex names subject
			
	foreach x in `vari' {						  // Remove quotes from strings
		replace  `x'   = subinstr(`x',`"""',"",.)
		}
	replace  prem 	   = substr(prem,-11,.) 	  // Remove prefixed HTML
	destring prem,	     replace 
	format   %11.0f 	 prem_number			  // Avoid scientific notation
	replace  sex	   = substr(sex,-1,.)													
	encode   sex,   	 gen(gender)
	replace  names     = subinstr(names,"P>","",.)
	replace  subjects  = subinstr(subjects,"P ALIGN=LEFT>","",.)
	gen 	 kiswahili = substr(subjects,13,1)
	gen 	 english   = substr(subjects,26,1)
	gen 	 maarifa   = substr(subjects,39,1)
	gen 	 hisabati  = substr(subjects,53,1)
	gen 	 science   = substr(subjects,66,1)
	gen 	 uraia     = substr(subjects,77,1)
	gen 	 average   = substr(subjects,-1,1)
	encode   kiswahili, gen(Kiswahili)
	encode   english,   gen(English)
	encode   maarifa,   gen(Maarifa)
	encode   hisabati,  gen(Hisabati)
	encode   science,   gen(Science)
	encode   uraia,     gen(Uraia)
	encode   average,   gen(Average)
	drop     subjects   kiswahili english maarifa sex ///
				 		hisabati science uraia average
	rename	 *, lower
