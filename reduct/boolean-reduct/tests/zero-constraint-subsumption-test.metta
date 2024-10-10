! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
 
;; Test 01
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (AND)) (OR (AND A B) (AND))) (()))

;; Test 02
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (OR)) (OR (AND A B) (OR))) (()))

;; Test 03
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (A)) (OR (AND A B) (A))) ((OR (AND A B) (A))))

;; Test 04
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) A) (OR (AND A B) A)) ((OR (AND A B) A)))

;; Test 05
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (OR A B (AND A B C)) (NOT A)) (OR (AND A B) (OR A B (AND A B C)) (NOT A))) ((OR (AND A B) (OR A B (AND A B C)) (NOT A))))

;; Test 06
! (assertEqualToResult (zeroConstraintSubsume (AND A B) (AND A B)) ((AND A B)))

;; Test 07
! (assertEqualToResult (zeroConstraintSubsume (NOT (AND A B)) (NOT (AND A B))) ((NOT (AND A B))))

;; Test 08
! (assertEqualToResult (zeroConstraintSubsume (OR (OR (AND) A) (AND)) (OR (OR (AND) A) (AND))) (()))

;; Test 09
! (assertEqualToResult (zeroConstraintSubsume (AND (OR) (OR (AND) B)) (AND (OR) (OR (AND) B))) ((AND (OR) (OR (AND) B))))
