! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

 ; Test : 01
! (assertEqual (orCut ())
    ())

 ;  ; Test : 02
! (assertEqual (orCut (OR A))
    (A))

 ;  ; Test : 03
! (assertEqual (orCut (OR (A B C)))
    (A B C))

 ;  ; Test : 04
! (assertEqual (orCut (OR (AND A B (NOT A))))
    (A B (NOT A)))

 ;  ; Test : 05
! (assertEqual (orCut (OR (AND (NOT D) C)))
    ( (NOT D) C))

 ;  ; Test : 06
! (assertEqual (orCut (OR (AND (NOT A) B C D)))
    ( (NOT A) B C D))

 ;  ; Test : 07
! (assertEqual (orCut (OR (AND (NOT A) B C D (OR A B))))
    ( (NOT A) B C D (OR A B)))

 ;  ; Test : 08
! (assertEqual (orCut (OR (AND (NOT A) B C (AND B C) D (OR A B))))
    ( (NOT A) B C D (AND B C) (OR A B)))