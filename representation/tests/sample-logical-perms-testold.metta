
!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:sample-logical-perms)

;; Testcase for sample-logical-perms
! (assertEqual (length (sampleLogicalPerms And 2)) 4)
! (assertEqual (length (sampleLogicalPerms OR 2)) 4)