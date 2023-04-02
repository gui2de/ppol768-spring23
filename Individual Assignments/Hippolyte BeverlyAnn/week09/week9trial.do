/*

Data Generating Process 

Keep in mind that you're running a regression 

* Process for data x

x = r(normal)

* generate outcome Y 

		generate Y = id_village covar_1 covar_2

* generate treatment

	generate treatment = covar_1 covar_3

* Multi-armed treatment effect

		clear 
		set obs 20 // number of localities in Bogota 
		gen id_village = _n // Village effect 
		expand 100 
		gen 
		
* generate strata groups 

		* Within the city of Bogota there are twenty localities 
					** Obs set at 20 
		
		* Localitie effect - - - 
				
				- within each localitie there are 10 businesses
		
				- Treatment arm based on women's proximity to admin offices 
				- if your business is within the first 10 localities; -2 
				
				- if you if your business is within the second half; +2
				
		* Children effect --- Treatment arm based on the number of children a woman has ? 
		
*generate covariates 
	gen covar_1 = rnormal()
	gen covar_2 = rnormal ()
	gen covar_3 = rnormal()
	

* generate five regression models 

		reg y treatment 
		covar_1 covar_2 strata_1
		reg y covar_2 covar_3 strata_2
		reg y covar_3 covar_1 strata_3
		reg y covar_1 covar_2 strata_2
		reg y covar_2 covar_3 strata_3

Strata group creates variation 	


 

		*always start at the highest level when creating effects 
		
		
* So each strata group has a different effect that would be unique to the specific strata group. 

* Within the city of Bogota there are 10 villages, within each village there are 100 entrepreneurs.

* runiform - generates variables with a distribution between 0 and 1, and the probability between points are the 
same 




