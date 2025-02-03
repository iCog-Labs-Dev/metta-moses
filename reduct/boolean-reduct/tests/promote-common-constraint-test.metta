! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)


;; Test 01
!(assertEqual
    (promoteCommonConstraints (AND (OR A C (AND A B) (AND A C))) (OR A C (AND A B) (AND A C))) ((AND A (OR C (AND B) (AND C))) (OR C (AND B) (AND C)) True)
)

;; Test 02
!(assertEqual
    (promoteCommonConstraints (AND (OR (AND (NOT A) B) (AND (NOT A) C))) (OR (AND (NOT A) B) (AND (NOT A) C)))
    ((AND (NOT A) (OR (AND B) (AND C))) (OR (AND B) (AND C)) True)
)

;; Test 03
!(assertEqual
    (promoteCommonConstraints (AND (OR E F (AND F (NOT G)) (AND H I))) (OR E F (AND F (NOT G)) (AND H I)))
    ((AND (OR E F (AND F (NOT G)) (AND H I))) (OR E F (AND F (NOT G)) (AND H I)) False)
)

;; Test 04
!(assertEqual
    (promoteCommonConstraints (AND (OR J (AND J K) (AND J L) (AND J M))) (OR J (AND J K) (AND J L) (AND J M)))
    ((AND J (OR (AND K) (AND L) (AND M))) (OR (AND K) (AND L) (AND M)) True)
)

;; Test 05
!(assertEqual
    (promoteCommonConstraints (AND (OR (NOT N) (AND N O) (AND N P) (AND M Q))) (OR (NOT N) (AND N O) (AND N P) (AND M Q)))
    ((AND (OR (NOT N) (AND N O) (AND N P) (AND M Q))) (OR (NOT N) (AND N O) (AND N P) (AND M Q)) False)
)

;; Test 06
!(assertEqual
    (promoteCommonConstraints (AND (OR (NOT N) (AND (NOT N) O) (AND (NOT N) P) (AND (NOT N) Q))) (OR (NOT N) (AND (NOT N) O) (AND (NOT N) P) (AND (NOT N) Q)))
    ((AND (NOT N) (OR (AND O) (AND P) (AND Q))) (OR (AND O) (AND P) (AND Q)) True)
)

;; Test 07: Test case from Holman paper page #39
!(assertEqual
    (promoteCommonConstraints (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) (OR (AND (NOT B) C) (AND (NOT B))))
    ((AND A (NOT B) (OR (AND C) (AND)) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) (OR (AND C) (AND)) True)
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

;; test removeCommonLiterals
;; Test 01
!(assertEqualToResult
   (removeCommonLiterals (A B) ((A C B H) (A B D) (A C F B)))
   (((C H) (D) (C F)))
 )

;; Test 02
!(assertEqualToResult
  (removeCommonLiterals (A) ((A C B H) (A B D) (A C F B)))
  (((C B H) (B D) (C F B)))
)
;; Test 03
!(assertEqualToResult
   (removeCommonLiterals () ((A C B H) (A B D) (A C F B)))
   (((A C B H) (A B D) (A C F B)))
)
;; Test 04
!(assertEqualToResult
 (removeCommonLiterals (A B) ((C H) ( B D) (A C F B)))
 (((C H) (D) (C F )))
)
;; Test 05
!(assertEqualToResult
  (removeCommonLiterals (A B) ())
  (())
)

