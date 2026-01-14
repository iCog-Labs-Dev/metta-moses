!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)
!(import! &self ../n-ary-gather-junctors)
!(import! &self ../n-ary-propagate-not)

;; Test 04: Test case from Mosh's paper. Page 37

;; (AND (OR G (AND A B (OR (NOT C) (NOT D) E) (OR C (AND C F))))) ==> (AND (OR G (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F))))) (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))) () ()) ((AND (OR (AND G) (AND A B C))) (OR (AND G) (AND A B C)) False))
;; (AND (OR G (AND A B C (OR (NOT D) E)))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
!(assertEqual (reduceToElegance (AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) () ()) ((AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) False))
!(assertEqual (reduceToElegance (OR (AND A) (AND B) (AND C D)) (AND C D) () ()) ((OR (AND A) (AND B) (AND C D)) (AND C D) False))

!(assertEqual (reduce-to (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))))) (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))))) 
!(assertEqual (reduce-to (AND (OR A B) A)) (AND A))
