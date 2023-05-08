********************************************************************************

*Question 1

*******************************************************************************
 
 use "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q1_village_pixel.dta"
 

*A) 
sort village

by pixel(payout), sort: gen pixel_consistent = payout[1] != payout[_N] 

*B)

by village(pixel), sort: gen pixel_village= pixel[1]!=pixel[_N]

browse village pixel_village

list village pixel if pixel_village

*C)

gen household_type=1 if pixel_village==0
replace household_type=2 if pixel_village==1 & pixel_consistent==0
replace household_type=3 if pixel_village==1 & pixel_consistent==1





********************************************************************************

*Question 2

********************************************************************************
clear all 
tempfile table21
save `table21', replace emptyok

forvalues i=1/135 {
	import excel "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx", sheet("Table `i'") firstrow clear allstring

	keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' 
	save `table21', replace //saving the tempfile so that we don't lose any data
}

use `table21'
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

drop table21
drop table

egen everything = concat(*),p(|)
replace everything = subinstr(everything," ","",.)
replace everything = subinstr(everything,"-","",.)

replace everything = "|" + everything

forvalues i= 1/135{
	replace everything = subinstr(everything,"||","|",.)
}

split everything, parse("|")

ren everything2 totalpop
ren everything3 allcnicard
ren everything4 allcninocard
ren everything5 malepop
ren everything6 cnimalecard
ren everything7 cnimalenocard
ren everything8 femalepop
ren everything9 cnifemalecard
ren everything10 cnifemalenocard
ren everything11 transpop
ren everything12 cnitranscard
ren everything13 cnitransnocard

forvalues i= 1/135{
	replace everything = subinstr(everything,"||","|",.)
}

drop B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC everything everything1


********************************************************************************

/*Question 3

********************************************************************************
Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score.
Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score
 
 5) rank (highest score =>1, lowest => 128)*/

use "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q3_grant_prop_review_2022.dta"

egen stand_r1_score = std(Review1Score)

egen stand_r2_score = std(Reviewer2Score)

egen stand_r3_score = std(Reviewer3Score)

egen average_stand_score = std(AverageScore)

gen standardscore= stand_r1_score+ stand_r2_score +stand_r3_score +average_stand_score

egen rank= rank(standardscore)

********************************************************************************

*Question 4 

********************************************************************************
clear 
use "/Users/diana/Desktop/Github/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q4_Tz_student_roster_html.dta"
 
 split s, parse(">PS")
 
 gen serial = 1
 drop s 
 reshape long s, i(serial) j(student) //j is the name of the new variable 
 
 *look at what the columns are separated by 
 
 split s, parse("<")
 
 keep s1 s6 s11 s16 s21 
 drop in 1 
 
 ren (s1 s6 s11 s16 s21) (candm prem sex name subjects)
 
 compress
 
 replace candm= "PS" + candm
 
 replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
 
 replace sex = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
 
 replace name = subinstr(name,`"P>"',"",.)  
 
 replace subjects = subinstr(subjects, `"P ALIGN="LEFT">"',"",.)
 
 compress
 
 split subjects , parse (",")
 
 
 
 foreach var of varlist subjects* {
 	replace `var' = substr(`var', -1,.)
 }

 compress 
 
 drop subjects 
 ren subjects1 Kiswahili 
 ren subjects2 English 
 ren subjects3 Maarifa 
 ren subjects4 Hisabati 
 ren subjects5 Science
 ren subjects6 Uraia
 ren subjects7 Average
 
 



