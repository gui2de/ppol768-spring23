capture program drop clean
program define clean

split s, parse(">PS")
gen serial = 26544
drop s
reshape long s, i(serial) j (student)
split s, parse("<")
keep s1 s6 s11 s16 s21
drop in 1
ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)
compress
replace cand = "PS"+cand //is the 0101114 supposed to be included? I can eliminate that
replace prem = subinstr(prem, `"P ALIGN="CENTER">"', "",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"', "",.)
replace name = subinstr(name, `"P>"', "",.)
replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"', "",.)
compress
split subject, parse(",")
foreach var of varlist subject* {
	replace `var' = substr(`var',-1,.)
}
drop subjects
rename subjects1 Kiswahili
rename subjects2 English
rename subjects3 maarifa
rename subjects4 hisabati
rename subjects5 science
rename subjects6 uraia
rename subjects7 average

compress
end



/*split s, parse(">PS")
gen serial = 26544
drop s
reshape long s, i(serial) j (student)
split s, parse("<")
keep s1 s6 s11 s16 s21
drop in 1
ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)
compress
replace cand = "PS"+cand
replace prem = subinstr(prem, `"P ALIGN="Center">"',"",.)
replace sex = subinstr(sex, `"P ALIGN="Center">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"',"",.)
compress
split subject, parse(",")
foreach var of varlist subject* {
	replace `var' = substr(`var',-1,.)
}*/
