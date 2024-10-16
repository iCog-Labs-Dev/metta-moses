! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)


;; Test 01
!(assertEqual
    (promoteCommonConstraints (OR A C (AND A B) (AND A C)))
    ((A) (OR C (AND B) (AND C)))
)

;; Test 02
!(assertEqual
    (promoteCommonConstraints (OR (AND (NOT A) B) (AND (NOT A) C)))
    (((NOT A)) (OR (AND B) (AND C)))
)

;; Test 03
!(assertEqual
    (promoteCommonConstraints (OR E F (AND F (NOT G)) (AND H I)))
    (() (OR E F (AND F (NOT G)) (AND H I)))
)

;; Test 04
!(assertEqual
    (promoteCommonConstraints (OR J (AND J K) (AND J L) (AND J M)))
    ((J) (OR (AND K) (AND L) (AND M)))
)

;; Test 05
!(assertEqual
    (promoteCommonConstraints (OR (NOT N) (AND N O) (AND N P) (AND M Q)))
    (() (OR (NOT N) (AND N O) (AND N P) (AND M Q)))
)

;;remove element Test
;; Test 01
!(assertEqualToResult 
  (removeElement (A B) (A C B H))
  ((C H))
 )

 ;; Test 02
 !(assertEqualToResult 
  (removeElement (A) (A C B H))
  ((C B H))
 )

 ;; Test 03
  !(assertEqualToResult 
  (removeElement () (A C B H))
  ((A C B H))
 )

 ;; Test 04
  !(assertEqualToResult 
  (removeElement (A B) (C  H))
  ((C H))
 )

;; Test 05
!(assertEqualToResult 
  (removeElement (A B) ())
  (())
 )
