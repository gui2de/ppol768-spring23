*PPOL 768-01 
*May 1, 2023 Week 13 Assignment .do File
*Author: Peyton Weber

ssc install iefieldkit

global wd "/Users/peytonweber/Desktop/GitHub/ppol768-spring23/Individual Assignments/Weber Peyton/Week 13"

ietestform using "$wd/Peyton+Weber+Week+07+Survey+Form.xlsx" , reportsave("$wd/report.csv") replace 
