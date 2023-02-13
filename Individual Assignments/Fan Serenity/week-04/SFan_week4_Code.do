*PPOL 768 - Week 4, STATA Assignment 
*Serenity Fan 

*______________________________
* ## Q1 : Crop Insurance in Kenya

*You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

*1a)	Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (`pixel_consistent`), this variable =1 if payout variable isn't consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)  

*Each HH: Village name, HH id, pixel, payout status 

*global excel_t21 "C:/Users/ah1152/Documents/PPOL_768/Week_4/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
*update the global

use q1_village_pixel, clear

*a) 
sort pixel
by pixel: egen pixel_min = min(payout)
by pixel: egen pixel_max = max(payout)

gen pixel_consistent = .
replace pixel_consistent = 0 if pixel_min == pixel_max

*LOGIC: Within each pixel / pixel ID, all HH's should have the same payout, either 0 or 1. This code calculates the min and max value of payout within each pixel. The min and max of payout within each pixel must be the same; if they are different, then we know that at least one of the HH's within a pixel has a different payout. 


*______________________________
*1b)	Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (`pixel_village`), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.  

sort village

*bysort village: list pixel
*replace pixel_village = 0 if pixel[_n] == pixel[_n+1]
*replace pixel_village = 0 if pixel[_n] == pixel[_n-1]

ssc install unique
unique pixel, by(village) gen(n_pixels)

by village: egen sum_n_pixels = sum(n_pixels)
gen pixel_village = 0
by village: replace pixel_village = 1 if sum_n_pixels>1

*LOGIC: We use the 'unique' user-created function in Stata to generate the categorical variable 'n_pixels', which tells us the number of unique strings (ie. 'pixels') in each village. Only those villages which are in multiple pixels (e.g. at a boundary between 2) will have a value for this of 2. Then, we use 'sum' to replicate this value for all HH's within such villages. All HH's in such villages will have a value of 1 for pixel_village. 


*______________________________
*1c)	For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:  
*I.	Villages that are entirely in a particular pixel. (==1)  
*II.	Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)  
*III.	Villages that are in different pixels AND have different payout status (==3)  
*These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.  

gen village_status = 0 

*Villages located entirely within precisely 1 pixel (1)  
replace village_status = 1 if pixel_village==0

*Villages spilling into multiple pixels with SAME (2) vs. DIFFERENT (3) payout status 
unique payout, by(village) gen(n_payouts)
by village: egen sum_n_payouts = sum(n_payouts)

replace village_status = 2 if pixel_village==1 & sum_n_payouts==1
replace village_status = 3 if pixel_village==1 & sum_n_payouts>1
order village_status, last

tab village_status
*Using tab here shows that our 3 categories are indeed mutually exclusive and exhaustive, i.e. every observation has a village_status number, and their count adds up to 958, which is the same number of total observations in the dataset 

list hhid if village_status==2
*This creates the list of villages (by hhid) that span multiple pixels but have the same payout status. We can see that 50 HH's fall under this classification.  


*______________________________
* ## Q2 : National ID's in Pakistan