! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)

;; Test-01:applied on an empty set(not affected)
! (assertEqualToResult (oneConstraintSubsume (OR) () (A B C)) (((OR) () False)))

;; Test-02:applied on a literal(not affected)
! (assertEqualToResult (oneConstraintSubsume (OR A) A (A B C)) (((OR A) A False)))

;; Test-03:applied on an OR node(not affected)
! (assertEqualToResult (oneConstraintSubsume (AND (OR A B (AND C D))) (OR A B (AND C D)) (A C D)) (((AND (OR A B (AND C D))) (OR A B (AND C D)) False)))

;;Test-04:applied on a NOT expression(not affected)
! (assertEqualToResult (oneConstraintSubsume (AND (NOT A)) (NOT A) (A B)) (((AND (NOT A)) (NOT A) False)))

;;Test-05:applied on an AND Node
;;;; Holamn Paper test case from page 44
! (assertEqualToResult (oneConstraintSubsume (OR (AND E D) C) (AND E D) (C D)) (((OR C) () True)))

;;;; empty $commandSet(the Root node or any AND node which is not commanded by any nodes)
! (assertEqualToResult (oneConstraintSubsume (OR (AND A (OR (AND B (OR (AND E D) C)) D))) (AND A (OR (AND B (OR (AND E D) C)) D)) ()) (((OR (AND A (OR (AND B (OR (AND E D) C)) D))) (AND A (OR (AND B (OR (AND E D) C)) D)) False)))

;;;; an AND node whose constraint is already inside the $commandSet
! (assertEqualToResult (oneConstraintSubsume (OR (AND A B C)) (AND A B C) (A D E F)) (((OR) () True)))

;;;; an AND node whose constraint isn't inside the $commandSet
! (assertEqualToResult (oneConstraintSubsume (OR (AND A B C)) (AND A B C) (D E F)) (((OR (AND A B C)) (AND A B C) False)))
