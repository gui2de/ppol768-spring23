*Set user path 

*Ali Hamza 1 (Windows)
*if c(username)=="kevin" { /// Serenity Fan 
*	global user "C:\Users\kevin\Box\Tz_reform_educ"
*}
*else if c(username)=="salonibhatia" { 
*	global user "C:\Users\salonibhatia\Box\Tz_reform_educ"
*} 
*else if c(username)=="ah1152" { 
*	global user ""
*}

***
*cd "$user"
clear
cd C:\Users\kevin\Box\Tz_reform_educ

*import excel "02_rawdata\Electoral\Raw Election Results\2000\2000_Ward_Results_Complete.xlsx", sheet("Sheet1") clear firstrow
import excel "02_rawdata\Electoral\Raw Election Results\2000\2000_Ward_Results_Complete.xlsx", sheet("Sheet1")

rename A s_no
rename B region   
rename C council 
rename D constituency 
rename E ward 
rename F candidate 
rename G male   
rename H female  
rename I political_party  
rename J candidate_vote
rename K percentage 
rename L elected_candidate 

drop in 1 

drop elected_candidate M N 
