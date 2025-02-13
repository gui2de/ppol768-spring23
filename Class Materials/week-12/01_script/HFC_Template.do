/*-----------------------------------------//

********************************************************************************/
set more off
clear
drop _all

********************************************************************************
*A. CHANGE DATE BELOW EVERYDAY
********************************************************************************
global date 20180316				

********************************************************************************
*B. INTEROPERABILITY
********************************************************************************
 

if c(username)=="ah1152" {
	global user "C:/Users/ah1152/Desktop/week_12"
	}

else if {
	display as error "Update the global according to your machine before running this do file"
	exit 
	}
	
cd "$user"


*******************************************************************************
*C. GLOBALS
*******************************************************************************

global midline_DG "$user/02_data/$date/Project_DiFi.dta"


********************************************************************************

*Graph

use "$midline_DG", clear
exit 


















exit 

	keep if surveystatus==1
	gen count=1
	keep count date

	bysort date: egen total = total(count)

	duplicates drop date, force
	*create dummy data so that line chart is not empty for the first day


	sort date
	line total date, ylabel(0(20)150, angle(horizontal)) xlabel(,angle(45)) yline(135)  xline(21245) ///
	 ytitle("# of Completed Suveys") xtitle("Date") title("Total Completed Surveys") ///
	 subtitle("  ")
	 
		
		gen count_comp = 1 if surveystatus==1
		gen count_incomp =  1 if surveystatus==2 | surveystatus==4 | surveystatus==5 | ///
								surveystatus==6 | surveystatus==9
		gen count_ref = 1 if surveystatus==3
		gen count_issues = 1 if surveystatus==8 | surveystatus==10 | surveystatus==11 
		gen count_other = 1 if surveystatus==13 | surveystatus==12 | surveystatus==7 
		
		
		egen status1 = total(count_comp)
		egen status2 = total(count_incomp)
		egen status3 = total(count_ref)
		egen status4 = total(count_issues)
		egen status5 = total(count_other)
		
		keep status*
		duplicates drop
		
		label variable status1 "Completed"
		label variable status2 "Incomplete"
		label variable status3 "Refusal"
		label variable status4 "hhid Issues"
		label variable status5 "Other"
		
		graph hbar (asis)  status*, bargap(30) blabel(bar) title("Survey Status: Overall") ///
		subtitle(" ")

exit 



preserve	
	keep if surveystatus==1
	keep if total_time<30
	keep enumerator hhid total_time village respname treatment date surveystatus 
	order enumerator hhid total_time village respname treatment date surveystatus
	export excel using "$HFC", sheet("Short Duration") firstrow(varlabels) replace
	
	keep if date==date("$date", "YMD")
	gen comments=""
	keep hhid total_time enumerator date comments
	putdocx table tbl2 = data("hhid total_time enumerator date comments"), varnames
	
restore




*	2) Table 2: Long duration incomplete surveys	

putdocx paragraph, style(Heading3)
putdocx text ("Table 2: Long duration incomplete surveys")

preserve
	keep if surveystatus!=1
	keep if total_time>=25
	keep enumerator hhid total_time village respname treatment date surveystatus
	order enumerator hhid total_time village respname treatment date surveystatus
	export excel using "$HFC", sheet("Long Duration") sheetmodify firstrow(varlabels)
	
	keep if date==date("$date", "YMD")
	gen comments=""
	keep hhid total_time enumerator date comments
	putdocx table tbl2 = data("hhid total_time enumerator date comments"), varnames
restore


	keep if date==date("$date", "YMD")
	keep if surveystatus!=.
	tostring starttime, generate(timestart) force format(%tchHMMSS)
	tostring endtime, generate(timeend) force format(%tchHMMSS)
	destring timestart, replace force 
	destring timeend, replace force

	tw (pcbarrow enumerator timestart enumerator timeend if surveystatus==1, lcolor (dkgreen) mlcolor(dkgreen )) ///
	(pcbarrow enumerator timestart enumerator timeend if surveystatus!=1, lcolor(red) lp(dash) mlcolor(red)), ///
	title("Enumerator Schedule: $date (ALL)") ytitle("Enumerator") xtitle("Survey Start and End Times") ///
	xlabel(90000 "09:00" 100000 "10:00" 110000 "11:00" 120000 "12:00" 130000 "13:00" 140000 "14:00" 150000 "15:00" 160000 "16:00" 170000 "17:00" 180000 "18:00") ///
	ylabel(    1   "Andrew Muiruri" ///
			   2   "Ann Wamboi" ///
			   3   "Beatrice Kagendo" ///
			   4   "Benjamin Thonge" ///
			   5   "Emmanuel Aswani" ///
			   6   "Eric Obose" ///
			   7   "Francesa Wangechi" ///
			   8   "Francis Nduhiu" ///
			   9   "Grace Watere" ///
			  10   "James Maina" ///
			  11   "James Njenga" ///
			  12   "Jane Wanja" ///
			  13   "John Muchiri" ///
			  14   "John Mutungi" ///
			  15   "Joseph Mackenzie" ///
			  16   "Joseph Mwangi" ///
			  17   "Killian Waruru" ///
			  18   "Lilian Murakaru" ///
			  19   "Margaret Kagai" ///
			  20   "Maureeen Waithera" ///
			  21   "Mecky Bwire" ///
			  22   "Naomi Wanjiru" ///
			  23   "Paul Gathirimu" ///
			  24   "Rachael Wanjiru" ///
			  25   "Samuel Wachanga" ///
			  26   "Samuel Wagura" ///
			  27   "Sarah Wanjiru" ///
			  28   "Stephen Kiiru" ///
			  29   "Titus Kyalo" ///
			  30   "Zipporah Ndiritu" ///
	, angle(0) ) ///
	scale(.8) legend(label(1 "Complete") label(2 "Incomplete")) 

	
*	3) Graph 3: Time taken to complete surveys (rcap plot) using all data
preserve
		keep if surveystatus==1
		qui tab enumerator 
		global M = `r(r)'
	
	
	//  Number listed individuals
		_pctile total_time,  percentile(5, 95) // percentiles(5 95)
		local lb `r(r1)'
		local ub `r(r2)'
		capture drop mean_total_time p25_total_time p75_total_time
		egen mean_total_time = mean(total_time), by(enumerator)
		egen p25_total_time = pctile(total_time), p(25) by(enumerator)
		egen p75_total_time = pctile(total_time), p(75) by(enumerator)
	 
		*lab define enumerator 1 "Grace Watere" 2 "Francis Nduhiu" 3 "James Maina" 4 "John Mutungi" 5 "Simon Muchiri" 6 "Mecky Bwire" 7 "Cyrus Wanjohi" 8 "Ann Wamboi" 9 "Beatrice Kagendo" 10 "Eric Obose" 11 "Naomi Wanjiru" 12 "Killian Waruru" 13 "Samuel Wagura" 14 "Erastus Gitahi" 15 "Gilbert Karuri" 16 "Dennis Kamande" 17 "Ernest Shivanda" 18 "Joseph Mwangi" 19 "Stephen Kiiru" 20 "Titus Kyalo" 21 "Zipporah Ndiritu" 22 "John Muchiri" 23 "Geoffrey Mworia", replace 
		
		gen x=100
		
		tw (scatter enumerator mean_total_time, msize(small) ) ///
			(rcap p25_total_time p75_total_time enumerator, horizontal lwidth(vthin) ) ///
			,ytitle("") ylabel(1(1)$M , valuelabel angle(horizontal) labsize(tiny)) ///
			xtitle("Average Survey Time") xlabel(0(10)90) ///
			ylabel(    1   "Andrew Muiruri" ///
			   2   "Ann Wamboi" ///
			   3   "Beatrice Kagendo" ///
			   4   "Benjamin Thonge" ///
			   5   "Emmanuel Aswani" ///
			   6   "Eric Obose" ///
			   7   "Francesa Wangechi" ///
			   8   "Francis Nduhiu" ///
			   9   "Grace Watere" ///
			  10   "James Maina" ///
			  11   "James Njenga" ///
			  12   "Jane Wanja" ///
			  13   "John Muchiri" ///
			  14   "John Mutungi" ///
			  15   "Joseph Mackenzie" ///
			  16   "Joseph Mwangi" ///
			  17   "Killian Waruru" ///
			  18   "Lilian Murakaru" ///
			  19   "Margaret Kagai" ///
			  20   "Maureeen Waithera" ///
			  21   "Mecky Bwire" ///
			  22   "Naomi Wanjiru" ///
			  23   "Paul Gathirimu" ///
			  24   "Rachael Wanjiru" ///
			  25   "Samuel Wachanga" ///
			  26   "Samuel Wagura" ///
			  27   "Sarah Wanjiru" ///
			  28   "Stephen Kiiru" ///
			  29   "Titus Kyalo" ///
			  30   "Zipporah Ndiritu" ///
	, angle(0) ) ///
			legend(order(1 "mean" 2 "inter-quartile range" )) ///
			note("Note: Respondent ID for outliers displayed.") ///
			name(total_time, replace)	