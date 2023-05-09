
// PPOL 768 - Week 12
// Group 8
// Jasmine Adams, Chance Hope, J Lei

global repo "/Users/jasmineadams/Dropbox/R Stata/repositories/ppol768-spring23"
global wd 	"$repo/Group Projects/group-8/week-12"
global w12  "$wd/w12.dta"
   cd 		"$wd"

// Load repurposed dataset
	clear
	use "$w12"
	
// Create enumerator id	
	gen enumerator = school  
	egen eid = group(enum)
	egen tag = tag(enum)

// Repurpose variables of interest
	gen open = gradhs		// P(graduate high s.) -> P(open bank account)
	gen apply = attendc		// P(attend a college) -> P(apply for loan)
	gen receive = gradc		// P(graduate college) -> P(receive the loan)
	
	label define prob ///
	1 "Won't" 2 "Unlikely" 3 "Probably" 4 "Definitely", replace
	label values open prob
	label values apply prob
	label values receive prob

	label variable open "open account"
	label variable apply "apply for loan"
	label variable receive "receive loan"
	
// Review invalid responses 
	tab open apply
	tab open receive
	tab apply receive

// Flag invalid responses
	gen	invalid = (open == 1 | open == 2) & ///
			((apply == 3 | apply == 4) |   ///
			(receive == 3 | receive == 4)) 

	replace invalid = 1 if (apply == 1 | apply == 2) & ///
			(receive == 3 | receive == 4)

// Check invalid responses by enumertor 		
	bysort enum: egen einvalid = total(invalid)
	bysort enum: egen eduration = total(dur/_N)
	label  variable einvalid "# of Invalid Responses"

// Review and visualize data 
	list eid einvalid eduration ssize if tag==1 	

	graph hbox dur if dur < 60, over(eid) ///
	subtitle(,fcolor(none) lcolor(black)) ///
	ytitle("Time Spent Taking Survey")
	
	graph bar (sum) invalid, bar(1, color(navy%50)) ///
	over(eid, sort(invalid)) subtitle(, fcolor(none) ///
	lcolor(black)) ytitle("Sum of Invalid Responses")
