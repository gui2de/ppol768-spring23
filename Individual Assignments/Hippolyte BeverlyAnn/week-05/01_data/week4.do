split s , parse(">PS")

gen serial = _n

  drop s

reshape long s            /// I want to do something
  , i(serial) j(student)  /// unique id is arbitrary
    // more options here

split s , parse("<")


  keep s1 s6 s11 s16 s21
  drop in 1

  ren (s1 s6 s11 s16 s21) ///
      (cand prem sex name subjects)

      compress

  replace cand = "PS" + cand
  replace prem = subinstr(prem,`"P ALIGN="CENTER">"',"",.)
  replace sex  = subinstr(sex,`"P ALIGN="CENTER">"',"",.)
  replace name = subinstr(name,`"P>"',"",.)
  replace subjects  = subinstr(subjects,`"P ALIGN="LEFT">"',"",.)

  compress

  split subjects , parse(",")

  foreach var of varlist subjects* {
    replace `var' = substr(`var',-1,.)
  }
  
format %5s sex subjects* 
replace name = proper(name)
