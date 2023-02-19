*We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

*global wd "/Users/marlyn/GitHub/ppol768-spring23/Class Materials" 
*use "$wd/week-04/03_assignment/01_data/q4_Tz_student_roster_html.dta", clear

*Drop everything before the table starts and it starts at "SUBJECT"
replace s = substr(s, strpos(s, "SUBJECT"), .)

*Break data after each "row" or observation as seen in website 
split s, parse("</TD></TR>")

*Break into columns
gen observation = _n //label each observation with a number
drop s
reshape long s, i(observation) j(student_n)

*Drop last observation which has no data
drop if _n == _N | _n == 1 //dropping the first and last observations since they don't contain data we're interested in, they're just HTML text

*We can now split the data into neat text chunks
split s, parse(">") //this neatly splits the data and starts each of the columns where we want it (at the start of the word)

*I want to keep only the variables that have the data 
keep observation student_ s s5 s10 s15 s20 s25 //this keeps the variables we're interested in, which I saw were organized in increments of 5

*Cleaning up the variable strings
replace s5 = subinstr(s5,"</FONT","",.)
replace s10 = subinstr(s10,"</FONT","",.)
replace s15 = subinstr(s15,"</FONT","",.)
replace s20 = subinstr(s20,"</FONT","",.)
replace s25 = subinstr(s25,"</FONT","",.)

*Renaming variables to match their website names
rename (s5 s10 s15 s20 s25) (cand_number prem_number sex cand_name subject) 

*Then I want to split up the subject categories and grades further
split subject, parse(",")

*Then rename the columns for their subjects
rename subject1 Kiswahili 
rename subject2 English
rename subject3 Maarifa
rename subject4 Hisabati
rename subject5 Science
rename subject6 Uraia
rename subject7 Avg_Grade

*Then strip down data to only the letter grades
replace Kiswahili = subinstr(Kiswahili,"Kiswahili - ","",.)
replace English = subinstr(English, "English - ","",.)
replace Maarifa = subinstr(Maarifa, "Maarifa - ","",.)
replace Hisabati = subinstr(Hisabati, "Hisabati - ","",.)
replace Science = subinstr(Science, "Science - ","",.)
replace Uraia = subinstr(Uraia, "Uraia - ","",.)
replace Avg_Grade = subinstr(Avg_Grade, "Average Grade - ","",.)

*Parse out the school code and candidate number (this is the only thing I'm copying from Ben's code and it's only to have a neater data set now that I understand more of the data I'm looking at')
split cand_number, parse("-")
drop cand_number
rename cand_number1 schoolcode
rename cand_number2 cand_id

order schoolcode cand_id, first

*Then get rid of other variables I created so they don't show up in the big student-level data set, where they don't make sense
drop s subject student_n observation
