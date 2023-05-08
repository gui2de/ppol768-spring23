*## Q4 : Student Data from Tanzania

*Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from [Tanzania's government website](https://onlinesys.necta.go.tz/results/2021/psle/results/shl_ps0101114.htm). Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

*use q1_psle_student_raw, clear

split s, parse(">PS") 

gen serial = _n
*Serial can be anything, as we only have 1 row, so don't need to worry about its identifier  
	drop s

reshape long s ///  
	, i(serial) j(student)

split s, parse("<")
	keep s1 s6 s11 s16 s21
	drop in 1 
	
	rename (s1 s6 s11 s16 s21) /// 
		(cand prem sex name subjects)
		
		compress 
		
	replace cand = "PS" + cand 
	replace prem = subinstr(prem, `"P ALIGN="CENTER">"' ,"", . )
	replace sex = subinstr(sex, `"P ALIGN="CENTER">"' ,"", . )
	replace name = subinstr(name, "P>" ,"", . )
	replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"' ,"", . )
	*Note: . at the end denotes all instance of the text to be subbed out 

	split subjects, parse(",")
	drop subjects
	
	foreach var of varlist subjects* {
		replace `var' = substr(`var', -1, 1 )  
		*Get only the last character
	}
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6 subjects7) /// 
		(Kiswahili English Maarifa Hisabati Science Uraia Average_Grade)
		
		compress


