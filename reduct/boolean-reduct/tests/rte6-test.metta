! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct:boolean-reduct:reduce-to-elegance)


;; (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) ==> (AND (OR (NOT A) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (AND (NOT A)) (AND A B C) (AND B C (NOT B)))) (OR (AND (NOT A)) (AND A B C) (AND B C (NOT B))) () ()) ((AND (OR (AND (NOT A)) (AND A B C))) (OR (AND (NOT A)) (AND A B C)) False))
;; (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) ==> (AND (OR (NOT A) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) (OR (NOT A) (AND A B C) (AND B C (NOT B))) () ()) ((AND B C (OR (NOT A) (AND A) (AND (NOT B)))) (OR (NOT A) (AND A) (AND (NOT B))) True))
;; (AND (OR (NOT A) (AND A B C) (AND C B (NOT B)))) ==> (AND (OR (NOT A ) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (AND A B C) (AND C B (NOT B)))) (OR (NOT A) (AND A B C) (AND C B (NOT B))) () ()) ((AND B C (OR (NOT A) (AND A) (AND (NOT B)))) (OR (NOT A) (AND A) (AND (NOT B))) True))
;; (AND (OR (AND C A D) (AND C A) (AND C A E))) ==> (AND C A)
!(assertEqual (reduceToElegance (AND (OR (AND C A D) (AND C A) (AND C A E))) (OR (AND C A D) (AND C A) (AND C A E)) () ()) ((AND C A) () True))
;; (AND (OR (AND A B) (AND A C D) (AND A C E) (AND C A))) ==> (AND A (OR B (AND C D) (AND C E) C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C D) (AND A C E) (AND C A))) (OR (AND A B) (AND A C D) (AND A C E) (AND C A)) () ()) ((AND A (OR (AND B) (AND C D) (AND C E) (AND C))) (OR (AND B) (AND C D) (AND C E) (AND C)) True))


