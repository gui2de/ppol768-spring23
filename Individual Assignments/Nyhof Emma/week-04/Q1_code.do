clear
cd "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-04\"

use "q1_village_pixel.dta"

* a) Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)
*bysort pixel: egen payout_avg = mean(payout)
*gen pixel_consistent = (payout_avg > 0 & payout_avg < 1)

sort pixel payout
by pixel (payout), sort: gen pixel_consistent = payout[1] != payout[_N]


* b) Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.

sort village pixel 
by village (pixel), sort: gen pixel_village = pixel[1] != pixel[_N]

* c) For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
sort village payout
by village (payout), sort: gen payout_village = payout[1] != payout[_N]

gen pixel_payout_status = .
* I. Villages that are entirely in a particular pixel. (==1)
replace pixel_payout_status = 1 if pixel_village == 0

* II. Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
replace pixel_payout_status = 2 if pixel_village == 1 & payout_village == 0

* III. Villages that are in different pixels AND have different payout status (==3)
replace pixel_payout_status = 3 if pixel_village == 1 & payout_village == 1

* These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.

