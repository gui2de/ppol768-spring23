//example_sj_reclink2.do generates examples in Wasi and Flaaen (2014), Section 5 //
//September 16, 2014

clear
*global mypath "C:\Users\nwasi\Dropbox\HRSrecordlinkage"
*adopath ++ "$mypath\SJsubmission"
*cd "$mypath\SJsubmission"

**To be run if example_sj_stnd.do was not run first
**--------------------------------------------------------------
**Specify Directory of Pattern Files (in case not already installed)

/*
local path1 "$mypath\HRSrecordlinkage\SJsubmission"

use respondent_employers, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) patpath(`path1')
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save respondent_employers_stn.dta, replace

use firm_dataset, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) patpath(`path1')
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save firm_dataset_stn.dta, replace
*/



//-------------------------reclink2-----------------------------------
//example 1: neither manytoone nor npair() is specified.
*capture sjlog close
*sjlog using "$mypath\SJsubmissionl\reclinkOne_a", replace
sjlog using reclink4, replace
use respondent_employers_stn, clear
reclink2 stn_name add1 pobox city state using firm_dataset_stn, idm(rid) idu(firm_id) wmatch(10 8 6 5 5) gen(rlsc)
sort rid
format rlsc %5.3f
list rid stn_name add1 Ustn_name Uadd1 rlsc, sep(4) noobs
sjlog close, replace

//example 2: manytoone option is specified.
*capture log close
*sjlog using "$mypath\SJsubmission\reclinkMany_a", replace
sjlog using reclink5, replace
use respondent_employers_stn, clear
reclink2 stn_name add1 pobox city state using firm_dataset_stn, idm(rid) idu(firm_id) wmatch(10 8 6 5 5) gen(rlsc) many
sort rid
format rlsc %5.3f
list rid stn_name add1 Ustn_name Uadd1 rlsc, sep(4) noobs
sjlog close, replace

//example 3: both manytoone and npair() options are specified.
*sjlog using "$mypath\SJsubmission\reclinkMany_b", replace
sjlog using reclink6, replace
use respondent_employers_stn, clear
reclink2 stn_name add1 pobox city state using firm_dataset_stn, idm(rid) idu(firm_id) wmatch(10 8 6 5 5) gen(rlsc) many npairs(2)
format rlsc %5.3f
list rid stn_name add1 Ustn_name Uadd1 rlsc, sep(4) noobs
*sjlog close, replace
save reclinking_forreview.dta, replace
sjlog close, replace
