
// Week 4 Do File

clear 

global wd "C:\Users\maxis\Documents\Stata\04-week\"
global w4q1 "$wd\q1_village_pixel.dta"
global w4q3 "$wd\q3_grant_prop_review_2022.dta"
global w4q4 "$wd\q4_Tz_student_roster_html.dta"


* Question 1a
	use "$w4q1", clear
	tab pixel payout
	gen pixel_payout = 0
	
* Question 1b

	encode pixel, gen(pixelnumber)

	bysort village: egen pmax = max(pixelnumber)
	bysort village: egen pmin = min(pixelnumber)

	    gen pixel_village = 0 if pmax == pmin
	replace pixel_village = 1 if pmax != pmin
	
	sum pixel_village, d
	
* Question 1c

	gen hhstatus = 1
	replace hhstatus = 2 if pixel_village == 1

	clear 
* Question 2a

	global excel_t21 "$wd\q2_Pakistan_district_table21.xlsx"

	clear
	tempfile table21
	save `table21', replace emptyok

forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring 	//import
	display as error `i' 										//display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 		// keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 													//there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

clear 
* Question 3

    use "$w4q3", clear
    encode Rewiewer1, gen (r1)
	encode Reviewer2, gen (r2)
	encode Reviewer3, gen (r3)
	
	rename Reviewer2Score Review2Score
	rename Reviewer3Score Review3Score

	bysort r1: egen mean1 = total(Review1Score/_N)
	bysort r2: egen mean2 = total(Review2Score/_N)
	bysort r2: egen mean3 = total(Review3Score/_N)

	bysort r1: egen sd1 = sd(Review1Score)
	bysort r2: egen sd2 = sd(Review2Score)
	bysort r2: egen sd3 = sd(Review3Score)

	gen stand_r1_score = (Review1Score - mean1) / (sd1)
	gen stand_r2_score = (Review2Score - mean2) / (sd2)
	gen stand_r3_score = (Review3Score - mean3) / (sd3)


* Question 4

//create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

	use "$w4q4", clear
	
	split s, parse(">PS")
	
	gen id = _n
	order id, first
	drop s
	
	reshape long s, i(id) j(student)
	split s, parse("<")
	
	keep s1 s6 s11 s16 s21
	drop in 1
	
	ren (s1 s6 s11 s16 s21) (cand_id prem_number sex names subjects)
	compress

	replace cand = "PS" + cand_id
	replace prem = subinstr(prem, "P ALIGN="CENTER">","",.)
	replace prem = subinstr(prem, `"""',  "", .)
	replace prem = subinstr(prem, "CENTER>" ,"",.)
	
	replace sex = subinstr(sex, "P ALIGN="CENTER">","",.)
	replace sex = subinstr(sex, `"""',  "", .)
	replace sex = subinstr(sex, "CENTER>" ,"",.)
	
	replace names = subinstr(names, "P>" ,"",.)
	
	replace subj = subinstr(subj, "P ALIGN="LEFT">","",.)
	replace subj = subinstr(subj, `"""',  "", .)
	replace subj = subinstr(subj, "LEFT>" ,"",.)
	
	generate Kiswahili = substr(subj, 13,1)
	generate English = substr(subj, 26,1)
	generate maarifa = substr(subj, 39,1) 
	generate hisabati = substr(subj,53,1) 
	generate science = substr(subj, 66,1) 
	generate uraia = substr(subj, 77,1) 
	generate average = substr(subj, -1,1) 
	



