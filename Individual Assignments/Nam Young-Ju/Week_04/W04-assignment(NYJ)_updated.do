cd "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\"

/* Q1 : Crop Insurance in Kenya */
/* a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel) */

use "q1_village_pixel.dta", clear

by pixel(payout), sort: gen pixel_consistent = payout[1] != payout[_N]
list pixel payout if pixel_consistent

/* b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level. */

by village(pixel), sort: gen pixel_village = pixel[1] != pixel[_N]
list village pixel if pixel_village

/* c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories. */

gen village_type = 0
replace village_type = 1 if pixel_village == 0 & pixel_consistent == 0
replace village_type = 2 if pixel_village == 1 & pixel_consistent == 0
replace village_type = 3 if pixel_village == 1 & pixel_consistent == 1
tab village_type

clear

/* Q2 : National IDs in Pakistan
We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly. */


global excel_t21 "C:\Genjuro\Georgetown_University\2_Spring_2023\Research_Design_and_Implementation\ppol768-spring23\Class Materials\week-04\03_assignment\01_data\q2_Pakistan_district_table21.xlsx"

clear

tempfile table21
save `table21', replace emptyok

forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring
	display as error `i' 
	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 
	keep in 1
	rename TABLE21PAKISTANICITIZEN1 table21

	foreach var of varlist * {
	  if missing(`var') {
	  	drop `var'
	  }
	}
	* This command helps to drop all variables, which only have missing values.
		
		
	local i = 1
	foreach var of varlist * {
		rename `var' colum_`i'
		local i = `i' +1
	}
	* This command helps to align observations by rearranging(renaming) colums start from 1.    (This command works given that order of dataset is not mixed up)		
	gen table=`i' 
	append using `table21' 
	save `table21', replace 
}

use `table21', clear

format %10s colum_*

rename colum_1 Age_Group
rename colum_2 Allsex_Total_Population
rename colum_3 Allsex_CNIcard_obtained
rename colum_4 Allsex_CNIcard_Not_obtained
rename colum_5 Male_Total_Population
rename colum_6 Male_CNIcard_obtained
rename colum_7 Male_CNIcard_Not_obtained
rename colum_8 Female_Total_Population
rename colum_9 Female_CNIcard_obtained
rename colum_10 Female_CNIcard_Not_obtained
rename colum_11 Transgender_Total_Population
rename colum_12 Transgender_CNIcard_obtained
rename colum_13 Transgender_CNIcard_Not_obtained
rename table Table_Number

order Table_Number, first
gen order = _n
gsort -order
replace Table_Number =_n
drop order

label define Distribution                                                                                           1 "Bannu" 2 "Lakki Marwat" 3 "Dera Ismail Khan" 4 "Tank" 5 "Abbottabad" 6 "Batagram" 7 "Haripur" 8 "Mansehra" 9 "Torghar" 10 "Kohistan" 11 "Hangu" 12 "Karak" 13 "Kohat" 14 "Mardan" 15 "Swabi" 16 "Charsadda" 17 "Nowshera" 18 "Peshawar" 19 "Buner" 20 "Chitral" 21 "Shangla" 22 "Swat" 23 "Lower Dir" 24 "Upper Dir" 25 "Malakand" 26 "Khyber" 27 "Kurram" 28 "Mohmand" 29 "North Waziristan" 30 "Orakzai" 31 "South Waziristan" 32 "Bajaur" 33 "FR Bannu" 34 "FR Dera Ismail Khan" 35 "FR Kohat" 36 "FR Lakki Marwat" 37 "FR Peshawar" 38 "FR Tank" 39 "Attock" 40 "Chakwal" 41 "Jhelum" 42 "Rawalpindi" 43 "Bhakkar" 44 "Khushab" 45 "Sargodha" 46 "Mianwali" 47 "Gujranwala" 48 "Gujrat" 49 "Hafizabad" 50 "Mandi Bahauddin" 51 "Marowal" 52 "Sialkot" 53 "Lahore" 54 "Kasur" 55 "Nankana Sahib" 56 "Sheikhupura" 57 "Faisalabad" 58 "Chiniot" 59 "Jhang" 60 "Toba Tek Singh"  61 "Sahiwal" 62 "Okara" 63 "Pakpattan" 64 "Bahawalnagar" 65 "Bahawalpur" 66 "Rahim Yar Khan" 67 "Dera Ghazi Khan" 68 "Rajanpur" 69 "Bababoyee" 70 "Muzaffargarh" 71 "Multan" 72 "Khanewal" 73 "Lodhran" 74 "Vehari" 75 "Jacobabad" 76 "Kashmore" 77 "Kambar Shahdad Kot" 78 "Larkana" 79 "Shikarpur" 80 "Ghotki" 81 "Khairpur" 82 "Sukkur" 83 "Badin" 84 "Dadu" 85 "Hyderabad" 86 "Jamshoro" 87 "Matiari" 88 "Sujawal" 89 "Tando Allahyar" 90 "Tando Muhammad Khan" 91 "Thatta" 92 "Karachi Central" 93 "Karachi East" 94 "Karachi South" 95 "Karachi West" 96 "Korangi" 97 "Malir" 98 "Mirpur Khas" 99 "Tharparkar" 100 "Umer Kot" 101 "Sanghar" 102 "Naushahro Feroze" 103 "Shaheed Benazirabad" 104 "Awaran" 105 "Kalat" 106 "Kharan" 107 "Khuzdar" 108 "Lasbela" 109 "Mastung"  110 "Washuk" 111 "Gwadar" 112 "Kech" 113 "Panjgur" 114 "Jaffarabad" 115 "Jhal Magsi" 116 "Kachhi" 117 "Nasirabad" 118 "Sohbatpur" 119 "Chagai" 120 "Killa Abdullah" 121 "Nushki" 122 "Pishin" 123 "Quetta" 124 "Dera Bugti" 125 "Harnai" 126 "Kohlu" 127 "Sibi" 128 "Ziarat" 129 "Barkhan" 130 "Killa Saifullah" 131 "Loralai" 132 "Musakhel" 133 "Sherani" 134 "Zhob" 135 "Islamabad"
 
label values Table_Number Distribution 
rename Table_Number Distribution 
replace Age_Group = subinstr("OVERALL18 AND ABOVE", "OVERALL18", "18", .)
* above commands are to cleaning dataset to easily figure out the table.

/* Q3 : Faculty Funding Proposals
Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128) */

use "q3_grant_prop_review_2022.dta", clear

egen stand_r1_score = std(Review1Score)
egen stand_r2_score = std(Reviewer2Score)
egen stand_r3_score = std(Reviewer3Score)
gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score)/3
 * when we generage average_stand_score, 'egen' command doesn't work. Thus, we neet to use 'gen'
gsort - average_stand_score
gen rank = _n

clear

/* Q4 : Student Data from Tanzania
Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average. */


use "q4_Tz_student_roster_html.dta", clear

display s[1] 
 * First, check how data in html looks like 
split s, parse(">PS")
 * And splitted the s variable with every staring ">PS" portion. When we see the table from website, all obseravations of CAND. NO starts from PS, and those observations are is the first row. That's why we splits cutting every ">PS". It will generate variables from s1 to s17
gen serial = 1234
 * This command is used to reshape later!!
drop s
 * We don't need s variable. 
reshape long s, i(serial) j(student)
 * reshape horizontal variables into vertical values!
split s, parse("<")
 * To seperate contents in s colum by meaningful variables, we have to find a point(in this case, "<") to cut them. 
keep s1 s6 s11 s16 s21
 * Those varialbes only contain meaningful observations
drop in 1
 * we don't need the first row anymore
ren (s1 s6 s11 s16 s21) (cand prem sex name subjects)

replace cand = "PS" + cand	
replace prem = subinstr(prem, `"P ALIGN="CENTER">"',"",.)
replace sex = subinstr(sex, `"P ALIGN="CENTER">"',"",.)
replace name = subinstr(name, `"P>"',"",.)
replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

compress
* clean dataset to make table look better
  split subjects, parse(",")
  * grades of subjects can be divided by variables. It is interesting that "," will be disappeared.
  drop subjects
  
  foreach var of varlist subjects* {
    replace `var' = substr(`var',-1,.)
  }
  * We only need finan grades (such as "A", "B")
format %5s sex subjects* 
 * compress command didn't work well, so I manually resize the table by %5s
rename subjects1 Kiswahili
rename subjects2 English
rename subjects3 Maarifa
rename subjects4 Hisabati
rename subjects5 Science
rename subjects6 Uraia
rename subjects7 Average_Grade