* import_lg94_w07_form.do
*
* 	Imports and aggregates "lg94 W07 Form" (ID: lg94_w07_form) data.
*
*	Inputs:  "lg94 W07 Form_WIDE.csv"
*	Outputs: "lg94 W07 Form.dta"
*
*	Output by SurveyCTO April 29, 2023 10:30 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "lg94 W07 Form_WIDE.csv"
local dtafile "lg94 W07 Form.dta"
local corrfile "lg94 W07 Form_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid name email_id calculate_email_id country city yearsgraduation university_roster_count university_index_* university_name_*"
local text_fields2 "university_country_* university_country_label_* sensitive_calculate instanceid"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable name "What is your name?"
	note name: "What is your name?"

	label variable email_id "What is your email?"
	note email_id: "What is your email?"

	label variable country "In which country were you born?"
	note country: "In which country were you born?"

	label variable city "What is the name of the city or village where you were born?"
	note city: "What is the name of the city or village where you were born?"

	label variable college "Did you obtaining a bachelor's degree?"
	note college: "Did you obtaining a bachelor's degree?"
	label define college 1 "Yes" 0 "No"
	label values college college

	label variable collegegraduation "What year did you graduate from college or university?"
	note collegegraduation: "What year did you graduate from college or university?"

	label variable confirm_graduation "So you graduated approximately \${yearsgraduation} years ago"
	note confirm_graduation: "So you graduated approximately \${yearsgraduation} years ago"
	label define confirm_graduation 1 "Yes" 0 "No"
	label values confirm_graduation confirm_graduation

	label variable university "Did you attend more than one college or university during your Bachelors Degree?"
	note university: "Did you attend more than one college or university during your Bachelors Degree?"
	label define university 1 "Yes" 0 "No"
	label values university university

	label variable university_n "How many Colleges or Universities did you go to during your Bachelors' Degree?"
	note university_n: "How many Colleges or Universities did you go to during your Bachelors' Degree?"

	label variable treatment "Please indicate the number of experiences you have had during college from the f"
	note treatment: "Please indicate the number of experiences you have had during college from the following list: I made new friends. I went to a house-party. I joined a student organization. I was raped."

	label variable control "Please indicate the number of experiences you have had during college from the f"
	note control: "Please indicate the number of experiences you have had during college from the following list: I made new friends. I went to a house-party. I joined a student organization."



	capture {
		foreach rgvar of varlist university_name_* {
			label variable `rgvar' "What is the name of your university number \${university_index}?"
			note `rgvar': "What is the name of your university number \${university_index}?"
		}
	}

	capture {
		foreach rgvar of varlist university_country_* {
			label variable `rgvar' "In which country is \${university_name}?"
			note `rgvar': "In which country is \${university_name}?"
		}
	}

	capture {
		foreach rgvar of varlist university_satisfaction_* {
			label variable `rgvar' "How would you rate the quality of teaching received at \${university_name}?"
			note `rgvar': "How would you rate the quality of teaching received at \${university_name}?"
			label define `rgvar' 0 "very poor" 1 "poor" 2 "fair" 3 "good" 4 "very good" 5 "excellent" 6 "exceptional"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist country_satisfaction_* {
			label variable `rgvar' "How would you rate your overall experience in \${university_country_label} durin"
			note `rgvar': "How would you rate your overall experience in \${university_country_label} during your time studying at \${university_name}?"
			label define `rgvar' 0 "very poor" 1 "poor" 2 "fair" 3 "good" 4 "very good" 5 "excellent" 6 "exceptional"
			label values `rgvar' `rgvar'
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  lg94 W07 Form_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
