clear
cd "C:\Users\yaphe\OneDrive\Documents\ppol768-spring23\Class Materials\week-05\03_assignment\01_data"
import excel q4_Tz_election_2010_raw
gen n=_n
drop if n<5
encode A, gen(region)
encode B, gen(district)
encode C, gen(constituency)
encode D, gen(ward)
drop A B C D
rename H political_party
rename I votes
drop if n < 7
*just properly name variables that needed for this table
replace region = region[_n-1] if missing(region)
replace district=district[_n-1] if missing(district)
replace constituency=constituency[_n-1] if missing(constituency)
replace ward=ward[_n-1] if missing(ward)
*fill the missing values as region district and constituency only appear for the first one in that group.
fillin ward political_party
by ward E, sort: gen nvals=_n==1
by ward: replace nvals=sum(nvals)
by ward: replace nvals= nvals[_N]-1
rename nvals total_candidates
*find the number of total candidates by finding distinct number for votes and minus the sum of it by 1 as missing also counts as a distinct value
drop E F G J K n 
drop _fillin
*get rid of unwanted variables
bysort ward: replace region =region[18] if missing(region)
bysort ward: replace district =district[18] if missing(district)
bysort ward: replace constituency =constituency[18] if missing(constituency)
*fill the missing value again as the filling creates missing values. for some reason all non missing values are in the last. hence i was able to set region/district/constituency equal to the 18th value in each group and get the desirable result. However, i wanted to replace them with the first non-missing value, but cannot figure out how to do that. 
encode political_party, gen(party_code)
encode votes, gen(votes_nonstr)
replace votes_nonstr=. if votes_nonstr==2428
decode votes_nonstr, gen (votes1)
replace votes=votes1
destring votes, replace
drop votes_nonstr votes1
*some votes have unopposed as value, I replace them by missing through encode and replace it=missing if the code is 2428 which is the code for unopposed. However, the encoded values is bit messy. So i convert it back to string then destring it and now the numerical values are just the numbers themselvs. 
reshape wide votes, i(ward) j(party_code)
*tried to reshape it to wide using party_code as the j. However, it cannot do. 
