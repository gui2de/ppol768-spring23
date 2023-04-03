
*Example: How to simulate multi-level data


set seed 896124
clear
set obs 6 //number of schools 
generate school = _n
generate u_i = rnormal(0,2)  // SCHOOL EFFECTS
generate urban = runiform()<0.50 //randomly assign urban/rural status
expand 10 //create 10 classroom in each school
bysort school: generate classroom = _n //create classroom id
generate u_ij = rnormal(0,3) // CLASSROOM EFFECTS

bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) //create a variabel for years of teaching experience
expand 16+int((25-16+1)*runiform()) //generate student level dataset, each school-class will have 16-25 students
bysort school classroom: generate child = _n //generate student ID
generate e_ijk = rnormal(0,5) //create student level effects 
*generate mother education variable
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

		
reg score urban teach_exp meduc2 meduc3		
*check if betas are the same/similar to DGP		
		
		
		
*See this Stata blog for more details re: multi-level data simulation
* https://blog.stata.com/2014/07/18/how-to-simulate-multilevellongitudinal-data/		