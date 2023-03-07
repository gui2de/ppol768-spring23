	clear
	
	
	cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-04\"
	use "q4_Tz_student_roster_html.dta"


	split s, p("SUBJECTS")
	drop s1

	split s2, p("</TR>")
	drop s s2 s21 s218

	gen serial = _n
	reshape long s, i(serial) j(j)

	split s, p(">")

	keep s5 s10 s15 s20 s25

	forvalues i = 5(5)25 {
		split s`i', p("</FONT")
		drop s`i'
	}

	split s251, p(",")
	drop s251

	forvalues i = 11/17 {
		replace s25`i' = substr(s25`i', -1, .)
	}

	gen schoolcode = "PS0101114"
	rename s51 cand_id
	rename s101 prem_number
	rename s151 gender
	rename s201 name
	rename s2511 kiswahili_grade
	rename s2512 english_grade
	rename s2513 maarifa_grade
	rename s2514 hisabati_grade
	rename s2515 science_grade
	rename s2516 uraia_grade
	rename s2517 avg_grade
