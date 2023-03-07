global excel_t21 "C:\Users\ecn20.la\Desktop\School\Research_Design_Implementation\ppol768-spring23\Individual Assignments\Nyhof Emma\week-04\q2_Pakistan_district_table21.xlsx"
*update the global

clear
*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 2-10 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regex(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
	foreach v of varlist _all {
	    if `v' == "" {
			drop `v'
		} 
	}
	
	local counter = 1
	foreach v of varlist _all {
			rename `v' column`counter'
			local counter = `counter' + 1
		}
	

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}

*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s column1 column2 column3 column4 column5 column6 column7 column8 column9 column10 column11 column12 column13 






