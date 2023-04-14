**Question 1 
**This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

split s, parse(">PS")

gen serial = _n 

drop s 

reshape long s, i(serial) j(student)

split s, parse("<")

keep s1 s6 s11 s16 s21
drop in 1 

ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)

compress 

replace cand = "PS" + cand 
replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)


split subjects, parse(",")
compress 

drop subjects
foreach var of varlist subjects* {
	replace `var' = substr(`var',-1,.)
	}

compress 
