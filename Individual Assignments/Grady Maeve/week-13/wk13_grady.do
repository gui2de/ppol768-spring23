/*using itestform to adjust survey form*/
*Maeve Grady - week 13

global wd "C:/Users/Maeve/GitHub/ppol768-spring23/Individual Assignments/Grady Maeve/week-13"

ietestform using "$wd/cmg_wk07_Survey.xlsx" , reportsave("$wd/report.csv") replace

/*the ietest form check alerted me to an old list of choices that i no longer use, a trailing space in one list option, and to two fields that I had forgotten to mark as required. I have corrected those errors. In addition to that it flagged that the state value is a string (that's because the value is imported from a dataset), and that I don't have stata labels in either the choice or survey sheet. For now, I am not adding stata labels.