********************************************************************************
* PPOL 768: Week 4
* Assignment for Week 4
* Michele Giunti
* Feb 9th, 2023
********************************************************************************

/*Note: I am copying and pasting the format because it is easier,
All this code is original
*/

/*******************************************************************************
1. Crop Insurance in Kenya
*******************************************************************************/

*Load Dataset
use "01_data/q1_village_pixel.dta"

*a) Create a dummy variable for consistency between pixel and payout
tab payout pixel
by pixel (payout), sort: gen pixel_consistent = (payout[1] != payout[_N])

*b) Create a dummy variable for consistency between pixel and village
by village (pixel), sort: gen pixel_village = (pixel[1] != pixel[_N])


*Other way to do it:
*a)
bysort pixel: egen pixel_min = min(payout)
bysort pixel: egen pixel_max = max(payout)
gen pixel_consistent_alt = 0
replace pixel_consistent_alt = 1 if pixel_min != pixel_max

bysort pixel: tab pixel_consistent pixel_consistent_alt

*b)
egen tag = tag(village pixel)
bysort village: gen pixel_village_alt = sum(tag)
bysort village: egen pix_vil_max = total(tag)
bysort village: replace pixel_village_alt = 0 if pix_vil_max == 1
bysort village: replace pixel_village_alt = 1 if pix_vil_max > 1

tab pixel_village_alt pixel_village

*c) Create a dummy for the experiment
gen pixel_exper = .
replace pixel_exper = 1 if pixel_village == 0
replace pixel_exper = 2 if pixel_village == 1 & pixel_consistent == 0
replace pixel_exper = 3 if pixel_village == 1 & pixel_consistent == 1
list hhid if pixel_exper == 2

/*******************************************************************************
2. National IDs in Pakistan
*******************************************************************************/
clear

*Creating Globals and Temps to reduce redundancy
global excel_t21 "01_data/q2_Pakistan_district_table21.xlsx"

clear
tempfile table21
save `table21', replace emptyok

local var B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC

*Extracting all columns through a loop and then selecting what specifically to keep
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

*Reordering Misaligned Columns
egen yes = concat(`var'), p(" ")
replace yes = subinstr(yes, ".", "", .)
split yes, destring 

drop `var' yes table21

*Cleaning Table with names and labels
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

/*******************************************************************************
3. Faculty Funding Proposals
*******************************************************************************/
clear
use "01_data/q3_grant_prop_review_2022.dta"
sort Rewiewer1 Reviewer2 Reviewer3

*Renaming mispelled variables
rename Rewiewer1 Reviewer1
rename Review1Score Review1
rename Reviewer2Score Review2
rename Reviewer3Score Review3

*Creating normalized scores with respect to each reviewer
reshape long Reviewer Review, i(proposal_id)

bysort Reviewer : sum Review
bysort Reviewer : gen stand_r = (Review - r(min)) / (r(max) - r(min))

*Recreating the previous table format
reshape wide Reviewer Review stand_r, i(proposal_id)

foreach v of varlist stand_r1 stand_r2 stand_r3{
	rename `v' `v'_score
}

*Create avereage score and rank
local standscore "stand_r1_score stand_r2_score stand_r3_score"
egen average_stand_score = rmean(`standscore')
egen rank = rank(-average_stand_score), unique

order proposal_id PIName Department Reviewer1 Reviewer2 Reviewer3 Review1 Review2 Review3 AverageScore StandardDeviation stand_r1_score stand_r2_score stand_r3_score average_stand_score rank

/*******************************************************************************
4. Faculty Funding Proposals
*******************************************************************************/

clear
use "01_data/q4_Tz_student_roster_html"

*Use only the table we are interested in
replace s = substr(s,strpos(s,"SUBJECT"),.)
split s, parse("</TD></TR>")
gen i = _n
drop s


reshape long s, i(i) j(j)

*Remove HTML and separate relevant information
replace s = ustrregexra(s,"<[^\>]*>"," ")
split s, parse(" ")

*Drop Missing
foreach var of varlist *{
    capture assert missing(`var')
    if !_rc {
        drop `var'
    }
}

drop if j == 1 | j == 18

*Clean Dataset
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