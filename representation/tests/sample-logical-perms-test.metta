
!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:sample-logical-perms)

;; Testcase for sample-logical-perms
! (assertEqual (length (sampleLogicalPerms And 4)) 10 )
! (assertEqual (length (sampleLogicalPerms OR 3)) 9 )
