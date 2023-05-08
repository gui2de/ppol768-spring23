*Elena Spielmann
*PPOL 768
*STATA assignment 1
*13FEB2023

************************************************************

cd "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation\week-04-materials"

use "q1_village_pixel", clear

/*

Q1 : Crop Insurance in Kenya
You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)

*/

*To solve this, we can sort pixel by the minimum and maximum payout and then see if the minimum and maximum are the same within that pixel. If they are the same, then they are consistent. We can then count to see how many are and are not the same. There are 958 consistent pixels.

br

tab pixel

sort pixel

bysort pixel: egen pixel_min = min(payout)
bysort pixel: egen pixel_max = max(payout)

gen pixel_consistent = 0
replace pixel_consistent = 1 if pixel_min==pixel_max

bysort pixel: tab pixel_consistent

count if pixel_consistent == 1

br

*NOTE: this could also be done in a simliar way, but using the mean of payout instead of min and max of payout.

/*

b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.

*/
*To solve this, we first sort that data by village and pixel. We then create a serial (1, 2, 3, 4, 5, 6) and look at the household max. If they are the same, then households in within a village are in the same pixel. If not, then there are boudary cases. There are 472 households in the same pixel and 486 households that are not.

sort village pixel a serial

bysort village (pixel): gen serial = _n
bysort village (pixel): gen hh_max = _N

gen pixel_first = ""
replace pixel_first = pixel if serial == 1

gen pixel_last = ""
replace pixel_last = pixel if serial == hh_max

gen pixel_village = 0
replace pixel_village = 1 if pixel_first==pixel_last

bysort village: tab pixel_village

count if pixel_village == 1

count if pixel_village == 0

br

exit

/*

c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
I. Villages that are entirely in a particular pixel. (==1)
II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III. Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.

*/

*To solve this we will need to create a categorical variable for each village's respective status.

gen pixel_expt = 0
replace pixel_expt = 1 if pixel_village == 1
replace pixel_expt = 2 if pixel_village == 0 & pixel_consistent == 1
replace pixel_expt = 3 if pixel_village == 0 & pixel_consistent == 0

br

list hhid if pixel_expt == 3

/*
Q2 : National IDs in Pakistan
We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

*/

clear

*First, create globals and temps
global excel_t21 "C:\Users\easpi\OneDrive\Desktop\Georgetown MPP\MPP Spring 2023\Research Design and Implmentation\week-04-materials\q2_Pakistan_district_table21.xlsx"


tempfile table21
save `table21', replace emptyok

local var B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC

*Next, extract all columns through a loop and then select what to keep
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring
	display as error `i' 

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1
	keep in 1
	rename TABLE21PAKISTANICITIZEN1 table21

	gen table=`i'
	append using `table21'
	save `table21', replace
}

use `table21', clear

format %40s table21 `var'

*Reorder misaligned columns
egen yes = concat(`var'), p(" ")
replace yes = subinstr(yes, ".", "", .)
split yes, destring 

drop `var' yes table21

*Clean table with names and labels
rename yes1 all_totpop
rename yes2 all_CNI
rename yes3 all_noCNI

rename yes4 male_totpop
rename yes5 male_CNI
rename yes6 male_noCNI

rename yes7 female_totpop
rename yes8 female_CNI
rename yes9 female_noCNI

rename yes10 trans_totpop
rename yes11 trans_CNI
rename yes12 trans_noCNI

save `table21', replace

rename table district

label define DIST 135 "Islamabad" 134 "Zhob" 133 "Sherani" 132 "Musakhel" 131 "Loralai" 130 "Killa Saifullah" 129 "Barkhan" 128 "Ziarat" 127 "Sibi" 126 "Kohlu" 125 "Harnai" 124 "Dera Bugti" 123 "Quetta" 122 "Pishin" 121 "Nushki" 120 "Killa Abdullah" 119 "Chagai" 118 "Sohbatpur" 117 "Nasirabad" 116 "Kachhi" 115 "Jhal Magsi" 114 "Jaffarabad" 113 "Panjgur" 112 "Kech" 111 "Gwadar" 110 "Washuk" 109 "Mastung" 108 "Lasbela" 107 "Khuzdar" 106 "Kharan" 105 "Kalat" 104 "Awaran" 103 "Shaheed Benazirabad" 102 "Naushahro Feroze" 101 "Sanghar" 100 "Umer Kot" 99 "Tharparkar" 98 "Mirpur Khas" 97 "Malir" 96 "Korangi" 95 "Karachi West" 94 "Karachi South" 93 "Karachi East" 92 "Karachi Central" 91 "Thatta" 90 "Tando Muhammad Khan" 89 "Tando Allahyar" 88 "Sujawal" 87 "Matiari" 86 "Jamshoro" 85 "Hyderabad" 84 "Dadu" 83 "Badin" 82 "Sukkur" 81 "Khairpur" 80 "Ghotki" 79 "Shikarpur" 78 "Larkana" 77 "Kambar Shahdad Kot" 76 "Kashmore" 75 "Jacobabad" 74 "Vehari" 73 "Lodhran" 72 "Khanewal" 71 "Multan" 70 "Muzaffargarh" 69 "Bababoyee" 68 "Rajanpur" 67 "Dera Ghazi Khan" 66 "Rahim Yar Khan" 65 "Bahawalpur" 64 "Bahawalnagar" 63 "Pakpattan" 62 "Okara" 61 "Sahiwal" 60 "Toba Tek Singh" 59 "Jhang" 58 "Chiniot" 57 "Faisalabad" 56 "Sheikhupura" 55 "Nankana Sahib" 54 "Kasur" 53 "Lahore" 52 "Sialkot" 51 "Marowal" 50 "Mandi Bahauddin" 49 "Hafizabad" 48 "Gujrat" 47 "Gujranwala" 46 "Mianwali" 45 "Sargodha" 44 "Khushab" 43 "Bhakkar" 42 "Rawalpindi" 41 "Jhelum" 40 "Chakwal" 39 "Attock" 38 "FR Tank" 37 "FR Peshawar" 36 "FR Lakki Marwat" 35 "FR Kohat" 34 "FR Dera Ismail Khan" 33 "FR Bannu" 32 "Bajaur" 31 "South Waziristan" 30 "Orakzai" 29 "North Waziristan" 28 "Mohmand" 27 "Kurram" 26 "Khyber" 25 "Malakand" 24 "Upper Dir" 23 "Lower Dir" 22 "Swat" 21 "Shangla" 20 "Chitral" 19 "Buner" 18 "Peshawar" 17 "Nowshera" 16 "Charsadda" 15 "Swabi" 14 "Mardan" 13 "Kohat" 12 "Karak" 11 "Hangu" 10 "Kohistan" 9 "Torghar" 8 "Mansehra" 7 "Haripur" 6 "Batagram" 5 "Abbottabad" 4 "Tank" 3 "Dera Ismail Khan" 2 "Lakki Marwat" 1 "Bannu"
label values district DIST

save `table21'

/*

Q3 : Faculty Funding Proposals
Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)

*/

*To solve this, we will need to normalize the data (use a z-score more or less), convert the data from wide to long (adjust the data based on normalization), and back to wide again (merging back to the orginal data set).
*NORMALIZE: Use Z score


use "q3_grant_prop_review_2022", clear

sort Rewiewer1 Reviewer2 Reviewer3

br

*After sorting and browsing, we noted that there were misspelled variables that needed to be re-named. 

rename Rewiewer1 Reviewer1
rename Review1Score Review1
rename Reviewer2Score Review2
rename Reviewer3Score Review3

br

*Next we ned to create normalized scores with respect to each reviewer (like a z-score)

reshape long Reviewer Review, i(proposal_id)

bysort Reviewer : sum Review
bysort Reviewer : gen stand_r = (Review - r(min)) / (r(max) - r(min))

br

*We need to re-shape the current table to the previous table format
reshape wide Reviewer Review stand_r, i(proposal_id)

foreach v of varlist stand_r1 stand_r2 stand_r3{
	rename `v' `v'_score
}

*We need an average score and rank
local standscore "stand_r1_score stand_r2_score stand_r3_score"
egen average_stand_score = rmean(`standscore')
egen rank = rank(-average_stand_score), unique

*Order table in logical sequence for review
order proposal_id PIName Department Reviewer1 Reviewer2 Reviewer3 Review1 Review2 Review3 AverageScore StandardDeviation stand_r1_score stand_r2_score stand_r3_score average_stand_score rank

br
/*
Q4 : Student Data from Tanzania
Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from Tanzania's government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.

*/

clear
use "q4_Tz_student_roster_html"

*We only want to use the tables we are interested in
replace s = substr(s,strpos(s,"SUBJECT"),.)
split s, parse("</TD></TR>")
gen i = _n
drop s

reshape long s, i(i) j(j)

*We must remove HTML and separate the relevant information
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")

*We must drop missing observations
foreach var of varlist *{
    capture assert missing(`var')
    if !_rc {
        drop `var'
    }
}

drop if j == 1 | j == 18

*Finally we finish cleaning our dataset.
drop i j s s1 s3 s7 s8 s12 s13 s17 s19 s25 s26 s29 s32 s35 s38 s41 s44 s48 s28 s31 s34 s37 s40 s43 s46 s47

rename s5 cand_id
rename s10 prem_number
rename s15 gender
rename s30 kiswahili
rename s33 english
rename s36 maarifa
rename s39 hisabati
rename s42 science
rename s45 uraia
rename s49 average
egen name = concat(s21 s22 s23), punct(" ")

drop s2 s21 s22 s23

foreach var of varlist *{
	replace `var' = subinstr(`var', ",","",.)
}

split cand_id, parse("-")
drop cand_id
rename cand_id1 schoolcode
rename cand_id2 cand_id

order schoolcode cand_id
order gender, after(cand_id)
order name, after(prem_number)