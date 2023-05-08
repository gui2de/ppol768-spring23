cd "/Users/al/ppol768-spring23/Class Materials/week-04/03_assignment/01_data"

global excel_t21 "/Users/al/ppol768-spring23/Class Materials/week-04/03_assignment/01_data/q2_Pakistan_district_table21.xlsx"
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

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' //adding the rows to the tempfile
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

*lines above are directly from the hint


global vars "B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC"
foreach v of varlist $vars{
	replace `v'="" if strmatch(`v', "*-")|strmatch(`v', "*.*")
}

*get rid of some invalid variables

gen new="1"
 foreach v of varlist $vars{

    replace new=  new+"+"+`v' if `v'!=""

     }
	 
split(new), parse("+") gen(pop)
*i tried to drop all missing, but didnot work, hence decide to combine all non minsing and then split them to get rid of missing
destring pop2-pop13, replace
forvalues i=2/13 {
	replace pop`i'=abs(pop`i')
}
*some varibales were given - due to some mistake when importing the excel, get rids of the "-" sign
drop B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC pop1

* drop varlists that we no longer needed. 
