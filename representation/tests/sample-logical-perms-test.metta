
!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:representation:sample-logical-perms)
!(import! &self metta-moses:scoring:bscore)

;; Testcase for sample-logical-perms
!(assertEqual (length (sampleLogicalPerms AND 2 (A B))) 4)
!(assertEqual (length (sampleLogicalPerms OR 2 (A B))) 4)
