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

;; (AND (OR (AND A B) (AND A C (OR D E A)))) ==> (AND A (OR B C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A)))) () ())  ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))) True))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) () ()) ((AND (AND A (OR (AND B) (AND C)))) (AND A (OR (AND B) (AND C))) False))
;; (AND (OR (AND A B) (AND A C (OR D E (NOT A))))) ==> (AND A (OR B (AND C (OR D E))))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))) True))  ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E))))) False))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C D)))) (AND A (OR (AND B) (AND C D))) False))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))) True))   ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C D)))) (AND A (OR (AND B) (AND C D))) False))


