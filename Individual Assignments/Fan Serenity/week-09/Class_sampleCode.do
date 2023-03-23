*Multi-level simulation (multivariable)

*i = school level 
*j = classroom level 
*k = student level 

*set seed 1 

clear 
set obs 6 //number of schools
generate school = _n 
generate u_i = rnormal(0,2) // school effects 

*School level effects (i)
generate urban = run iform()<0.50 //randomly assign urban/rural status

*Classroom level effects (j) 
expand 10 // Create 10 classrooms per school 
bysort school: generate classroom = _n // create classroom ID 
generate u_ij = rnormal(0,3) // classrooom effects 
bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) // create variable for years of teaching experience 

*Student-level effects (k)  
expand 16+int((25-16+1)*runiform()) // generate student level dataset, each school-class will have 16 students 
bysort school classroom: generate child = _n // generate student ID 
generate e_ijk = rnormal(0,5) // gen student-level effects 

	*Generate mother educ variable (student level)
	generate temprand = runiform() 
	egen mother_educ = cut(temprand), at (0,0.5, 0.9, 1) icodes 
	label define mother_educ 0 "HighSchool" 1 "College" 2 ">College" 
	label values mother_educ mother_educ 
	tabulate mother_educ, generate(meduc) 

	
*DGP 
generate score = 70 + (-2)*urban + 1.5*teach_exp + 0*meduc1 + 2*meduc2 + 5*meduc3 + u_i + u_ij + e_ijk