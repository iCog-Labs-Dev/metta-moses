! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:deme:deme-id-creation)

;; Test cases -- createDemeIds
! (assertEqual (createDemeIds 0 1) (Cons (mkDemeId "1") Nil))
! (assertEqual (createDemeIds 0 2) (Cons (mkDemeId "1.0") (Cons (mkDemeId "1.1") Nil)))
! (assertEqual (createDemeIds 0 3) (Cons (mkDemeId "1.0") (Cons (mkDemeId "1.1") (Cons (mkDemeId "1.2") Nil))))