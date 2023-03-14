//example_sj_clrevmatch.do generates examples in Wasi and Flaaen (2014), Section 6//
//September 16, 2014

*clear
*global mypath "C:\Users\nwasi\Dropbox\HRSrecordlinkage"
*adopath ++ "$mypath\SJsubmission"
*cd "$mypath\SJsubmission"

**To be run if example_sj_stnd.do and example_sj_reclink2 were not run first
**--------------------------------------------------------------

**Specify Directory of Pattern Files (in case not already installed)
*local path1 "$mypath\HRSrecordlinkage\SJsubmission"
local path1 "/home/kbv/sj/software/reclink/"

use respondent_employers, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) patpath(`path1')
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save respondent_employers_stn.dta, replace

use firm_dataset, clear
stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) patpath(`path1')
stnd_address streetadd, gen(add1 pobox unit bldg floor) patpath(`path1')
save firm_dataset_stn.dta, replace

use respondent_employers_stn, clear
reclink2 stn_name add1 pobox city state using firm_dataset_stn, idm(rid) idu(firm_id) wmatch(10 8 6 5 5) gen(rlsc) many npairs(2)
save reclinking_forreview.dta, replace



//-------------------------clrevmatch-----------------------------------

clear
*capture sjlog close
*sjlog using "$mypath\SJsubmission\clrevmatch_a", replace
clrevmatch using reclinking_forreview, idm(rid) idu(firm_id) varM(stn_name add1 pobox city state) varU(Ustn_name Uadd1 Upobox Ucity Ustate) reclinkscore(rlsc) clrev_result(crev) clrev_note(crnote) replace
*sjlog close, replace
