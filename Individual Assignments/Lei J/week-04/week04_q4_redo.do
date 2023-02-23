use q4_Tz_student_roster_html, clear
gen subject_position= strpos(s, "Subject")
replace s= substr(s, strpos(s, "Subject"), .)
split s, parse("</TD></TR>")
gen serial = _n
drop s
reshape long s, i(serial) j(j)
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")
foreach var of varlist _all {
    capture assert missing(var)
    if !_rc {
        drop var
    }
}
*attemp to drop all empty variables, but lots of them cannot be drop as they contain something
drop s s1 s2 s3 s4
drop if missing(s5)
drop if j==1

rename s5 CAND_NO
drop s6 s7 s8 s9
rename s10 Prem_NO
drop s11 s12 s13 s14
rename s15 SEX
drop s16-s20
drop s24-s27
*drop empty values and gives variables proper names

replace s30=substr(s30,1,1)	
replace s33=substr(s33,1,1)	
replace s36=substr(s36,1,1)	
replace s39=substr(s39,1,1)
replace s42=substr(s42,1,1)	
replace s45=substr(s45,1,1)
*get rid of commas.  
drop s29 s32 s35 s38 s41 s44 s48
rename s30 Kiswahili
rename s33 English
rename s36 Maarifa 
rename s39 Hisabati 
rename s42 Science 
rename s45 Uraia 
rename s49 Average_Grade 
*rename all subjects 
gen Candidate_Name=s21+"_"+s22+"_"+s23
order Candidate_Name, after(SEX)
*combine names into one and put it in order
keep CAND_NO Prem_NO SEX Candidate_Name Kiswahili English Hisabati Science  Uraia Average_Grade
*ger rid of all unwanted variables. 