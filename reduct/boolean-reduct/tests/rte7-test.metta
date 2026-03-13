!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../n-ary-gather-junctors)
!(import! &self ../n-ary-propagate-not)
!(import! &self ../reduce-to-elegance)

;; Test 04: Test case from Mosh's paper. Page 37

;; (AND (OR G (AND A B (OR (NOT C) (NOT D) E) (OR C (AND C F))))) ==> (AND (OR G (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F))))) (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
;; (AND (OR G (AND A B C (OR (NOT D) E)))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
!(assertEqual (reduceToElegance (AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) () ()) ((AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) False))
!(assertEqual (reduceToElegance (OR (AND A) (AND B) (AND C D)) (AND C D) () ()) ((OR (AND A) (AND B) (AND C D)) (AND C D) False))

!(assertEqual (reduce-to (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))))) (AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))))
!(assertEqual (reduce-to (AND (OR A B) A)) (AND A))

!(assertEqual (reduce-to (AND (OR (AND (OR)) (AND (OR (AND (NOT X1))))))) (AND (NOT X1)))

;;TODO: Add the following test cases
;; 
;; Input: (AND (OR (AND (OR (AND (NOT X1) (NOT X2) (NOT X3) (OR (AND X2) (AND (NOT X3))) (OR (AND (NOT X1)) (AND (NOT X3))) (OR (AND X1) (AND (NOT X2))) (OR (AND X2) (AND X1) (AND X3) (AND X1 X2) (AND (NOT X2) X3) (AND X1 X3)) X3 (OR (AND (NOT X1)) (AND X2)) (OR (AND X2) (AND X3)) (OR (AND X1) (AND X2)) (OR (AND X1) (AND X2) (AND X3) (AND X2 X3) (AND (NOT X1) X3) (AND (NOT X1)) (AND (NOT X3)))) (AND (OR (AND (NOT X3))) (OR (AND X1) (AND X2) (AND)) (OR)) (AND)) (OR)) (AND)))
;; Output: (AND (NOT X3) (OR (AND X1) (AND X2)))
