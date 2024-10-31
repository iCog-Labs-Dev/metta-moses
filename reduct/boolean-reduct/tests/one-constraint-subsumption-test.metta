! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)

;; Test-01:applied on an empty set(not affected)
! (assertEqualToResult (oneConstraintSubsume () (A B C)) (()))

;; Test-02:applied on a literal(not affected)
! (assertEqualToResult (oneConstraintSubsume A (A B C)) (A))

;; Test-03:applied on an OR node(not affected)
! (assertEqualToResult (oneConstraintSubsume (OR A B (AND C D)) (A C D)) ((OR A B (AND C D))))

;;Test-04:applied on a NOT expression(not affected)
! (assertEqualToResult (oneConstraintSubsume (NOT A) (A B)) ((NOT A)))

;;Test-05:applied on an AND Node
;;;; Holamn Paper test case from page 44
! (assertEqualToResult (oneConstraintSubsume (AND E D) (C D)) (()))

;;;; empty $commandSet(the Root node or any AND node which is not commanded by any nodes)
! (assertEqualToResult (oneConstraintSubsume (AND A (OR (AND B (OR (AND E D) C)) D)) ()) ((AND A (OR (AND B (OR (AND E D) C)) D))))

;;;; an AND node whose constraint is already inside the $commandSet
! (assertEqualToResult (oneConstraintSubsume (AND A B C) (A D E F)) (()))

;;;; an AND node whose constraint isn't inside the $commandSet
! (assertEqualToResult (oneConstraintSubsume (AND A B C) (D E F)) ((AND A B C)))
