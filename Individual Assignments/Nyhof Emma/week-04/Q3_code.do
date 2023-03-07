clear
cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-04\"

use "q3_grant_prop_review_2022.dta"

*Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)

rename Review1Score Reviewer1Score

forvalues i = 1/3 {
	gen stand_r`i'_score = (Reviewer`i'Score - AverageScore)/StandardDeviation
}

egen average_stand_score = rowmean(stand*)

gsort - average_stand_score
gen rank = _n