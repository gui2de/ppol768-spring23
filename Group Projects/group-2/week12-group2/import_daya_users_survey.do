* import_daya_users_survey.do
*
* 	Imports and aggregates "Daya Users Survey" (ID: daya_users_survey) data.
*
*	Inputs:  "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-data//Daya Users Survey_WIDE.csv"
*	Outputs: "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/01-output//Daya Users Survey.dta"
*
*	Output by SurveyCTO April 16, 2023 11:33 PM.

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
local csvfile "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/01-data//Daya Users Survey_WIDE.csv"
local dtafile "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-output//Daya Users Survey.dta"
local corrfile "C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/01-data//Daya Users Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid name email region company product_type daya_time instanceid"
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
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
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
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
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


	label variable consent "This form will ask you individual questions regarding: personal information, you"
	note consent: "This form will ask you individual questions regarding: personal information, your experience using the tools provided by Daya, business activity, among other useful information that will enable us to measure the impact of Daya. Would you like to continue and fill it out?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable name "What is your name?"
	note name: "What is your name?"

	label variable age "What is your age?"
	note age: "What is your age?"

	label variable email "What is your email?"
	note email: "What is your email?"

	label variable marital_status "What is your marital status?"
	note marital_status: "What is your marital status?"
	label define marital_status 0 "Single" 1 "Married" 2 "Separated" 3 "Divorced"
	label values marital_status marital_status

	label variable region "What is your region?"
	note region: "What is your region?"

	label variable children "Do you have any children?"
	note children: "Do you have any children?"
	label define children 1 "Yes" 0 "No"
	label values children children

	label variable children_n "How many children do you have?"
	note children_n: "How many children do you have?"

	label variable mobile_ownership "Do you own a mobile phone?"
	note mobile_ownership: "Do you own a mobile phone?"
	label define mobile_ownership 1 "Yes" 0 "No"
	label values mobile_ownership mobile_ownership

	label variable simcard_ownership "Do you have a Mobile SIM Card?"
	note simcard_ownership: "Do you have a Mobile SIM Card?"
	label define simcard_ownership 1 "Yes" 0 "No"
	label values simcard_ownership simcard_ownership

	label variable company "What is your business name?"
	note company: "What is your business name?"

	label variable product_type "What product do you sell?"
	note product_type: "What product do you sell?"

	label variable employees "How many people (including you) work in your business?"
	note employees: "How many people (including you) work in your business?"

	label variable volunteers "Are any of these workers volunteers (non-paid)?"
	note volunteers: "Are any of these workers volunteers (non-paid)?"
	label define volunteers 1 "Yes" 0 "No"
	label values volunteers volunteers

	label variable volunteers_number "How many volunteers?"
	note volunteers_number: "How many volunteers?"

	label variable daya_time "How long have you been using Daya? (Specifiy if days, weeks or months)"
	note daya_time: "How long have you been using Daya? (Specifiy if days, weeks or months)"

	label variable daya_comfort "How comfortable do you feel using Daya?"
	note daya_comfort: "How comfortable do you feel using Daya?"
	label define daya_comfort 0 "Very comfortable" 1 "Somewhat comfortable" 2 "Not very comfortable" 3 "Not comfortable at all"
	label values daya_comfort daya_comfort

	label variable daya_happiness "Do you feel happier after using Daya?"
	note daya_happiness: "Do you feel happier after using Daya?"
	label define daya_happiness -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values daya_happiness daya_happiness

	label variable daya_bizeasy "Do you feel that daya has made your business management easier?"
	note daya_bizeasy: "Do you feel that daya has made your business management easier?"
	label define daya_bizeasy -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values daya_bizeasy daya_bizeasy

	label variable daya_stress "Do you feel less stressed about money?"
	note daya_stress: "Do you feel less stressed about money?"
	label define daya_stress -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values daya_stress daya_stress

	label variable family_resources "Do you feel like you can provide more resources to your family?"
	note family_resources: "Do you feel like you can provide more resources to your family?"
	label define family_resources -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values family_resources family_resources

	label variable business_expenditure "How much money did you spend in your business in the last four weeks?"
	note business_expenditure: "How much money did you spend in your business in the last four weeks?"

	label variable family_expenditure "How much money did you spend in family-related things in the last four weeks?"
	note family_expenditure: "How much money did you spend in family-related things in the last four weeks?"

	label variable hours_worked "How many hours did you work last week?"
	note hours_worked: "How many hours did you work last week?"

	label variable hours_family "How many hours did you spend in household activities last week (food preparation"
	note hours_family: "How many hours did you spend in household activities last week (food preparation, cleaning, laundry, gardening, etcterera)?"

	label variable hours_leisure "How many hours of leisure/ free time did you have last week? (Activities not rel"
	note hours_leisure: "How many hours of leisure/ free time did you have last week? (Activities not related to business, work, domestic chores, education, or any essential necessities)"

	label variable socialmedia_use "Do you believe that your business make a good use of social media for marketing "
	note socialmedia_use: "Do you believe that your business make a good use of social media for marketing purposes?"
	label define socialmedia_use -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values socialmedia_use socialmedia_use

	label variable digitaltools_storage "Do you believe that your business make a good use of excel or any other tool for"
	note digitaltools_storage: "Do you believe that your business make a good use of excel or any other tool for storing sales, expenses, revenue, etcetera?"
	label define digitaltools_storage -2 "Stronly disagree" -1 "Disagree" 0 "Neutral" 1 "Agree" 2 "Stronly agree"
	label values digitaltools_storage digitaltools_storage






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
*   Corrections file path and filename:  C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Research Design Implementation/week-12-practice/02-data//Daya Users Survey_corrections.csv
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
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
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
