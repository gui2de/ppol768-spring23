cd "/Users/al/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"
use q4_Tz_student_roster_html, clear
gen subject_position= strpos(s, "SUBJECT")
replace s= substr(s, strpos(s, "SUBJECT"), .)
split s, parse("</TD></TR>")
gen serial = _n
drop s
reshape long s, i(serial) j(j)
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")
foreach var of varlist _all {
    capture assert missing(`var')
    if _rc==0 {
        drop `var'
    }
}
 *drop all empty variables
drop if j==1
drop serial j subject_position s s1 s2 s3 
rename s5 CAND_NO
drop  s7 s8
rename s10 Prem_NO
drop s12 s13
rename s15 SEX
drop s17 s19
drop s25 s26
*drop empty values and gives variables proper names

forvalues i=30 (3) 45{
	replace s`i'=substr(s`i',1,1)
}
*get rid of commas.  
drop s29 s32 s35 s38 s41 s44 s48
rename (s30 s33 s36 s39 s42 s45 s49) (Kiswahili  English  Maarifa Hisabati Science Uraia Average_Grade) 
*rename all subjects 
gen Candidate_Name=s21+"_"+s22+"_"+s23
order Candidate_Name, after(SEX)
*combine names into one and put it in order
keep CAND_NO Prem_NO SEX Candidate_Name Kiswahili English Hisabati Science  Uraia Average_Grade
*ger rid of all unwanted variables. 
