#Week 13 Assignment
----------------------------------------------------------------------
*link for surveyCTO: URL: https://gui2de.surveycto.com/collect/selina_sun?caseid=
*link for google sheet: https://docs.google.com/spreadsheets/d/123HTDuWZGXV97y3xuxJX7_ZoPrHbcTkgbE3qYfy4KPk/edit?usp=sharing

----------------------------------------------------------------------

This report was created by user Selina on 5May2023 using the Stata command ietestform

Use either of these links to read more about this command:
,https://github.com/worldbank/iefieldkit
,https://dimewiki.worldbank.org/wiki/Ietestform

,Form ID,selina_sun
,Form Title,Selina_Sun_week13
,Form Version,2305050303
,Form File,Selina_Sun_week13.xlsx

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: SPACES BEFORE OR AFTER STRING (choice sheet)
----------------------------------------------------------------------

"The string values in [label] column in the choice sheet are imported as strings and has leading or "
"trailing spaces in the Excel file in the following cases:"

,"row" ,"label" 
,"12","Associate degree "
,"13","Bachelors degree "
,"17","Never "
,"21","Never "


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Leading_and_Trailing_Spaces

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: NON NUMERIC NAME VALUES
----------------------------------------------------------------------

"There are non numeric values in the [value] column of the choice sheet"

,"row" ,"list_name" ,"value" ,"label" 
,"4","country","Country_Code","Country_Name"


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Value.2FName_Numeric

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: NO STATA LIST LABEL
----------------------------------------------------------------------

"There is no column in the choice sheet with the name [label:stata]. This is best practice as it "
"allows you to automatically import choice list labels optimized for Stata's value labels, making "
"the data set easier to read."


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Stata_Labels_Columns

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: END/BEGIN NAME MISMATCH
----------------------------------------------------------------------

"The name in the end group/repeat does not match the name in the most recent begin group/repeat. "
"This does not cause an error in ODK, but is recommended to solve programming errors with "
"missmatching group/repeats fields. These cases were found:"

"begin_group [Environment] on row 43 and end_group [main] on row 55"
"begin_group [Environment] on row 43 and end_group [consented] on row 59"


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Matching_begin_.2Fend

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: NO STATA FIELD LABEL
----------------------------------------------------------------------

"There is no column in the survey sheet with the name [label:stata]. This is best practice as this "
"allows you to automatically import variable labels optimized for Stata, making the data set easier "
"to read."


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Stata_Labels_Columns

----------------------------------------------------------------------
----------------------------------------------------------------------
TEST: NON-REQUIRED NON-NOTE TYPE FIELD
----------------------------------------------------------------------

"Fields of types other than note should all be required so that it cannot be skipped during the "
"interview. The following fields are not required and could therfore be skipped by the enumerator:"

,"row" ,"type" ,"name" 
,"22","select_one","qualification"
,"33","text","school_name"
,"56","text","feedback"


Read more about this test and why this is an error or does not follow the best practices we recommend here:
https://dimewiki.worldbank.org/wiki/Ietestform#Required_Column

----------------------------------------------------------------------
----------------------------------------------------------------------

This is the end of the report.
