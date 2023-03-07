global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week-04"
global q1 "$wd/q1_village_pixel.dta"
global q3 "$wd/q3_grant_prop_review_2022.dta"
global q4 "$wd/q4_Tz_student_roster_html.dta"
use "$q4", clear
replace s = substr(s, strpos(s, "SUBJECT"), .)
*split each line 
split s, parse("</TD></TR>") 
gen serial = _n
drop s 
reshape long s, i(serial) j(observation)
