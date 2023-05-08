clear
cd "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"
import excel q4_Tz_election_2010_raw
gen n=_n
drop if n<7
rename (A B C D E H I ) (region district constituency ward candidate political_party TTL_Votes)
keep region district constituency ward candidate political_party TTL_Votes
*just properly name variables that needed for this table and drop else
replace region = region[_n-1] if missing(region)
replace district=district[_n-1] if missing(district)
replace constituency=constituency[_n-1] if missing(constituency)
replace ward=ward[_n-1] if missing(ward)
*fill the missing values as region district and constituency only appear for the first one in that group.
by ward candidate, sort: gen nvals=_n==1
by ward: replace nvals=sum(nvals)
by ward: replace nvals= nvals[_N]
rename nvals total_candidates
*find the number of total candidates by finding distinct number for votes and minus the sum of it by 1 as missing also counts as a distinct value
*get rid of unwanted variables
replace TTL_Votes="" if TTL_Votes=="UN OPPOSSED"
destring TTL_Votes, replace
bysort ward: egen votes=sum(TTL_Votes)
*clean up votes for each candidate to get the total votes 
drop TTL_Votes
replace political_party=subinstr(political_party," ","",.)
replace political_party=subinstr(political_party,"-","",.)
reshape wide votes, i(ward candidate) j(political_party) string 
*get rid of the symblols that stata cannot read for reshaping, and then reshape.
order region district constituency ward candidate
 global vars "votesAFP votesAPPTMAENDELEO votesCCM votesCHADEMA votesCHAUSTA votesCUF votesDP votesJAHAZIASILIA votesMAKIN votesNCCRMAGEUZI votesNLD votesNRA votesSAU votesTADEA votesTLP votesUDP votesUMD votesUPDP"


 foreach v of varlist $vars {

 bysort region district constituency ward: egen `v'_10 = sum(`v')

     }
	* add _10 label as the sample to indicate it is the 2010 election.
duplicates drop region district constituency ward, force
* I kept all the candidates, so there are mandy duplicate values for each ward. 
drop votesAFP votesAPPTMAENDELEO votesCCM votesCHADEMA votesCHAUSTA votesCUF votesDP votesJAHAZIASILIA votesMAKIN votesNCCRMAGEUZI votesNLD votesNRA votesSAU votesTADEA votesTLP votesUDP votesUMD votesUPDP
 foreach v of varlist  votesAFP_10 votesAPPTMAENDELEO_10 votesCCM_10 votesCHADEMA_10 votesCHAUSTA_10 votesCUF_10 votesDP_10 votesJAHAZIASILIA_10 votesMAKIN_10 votesNCCRMAGEUZI_10 votesNLD_10 votesNRA_10 votesSAU_10 votesTADEA_10 votesTLP_10 votesUDP_10 votesUMD_10 votesUPDP_10 {

 replace `v' = . if `v'==0
     }
drop candidate 

*final cleaning up, convert the un opposed back to missing and drop unwanted vars.
