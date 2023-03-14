*q4

clear 
cd "/Users/al/ppol768-spring23/Class Materials/week-05/03_assignment/01_data"

use q1_psle_student_raw, clear

gen subject_position= strpos(s, "SUBJECTS")
replace s= substr(s, strpos(s, "SUBJECTS"), .)
split s, parse("</TD></TR>")
*attempt to separate the text
gen serial = _n
drop s
reshape long s, i(serial) j(j)
*generate a serial number in order to reshape 
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")
*get rid of special keys by replacing them with space and then get rids of the generated space
foreach var of varlist _all {
    capture assert missing(`var')
    if _rc == 0 {
        drop `var'
    }
}
*construct a test for missing value if the variable has missing value, it would be asserted to be 0, then drop all that being asserted to be 0. 
drop s s1
drop if missing(s5)
rename (s5 s10 s15) (CAND_NO Prem_NO SEX)
*cleaning
forvalues i=30 (3) 45{
	replace s`i'=substr(s`i',1,1)
}
*grades all has a comma in the end, so get rids of the comma witha a loop. 
rename (s30 s33 s36 s39 s42 s45 s49) (Kiswahili English Maarifa Hisabati Science Uraia Average_Grade)
gen Candidate_Name=s21+"_"+s22+"_"+s23
order Candidate_Name, after(SEX)
keep CAND_NO Prem_NO SEX Candidate_Name Kiswahili English Hisabati Science  Uraia Average_Grade
*some basic cleaning and tidying up. 
