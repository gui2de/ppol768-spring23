
tempfile newschools // Create a tempfile 


clear // Load dataset


	use "q1_psle_student_raw.dta", clear
	
	keep in 138

		do "week4" // Using the previous dofile from assignment 4 
		
	save newschools, replace

	use newschools // Open local file 
		
	drop if cand == "PS"
	
	rename (subjects1 subjects2 subjects3 subjects4 subjects5 subjects6 subjects7) (Kiswahili English Maarifa Hisabiti Science Uraia AverageGrade)
  
		replace prem = subinstr(prem, `"BODY TEXT="#000080" LINK="#0000ff" VLINK="#800080" BGCOLOR= "LIGHTBLUE">"', "",.) // This and the next few lines of code substitute the original variable with nothing and returns nothing

		replace sex = subinstr(sex, `"P ALIGN="LEFT"  > PSLE 2021 EXAMINATION RESULTS"', "",.)
	
		replace name = subinstr(name, `"/"', "",.)
		
		save newschools, replace 
	