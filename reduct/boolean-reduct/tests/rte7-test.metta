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


;; Test 04: Test case from Mosh's paper. Page 37

;; (AND (OR G (AND A B (OR (NOT C) (NOT D) E) (OR C (AND C F))))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F))))) (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
;; (AND (OR G (AND A B C (OR (NOT D) E)))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
!(assertEqual (reduceToElegance (AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) () ()) ((AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) False))
!(assertEqual (reduceToElegance (OR (AND A) (AND B) (AND C D)) (AND C D) () ()) ((OR (AND A) (AND B) (AND C D)) (AND C D) False))


