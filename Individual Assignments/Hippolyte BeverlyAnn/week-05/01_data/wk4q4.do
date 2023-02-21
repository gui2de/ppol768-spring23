split s, parse(">PS") // Split the string using ">PS" as the indicator of where we would like to begin the split.

	gen serial = _n       // this helps us generate a unique identifier when we reshape the data 
		drop s
	
	reshape long ///
		s , i(serial) j(student)

	split s , parse ("<")		// Split the string again using the indicator "<"
		keep  // Keep the columns that are relevant to the table
		drop in 1              // 
	
	rename (s1 s6 s11 s16 s21) (cand prem sex name subjects) // renamed each column
	
	compress 					// shortened the length of some of the string by reducing the number of characters; specficially prem and sex
	
	replace cand = "PS" + cand // cand is numeric so adding PS helps display the unique candidate number for each student 
	replace prem = subinstr(prem, `"P ALIGN="CENTER">"', "",.) // This and the next few lines of code substitute the original variable with nothing and returns nothing
	replace sex = subinstr(sex, `"P ALIGN="CENTER">"', "",.)   // This helps clean the data in the table and removing unnecessary characters in the columns and rows 
	replace name = subinstr(name, `"P>"', "",.)
	replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"', "",.)

	split subject , parse(",") // we split the variable "subject" into each individual subject; 
							//	the comma is the character used to identify where to in the string we should split

	foreach var in varlist subject* {  // for each variable in the list of subjects 
		replace `'"var " = substr(`'var', -1, .)
	}
	
	compress
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6) (Kiswahili English Maarifa Hisabiti Uraia AverageGrade)
	rename (Uraia AverageGrade subjects7) (Science Uraia AverageGrade)
