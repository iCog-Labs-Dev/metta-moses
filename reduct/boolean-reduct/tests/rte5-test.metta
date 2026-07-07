!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; (AND (OR (AND A B) (AND A C (OR D E A)))) ==> (AND A (OR B C))
!(assertEqual (reduceToElegance (quote (AND (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E) (AND $A)))))) (quote (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E) (AND $A))))) () ())  (quote ((AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND $A))))) (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND $A)))) True)))
!(assertEqual (reduceToElegance (quote (AND (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND $A))))))) (quote (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND $A)))))) () ()) (quote ((AND (AND $A (OR (AND $B) (AND $C)))) (AND $A (OR (AND $B) (AND $C))) False)))
;; (AND (OR (AND A B) (AND A C (OR D E (NOT A))))) ==> (AND A (OR B (AND C (OR D E))))
!(assertEqual (reduceToElegance (quote (AND (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E) (AND (NOT $A))))))) (quote (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E) (AND (NOT $A)))))) () ()) (quote ((AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND (NOT $A)))))) (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND (NOT $A))))) True)))
!(assertEqual (reduceToElegance (quote (AND (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND (NOT $A)))))))) (quote (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E) (AND (NOT $A))))))) () ()) (quote ((AND (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E)))))) (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E))))) False)))

;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR (AND B) (AND C D)))
!(assertEqual (reduceToElegance (quote (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E (NOT $A))))))) (quote (AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E (NOT $A))))))) () ()) (quote ((AND $A (OR (AND $B) (AND $C $D))) (AND $A (OR (AND $B) (AND $C $D))) False)))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (quote (AND (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E (NOT $A))))))) (quote (OR (AND $A $B) (AND $A $C (OR (AND $D) (AND $E (NOT $A)))))) () ()) (quote ((AND $A (OR (AND $B) (AND $C (OR (AND $D) (AND $E (NOT $A)))))) (OR (AND $B) (AND $C (OR (AND $D) (AND $E (NOT $A))))) True)))   ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
