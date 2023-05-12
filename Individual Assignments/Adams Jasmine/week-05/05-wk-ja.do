*	 																		   *
*						   	     Jasmine Adams								   *
*					      	  PPOL 768 -- Week 05 						       *
*						   Updated: February 24, 2023						   *
*							      05-wk-ja.do								   *
*																			   *
* 							   - Program Setup -							   *

	version 17             	    // Version no. for backward compatibility
	set more off                // Disable partitioned output
	set linesize 120            // Line size limit for readability
	clear all                   // Start with a clean slate
	* macro drop _all           // clear all macros
	* capture log close         // Close existing log files
	
	global main    "/Users/jasmineadams/Dropbox/R Stata"
	global rd      "$main/repositories/Rsrch-Dsgn"
	global wd5	   "$rd/w05-ja"
	global w5q1    "$wd5/q1_psle_student_raw.dta"	
	global w5q2e   "$wd5/q2_CIV_populationdensity.xlsx"
	global w5q2    "$wd5/q2_CIV_Section_0.dta"	
	global w5q3    "$wd5/q3_GPS Data.dta"	
	global w5q4e   "$wd5/q4_Tz_election_2010_raw.xlsx"
	global w5q4    "$wd5/q4_Tz_election_template.dta"
	global w5q510  "$wd5/q5_Tz_elec_10_clean.dta"
	global w5q515  "$wd5/q5_Tz_elec_15_clean.dta"
	cd 			   "$wd5"
	
* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *

*				       -- Q1 : Tanzania Student Data -- 

* This builds on Q4 of week 4 assignment. We downloaded the PSLE data of 
* students of 138 schools in Arusha District in Tanzania (previously had data 
* of only 1 school). You can build on your code from week 4 assignment to create 
* a student level dataset for these 138 schools.


						   ***  --APPENDING DATA--  *** 
	clear
	
	tempfile  q1temp   
	save	 `q1temp', replace emptyok
	
	qui forvalues i = 1/138 {
		display	  as error `i'
		use       "$w5q1", clear  
		replace   schoolcode = substr(schoolcode,7,7)
		destring  (schoolcode), replace
		format    %07.0f schoolcode
		sort      schoolcode
		gen       snum = _n
		order     snum, first
		keep      in `i'
		split     s, parse(">PS")
		gen       id = _n
		order     id, first
		drop      s
		reshape   long s, i(id) j(student)
		split     s, parse("<")
		keep      snum schoolcode s1 s6 s11 s16 s21
		drop      in 1
		rename    (s1 s6 s11 s16 s21) (cand_id prem_number sex names subjects)
		compress
		gen       cnum = _n
		format    %04.0f cnum
		append    using `q1temp' 
		save     `q1temp', replace
	}
							***  --DATA CLEANING--  *** 
							
	use      `q1temp',    clear	
	sort      snum cnum	
	order     cnum,       first
	order     schoolcode, first
	order     snum,       first
	local     vari        cand_id prem_number sex names subjects
	foreach   x in        `vari'  {
		replace `x'     = subinstr(`x',     `"""',              "", .)
	}
	replace   names     = subinstr(names,    "P>",              "", .)
	replace   subjects  = subinstr(subjects, "P ALIGN=LEFT>",   "", .)
	replace   prem      = subinstr(prem,     "P ALIGN=CENTER>", "", .)
	replace   sex       = subinstr(sex,      "P ALIGN=CENTER>", "", .)
	replace   cand_id   =                    "PS" + cand_id
	destring  prem,       replace 
	format    %11.0f      prem	
	encode    sex,        gen(gender)
	gen       kiswahili = substr(subjects,13,1)
	gen       english   = substr(subjects,26,1)
	gen       maarifa   = substr(subjects,39,1)
	gen       hisabati  = substr(subjects,53,1)
	gen    	  science   = substr(subjects,66,1)
	gen   	  uraia     = substr(subjects,77,1)
	gen       average   = substr(subjects,-1,1)
	encode    kiswahili,  gen(Kiswahili)
	encode    english,    gen(English)
	encode    maarifa,    gen(Maarifa)
	encode    hisabati,   gen(Hisabati)
	encode    science,    gen(Science)
	encode    uraia,      gen(Uraia)
	encode    average,    gen(Average)
	drop      subjects    kiswahili english maarifa ///
				 		  hisabati science uraia average
	

*				    -- Q2 : Côte d'Ivoire Population Density -- 
	
* We have household survey data and population density data for Côte d'Ivoire. 
* Merge departmente-level density data from the excel sheet 
* (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) 
* i.e. add population density column to the CIV_Section_0 dataset.
	
	clear 
	
	tempfile  q2temp   
	save	 `q2temp',         replace emptyok
	import    excel "$w5q2e",  sheet("Population density") ///
							   firstrow case(lower) clear
	keep if                    regex( nomcirconscription, "DEPARTEMENT") == 1
	gen       departmen1     = substr(nomcirconscription, 16, .)
	gen       departmen2     = lower(departmen1)
	encode    departmen2,	   gen(department)
	drop      departmen1	   departmen2 nomcirconscription 
	order 	  department,      first
	sort      department
	append    using           `q2temp' 
	save     `q2temp',         replace
	use       "$w5q2",         clear
	rename    b06_departemen   department
	merge     m:1 department   using `q2temp'
	drop      in 12900

*				    -- Q3 : Côte d'Ivoire Population Density -- 

* We have the GPS coordinates for 111 households from a village. Your job is to 
* Assign these households to 19 enumerators (~6 surveys per enumerator per day) 
* such that each enumerator is assigned 6 households that are near each other. 
* Write an algorithm that would auto assign each household (i.e. add a column 
* and assign it a value 1-19 which can be used as enumerator ID). Note: Your 
* code should still work if I run it on data from another village.	

	clear 

	use      	 "$w5q3", clear 
	gen		      enum =  0
	save         "$w5q3", replace
	
	qui forvalues i = 1/16 {
		use      	 "$w5q3", clear
		drop if		 enum != 0
		sort 		 latitude longitude
		rename 		 * *1 
		keep         latitude1 longitude1
		keep		 in 1
		cross 		 using "$w5q3" 
		geodist      latitude1 longitude1 latitude longitude, gen(d`i')
		sort 		 enum d`i'
		gen 		 row  = _n
		replace      enum = `i' if row < 7
		drop         row latitude1 longitude1 d`i'
		save         "$w5q3", replace
		}
		
	qui forvalues i = 17/19 {			// Making the last 3 groups of 5 since 
		use      	 "$w5q3", clear	    // 111 is not divisible by 6
		drop if		 enum != 0
		sort 		 latitude longitude
		rename 		 * *1 
		keep         latitude1 longitude1
		keep		 in 1
		cross 		 using "$w5q3" 
		geodist      latitude1 longitude1 latitude longitude, gen(d`i')
		sort 		 enum d`i'
		gen 		 row = _n
		replace      enum = `i' if row < 6
		drop         row latitude1 longitude1 d`i'
		save         "$w5q3", replace
		}
	
		sort enum
		
		use          "$w5q3", clear
		drop		  enum
		save         "$w5q3", replace
	
*				    -- Q4 : Tanzania Election Data cleaning --

* 2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in 
* its current form. You have to create a dataset in the wide form, where each 
* row is a unique ward and votes received by each party are given in separate 
* columns. You can check the following dta file as a template for your output: 
* Tz_elec_template. Your objective is to clean the dataset in such a way that 
* it resembles the format of the template dataset.
	
	import excel "$w5q4e", sheet("Sheet1") cellrange(A5:J7927) ///
	firstrow case(lower) clear

	drop         	in 1 
	drop      		electedcandidate 	g sex
	rename       	costituency    		constit
	rename 			politicalparty 		party
	carryforward 	region,        		replace
	carryforward 	district,      		replace
	carryforward 	constit,	  		replace
	carryforward 	ward,          		replace
	
	local areas 	region district 	constit ward candidatename party
	foreach      x  in `areas' {
		replace `x' = strrtrim(`x')
		replace `x' = subinstr(`x',"   "," ",.)
		replace `x' = subinstr(`x',"  "," ",.)
	}
	
	replace         party             = "ApptMaendeleo" if party == ///
										"APPT - MAENDELEO"
	replace         party             = "JahaziAsilia" if party == /// 
									    "JAHAZI ASILIA"
	replace         party             = "NccrMageuzi" if party == /// 
									    "NCCR-MAGEUZI"
	replace      	ttlvotes          = "0" if ttlvotes == "UN OPPOSSED"
	destring     	ttlvotes,      		replace
	
	generate		num 			  = 1
	bysort ward:    egen          		tcands10  = total(num)
	bysort ward:    egen          		tvoters10 = total(ttlvotes)
	bysort war par: egen         		pvotes10  = total(ttlvotes)
	encode 			party,				gen(party10)
	encode 			ward,         		gen(ward10)
	encode 			region,       		gen(region10)
	encode 			district,     		gen(district10)
	encode 			constit		, 		gen(constit10)
	sort    		ward region 		district 
	gen 			id 				  = (ward10 * 100000) + ///
										(region10 * 1000) + district10
	format 		    %9.0f id   
	order 			id, first
	drop 			region district 	constit ttl ward cand num party10
	duplicates 		drop id party, 		force
	reshape	wide 	pvotes10, 			i(id) j(party) string
	
	order 			tcands10,	first
	order 			tvoters10, 	first
	order 			ward10, 	first
	order 			constit10,  first  
	order 			district10, first  
	order 			region10, 	first 
	order 			id, 		first   
	rename  		pvotes10* 	*10
	rename  		id 			election10
	rename  		CHADEMA		Chadema10
	rename  		CHAUSTA 	Chausta10
	rename  		MAKIN   	Makin10
	rename  		TADEA   	Tadea10
	label 			variable 	election10 	"Election ID"
	label 			variable 	tvoters10 	"Voters per ward"
	label 			variable 	tcands10 	"Candidates per ward"
	label			variable 	region10 	"Region"
	label			variable 	district10 	"District"
	label 			variable 	constit10 	"Constituency"
	label 			variable 	ward10 		"Ward"
	sort 			region10 	district10 ward10
	gen 			id = _n
	order			id, first
