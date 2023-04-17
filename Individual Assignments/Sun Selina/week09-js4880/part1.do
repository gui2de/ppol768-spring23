cd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880/"

global wd "/Users/Selina/Desktop/ppol768-spring23/Individual Assignments/Sun Selina/week09-js4880/"

*program generate sample
capture program drop infinite
program define infinite, rclass 
*samplesize as syntax
syntax, samplesize(integer)
clear

*DGP
set seed 20230416
set obs `samplesize'
generate school = _n
generate u_i = rnormal(0,5)  // SCHOOL EFFECTS

generate stem = runiform()<0.6 //randomly assign stem/liberal school
expand 18 //create 18 department in each school
bysort school: generate department = _n //create classroom id
generate u_ij = rnormal(5,2) // Department EFFECTS

*generate confounder, effect outcomes and treatment
*millions of total fundings per year
bysort school: generate fund = 50+int((50-10+1)*runiform()) //create a variabel for years of teaching experience

expand 4+int((12-4+1)*runiform()) //generate major level dataset, each school-department will have 4-12 majors

bysort school department: generate major = _n //generate major ID
generate e_ijk = rnormal(2,1) //create student level effects 

*generate publication 
generate temprand = runiform()
egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes
label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
label values mother_educ mother_educ
tabulate mother_educ, generate(meduc)

*DGP
generate score = 70 ///
        + (-2)*urban ///
        + 1.5*teach_exp  ///
        + 0*meduc1 ///
        + 2*meduc2 ///
        + 5*meduc3 ///
        + u_i + u_ij + e_ijk
