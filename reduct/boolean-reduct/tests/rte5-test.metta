!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)

;; (AND (OR (AND A B) (AND A C (OR D E A)))) ==> (AND A (OR B C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A)))) () ())  ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))) True))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) () ()) ((AND (AND A (OR (AND B) (AND C)))) (AND A (OR (AND B) (AND C))) False))
;; (AND (OR (AND A B) (AND A C (OR D E (NOT A))))) ==> (AND A (OR B (AND C (OR D E))))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))) True))  ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C)))) (AND A (OR (AND B) (AND C))) False)) ;; removes the entire OR node containing inconsistancy 
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C)))
!(assertEqual (reduceToElegance (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) () ()) ((AND A (OR (AND B) (AND C))) (AND A (OR (AND B) (AND C))) False))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))) True))   ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed


