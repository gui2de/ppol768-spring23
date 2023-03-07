//example_sj_stnd.do generates examples in Wasi and Flaaen (2014), Sections 2 and 3//
//September 16, 2014

*clear
*global mypath "C:\Users\nwasi\Dropbox\HRSrecordlinkage"
*adopath ++ "$mypath\SJsubmission"
*cd "$mypath\SJsubmission"

**Specify Directory of Pattern Files (in case not already installed)
*local path1 "$mypath\SJsubmission\PatternFiles"

//-------------------------name-----------------------------------

*capture log close
*sjlog using "$mypath\SJsubmission\ex_stndcompname1", replace
use respondent_employers, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) 
list firm_name stn_name stn_dbaname entitytype
*sjlog close, replace


*sjlog using "$mypath\SJsubmission\ex_stndcompname2", replace
use firm_dataset, clear
list firm_name
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)
list stn_name stn_dbaname entitytype 
list stn_name stn_fkaname attn_name
*sjlog close, replace


//-------------------------address-----------------------------------
*capture log close
*sjlog using "$mypath\SJsubmission\ex_stndadd1", replace
use respondent_employers, clear
list streetadd
stnd_address streetadd, gen(add1 pobox unit bldg floor) 
list add1-floor
*sjlog close, replace

*capture log close
*sjlog using "$mypath\SJsubmission\ex_stndadd2", replace
use firm_dataset, clear
list streetadd
stnd_address streetadd, gen(add1 pobox unit bldg floor) 
list add1-floor
*sjlog close, replace



//------------Standardize Both Datasets for Subsequent Steps ----------------
use respondent_employers, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) 
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save respondent_employers_stn, replace

use firm_dataset, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) 
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save firm_dataset_stn, replace
