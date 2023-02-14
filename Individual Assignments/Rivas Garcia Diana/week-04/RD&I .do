/*Q1 : Crop Insurance in Kenya
You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)

b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.

c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:

I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.*/
 
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






*Question 2

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


destring B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC , replace
*This left M as a string so upon inspection, one of the values was - so cold not destring

destring M, ignore("-")replace
destring N O Q U, ignore("-" "...")replace
destring W, ignore("-")replace
----
local variables B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC

/*Question 3

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







