!(import! &self ../../../utilities/general-helpers)

!(import! &self ../rte-helpers)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

!(car-atom A)
;; Test-01:applied on an empty set(not affected)
!(assertEqual (oneConstraintSubsume (quote (OR)) () ($A $B $C)) (quote ((OR) () False)))

;; Test-02:applied on a literal(not affected)
!(assertEqual (oneConstraintSubsume (quote (OR $A)) ($A) ($A $B $C)) (quote ((OR $A) ($A) False)))

;; Test-03:applied on an OR node(not affected)
!(assertEqual(oneConstraintSubsume (quote (AND (OR $A $B (AND $C $D)))) (quote (OR $A $B (AND $C $D))) ($A $C $D)) (quote ((AND (OR $A $B (AND $C $D))) (OR $A $B (AND $C $D)) False)))

;;Test-04:applied on a NOT expression(not affected)
!(assertEqual (oneConstraintSubsume (quote (AND (NOT $A))) (quote (NOT $A)) ($A $B)) (quote ((AND (NOT $A)) (NOT $A) False)))

;;Test-05:applied on an AND Node
;;;; Holamn Paper test case from page 44
!(assertEqual (oneConstraintSubsume (quote (OR (AND $E $D) $C)) (quote (AND $E $D)) ($C $D)) (quote ((OR $C) () True)))

;;;; empty $commandSet(the Root node or any AND node which is not commanded by any nodes)
!(assertEqual (oneConstraintSubsume (quote (OR (AND $A (OR (AND $B (OR (AND $E $D) $C)) $D)))) (quote (AND $A (OR (AND $B (OR (AND $E $D) $C)) $D))) ()) (quote ((OR (AND $A (OR (AND $B (OR (AND $E $D) $C)) $D))) (AND $A (OR (AND $B (OR (AND $E $D) $C)) $D)) False)))

;;;; an AND node whose constraint is already inside the $commandSet
!(assertEqual (oneConstraintSubsume (quote (OR (AND $A $B $C))) (quote (AND $A $B $C)) ($A $D $E $F)) (quote ((OR) () True)))

;;;; an AND node whose constraint isn't inside the $commandSet
!(assertEqual (oneConstraintSubsume (quote (OR (AND $A $B $C))) (quote (AND $A $B $C)) ($D $E $F)) (quote ((OR (AND $A $B $C)) (AND $A $B $C) False)))
