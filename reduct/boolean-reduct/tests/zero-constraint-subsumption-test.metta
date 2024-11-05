! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
 
;; Test 01
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (AND))) ((() True)))

;; Test 02
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (OR))) ((() True)))

;; Test 03
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (A))) (((OR (AND A B) (A)) False)))

;; Test 04
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) A)) (((OR (AND A B) A) False)))

;; Test 05
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (((OR (AND A B) (OR A B (AND A B C)) (NOT A)) False)))

;; Test 06
! (assertEqualToResult (zeroConstraintSubsume (AND A B)) (((AND A B) False)))

;; Test 07
! (assertEqualToResult (zeroConstraintSubsume (NOT (AND A B))) (((NOT (AND A B)) False)))

;; Test 08
! (assertEqualToResult (zeroConstraintSubsume (OR (OR (AND) A) (AND))) ((() True)))

;; Test 09
! (assertEqualToResult (zeroConstraintSubsume (AND (OR) (OR (AND) B))) (((AND (OR) (OR (AND) B)) False)))

;; Test 10
! (assertEqualToResult (zeroConstraintSubsume (OR C (AND))) ((() True)))
