***Survey 

clear all

global wd "/Users/lidiaguzman/Desktop/RD_LAB/ppol768-spring23/Individual Assignments/Guzman Lidia/week-13"

clear all

ssc install iefieldkit

ietestform , surveyform("${wd}/lg94_W07_Form.xlsx") reportsave("${wd}/report.csv")
	 