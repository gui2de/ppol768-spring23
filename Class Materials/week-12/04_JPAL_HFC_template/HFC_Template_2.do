/*-----------------------------------------------* 
File: 	   High Frequency Check template		
Author(s): Saurabh (J-PAL SA)
Modified by: Krishanu Chakraborty ( J-PAL SA)					
Version:   v2								
Date: 	   21 March, 2017						
*-----------------------------------------------*/


*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/*Install user-written commands. Some users might not have the 
user written commands installed. If you search for any of these
user written commands, you would probably find and .ado file.
Try finding mdesc.ado after you run the commands below.

Question 1: What is an .ado file? 
Question 2: What does the commands : mdesc and nmissing do?
            How can you see the same?
*/

foreach package in mdesc nmissing{
     capture which `package'
     if _rc==111 ssc install `package'
}

*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
				
	
	version 12 
	clear all 
	pause on 
	set more off 
	qui cap log c 
	
*--------------------------------------------------------
** Set directories
*--------------------------------------------------------

	if c(os) == "Windows" {
		local DROPBOX "C:/Users/`c(username)'/Dropbox/"
	}
	else if c(os) == "MacOSX" {
		local DROPBOX "/Users/`c(username)'/Dropbox/"
	}
	

* Change directory to the data location 
	cd ""
		local data "dummy_main.dta" // data to be checked 

* Setting locals for output folders (reports, errors, etc.) 
	local reports "" 	// eg. reports directory 


use dummy_main.dta, clear

* Define key variables 
	local unique surveyor_id 	// Unique ID variable
	local enum "" 		        // Enumerator code variable 

*==========================================================================
************************* Unique ID Checks ********************************
*==========================================================================

*--------------------------------------------------------------------------
** Checking for missing Unique IDs
*--------------------------------------------------------------------------
/*The Unique ID cannot be missing. This should be taken care of during programming. 
Let us consider the variables which are unique and you want to run the missing checks for. 
Suppose we consider "surveyor_id"

*/

mdesc surveyor_id 
cap assert `r(miss)' == 0 
	if _rc != 0 {
		di "`unique' has `r(miss)' missing values" 
	}

list surveyor_id `enum' starttime if surveyor_id == .  

* Question 3: Suppose you want to see the pattern of missing values. What would you do?

*--------------------------------------------------------------------------
** Duplicates in unique ID
*--------------------------------------------------------------------------

*Finding the number of duplicates in surveyor_id

sort surveyor_id, stable
qui by surveyor_id: gen dup = cond(_N==1,0,_n) // --duplicates tag `unique', gen(dup)-- would essentially work similarly but dup would be a binary 
	count if dup > 0 

di "Surveys with duplicates:" 
list surveyor_id `enum' starttime dup if dup > 0 & !missing(surveyor_id), sepby(surveyor_id) abbr(16)


*isid `unique'  // This line should run successfully once all duplicates are fixed


*--------------------------------------------------------------------------
** Unique ID matches with master tracking list & field tracking lists
*--------------------------------------------------------------------------

ds `unique', not
	local master "`r(varlist)'"  // this local contains all variables except unique ID variable

preserve 
	use ".dta", clear 	// Tracking data 
	/*Ensure that the ID variable here has the same name
	as that in your master data */
	ds 
		local using "`r(varlist)'" // this local contains all variables in using data
	tempfile tmp1 
	sa `tmp1' 
restore

** Checking for variables with same name in master & using
/* The merge command retains observations from master dataset whenever the master and using data have a same varname. 
It's a good habit to check for such common varnames to avoid losing necessary variables from using data */

foreach var in `master' {
	foreach i in `using' {
		cap assert "`var'" == "`i'"
			if _rc == 0 {
				di "Variable `var' has same name in both master and using." 
			}
	}
}

merge 1:1 `unique' using `tmp1' 
	assert _merge != 1    

//Check the merge results thoroughly and carry out further checks as needed 

*==========================================================================
************************** Date & Time Checks *****************************
*==========================================================================

/* Stata can work with dates such as 21nov2006, with times such as 13:42:02.213, and with dates
and times such as 21nov2006 13:42:02.213. You can write these dates and times however you wish,
such as 11/21/2006, November 21, 2006, and 1:42 p.m. */

** Surveys that don't end on the same day as they started

sort surveyor_id
list surveyor_id starttime endtime name if dofc(starttime) != dofc(endtime), sep(0)

** Surveys where end date/time is before start date/time

list `unique' starttime endtime if dofc(starttime) > dofc(endtime), sep(0)
list `unique' starttime endtime if Cofc(starttime) > Cofc(endtime) & dofc(starttime) == dofc(endtime), sep(0)

** Surveys that show starttime earlier than first day of data collection

list surveyor_id starttime name if dofc(starttime) < mdy(4, 21, 2016) 
											// 21st April 2016 is just an example. Replace it with start date of your data collection

** Surveys that have starttime after system date (current)

list `unique' starttime endtime if starttime > date(c(current_date), "DMYhms")

* Question 4: Do you know what is the difference between cofd() and dofc()?

*==========================================================================
***************************** Distributions *******************************
*==========================================================================

*--------------------------------------------------------------------------
** Missing Values
*--------------------------------------------------------------------------

** Variables with all observations missing  

qui nmissing, min(*) //this will list variables that have all values missing 

foreach i of varlist `r(varlist)' { 
	di "`i'"
}

** Missing value percentages for remaining variables (which don't have all values missing)
	
local w "`r(varlist)'" 	// storing the result of the nmissing command above in w 
qui ds `w', not 
	local x "`r(varlist)'"

qui ds `x', has(type numeric)
display "Displaying percent missing in numeric variables"
mdesc `r(varlist)', ab(32) 

qui ds `x', has(type string)
display "Displaying percent missing in non-numeric variables"
mdesc `r(varlist)', ab(32) 

*--------------------------------------------------------------------------
** Number of distinct values
*--------------------------------------------------------------------------

// Pay attention to variables with very few distinct values. 
// Lack of variation in variables is an important flag to be raised and discussed with the PIs. 

foreach var of varlist _all { 
	qui ta `var' 
	if `r(N)' != 0 {
	di "`var'{col 32}" %10.0f r(r) %10.0f r(N) // displays three columns: varname, no. of distinct obs, total obs
	}
}
 
*--------------------------------------------------------------------------
** Distribution of specific coded values (don't know, refused, other etc.)
*--------------------------------------------------------------------------

/* Checking distributions across all variables / major variables let us know critical problems with one/ more variable. 
Also, at a very early stage, the distributions help us detect problem with the survey design / data collection. 
This is one of the most important daily checks. */

qui ds, has(type numeric)
foreach var of varlist `r(varlist)' {
	qui count if `var' == 120  		//"-999" is used as and example. Run this for all the codes in your survey
	di "'-999' in `var'{col 32}" %10.2f (r(N)/c(N))*100 "%"
}
 
qui ds, has(type string)
foreach var of varlist `r(varlist)' {
	qui count if `var' == "-999" 		//"-999" is used as and example. Run this for all the codes in your survey
	di "'-999' in `var'{col 32}" %10.2f (r(N)/c(N))*100 "%"
}

*--------------------------------------------------------------------------
** Outliers
*--------------------------------------------------------------------------
qui ds deviceid subscriberid simid devicephonenum starttime endtime key submissiondate surveydate, not
qui ds `r(varlist)', has(type numeric) // or define numeric variables for which you want to detect outliers. 
											//Replace `r(varlist)' with variables of interest. 
											
//The loop below produces lists of outliers for each variable.   
foreach var of varlist `r(varlist)' { 
		qui sum `var' if `var' > 0 , d   // the expression `var' > 0 ignores codes for DK, Others, Refused etc., which should be negative integers
			gen sds = (`var' - r(mean))/(r(sd))
				list sds `unique' `enum' `var' if abs(sds) > 2 & !missing(`var') // the value of 2 sds is used here as an example. 
																				//You will have to come up with a suitable threshold for your data
		drop sds
	}

*==========================================================================
**************************** Survey Duration ******************************
*==========================================================================
/*
* Use the following four lines of code only if you haven't used the SurveyCTO generated .do file. 
	// Then replace the "starttime" and "endtime" variables in duration calculations below with "start" and "end"
gen start = clock(starttime,"MDYhms",2025)
    format %tc start

gen end = clock(endtime,"MDY",2025)
    format %tc end
*/

** Calculating duration 

gen t = endtime - starttime
	gen duration = round(t/(1000*60),1) // duration in minutes
	drop t


qui sum duration, d
	gen sds = (duration - r(mean))/r(sd) 

di "Unusually short or long survey duration:" 
list `unique' `enum' duration if abs(sds) > 2 & duration != . , abbr(32)	// the value of 2 sds is used here as an example. 
																			//You will have to come up with a suitable threshold for your data
	drop sds 

*==========================================================================
*************************** Enumerator Checks *****************************
*==========================================================================

* As a practice, we should look at enumerator level checks. Also, we may extend this for enumerator pairs or enumerator teams.

*--------------------------------------------------------------------------
** Enumerator level average survey duration
*--------------------------------------------------------------------------

bys surveyor_id: egen enum_avg_dur = mean(duration)
qui sum duration, d 
	gen overall_avg_dur = r(mean)
	gen diff_avg_dur = enum_avg_dur - r(mean)
	gen perc_diff_avg = (diff_avg_dur/r(mean))*100

egen tag_enum = tag(enum)

list surveyor_id enum_avg_dur overall_avg_dur perc_diff_avg if tag
	drop enum_avg_dur overall_avg_dur perc_diff_avg diff_avg_dur tag

*--------------------------------------------------------------------------
** Enumerator level distribution checks
*--------------------------------------------------------------------------

** Missing Values
	
qui ds location_code  	// replace ### with names of variables for which you want to run this check
display "Displaying percent missing in numeric variables"
bys surveyor_id: mdesc `r(varlist)', ab(32) 


** Number of distinct values

foreach var of varlist starttime {	 		// replace ### with names of variables for which you want to run this check
	qui ta `var' 
	if `r(N)' != 0 {
	di "`var'{col 32}" %10.0f r(r) %10.0f r(N) // displays three columns: varname, no. of distinct obs, total obs
	}
}
 
** Distribution of specific coded values (don't know, refused, other etc.)

foreach var of varlist ### {	 		// replace ### with names of numeric variables for which you want to run this check
	qui count if `var' == -999   		// "-999" is used as and example. Run this for all the codes in your survey
	di "'-999' in `var'{col 32}" %10.2f (r(N)/c(N))*100 "%"
}
 
foreach var of varlist ### {			// replace ### with names of string variables for which you want to run this check
	qui count if `var' == "-999"  		//"-999" is used as and example. Run this for all the codes in your survey
	di "'-999' in `var'{col 32}" %10.2f (r(N)/c(N))*100 "%"
}



*==========================================================================
***************************** Productivity ********************************
*==========================================================================

*--------------------------------------------------------------------------
** Overall Productivity
*--------------------------------------------------------------------------

qui bys surveydate: gen daily_avg = _N 
qui egen tag = tag(surveydate) 

* Question 5 : What is an alternate way to do this?

// Summary of daily average productivity: 
sum daily_avg if tag 
drop tag daily_avg

** Overall Productivity histogram 

qui sum surveydate

#delimit ; 
histogram surveydate, freq discrete fcolor(emidblue) width(1) lw(none) lc(white)
	xtitle(Date, height(6) si(small)) 
	ytitle(Number of Surveys, height(6) si(small)) ylabel(0 (20) 140, labsize(vsmall)) xsize(20) ysize(12)
	tlabel(`r(min)' (7) `r(max)', labsize(vsmall)) title(Surveys Per Day, si(medsmall) m(medium) c(black)) 
	scheme(vg_outc) plotr(m(zero) ifc(white)) aspect(.4);
#delimit cr
	// Using just the first line -- histogram surveydate, freq -- will also produce a graph. The remaining part of the code is 
	// for formatting. Refer to graph twoway options in help to understand formatting. 

*--------------------------------------------------------------------------
** Enumerator level productivity
*--------------------------------------------------------------------------

egen tag = tag(surveyor_id surveydate)
egen days_worked = total(tag), by(surveyor_id)

bys surveyor_id: gen total_surveys_done = _N

gen daily_avg = round(total_surveys_done/days_worked, .01) 
// average productivity per day by surveyor :- 
tabdisp surveyor_id, c(days_worked total_surveys_done daily_avg) format(%9.2f) center


qui sum daily_avg if tag, d
qui gen sds = (daily_avg - r(mean))/r(sd) 

qui egen tag2 = tag(surveyor_id)
// Surveyors with very low or high productivity :-
list surveyor_id daily_avg if (abs(sds) > 2 & daily_avg != .) & tag2, abbr(24)	// the value of 2 sds is used here as an example. 
																				//You will have to come up with a suitable threshold for your data

drop tag days_worked total_surveys_done daily_avg sds tag2 

* Question 6 : We have been using -999 as an example code throughout this template? Can you give some cases where responses needs to be specially coded like this?

/* Question 7: When dealing with live survey data, the default columns starttime and endtime can be very deceptive sometimes. 
               Can you think about what problem may arise and how do you go about solving the same? */

*--------------------------------------------------------------------------
**Answers
*--------------------------------------------------------------------------

/*

Answer 1:

An ado-file defines a Stata command, but not all Stata commands are defined by ado-files.
When you type summarize to obtain summary statistics, you are using a command built into
Stata. An ado-file is a text file that contains a Stata program. When you type a command that Stata does
not know, it looks in certain places for an ado-file of that name. If Stata finds it, Stata loads and
executes it, so it appears to you as if the ado-command is just another command built into Stata.

See: http://www.stata.com/manuals13/u17.pdf

Answer 2: 

Type 
       -help mdesc- 
       -help nmissing-
	   
Answer 3: 

Type

 -misstable pat surveyor_id-

 Missing-value patterns
     (1 means complete)

              |   Pattern
    Percent   |  1
  ------------+-------------
      100%    |  1
              |
       <1     |  0
  ------------+-------------
      100%    |

  Variables are  (1) surveyor_id

Answer 4:

cofd() of 17,126 (21nov2006) returns 1,479,686,400,000 (21nov2006 00:00:00).
Function dofc() of 1,479,736,920,000 (21nov2006 14:02) returns 17,126 (21nov2006).
 
Answer 5:
 
*qui gen surveydate = dofc(endtime) //you can use starttime too, instead

Answer 6: 

There might be various cases where you would need coding in response to a specific answer. 
For example, refusing to answer a question may be coded with a special negative number. 
Similarly, you might also want to specially code "don't know" as a response.

Answer 7:

SurveyCTO generally updates the time related variables when you change the survey at 
a later time and date. So, it is better to create two dummy variable for start time and end time and do all the checks for date and time.
