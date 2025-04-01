!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:general-helpers)

;;Test case for lazy-random selector
! (assertEqual (length (lazyRandomSelector 0 5 3)) 3)
! (assertEqual (length (lazyRandomSelector 0 3 4)) 3)
! (assertEqual (length (lazyRandomSelector 0 5 5)) 5)
! (assertEqual (length (lazyRandomSelector 0 1 6)) 1)


