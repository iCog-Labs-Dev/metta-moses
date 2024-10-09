! (register-module! ../../../metta-moses-reduction) 
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:one-constraint-subsumption)

;Test-01:applied on an empty set(not affected)
 ! (assertEqualToResult (oneConstraintSubsume () () (A B C)) (()))
;Test-02:applied on a literal(not affected)
 ! (assertEqualToResult (oneConstraintSubsume A A (A B C)) (A))
;Test-03:applied on an OR node(not affected)
 ! (assertEqualToResult (oneConstraintSubsume (OR A B (AND C D)) (OR A B (AND C D)) (A C D)) ((OR A B (AND C D))))
;Test-04:applied on a NOT expression(not affected)
 ! (assertEqualToResult (oneConstraintSubsume (NOT A) (NOT A) (A B)) ((NOT A)))
;Test-05:applied on an AND Node
;;; the example given in the Holman paper(the POA)
 ! (assertEqualToResult (oneConstraintSubsume (AND E D) (AND E D) (D)) (()))
;;; empty $commandSet(the Root node or any AND node which is not commanded by any nodes)
 ! (assertEqualToResult (oneConstraintSubsume (AND A (OR (AND B (OR (AND E D) C)) D)) (AND A (OR (AND B (OR (AND E D) C)) D)) ()) ((AND A (OR (AND B (OR (AND E D) C)) D))))
;;; an AND node whose constraint is already inside the $commandSet
 ! (assertEqualToResult (oneConstraintSubsume (AND A B C) (AND A B C) (A D E F)) (()))
;;; an AND node whose constraint isn't inside the $commandSet 
 ! (assertEqualToResult (oneConstraintSubsume (AND A B C) (AND A B C) (D E F)) ((AND A B C)))